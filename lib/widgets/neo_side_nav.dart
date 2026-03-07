import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';

class NeoSideNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NeoSideNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final neo = NeoTheme.of(context);
    return Container(
      width: 120, // fixed width for the side nav
      decoration: BoxDecoration(
        color: neo.surface,
        border: Border(right: BorderSide(color: neo.ink, width: 3.0)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          // Nav Logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: NeoColors.tertiary,
              border: Border.all(color: neo.ink, width: 3),
            ),
            child: Center(
              child: Icon(Icons.flash_on, color: neo.inkOnCard, size: 32),
            ),
          ),
          const SizedBox(height: 64),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              // mainAxisSize: MainAxisSize.min, // remove since using Expanded
              children: [
                _buildNavItem(
                  context,
                  0,
                  Icons.home_outlined,
                  AppLocalizations.of(context)!.navHome,
                ),
                const SizedBox(height: 32),
                _buildNavItem(
                  context,
                  1,
                  Icons.receipt_long_outlined,
                  AppLocalizations.of(context)!.navTransactions,
                ),
                const SizedBox(height: 32),
                _buildNavItem(
                  context,
                  2,
                  Icons.pie_chart_outline,
                  AppLocalizations.of(context)!.navBreakdown,
                ),
                const SizedBox(height: 32),
                _buildNavItem(
                  context,
                  3,
                  Icons.settings_outlined,
                  AppLocalizations.of(context)!.navSettings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final neo = NeoTheme.of(context);
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 48, // Taller than bottom nav
            decoration: BoxDecoration(
              color: isSelected
                  ? NeoColors.primary
                  : neo.ink.withValues(alpha: 0.1),
              border: Border.all(
                color: isSelected
                    ? NeoColors.ink
                    : neo.ink.withValues(alpha: 0.5),
                width: 2,
              ),
              borderRadius: isSelected
                  ? BorderRadius.circular(24)
                  : BorderRadius.zero,
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? NeoColors.ink
                  : neo.textMain.withValues(alpha: 0.5),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? neo.textMain
                  : neo.textMain.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
