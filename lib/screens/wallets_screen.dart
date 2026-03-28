import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../widgets/neo_card.dart';
import '../widgets/neo_button.dart';
import '../widgets/wallet_card.dart';
import '../providers/app_provider.dart';
import '../models/wallet.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: neo.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, neo, loc),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Consumer<AppProvider>(
                    builder: (context, provider, child) {
                      return ListView(
                        padding: const EdgeInsets.only(
                          top: 24,
                          bottom: 100,
                          left: 16,
                          right: 16,
                        ),
                        children: [
                          _buildTotalBalance(context, provider, neo, loc),
                          const SizedBox(height: 24),
                          _buildWalletsList(context, provider, neo, loc),
                          const SizedBox(height: 16),
                          _buildAddWalletButton(context, neo, loc),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NeoThemeData neo, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: neo.background,
        border: Border(bottom: BorderSide(color: neo.ink, width: 3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Transform.rotate(
            angle: -0.05,
            child: Text(
              loc.wallets,
              style: NeoTypography.textTheme.displayMedium?.copyWith(
                fontStyle: FontStyle.italic,
                letterSpacing: -1,
                color: neo.textMain,
              ),
            ),
          ),
          NeoButton(
            padding: const EdgeInsets.all(8),
            onPressed: () => _showTransferDialog(context),
            child: Icon(Icons.swap_horiz, color: neo.textMain, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBalance(
    BuildContext context,
    AppProvider provider,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    return NeoCard(
      backgroundColor: NeoColors.tertiary,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            loc.balance,
            style: NeoTypography.mono.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: neo.textMain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${provider.currencySymbol}${_formatCurrency(provider.totalWalletBalance)}',
            style: NeoTypography.textTheme.displayMedium?.copyWith(
              fontSize: 42,
              letterSpacing: -2,
              color: NeoColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletsList(
    BuildContext context,
    AppProvider provider,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    if (provider.wallets.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 48, color: neo.textSub),
            const SizedBox(height: 12),
            Text(
              loc.noWallets,
              style: NeoTypography.mono.copyWith(color: neo.textSub),
            ),
          ],
        ),
      );
    }

    return Column(
      children: provider.wallets.map((wallet) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: WalletCard(
            wallet: wallet,
            isSelected: provider.selectedWallet?.id == wallet.id,
            onTap: () => provider.selectWallet(wallet),
            onEdit: () => _showEditWalletDialog(context, wallet),
            onSetDefault: wallet.isDefault
                ? null
                : () => provider.setDefaultWallet(wallet.id!),
            onDelete: () => _showDeleteWalletDialog(context, wallet),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddWalletButton(
    BuildContext context,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    return NeoButton(
      backgroundColor: neo.surface,
      padding: const EdgeInsets.symmetric(vertical: 16),
      onPressed: () => _showAddWalletDialog(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add, size: 24),
          const SizedBox(width: 8),
          Text(
            loc.addWallet,
            style: NeoTypography.textTheme.titleLarge?.copyWith(
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddWalletDialog(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;

    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    String selectedType = 'cash';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: neo.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
              side: BorderSide(color: neo.ink, width: 3),
            ),
            title: Text(
              loc.addWallet,
              style: NeoTypography.textTheme.headlineSmall,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: loc.walletName,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(color: neo.ink, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: balanceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: loc.balance,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(color: neo.ink, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: InputDecoration(
                      labelText: loc.type,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(color: neo.ink, width: 2),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 'cash', child: Text(loc.cash)),
                      DropdownMenuItem(value: 'bank', child: Text(loc.bank)),
                      DropdownMenuItem(
                          value: 'credit', child: Text(loc.credit)),
                      DropdownMenuItem(
                          value: 'savings', child: Text(loc.savings)),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedType = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(loc.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty) return;
                  final balance =
                      double.tryParse(balanceController.text) ?? 0.0;
                  final wallet = WalletModel(
                    name: nameController.text,
                    balance: balance,
                    type: selectedType,
                  );
                  await context.read<AppProvider>().addWallet(wallet);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(loc.add),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditWalletDialog(BuildContext context, wallet) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;

    final nameController = TextEditingController(text: wallet.name);
    final balanceController = TextEditingController(
        text: wallet.balance.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: neo.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: neo.ink, width: 3),
        ),
        title: Text(
          loc.editWallet,
          style: NeoTypography.textTheme.headlineSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: loc.walletName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(color: neo.ink, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: balanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: loc.balance,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(color: neo.ink, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              final balance =
                  double.tryParse(balanceController.text) ?? wallet.balance;
              final updatedWallet = wallet.copyWith(
                name: nameController.text,
                balance: balance,
              );
              await context.read<AppProvider>().updateWallet(updatedWallet);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(loc.save),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;
    final provider = context.read<AppProvider>();

    if (provider.wallets.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Need at least 2 wallets to transfer')),
      );
      return;
    }

    final amountController = TextEditingController();
    int? fromWalletId;
    int? toWalletId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: neo.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
              side: BorderSide(color: neo.ink, width: 3),
            ),
            title: Text(
              loc.transfer,
              style: NeoTypography.textTheme.headlineSmall,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: fromWalletId,
                    decoration: InputDecoration(
                      labelText: loc.from,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(color: neo.ink, width: 2),
                      ),
                    ),
                    items: provider.wallets.map((w) {
                      return DropdownMenuItem(
                        value: w.id,
                        child: Text('${w.name} (${w.balance})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        fromWalletId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: toWalletId,
                    decoration: InputDecoration(
                      labelText: loc.to,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(color: neo.ink, width: 2),
                      ),
                    ),
                    items: provider.wallets.map((w) {
                      return DropdownMenuItem(
                        value: w.id,
                        child: Text('${w.name} (${w.balance})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        toWalletId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: loc.amount,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(color: neo.ink, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(loc.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (fromWalletId == null ||
                      toWalletId == null ||
                      fromWalletId == toWalletId) {
                    return;
                  }
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount <= 0) return;
                  await provider.transferBetweenWallets(
                      fromWalletId!, toWalletId!, amount);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(loc.transfer),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteWalletDialog(BuildContext context, wallet) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: neo.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: neo.ink, width: 3),
        ),
        title: Text(loc.deleteWallet),
        content: Text('Are you sure you want to delete "${wallet.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<AppProvider>().deleteWallet(wallet.id!);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(loc.delete),
          ),
        ],
      ),
    );
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
