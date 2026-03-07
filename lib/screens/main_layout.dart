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
import 'quick_add_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionsScreen(),
    const BreakdownScreen(),
    const SettingsScreen(),
  ];

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
    return Scaffold(
      backgroundColor: neo.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 800) {
            // Desktop / Wide Layout
            return Row(
              children: [
                NeoSideNav(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                Expanded(
                  child: IndexedStack(index: _currentIndex, children: _screens),
                ),
              ],
            );
          } else {
            // Mobile / Narrow Layout
            return IndexedStack(index: _currentIndex, children: _screens);
          }
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 800) {
            return const SizedBox.shrink(); // Hide bottom nav on wide screens
          }
          return NeoBottomNav(
            currentIndex: _currentIndex,
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
            // Desktop FAB - moving to bottom right instead of center docked
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

          // Mobile FAB
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
