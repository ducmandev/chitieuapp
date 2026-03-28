import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../widgets/neo_button.dart';
import '../widgets/budget_progress_card.dart';
import '../providers/app_provider.dart';
import '../models/budget.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

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
                          _buildSummaryCard(context, provider, neo, loc),
                          const SizedBox(height: 24),
                          _buildBudgetsList(context, provider, neo, loc),
                          const SizedBox(height: 16),
                          _buildAddBudgetButton(context, neo, loc),
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
              loc.budgets,
              style: NeoTypography.textTheme.displayMedium?.copyWith(
                fontStyle: FontStyle.italic,
                letterSpacing: -1,
                color: neo.textMain,
              ),
            ),
          ),
          NeoButton(
            padding: const EdgeInsets.all(8),
            onPressed: () => _showPeriodSelector(context),
            child: Icon(Icons.calendar_month, color: neo.textMain, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    AppProvider provider,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    final totalBudget = provider.activeBudgets.fold(0.0, (sum, b) => sum + b.limit);
    final totalSpent = provider.activeBudgets.fold(0.0, (sum, b) => sum + provider.getBudgetSpending(b.category));
    final overallPercent = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: neo.surface,
        border: Border.all(color: neo.ink, width: 3),
        boxShadow: [BoxShadow(color: neo.ink, offset: const Offset(4, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${loc.monthly} ${loc.budgetLimit}',
                style: NeoTypography.textTheme.titleLarge?.copyWith(
                  color: neo.textMain,
                ),
              ),
              Text(
                '${(overallPercent * 100).toStringAsFixed(0)}%',
                style: NeoTypography.mono.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: overallPercent > 0.9 ? neo.error : NeoColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  loc.spent,
                  totalSpent,
                  provider.currencySymbol,
                  NeoColors.secondary,
                  neo,
                ),
              ),
              Container(width: 3, height: 48, color: neo.ink),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  loc.remaining,
                  totalBudget > totalSpent ? totalBudget - totalSpent : 0,
                  provider.currencySymbol,
                  NeoColors.success,
                  neo,
                ),
              ),
              Container(width: 3, height: 48, color: neo.ink),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  loc.budgetLimit,
                  totalBudget,
                  provider.currencySymbol,
                  NeoColors.tertiary,
                  neo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    double value,
    String symbol,
    Color color,
    NeoThemeData neo,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: NeoTypography.mono.copyWith(
            fontSize: 12,
            color: neo.textSub,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$symbol${_formatCurrency(value)}',
          style: NeoTypography.numbers.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetsList(
    BuildContext context,
    AppProvider provider,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    if (provider.activeBudgets.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 48, color: neo.textSub),
            const SizedBox(height: 12),
            Text(
              loc.noBudgets,
              style: NeoTypography.mono.copyWith(color: neo.textSub),
            ),
          ],
        ),
      );
    }

    return Column(
      children: provider.activeBudgets.map((budget) {
        final spent = provider.getBudgetSpending(budget.category);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: BudgetProgressCard(
            category: budget.category,
            limit: budget.limit,
            spent: spent,
            period: budget.period,
            onEdit: () => _showEditBudgetDialog(context, budget),
            onDelete: () => _showDeleteBudgetDialog(context, budget),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddBudgetButton(
    BuildContext context,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    return NeoButton(
      backgroundColor: neo.surface,
      padding: const EdgeInsets.symmetric(vertical: 16),
      onPressed: () => _showAddBudgetDialog(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add, size: 24),
          const SizedBox(width: 8),
          Text(
            loc.addBudget,
            style: NeoTypography.textTheme.titleLarge?.copyWith(
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;
    final provider = context.read<AppProvider>();

    final limitController = TextEditingController();
    String selectedCategory = loc.food;
    String selectedPeriod = 'monthly';

    // Get existing budget categories
    final existingCategories = provider.budgets.map((b) => b.category).toSet();

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
              loc.addBudget,
              style: NeoTypography.textTheme.headlineSmall,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category selector
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: InputDecoration(
                      labelText: loc.category,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(color: neo.ink, width: 2),
                      ),
                    ),
                    items: [
                      loc.food,
                      loc.travel,
                      loc.games,
                      loc.coffee,
                      loc.rides,
                      'SHOPPING',
                      'BILLS',
                      'ENTERTAINMENT',
                      'HEALTH',
                      'OTHER',
                    ].where((cat) => !existingCategories.contains(cat)).map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedCategory = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Limit input
                  TextField(
                    controller: limitController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: loc.budgetLimit,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(color: neo.ink, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Period selector
                  DropdownButtonFormField<String>(
                    initialValue: selectedPeriod,
                    decoration: InputDecoration(
                      labelText: loc.period,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(color: neo.ink, width: 2),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 'monthly', child: Text(loc.monthly)),
                      DropdownMenuItem(value: 'weekly', child: Text(loc.weekly)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedPeriod = value;
                        });
                      }
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
                  final limit = double.tryParse(limitController.text);
                  if (limit == null || limit <= 0) return;

                  final budget = BudgetModel(
                    category: selectedCategory,
                    limit: limit,
                    period: selectedPeriod,
                  );
                  await provider.addBudget(budget);
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

  void _showEditBudgetDialog(BuildContext context, budget) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;
    final provider = context.read<AppProvider>();

    final limitController = TextEditingController(text: budget.limit.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: neo.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: neo.ink, width: 3),
        ),
        title: Text(
          loc.editBudget,
          style: NeoTypography.textTheme.headlineSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${loc.setCategoryBudget} ${budget.category}',
              style: NeoTypography.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: limitController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: loc.budgetLimit,
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
              final limit = double.tryParse(limitController.text);
              if (limit == null || limit <= 0) return;

              final updatedBudget = budget.copyWith(limit: limit);
              await provider.updateBudget(updatedBudget);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(loc.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteBudgetDialog(BuildContext context, budget) {
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
        title: Text(loc.deleteBudget),
        content: Text('Remove budget limit for ${budget.category}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<AppProvider>().deleteBudget(budget.id!);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(loc.delete),
          ),
        ],
      ),
    );
  }

  void _showPeriodSelector(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
                    child: Center(
                      child: Text(
                        loc.period,
                        style: NeoTypography.textTheme.titleLarge?.copyWith(
                          color: neo.surface,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  _buildPeriodOption(context, neo, loc.monthly, true),
                  _buildPeriodOption(context, neo, loc.weekly, false),
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

  Widget _buildPeriodOption(
    BuildContext context,
    NeoThemeData neo,
    String label,
    bool isSelected,
  ) {
    return Column(
      children: [
        Container(height: 3, color: neo.ink),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: isSelected ? NeoColors.primary : neo.surface,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: NeoTypography.textTheme.titleMedium?.copyWith(
                      color: isSelected ? NeoColors.ink : neo.textMain,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check, color: NeoColors.ink),
              ],
            ),
          ),
        ),
      ],
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
