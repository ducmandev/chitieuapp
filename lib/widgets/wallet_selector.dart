import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../models/wallet.dart';
import '../providers/app_provider.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';

class WalletSelector extends StatelessWidget {
  final WalletModel? selectedWallet;
  final Function(WalletModel?) onWalletSelected;
  final bool showAllOption;

  const WalletSelector({
    super.key,
    this.selectedWallet,
    required this.onWalletSelected,
    this.showAllOption = true,
  });

  @override
  Widget build(BuildContext context) {
    final neo = NeoTheme.of(context);
    final provider = context.watch<AppProvider>();
    final loc = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => _showWalletSelector(context),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: neo.surface,
          border: Border.all(color: neo.ink, width: 3),
          boxShadow: [BoxShadow(color: neo.ink, offset: const Offset(4, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: neo.ink, width: 3),
                ),
              ),
              child: Icon(Icons.account_balance_wallet, color: neo.textMain),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  selectedWallet?.name ?? (showAllOption ? loc.allWallets : loc.selectWallet),
                  style: NeoTypography.textTheme.titleMedium,
                ),
              ),
            ),
            if (selectedWallet != null)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${provider.currencySymbol}${_formatCurrency(selectedWallet!.balance)}',
                  style: NeoTypography.mono.copyWith(
                    color: neo.textSub,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Container(
              width: 52,
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: neo.ink, width: 3),
                ),
              ),
              child: Icon(Icons.expand_more, color: neo.textMain, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  void _showWalletSelector(BuildContext context) {
    final neo = NeoTheme.of(context);
    final provider = context.read<AppProvider>();
    final loc = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: neo.surface,
                border: Border.all(color: neo.ink, width: 3),
                boxShadow: [
                  BoxShadow(color: neo.ink, offset: const Offset(6, 6)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: neo.ink,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.selectWallet,
                          style: NeoTypography.textTheme.titleLarge?.copyWith(
                            color: neo.surface,
                            letterSpacing: 2,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: neo.surface),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  if (provider.wallets.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        loc.noWallets,
                        style: NeoTypography.mono.copyWith(color: neo.textSub),
                      ),
                    )
                  else
                    Column(
                      children: [
                        if (showAllOption)
                          _buildWalletOption(
                            context,
                            neo,
                            loc,
                            null,
                            loc.allWallets,
                            Icons.apps,
                            selectedWallet == null,
                          ),
                        ...provider.wallets.map((wallet) {
                          return _buildWalletOption(
                            context,
                            neo,
                            loc,
                            wallet,
                            wallet.name,
                            wallet.defaultIcon,
                            selectedWallet?.id == wallet.id,
                            balance: wallet.balance,
                            provider: provider,
                          );
                        }),
                      ],
                    ),
                  Container(height: 3, color: neo.ink),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: neo.surface,
                      child: Center(
                        child: Text(
                          '✕  ${loc.cancel.toUpperCase()}',
                          style: NeoTypography.mono.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 2,
                            color: neo.textMain,
                          ),
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

  Widget _buildWalletOption(
    BuildContext context,
    NeoThemeData neo,
    AppLocalizations loc,
    WalletModel? wallet,
    String label,
    IconData icon,
    bool isSelected, {
    double? balance,
    AppProvider? provider,
  }) {
    return Column(
      children: [
        if (wallet != null || !isSelected) Container(height: 3, color: neo.ink),
        GestureDetector(
          onTap: () {
            onWalletSelected(wallet);
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: isSelected ? NeoColors.primary : neo.surface,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? neo.surface : neo.background,
                    border: Border.all(color: neo.ink, width: 2),
                  ),
                  child: Icon(icon, color: isSelected ? neo.ink : neo.textMain),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: NeoTypography.textTheme.titleMedium?.copyWith(
                      color: isSelected ? NeoColors.ink : neo.textMain,
                    ),
                  ),
                ),
                if (balance != null && provider != null)
                  Text(
                    '${provider.currencySymbol}${_formatCurrency(balance)}',
                    style: NeoTypography.mono.copyWith(
                      color: neo.textSub,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
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
