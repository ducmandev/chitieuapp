import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../widgets/neo_button.dart';
import '../providers/app_provider.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      icon: Icons.account_balance_wallet,
      title: 'Track Your Spending',
      description: 'Keep tabs on where your money goes with Neo.Cash',
      color: NeoColors.primary,
    ),
    OnboardingPage(
      icon: Icons.pie_chart,
      title: 'Set Budgets',
      description: 'Create budgets for each category to stay on track',
      color: NeoColors.secondary,
    ),
    OnboardingPage(
      icon: Icons.flag,
      title: 'Reach Your Goals',
      description: 'Set savings goals and watch your progress grow',
      color: NeoColors.success,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: neo.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        loc.skip.toUpperCase(),
                        style: NeoTypography.mono.copyWith(
                          fontWeight: FontWeight.bold,
                          color: neo.textSub,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(context, _pages[index], neo);
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? NeoColors.primary
                          : neo.ink.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: NeoButton(
                        backgroundColor: neo.surface,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        onPressed: _previousPage,
                        child: Text(
                          loc.previous.toUpperCase(),
                          style: NeoTypography.mono.copyWith(
                            fontWeight: FontWeight.bold,
                            color: neo.textMain,
                          ),
                        ),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: _currentPage > 0 ? 1 : 2,
                    child: NeoButton(
                      backgroundColor: NeoColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? loc.getStarted.toUpperCase()
                            : loc.next.toUpperCase(),
                        style: NeoTypography.mono.copyWith(
                          fontWeight: FontWeight.bold,
                          color: NeoColors.ink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, OnboardingPage page, NeoThemeData neo) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with rotation
          Transform.rotate(
            angle: -0.1,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: page.color,
                border: Border.all(color: neo.ink, width: 4),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: neo.ink,
                    offset: const Offset(8, 8),
                  ),
                ],
              ),
              child: Icon(
                page.icon,
                size: 80,
                color: NeoColors.ink,
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Transform.rotate(
            angle: 0.05,
            child: Text(
              page.title,
              style: NeoTypography.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: neo.textMain,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),

          // Description
          Text(
            page.description,
            style: NeoTypography.textTheme.titleLarge?.copyWith(
              color: neo.textSub,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    // Mark onboarding as complete
    context.read<AppProvider>().setOnboardingComplete();

    // Navigate to dashboard
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
