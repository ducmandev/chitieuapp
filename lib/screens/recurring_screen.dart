import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';
import '../providers/app_provider.dart';
import '../utils/category_utils.dart';
import '../models/recurring_transaction.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';

class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

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
                      final recurringList = provider.recurringTransactions;

                      if (recurringList.isEmpty) {
                        return _buildEmptyState(context, neo, loc);
                      }

                      return ListView(
                        padding: const EdgeInsets.only(
                          top: 24,
                          bottom: 100,
                          left: 16,
                          right: 16,
                        ),
                        children: [
                          ...recurringList.map((recurring) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildRecurringCard(
                                context,
                                recurring,
                                provider,
                                neo,
                                loc,
                              ),
                            );
                          }),
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
      floatingActionButton: _buildAddButton(context, neo, loc),
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
              loc.recurring,
              style: NeoTypography.textTheme.displayMedium?.copyWith(
                fontStyle: FontStyle.italic,
                letterSpacing: -1,
                color: neo.textMain,
              ),
            ),
          ),
          NeoButton(
            padding: const EdgeInsets.all(8),
            onPressed: () => _processAllNow(context),
            child: Icon(Icons.sync, color: neo.textMain, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_repeat_outlined, size: 64, color: neo.textSub),
          const SizedBox(height: 16),
          Text(
            loc.noRecurring,
            style: NeoTypography.textTheme.titleLarge?.copyWith(
              color: neo.textSub,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set up recurring transactions to automate your finances',
            style: NeoTypography.mono.copyWith(color: neo.textSub),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringCard(
    BuildContext context,
    recurring,
    AppProvider provider,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    final isDue = recurring.nextDueDate.isBefore(DateTime.now().add(const Duration(days: 1)));
    final isOverdue = recurring.nextDueDate.isBefore(DateTime.now());

    return NeoCard(
      backgroundColor: recurring.isActive
          ? neo.surface
          : neo.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: CategoryUtils.getCategoryColor(recurring.category),
                            border: Border.all(color: neo.ink, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            CategoryUtils.getCategoryIcon(recurring.category),
                            color: NeoColors.ink,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recurring.title,
                                style: NeoTypography.textTheme.titleLarge?.copyWith(
                                  color: recurring.isActive ? neo.textMain : neo.textSub,
                                ),
                              ),
                              Text(
                                _getFrequencyLabel(recurring.frequency, loc),
                                style: NeoTypography.mono.copyWith(
                                  fontSize: 11,
                                  color: neo.textSub,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit,
                  size: 20,
                  color: recurring.isActive ? neo.textMain : neo.textSub),
                onPressed: recurring.isActive
                    ? () => _showEditDialog(context, recurring)
                    : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                icon: Icon(Icons.delete,
                  size: 20,
                  color: neo.error),
                onPressed: () => _showDeleteDialog(context, recurring),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Amount and next due
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.amount,
                    style: NeoTypography.mono.copyWith(
                      fontSize: 11,
                      color: neo.textSub,
                    ),
                  ),
                  Text(
                    '${provider.currencySymbol}${_formatCurrency(recurring.amount)}',
                    style: NeoTypography.numbers.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: recurring.type == 'income'
                          ? NeoColors.success
                          : NeoColors.secondary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    loc.nextDue,
                    style: NeoTypography.mono.copyWith(
                      fontSize: 11,
                      color: neo.textSub,
                    ),
                  ),
                  Text(
                    _formatDate(recurring.nextDueDate),
                    style: NeoTypography.mono.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isOverdue ? neo.error : isDue ? NeoColors.primary : neo.textMain,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Status indicators
          if (!recurring.isActive)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: neo.textSub.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'PAUSED',
                  style: NeoTypography.mono.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: neo.textSub,
                  ),
                ),
              ),
            ),
          if (recurring.endDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Ends: ${_formatDate(recurring.endDate!)}',
                style: NeoTypography.mono.copyWith(
                  fontSize: 10,
                  color: neo.textSub,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton(
    BuildContext context,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    return NeoButton(
      backgroundColor: NeoColors.primary,
      padding: const EdgeInsets.all(16),
      onPressed: () => _showAddDialog(context),
      child: const Icon(Icons.add, color: NeoColors.ink, size: 28),
    );
  }

  void _showAddDialog(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;
    final provider = context.read<AppProvider>();

    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = loc.food;
    String selectedFrequency = 'monthly';
    bool isIncome = false;
    DateTime? selectedEndDate;

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
              loc.addRecurring,
              style: NeoTypography.textTheme.headlineSmall,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Type toggle
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => isIncome = true),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: isIncome ? NeoColors.success : neo.background,
                              border: Border.all(color: neo.ink, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                loc.income,
                                style: NeoTypography.mono.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isIncome ? Colors.white : neo.textMain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => isIncome = false),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: !isIncome ? NeoColors.secondary : neo.background,
                              border: Border.all(color: neo.ink, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                loc.expense,
                                style: NeoTypography.mono.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: !isIncome ? Colors.white : neo.textMain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(color: neo.ink, width: 2),
                      ),
                    ),
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedFrequency,
                    decoration: InputDecoration(
                      labelText: loc.frequency,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(color: neo.ink, width: 2),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 'daily', child: Text(loc.daily)),
                      DropdownMenuItem(value: 'weekly', child: Text(loc.weekly)),
                      DropdownMenuItem(value: 'monthly', child: Text(loc.monthly)),
                      DropdownMenuItem(value: 'yearly', child: Text(loc.yearly)),
                    ],
                    onChanged: (value) => setDialogState(() => selectedFrequency = value!),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Optional end date:',
                    style: NeoTypography.mono.copyWith(fontSize: 12, color: neo.textSub),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (date != null) {
                        setDialogState(() => selectedEndDate = date);
                      }
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: neo.ink, width: 2),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(Icons.calendar_today, size: 20, color: neo.textMain),
                          const SizedBox(width: 12),
                          Text(
                            selectedEndDate != null
                                ? '${selectedEndDate!.day}/${selectedEndDate!.month}/${selectedEndDate!.year}'
                                : loc.endDate,
                            style: NeoTypography.textTheme.titleMedium,
                          ),
                        ],
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
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) return;
                  if (titleController.text.isEmpty) return;

                  final recurring = RecurringTransactionModel(
                    title: titleController.text,
                    amount: amount,
                    category: selectedCategory,
                    type: isIncome ? 'income' : 'expense',
                    frequency: selectedFrequency,
                    nextDueDate: _calculateNextDueDate(selectedFrequency),
                    endDate: selectedEndDate,
                  );
                  await provider.addRecurring(recurring);
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

  void _showEditDialog(BuildContext context, recurring) {
    // Similar to add dialog but with pre-filled values
    _showAddDialog(context);
  }

  void _showDeleteDialog(BuildContext context, recurring) {
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
        title: Text(loc.deleteRecurring),
        content: Text('Delete "${recurring.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<AppProvider>().deleteRecurring(recurring.id!);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: neo.error),
            child: Text(loc.delete),
          ),
        ],
      ),
    );
  }

  void _processAllNow(BuildContext context) async {
    await context.read<AppProvider>().processDueRecurring();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processed recurring transactions')),
      );
    }
  }

  DateTime _calculateNextDueDate(String frequency) {
    final now = DateTime.now();
    switch (frequency) {
      case 'daily':
        return now.add(const Duration(days: 1));
      case 'weekly':
        return now.add(const Duration(days: 7));
      case 'monthly':
        final nextMonth = now.month == 12
            ? DateTime(now.year + 1, 1, 1)
            : DateTime(now.year, now.month + 1, 1);
        return nextMonth;
      case 'yearly':
        return DateTime(now.year + 1, now.month, now.day);
      default:
        return now;
    }
  }

  String _getFrequencyLabel(String frequency, AppLocalizations loc) {
    switch (frequency) {
      case 'daily':
        return loc.daily;
      case 'weekly':
        return loc.weekly;
      case 'monthly':
        return loc.monthly;
      case 'yearly':
        return loc.yearly;
      default:
        return frequency;
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
