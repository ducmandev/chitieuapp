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
    final provider = context.read<AppProvider>();

    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    String selectedType = 'cash';
    IconData selectedIcon = Icons.account_balance_wallet;
    Color selectedColor = NeoColors.tertiary;

    final walletIcons = [
      Icons.account_balance_wallet,
      Icons.money,
      Icons.account_balance,
      Icons.credit_card,
      Icons.savings,
      Icons.wallet,
      Icons.payments,
      Icons.store,
    ];

    final walletColors = [
      NeoColors.tertiary,
      NeoColors.primary,
      NeoColors.secondary,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.blue,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: neo.background,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: neo.surface,
                    border: Border.all(color: neo.ink, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: neo.ink,
                        offset: const Offset(6, 6),
                        blurRadius: 0,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: NeoColors.primary,
                                border:
                                    Border.all(color: neo.ink, width: 2),
                              ),
                              child: Text(
                                loc.addWallet.toUpperCase(),
                                style: NeoTypography.mono.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: NeoColors.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Wallet Name
                        Text(
                          loc.walletName,
                          style: NeoTypography.mono.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: loc.walletName,
                            filled: true,
                            fillColor: neo.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: BorderSide(color: neo.ink, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: BorderSide(color: neo.ink, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide:
                                  BorderSide(color: NeoColors.primary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Balance
                        Text(
                          loc.balance,
                          style: NeoTypography.mono.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: balanceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixText: '${provider.currencySymbol} ',
                            filled: true,
                            fillColor: neo.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: BorderSide(color: neo.ink, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: BorderSide(color: neo.ink, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide:
                                  BorderSide(color: NeoColors.primary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Wallet Type
                        Text(
                          loc.type,
                          style: NeoTypography.mono.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: neo.ink, width: 2),
                          ),
                          child: Column(
                            children: [
                              _buildTypeOption(
                                context,
                                'cash',
                                loc.cash,
                                Icons.money,
                                selectedType,
                                setDialogState,
                                (value) => selectedType = value!,
                                neo,
                              ),
                              _buildTypeOption(
                                context,
                                'bank',
                                loc.bank,
                                Icons.account_balance,
                                selectedType,
                                setDialogState,
                                (value) => selectedType = value!,
                                neo,
                              ),
                              _buildTypeOption(
                                context,
                                'credit',
                                loc.credit,
                                Icons.credit_card,
                                selectedType,
                                setDialogState,
                                (value) => selectedType = value!,
                                neo,
                              ),
                              _buildTypeOption(
                                context,
                                'savings',
                                loc.savings,
                                Icons.savings,
                                selectedType,
                                setDialogState,
                                (value) => selectedType = value!,
                                neo,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Icon Selection
                        Text(
                          'ICON',
                          style: NeoTypography.mono.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: walletIcons.map((icon) {
                            final isSelected = selectedIcon == icon;
                            return GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  selectedIcon = icon;
                                });
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? NeoColors.primary
                                      : neo.background,
                                  border: Border.all(
                                    color: neo.ink,
                                    width: isSelected ? 3 : 2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: neo.ink,
                                            offset: const Offset(2, 2),
                                            blurRadius: 0,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  icon,
                                  color: isSelected
                                      ? NeoColors.ink
                                      : neo.textMain,
                                  size: 24,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        // Color Selection
                        Text(
                          'MÀU SẮC',
                          style: NeoTypography.mono.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: walletColors.map((color) {
                            final isSelected = selectedColor == color;
                            return GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  selectedColor = color;
                                });
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: color,
                                  border: Border.all(
                                    color: neo.ink,
                                    width: isSelected ? 3 : 2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: neo.ink,
                                            offset: const Offset(2, 2),
                                            blurRadius: 0,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: isSelected
                                    ? Icon(Icons.check,
                                        color: NeoColors.ink, size: 24)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                // Action Buttons
                Positioned(
                  right: 24,
                  bottom: -16,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildNeoButton(
                        context,
                        loc.cancel,
                        NeoColors.secondary,
                        () => Navigator.pop(context),
                        neo,
                      ),
                      const SizedBox(width: 12),
                      _buildNeoButton(
                        context,
                        loc.add,
                        NeoColors.primary,
                        () async {
                          if (nameController.text.isEmpty) return;
                          final balance =
                              double.tryParse(balanceController.text) ?? 0.0;
                          final wallet = WalletModel(
                            name: nameController.text,
                            balance: balance,
                            type: selectedType,
                            icon: _getIconString(selectedIcon),
                            color: selectedColor,
                          );
                          await context
                              .read<AppProvider>()
                              .addWallet(wallet);
                          if (context.mounted) Navigator.pop(context);
                        },
                        neo,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeOption(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    String selectedType,
    Function setDialogState,
    Function(String?) onChanged,
    NeoThemeData neo,
  ) {
    final isSelected = selectedType == value;
    return InkWell(
      onTap: () {
        setDialogState(() {
          onChanged(value);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? NeoColors.primary : null,
          border: Border(
            bottom: BorderSide(color: neo.ink, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? NeoColors.ink : neo.textMain,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: NeoTypography.mono.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? NeoColors.ink : neo.textMain,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check, color: NeoColors.ink, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNeoButton(
    BuildContext context,
    String label,
    Color bgColor,
    VoidCallback onPressed,
    NeoThemeData neo,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: neo.ink, width: 2),
          boxShadow: [
            BoxShadow(
              color: neo.ink,
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          label.toUpperCase(),
          style: NeoTypography.mono.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: NeoColors.ink,
          ),
        ),
      ),
    );
  }

  String _getIconString(IconData icon) {
    if (icon == Icons.money) return 'money';
    if (icon == Icons.account_balance) return 'account_balance';
    if (icon == Icons.credit_card) return 'credit_card';
    if (icon == Icons.savings) return 'savings';
    if (icon == Icons.wallet) return 'wallet';
    if (icon == Icons.payments) return 'payments';
    if (icon == Icons.store) return 'store';
    return 'account_balance_wallet';
  }

  void _showEditWalletDialog(BuildContext context, wallet) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;
    final provider = context.read<AppProvider>();

    final nameController = TextEditingController(text: wallet.name);
    final balanceController = TextEditingController(
        text: wallet.balance.toStringAsFixed(0));
    String selectedType = wallet.type;
    IconData selectedIcon = wallet.icon != null 
        ? _getIconDataFromString(wallet.icon!) 
        : wallet.defaultIcon;
    Color selectedColor = wallet.color ?? NeoColors.tertiary;

    final walletIcons = [
      Icons.account_balance_wallet,
      Icons.money,
      Icons.account_balance,
      Icons.credit_card,
      Icons.savings,
      Icons.wallet,
      Icons.payments,
      Icons.store,
    ];

    final walletColors = [
      NeoColors.tertiary,
      NeoColors.primary,
      NeoColors.secondary,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.blue,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: neo.background,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: neo.surface,
                    border: Border.all(color: neo.ink, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: neo.ink,
                        offset: const Offset(6, 6),
                        blurRadius: 0,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: NeoColors.secondary,
                                border: Border.all(color: neo.ink, width: 2),
                              ),
                              child: Text(
                                loc.editWallet.toUpperCase(),
                                style: NeoTypography.mono.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: NeoColors.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Wallet Name
                        Text(
                          loc.walletName,
                          style: NeoTypography.mono.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: loc.walletName,
                            filled: true,
                            fillColor: neo.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: BorderSide(color: neo.ink, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: BorderSide(color: neo.ink, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide:
                                  BorderSide(color: NeoColors.secondary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Balance
                        Text(
                          loc.balance,
                          style: NeoTypography.mono.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: balanceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixText: '${provider.currencySymbol} ',
                            filled: true,
                            fillColor: neo.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: BorderSide(color: neo.ink, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: BorderSide(color: neo.ink, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide:
                                  BorderSide(color: NeoColors.secondary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Wallet Type
                        Text(
                          loc.type,
                          style: NeoTypography.mono.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: neo.ink, width: 2),
                          ),
                          child: Column(
                            children: [
                              _buildTypeOptionForEdit(
                                context,
                                'cash',
                                loc.cash,
                                Icons.money,
                                selectedType,
                                setDialogState,
                                (value) => selectedType = value!,
                                neo,
                              ),
                              _buildTypeOptionForEdit(
                                context,
                                'bank',
                                loc.bank,
                                Icons.account_balance,
                                selectedType,
                                setDialogState,
                                (value) => selectedType = value!,
                                neo,
                              ),
                              _buildTypeOptionForEdit(
                                context,
                                'credit',
                                loc.credit,
                                Icons.credit_card,
                                selectedType,
                                setDialogState,
                                (value) => selectedType = value!,
                                neo,
                              ),
                              _buildTypeOptionForEdit(
                                context,
                                'savings',
                                loc.savings,
                                Icons.savings,
                                selectedType,
                                setDialogState,
                                (value) => selectedType = value!,
                                neo,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Icon Selection
                        Text(
                          'ICON',
                          style: NeoTypography.mono.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: walletIcons.map((icon) {
                            final isSelected = selectedIcon == icon;
                            return GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  selectedIcon = icon;
                                });
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? NeoColors.secondary
                                      : neo.background,
                                  border: Border.all(
                                    color: neo.ink,
                                    width: isSelected ? 3 : 2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: neo.ink,
                                            offset: const Offset(2, 2),
                                            blurRadius: 0,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  icon,
                                  color: isSelected
                                      ? NeoColors.ink
                                      : neo.textMain,
                                  size: 24,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        // Color Selection
                        Text(
                          'MÀU SẮC',
                          style: NeoTypography.mono.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: walletColors.map((color) {
                            final isSelected = selectedColor == color;
                            return GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  selectedColor = color;
                                });
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: color,
                                  border: Border.all(
                                    color: neo.ink,
                                    width: isSelected ? 3 : 2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: neo.ink,
                                            offset: const Offset(2, 2),
                                            blurRadius: 0,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: isSelected
                                    ? Icon(Icons.check,
                                        color: NeoColors.ink, size: 24)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                // Action Buttons
                Positioned(
                  right: 24,
                  bottom: -16,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildNeoButtonForEdit(
                        context,
                        loc.cancel,
                        NeoColors.secondary,
                        () => Navigator.pop(context),
                        neo,
                      ),
                      const SizedBox(width: 12),
                      _buildNeoButtonForEdit(
                        context,
                        loc.save,
                        NeoColors.secondary,
                        () async {
                          if (nameController.text.isEmpty) return;
                          final balance =
                              double.tryParse(balanceController.text) ?? wallet.balance;
                          final updatedWallet = wallet.copyWith(
                            name: nameController.text,
                            balance: balance,
                            type: selectedType,
                            icon: _getIconString(selectedIcon),
                            color: selectedColor,
                          );
                          await context.read<AppProvider>().updateWallet(updatedWallet);
                          if (context.mounted) Navigator.pop(context);
                        },
                        neo,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeOptionForEdit(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    String selectedType,
    Function setDialogState,
    Function(String?) onChanged,
    NeoThemeData neo,
  ) {
    final isSelected = selectedType == value;
    return InkWell(
      onTap: () {
        setDialogState(() {
          onChanged(value);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? NeoColors.secondary : null,
          border: Border(
            bottom: BorderSide(color: neo.ink, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? NeoColors.ink : neo.textMain,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: NeoTypography.mono.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? NeoColors.ink : neo.textMain,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check, color: NeoColors.ink, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNeoButtonForEdit(
    BuildContext context,
    String label,
    Color bgColor,
    VoidCallback onPressed,
    NeoThemeData neo,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: neo.ink, width: 2),
          boxShadow: [
            BoxShadow(
              color: neo.ink,
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          label.toUpperCase(),
          style: NeoTypography.mono.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: NeoColors.ink,
          ),
        ),
      ),
    );
  }

  IconData _getIconDataFromString(String iconString) {
    switch (iconString.toLowerCase()) {
      case 'money':
        return Icons.money;
      case 'account_balance':
        return Icons.account_balance;
      case 'credit_card':
        return Icons.credit_card;
      case 'savings':
        return Icons.savings;
      case 'wallet':
        return Icons.wallet;
      case 'payments':
        return Icons.payments;
      case 'store':
        return Icons.store;
      default:
        return Icons.account_balance_wallet;
    }
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
