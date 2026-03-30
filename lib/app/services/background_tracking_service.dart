import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Hardcoded dummy office location for testing.
// In a real app, this would be fetched from the backend.
const double officeLat = 28.0;
const double officeLng = 77.0;
const double maxRadius = 15.0; // 15 meters boundary

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'attendance_channel_id',
    'Attendance Tracking',
    description: 'Background service for enforcing geofence attendance',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false, // We only start on punch-in
      isForegroundMode: true,
      notificationChannelId: 'attendance_channel_id',
      initialNotificationTitle: 'Attendance Tracking Active',
      initialNotificationContent: 'Monitoring geofence boundary...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  int secondsOutOfOffice = 0;
  bool isBreakTriggered = false;

  // Poll GPS every 30 seconds
  Timer.periodic(const Duration(seconds: 30), (timer) async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.bestForNavigation),
      );

      double distance = Geolocator.distanceBetween(
        officeLat,
        officeLng,
        position.latitude,
        position.longitude,
      );

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Attendance Geofence Active",
          content: "Dist: ${distance.toStringAsFixed(1)}m | Out: ${secondsOutOfOffice}s",
        );
      }

      if (distance > maxRadius) {
        secondsOutOfOffice += 30; // Add the interval
      } else {
        if (!isBreakTriggered) {
          secondsOutOfOffice = 0; // Return to safe zone resets timer (if not already broken)
        }
      }

      // 120 Seconds (2 Mins) -> Auto Break
      if (secondsOutOfOffice >= 120 && !isBreakTriggered) {
        isBreakTriggered = true;
        prefs.setBool('isBreakActive', true);
        service.invoke('onAutoBreak'); // Ping foreground isolate
      }

      // 600 Seconds (10 Mins on break) + 120s buffer = 720s -> Auto Logout
      if (secondsOutOfOffice >= 720) {
        prefs.setBool('forceLogout', true);
        service.invoke('onAutoLogout'); // Ping foreground isolate
        timer.cancel();
        service.stopSelf();
      }

    } catch (e) {
      // Silent catch to prevent background crashes
    }
  });
}
