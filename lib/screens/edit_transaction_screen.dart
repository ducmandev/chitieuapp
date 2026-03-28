import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';
import '../widgets/wallet_selector.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../providers/app_provider.dart';
import '../utils/category_utils.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late final TextEditingController _tagsController;
  late DateTime _selectedDate;
  late String _selectedCategory;
  late bool _isIncome;
  WalletModel? _selectedWallet;
  String? _receiptImagePath;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.transaction.title);
    _amountController = TextEditingController(
        text: widget.transaction.amount.toString());
    _noteController = TextEditingController(text: widget.transaction.note ?? '');
    _tagsController = TextEditingController(text: widget.transaction.tags ?? '');
    _selectedDate = widget.transaction.date;
    _selectedCategory = widget.transaction.category;
    _isIncome = widget.transaction.type == 'income';
    _selectedWallet = context.read<AppProvider>()
        .wallets
        .firstWhere(
          (w) => w.id == widget.transaction.walletId,
          orElse: () => context.read<AppProvider>().defaultWallet ?? WalletModel(
            name: 'Default',
            balance: 0,
            type: 'cash',
            isDefault: true,
          ),
        );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: neo.background,
      appBar: AppBar(
        backgroundColor: neo.background,
        elevation: 0,
        leading: NeoButton(
          padding: const EdgeInsets.all(8),
          backgroundColor: neo.surface,
          onPressed: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: neo.textMain),
        ),
        title: Text(
          loc.edit,
          style: NeoTypography.textTheme.headlineSmall?.copyWith(
            color: neo.textMain,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: NeoButton(
              backgroundColor: neo.error,
              onPressed: () => _showDeleteDialog(context),
              child: Icon(Icons.delete, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Income/Expense toggle
              _buildIncomeExpenseToggle(context, neo, loc),
              const SizedBox(height: 16),

              // Amount
              _buildAmountInput(context, neo, loc),
              const SizedBox(height: 16),

              // Title
              _buildTitleInput(context, neo, loc),
              const SizedBox(height: 16),

              // Category
              _buildCategorySelector(context, neo, loc),
              const SizedBox(height: 16),

              // Wallet
              WalletSelector(
                selectedWallet: _selectedWallet,
                onWalletSelected: (wallet) {
                  setState(() {
                    _selectedWallet = wallet;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Date
              _buildDateSelector(context, neo, loc),
              const SizedBox(height: 16),

              // Note
              _buildNoteInput(context, neo, loc),
              const SizedBox(height: 16),

              // Tags
              _buildTagsInput(context, neo, loc),
              const SizedBox(height: 16),

              // Receipt
              _buildReceiptSection(context, neo, loc),
              const SizedBox(height: 24),

              // Save button
              _buildSaveButton(context, neo, loc),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseToggle(
    BuildContext context,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isIncome = true;
                if (_selectedCategory == loc.income) return;
                _selectedCategory = loc.income;
              });
            },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: _isIncome ? NeoColors.success : neo.surface,
                border: Border.all(color: neo.ink, width: 3),
                boxShadow: [
                  BoxShadow(color: neo.ink, offset: const Offset(2, 2)),
                ],
              ),
              child: Center(
                child: Text(
                  '+ ${loc.income}',
                  style: NeoTypography.mono.copyWith(
                    color: _isIncome ? Colors.white : neo.textMain,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isIncome = false;
                if (_selectedCategory != loc.income) return;
                _selectedCategory = loc.food;
              });
            },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: !_isIncome ? NeoColors.secondary : neo.surface,
                border: Border.all(color: neo.ink, width: 3),
                boxShadow: [
                  BoxShadow(color: neo.ink, offset: const Offset(2, 2)),
                ],
              ),
              child: Center(
                child: Text(
                  '- ${loc.expense}',
                  style: NeoTypography.mono.copyWith(
                    color: !_isIncome ? Colors.white : neo.textMain,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput(
    BuildContext context,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.amount,
            style: NeoTypography.mono.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: neo.textSub,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: NeoTypography.textTheme.displaySmall?.copyWith(
              color: neo.textMain,
            ),
            decoration: InputDecoration(
              prefix: Text(
                context.read<AppProvider>().currencySymbol,
                style: NeoTypography.textTheme.displaySmall?.copyWith(
                  color: neo.textSub,
                ),
              ),
              border: InputBorder.none,
              hintText: '0.00',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleInput(
    BuildContext context,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _titleController,
        style: NeoTypography.textTheme.titleMedium,
        decoration: InputDecoration(
          labelText: loc.title,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0),
            borderSide: BorderSide(color: neo.ink, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(
    BuildContext context,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    final categories = _isIncome
        ? [loc.income]
        : [loc.food, loc.travel, loc.games, loc.coffee, loc.rides];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.category,
          style: NeoTypography.mono.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: neo.textSub,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            final isSelected = _selectedCategory == cat;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CategoryUtils.getCategoryColor(cat)
                      : neo.surface,
                  border: Border.all(color: neo.ink, width: isSelected ? 3 : 2),
                  boxShadow: isSelected
                      ? [BoxShadow(color: neo.ink, offset: const Offset(2, 2))]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CategoryUtils.getCategoryIcon(cat),
                      size: 18,
                      color: isSelected ? NeoColors.ink : neo.textMain,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat,
                      style: NeoTypography.mono.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? NeoColors.ink : neo.textMain,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 30)),
          );
          if (date != null) {
            setState(() {
              _selectedDate = date;
            });
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.date,
              style: NeoTypography.mono.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: neo.textSub,
              ),
            ),
            Row(
              children: [
                Icon(Icons.calendar_today, color: neo.textMain),
                const SizedBox(width: 8),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: NeoTypography.textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteInput(
    BuildContext context,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _noteController,
        maxLines: 3,
        style: NeoTypography.textTheme.bodyMedium,
        decoration: InputDecoration(
          labelText: loc.note,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0),
            borderSide: BorderSide(color: neo.ink, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildTagsInput(
    BuildContext context,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.tags,
            style: NeoTypography.mono.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: neo.textSub,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _tagsController,
            style: NeoTypography.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: loc.addTag,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: BorderSide(color: neo.ink, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptSection(
    BuildContext context,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.attachReceipt,
                style: NeoTypography.mono.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: neo.textSub,
                ),
              ),
              if (_receiptImagePath != null)
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _showRemoveReceiptDialog(context),
                      child: Text(loc.removeReceipt),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_receiptImagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_receiptImagePath!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            GestureDetector(
              onTap: () => _pickReceiptImage(context),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: neo.background,
                  border: Border.all(color: neo.ink.withValues(alpha: 0.3), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, size: 32, color: neo.textSub),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add receipt',
                      style: NeoTypography.mono.copyWith(color: neo.textSub),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    return NeoButton(
      backgroundColor: NeoColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 16),
      onPressed: _saveTransaction,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.save, size: 24),
          const SizedBox(width: 8),
          Text(
            loc.save,
            style: NeoTypography.textTheme.headlineMedium?.copyWith(
              color: NeoColors.ink,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickReceiptImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _receiptImagePath = pickedFile.path;
      });
    }
  }

  void _showRemoveReceiptDialog(BuildContext context) {
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
        title: Text(loc.removeReceipt),
        content: Text('Remove receipt image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _receiptImagePath = null;
              });
              Navigator.pop(context);
            },
            child: Text(loc.remove),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTransaction() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    final updatedTransaction = widget.transaction.copyWith(
      title: _titleController.text.isEmpty ? _selectedCategory : _titleController.text,
      amount: amount,
      date: _selectedDate,
      category: _selectedCategory,
      type: _isIncome ? 'income' : 'expense',
      walletId: _selectedWallet?.id,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      tags: _tagsController.text.isEmpty ? null : _tagsController.text,
    );

    await context.read<AppProvider>().updateTransaction(updatedTransaction);
    if (mounted) Navigator.pop(context);
  }

  void _showDeleteDialog(BuildContext context) {
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
        title: Text(loc.delete),
        content: Text('Delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await context.read<AppProvider>().deleteTransaction(widget.transaction.id!);
              if (mounted) {
                navigator.pop();
                navigator.pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: neo.error),
            child: Text(loc.delete),
          ),
        ],
      ),
    );
  }
}
