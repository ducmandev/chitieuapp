import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';

class NeoBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<String> labels;

  const NeoBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.labels = const [],
  });

  @override
  Widget build(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;

    // Use provided labels or fallback to localization keys (4 items for mobile)
    final navLabels = labels.isNotEmpty
        ? labels
        : [
            loc.navHome,
            loc.navTransactions,
            loc.navWallets,
            loc.navSettings,
          ];

    // Define icons for each tab (4 items for mobile)
    final icons = [
      Icons.home_outlined,
      Icons.receipt_long_outlined,
      Icons.account_balance_wallet_outlined,
      Icons.settings_outlined,
    ];

    return Container(
      decoration: BoxDecoration(
        color: neo.surface,
        border: Border(top: BorderSide(color: neo.ink, width: 3.0)),
      ),
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 24, top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Left side items (Home, Transactions)
          for (int i = 0; i < 2; i++)
            _buildNavItem(
              context,
              i,
              icons[i],
              navLabels[i],
            ),
          // Spacer for FAB
          const SizedBox(width: 56),
          // Right side items (Wallets, Settings)
          for (int i = 2; i < 4; i++)
            _buildNavItem(
              context,
              i,
              icons[i],
              navLabels[i],
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 48 : 40,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? NeoColors.primary
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? NeoColors.ink
                      : Colors.transparent,
                  width: 2,
                ),
                borderRadius: isSelected
                    ? BorderRadius.circular(16)
                    : BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? NeoColors.ink
                    : neo.textMain.withValues(alpha: 0.5),
                size: isSelected ? 24 : 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: NeoTypography.mono.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? neo.textMain
                    : neo.textMain.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
