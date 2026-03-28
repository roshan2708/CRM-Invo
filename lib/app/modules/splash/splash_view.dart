import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../routes/app_routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      Get.offNamed(AppRoutes.onboarding);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppColors.primaryBackground),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: size.width * 0.22,
                      height: size.width * 0.22,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(size.width * 0.06),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.people_alt_rounded,
                        size: size.width * 0.12,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: size.width * 0.06),
                  Text(
                    'CRM Pro',
                    style: TextStyle(
                      fontSize: size.width * 0.1,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  SizedBox(height: size.width * 0.02),
                  Text(
                    'Manage your leads, close more deals',
                    style: TextStyle(
                      fontSize: size.width * 0.038,
                      color: AppColors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: size.height * 0.1),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
