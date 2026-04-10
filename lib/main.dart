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

import 'app/data/providers/auth_provider.dart';
import 'app/data/providers/lead_provider.dart';
import 'app/data/providers/attendance_provider.dart';
import 'app/data/providers/admin_provider.dart';
import 'app/data/providers/manager_provider.dart';
import 'app/data/providers/tl_provider.dart';
import 'app/data/providers/associate_provider.dart';
import 'app/data/providers/payment_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeBackgroundService();
  
  // Register Providers first
  Get.put(AuthProvider(), permanent: true);
  Get.put(LeadProvider(), permanent: true);
  Get.put(AttendanceProvider(), permanent: true);
  Get.put(AdminProvider(), permanent: true);
  Get.put(ManagerProvider(), permanent: true);
  Get.put(TlProvider(), permanent: true);
  Get.put(AssociateProvider(), permanent: true);
  Get.put(PaymentProvider(), permanent: true);

  // Register permanent controllers
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
