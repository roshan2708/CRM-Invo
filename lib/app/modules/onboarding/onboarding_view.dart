import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';

class _OnboardingPage {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _OnboardingPage({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.track_changes_rounded,
      color: Color(0xFF4F46E5),
      title: 'Track Every Lead',
      subtitle:
          'Keep all your contacts and leads in one place. Never miss a follow-up again.',
    ),
    _OnboardingPage(
      icon: Icons.bar_chart_rounded,
      color: Color(0xFF06B6D4),
      title: 'Insights at a Glance',
      subtitle:
          'View conversion rates, pipeline health, and activity summaries on a beautiful dashboard.',
    ),
    _OnboardingPage(
      icon: Icons.rocket_launch_rounded,
      color: Color(0xFF10B981),
      title: 'Close Deals Faster',
      subtitle:
          'Schedule follow-ups, log activities, and move deals to closure with ease.',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Get.offNamed(AppRoutes.login),
                child: Text(
                  'Skip',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _OnboardingPageWidget(page: page, size: size);
                },
              ),
            ),
            // Dots + button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: size.height * 0.03,
              ),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? theme.colorScheme.primary
                              : theme.dividerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),
                  CustomButton(
                    label: isLast ? 'Get Started' : 'Next',
                    onPressed: _next,
                    icon: isLast ? null : Icons.arrow_forward_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageWidget extends StatelessWidget {
  final _OnboardingPage page;
  final Size size;

  const _OnboardingPageWidget({required this.page, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: size.width * 0.45,
            height: size.width * 0.45,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(size.width * 0.125),
              border: Border.all(
                color: page.color.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Icon(page.icon, size: size.width * 0.22, color: page.color),
          ),
          SizedBox(height: size.height * 0.06),
          Text(
            page.title,
            style: theme.textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            page.subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodySmall?.color,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
