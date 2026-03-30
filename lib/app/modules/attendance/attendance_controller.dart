import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/attendance_model.dart';
import '../../services/background_tracking_service.dart';
import '../auth/auth_controller.dart';

class AttendanceController extends GetxController {
  final Rx<AttendanceModel?> currentRecord = Rx<AttendanceModel?>(null);
  final RxBool isLoading = false.obs;

  bool get isPunchedIn =>
      currentRecord.value != null && !currentRecord.value!.isPunchedOut;
  bool get isOnBreak => currentRecord.value?.isOnBreak ?? false;

  @override
  void onInit() {
    super.onInit();
    _initBackgroundServiceListeners();
  }

  void _initBackgroundServiceListeners() {
    final service = FlutterBackgroundService();
    // Listen to background isolate events while app is foregrounded
    service.on('onAutoBreak').listen((event) {
      if (currentRecord.value != null && !isOnBreak) {
        currentRecord.value = currentRecord.value!.copyWith(isOnBreak: true);
        Get.snackbar(
          'Geofence Alert',
          'You left the office radius for >2 mins. Switched to Break Mode.',
          snackPosition: SnackPosition.TOP,
        );
      }
    });

    service.on('onAutoLogout').listen((event) {
      Get.snackbar(
        'Auto Logout',
        'Break exceeded 10 mins outside office. Logging out automatically.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
      final auth = Get.find<AuthController>();
      punchOut().then((_) => auth.logout());
    });
  }

  // ─── Private Logic ────────────────────────────────────────────────────────

  Future<String?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Location Disabled', 'Please enable location services.');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Permission Denied', 'Location permission is required to punch in.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Permission Denied', 'Location permissions are permanently denied. Please enable them in app settings.');
      return null;
    }

    // When we reach here, permissions are granted
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      // Reverse geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        // e.g. "123 Main St, New York"
        return '${p.street}, ${p.locality}';
      } else {
        return '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      }
    } catch (e) {
      return 'Unknown Location';
    }
  }

  // ─── Public Actions ───────────────────────────────────────────────────────

  Future<void> punchIn() async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn.value) return;

    isLoading.value = true;
    final locationName = await _getCurrentLocation();
    
    if (locationName != null) {
      // 1. Strict Geofencing Validation
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.bestForNavigation),
      );
      final double distance = Geolocator.distanceBetween(
        officeLat,
        officeLng,
        position.latitude,
        position.longitude,
      );

      if (distance > maxRadius) {
        Get.snackbar(
          'Out of Range',
          'You are ${distance.toStringAsFixed(1)}m from the office. You must be within 15m to punch in!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        isLoading.value = false;
        return;
      }

      // 2. Punch in if in range
      currentRecord.value = AttendanceModel(
        id: 'att_${DateTime.now().millisecondsSinceEpoch}',
        userId: auth.currentUser.value.id,
        punchInTime: DateTime.now(),
        punchInLocation: locationName,
      );
      Get.snackbar('Punched In', 'Successfully punched in at $locationName');

      // 3. Start background monitoring
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPunchedIn', true);
      await prefs.setBool('isBreakActive', false);
      FlutterBackgroundService().startService();
    }
    
    isLoading.value = false;
  }

  Future<void> punchOut() async {
    if (!isPunchedIn) return;

    isLoading.value = true;
    final locationName = await _getCurrentLocation();

    if (locationName != null) {
      currentRecord.value = currentRecord.value!.copyWith(
        punchOutTime: DateTime.now(),
        punchOutLocation: locationName,
        isOnBreak: false,
      );
      Get.snackbar('Punched Out', 'Successfully punched out at $locationName');

      // 4. Terminate background service
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPunchedIn', false);
      FlutterBackgroundService().invoke('stopService');
    }

    isLoading.value = false;
  }
}
