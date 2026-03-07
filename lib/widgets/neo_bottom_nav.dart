import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';

class NeoBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NeoBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final neo = NeoTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: neo.surface,
        border: Border(top: BorderSide(color: neo.ink, width: 3.0)),
      ),
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildNavItem(
            context,
            0,
            Icons.home_outlined,
            AppLocalizations.of(context)!.navHome,
          ),
          _buildNavItem(
            context,
            1,
            Icons.receipt_long_outlined,
            AppLocalizations.of(context)!.navTransactions,
          ),
          _buildFabPlaceholder(),
          _buildNavItem(
            context,
            2,
            Icons.pie_chart_outline,
            AppLocalizations.of(context)!.navBreakdown,
          ),
          _buildNavItem(
            context,
            3,
            Icons.settings_outlined,
            AppLocalizations.of(context)!.navSettings,
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
            height: 32,
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
                  ? BorderRadius.circular(16)
                  : BorderRadius.zero,
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? NeoColors.ink
                  : neo.textMain.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SpaceMono', // Space Mono font
              fontSize: 10,
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

  Widget _buildFabPlaceholder() {
    return const SizedBox(width: 64, height: 64);
  }
}
