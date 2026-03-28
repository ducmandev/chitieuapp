import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';

class NeoSideNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<String> labels;

  const NeoSideNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.labels = const [],
  });

  @override
  Widget build(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;

    // Use provided labels or fallback to localization keys (8 items for desktop)
    final navLabels = labels.isNotEmpty
        ? labels
        : [
            loc.navHome,
            loc.navTransactions,
            loc.navBreakdown,
            loc.navWallets,
            loc.navBudgets,
            loc.navGoals,
            loc.navStatistics,
            loc.navSettings,
          ];

    // Define icons for each tab
    final icons = [
      Icons.home_outlined,
      Icons.receipt_long_outlined,
      Icons.pie_chart_outline,
      Icons.account_balance_wallet_outlined,
      Icons.account_balance_outlined,
      Icons.flag_outlined,
      Icons.bar_chart_outlined,
      Icons.settings_outlined,
    ];

    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: neo.surface,
        border: Border(right: BorderSide(color: neo.ink, width: 3.0)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      child: Column(
        children: [
          // Nav Logo
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: NeoColors.tertiary,
              border: Border.all(color: neo.ink, width: 3),
            ),
            child: Center(
              child: Icon(Icons.flash_on, color: NeoColors.ink, size: 32),
            ),
          ),
          const SizedBox(height: 32),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(navLabels.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildNavItem(
                      context,
                      index,
                      icons[index],
                      navLabels[index],
                    ),
                  );
                }),
              ),
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected
                  ? NeoColors.primary
                  : neo.ink.withValues(alpha: 0.05),
              border: Border.all(
                color: isSelected
                    ? NeoColors.ink
                    : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? NeoColors.ink
                  : neo.textMain.withValues(alpha: 0.6),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: NeoTypography.mono.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? neo.textMain
                  : neo.textMain.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
