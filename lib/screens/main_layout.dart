import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../widgets/neo_bottom_nav.dart';
import '../widgets/neo_side_nav.dart';
import '../widgets/neo_button.dart';
import 'dashboard_screen.dart';
import 'transactions_screen.dart';
import 'breakdown_screen.dart';
import 'settings_screen.dart';
import 'wallets_screen.dart';
import 'budgets_screen.dart';
import 'goals_screen.dart';
import 'statistics_screen.dart';
import 'quick_add_screen.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // Desktop: 8 screens with full navigation
  List<Widget> _desktopScreens() {
    return [
      const DashboardScreen(),
      const TransactionsScreen(),
      const BreakdownScreen(),
      const WalletsScreen(),
      const BudgetsScreen(),
      const GoalsScreen(),
      const StatisticsScreen(),
      const SettingsScreen(),
    ];
  }

  // Mobile: 4 screens with simplified navigation
  List<Widget> _mobileScreens() {
    return [
      const DashboardScreen(),
      const TransactionsScreen(),
      const WalletsScreen(),
      const SettingsScreen(),
    ];
  }

  void _showQuickAdd() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickAddScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;

    // Desktop navigation - 8 items
    final desktopNavLabels = [
      loc.navHome,
      loc.navTransactions,
      loc.navBreakdown,
      loc.navWallets,
      loc.navBudgets,
      loc.navGoals,
      loc.navStatistics,
      loc.navSettings,
    ];

    // Mobile navigation - 4 items (simplified)
    final mobileNavLabels = [
      loc.navHome,
      loc.navTransactions,
      loc.navWallets,
      loc.navSettings,
    ];

    return Scaffold(
      backgroundColor: neo.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 800;
          final screens = isDesktop ? _desktopScreens() : _mobileScreens();
          final navLabels = isDesktop ? desktopNavLabels : mobileNavLabels;

          // Reset index if it's out of bounds (e.g., when resizing)
          if (_currentIndex >= screens.length) {
            _currentIndex = 0;
          }

          if (isDesktop) {
            // Desktop / Wide Layout
            return Row(
              children: [
                NeoSideNav(
                  currentIndex: _currentIndex,
                  labels: navLabels,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                Expanded(
                  child: IndexedStack(index: _currentIndex, children: screens),
                ),
              ],
            );
          } else {
            // Mobile / Narrow Layout
            return IndexedStack(index: _currentIndex, children: screens);
          }
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 800) {
            return const SizedBox.shrink();
          }
          return NeoBottomNav(
            currentIndex: _currentIndex,
            labels: mobileNavLabels,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          );
        },
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 800) {
            return Container(
              height: 64,
              width: 64,
              margin: const EdgeInsets.only(bottom: 16, right: 16),
              child: NeoButton(
                padding: EdgeInsets.zero,
                backgroundColor: NeoColors.primary,
                onPressed: _showQuickAdd,
                child: const Center(
                  child: Icon(Icons.add, color: NeoColors.ink, size: 32),
                ),
              ),
            );
          }

          return Container(
            height: 64,
            width: 64,
            margin: const EdgeInsets.only(top: 8),
            child: NeoButton(
              padding: EdgeInsets.zero,
              backgroundColor: NeoColors.primary,
              onPressed: _showQuickAdd,
              child: const Center(
                child: Icon(Icons.add, color: NeoColors.ink, size: 32),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: MediaQuery.of(context).size.width >= 800
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.centerDocked,
    );
  }
}
