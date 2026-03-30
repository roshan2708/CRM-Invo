import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'app/modules/theme_controller.dart';
import 'app/modules/auth/auth_controller.dart';
import 'app/modules/leads/lead_controller.dart';
import 'app/modules/activity/activity_controller.dart';
import 'app/modules/calls/call_controller.dart';
import 'app/modules/attendance/attendance_controller.dart';
import 'app/services/background_tracking_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeBackgroundService();
  // Register permanent controllers BEFORE runApp  avoids repeated
  // registration on hot-reload that causes GetX ownership warnings.
  Get.put(ThemeController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(LeadController(), permanent: true);
  Get.put(ActivityController(), permanent: true);
  Get.put(CallController(), permanent: true);
  Get.put(AttendanceController(), permanent: true);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(const CRMApp()));
}

class CRMApp extends StatelessWidget {
  const CRMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<ThemeController>(
      // GetX (not GetBuilder) reacts to .obs values automatically
      builder: (themeCtrl) => GetMaterialApp(
        title: 'CRM Pro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeCtrl.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        initialRoute: AppRoutes.splash,
        getPages: AppPages.routes,
        defaultTransition: Transition.rightToLeft,
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
