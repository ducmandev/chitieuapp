import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../models/wallet.dart';
import '../providers/app_provider.dart';
import '../widgets/neo_card.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';

class WalletCard extends StatelessWidget {
  final WalletModel wallet;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onSetDefault;
  final VoidCallback? onDelete;

  const WalletCard({
    super.key,
    required this.wallet,
    this.isSelected = false,
    required this.onTap,
    this.onEdit,
    this.onSetDefault,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;
    final provider = context.watch<AppProvider>();

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          NeoCard(
            backgroundColor: isSelected ? NeoColors.primary : neo.surface,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: wallet.color ?? NeoColors.tertiary,
                    border: Border.all(color: neo.ink, width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    wallet.icon != null
                        ? _getIconFromString(wallet.icon!)
                        : wallet.defaultIcon,
                    color: NeoColors.ink,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              wallet.name,
                              style: NeoTypography.textTheme.titleLarge
                                  ?.copyWith(
                                color: isSelected ? NeoColors.ink : neo.textMain,
                              ),
                            ),
                          ),
                          if (wallet.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: neo.ink,
                                border: Border.all(
                                  color: NeoColors.secondary,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                loc.defaultWallet,
                                style: NeoTypography.mono.copyWith(
                                  color: NeoColors.secondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        wallet.getDisplayName((key) => loc._getKeyValue(key)),
                        style: NeoTypography.mono.copyWith(
                          color: isSelected
                              ? NeoColors.ink.withValues(alpha: 0.7)
                              : neo.textSub,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${provider.currencySymbol}${_formatCurrency(wallet.balance)}',
                        style: NeoTypography.numbers.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? NeoColors.ink : neo.textMain,
                        ),
                      ),
                    ],
                  ),
                ),
                // Actions
                if (onEdit != null || onDelete != null)
                  Column(
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: Icon(Icons.edit, color: neo.textMain, size: 20),
                          onPressed: onEdit,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: Icon(Icons.delete,
                              color: neo.error, size: 20),
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              right: -8,
              top: -8,
              child: Transform.rotate(
                angle: 0.2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: NeoColors.secondary,
                    border: Border.all(color: neo.ink, width: 2),
                    boxShadow: [
                      BoxShadow(color: neo.ink, offset: const Offset(2, 2)),
                    ],
                  ),
                  child: Text(
                    'SELECTED',
                    style: NeoTypography.mono.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconFromString(String iconString) {
    switch (iconString.toLowerCase()) {
      case 'money':
      case 'cash':
        return Icons.money;
      case 'account_balance':
      case 'bank':
        return Icons.account_balance;
      case 'credit_card':
      case 'credit':
        return Icons.credit_card;
      case 'savings':
      case 'piggy_bank':
        return Icons.savings;
      case 'wallet':
        return Icons.wallet;
      default:
        return Icons.account_balance_wallet;
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    if (amount == amount.toInt()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }
}

extension on AppLocalizations {
  String _getKeyValue(String key) {
    switch (key) {
      case 'cash':
        return cash;
      case 'bank':
        return bank;
      case 'credit':
        return credit;
      case 'savings':
        return savings;
      default:
        return key;
    }
  }
}
