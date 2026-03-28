import 'package:get/get.dart';
import '../modules/activity/activity_controller.dart';
import '../modules/auth/auth_controller.dart';
import '../modules/auth/login_view.dart';
import '../modules/auth/signup_view.dart';
import '../modules/dashboard/dashboard_view.dart';
import '../modules/leads/lead_controller.dart';
import '../modules/leads/leads_list_view.dart';
import '../modules/leads/lead_detail_view.dart';
import '../modules/leads/add_lead_view.dart';
import '../modules/activity/activity_view.dart';
import '../modules/onboarding/onboarding_view.dart';
import '../modules/profile/profile_view.dart';
import '../modules/settings/settings_view.dart';
import '../modules/splash/splash_view.dart';
import '../modules/theme_controller.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController(), fenix: true);
        Get.lazyPut(() => ThemeController(), fenix: true);
      }),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => SignupView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => LeadController(), fenix: true);
        Get.lazyPut(() => ActivityController(), fenix: true);
      }),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.leads,
      page: () => const LeadsListView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.leadDetail,
      page: () => const LeadDetailView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.addLead,
      page: () => const AddLeadView(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.activity,
      page: () => const ActivityView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
