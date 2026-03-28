import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';
import '../providers/app_provider.dart';
import '../utils/category_utils.dart';
import '../models/transaction_template.dart';
import '../models/transaction.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

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
                      final templates = provider.templates;

                      if (templates.isEmpty) {
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
                          ...templates.map((template) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildTemplateCard(
                                context,
                                template,
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
      floatingActionButton: _buildAddFromCurrentButton(context, neo, loc),
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
              loc.templates,
              style: NeoTypography.textTheme.displayMedium?.copyWith(
                fontStyle: FontStyle.italic,
                letterSpacing: -1,
                color: neo.textMain,
              ),
            ),
          ),
          NeoButton(
            padding: const EdgeInsets.all(8),
            onPressed: () => _showCreateDialog(context),
            child: Icon(Icons.add_circle_outline, color: neo.textMain, size: 28),
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
          Icon(Icons.description_outlined, size: 64, color: neo.textSub),
          const SizedBox(height: 16),
          Text(
            loc.noTemplates,
            style: NeoTypography.textTheme.titleLarge?.copyWith(
              color: neo.textSub,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save frequently used transactions as templates',
            style: NeoTypography.mono.copyWith(color: neo.textSub),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          NeoButton(
            backgroundColor: NeoColors.primary,
            onPressed: () => _showCreateDialog(context),
            child: Text(loc.create),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    template,
    AppProvider provider,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: CategoryUtils.getCategoryColor(template.category),
              border: Border.all(color: neo.ink, width: 3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              CategoryUtils.getCategoryIcon(template.category),
              color: NeoColors.ink,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Template info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name,
                  style: NeoTypography.textTheme.titleLarge?.copyWith(
                    color: neo.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${provider.currencySymbol}${_formatCurrency(template.amount)}',
                      style: NeoTypography.numbers.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: template.type == 'income'
                            ? NeoColors.success
                            : NeoColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: neo.ink.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        template.category,
                        style: NeoTypography.mono.copyWith(
                          fontSize: 11,
                          color: neo.textSub,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.history, size: 14, color: neo.textSub),
                    const SizedBox(width: 4),
                    Text(
                      'Used ${template.usageCount}x',
                      style: NeoTypography.mono.copyWith(
                        fontSize: 11,
                        color: neo.textSub,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          Column(
            children: [
              // Use template button
              NeoButton(
                backgroundColor: NeoColors.primary,
                padding: const EdgeInsets.all(8),
                onPressed: () => _useTemplate(context, template),
                child: Icon(Icons.play_arrow, color: NeoColors.ink),
              ),
              const SizedBox(height: 4),
              // More options
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: neo.textSub),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showEditDialog(context, template);
                      break;
                    case 'delete':
                      _showDeleteDialog(context, template);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        const SizedBox(width: 12),
                        Text(loc.edit),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        const SizedBox(width: 12),
                        Text(loc.delete),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddFromCurrentButton(
    BuildContext context,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    return NeoButton(
      backgroundColor: NeoColors.secondary,
      onPressed: () => _showSaveAsTemplateDialog(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.save_alt, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            loc.saveAsTemplate,
            style: NeoTypography.mono.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;
    final provider = context.read<AppProvider>();

    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = loc.food;
    bool isIncome = false;
    final noteController = TextEditingController();

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
              loc.templateName,
              style: NeoTypography.textTheme.headlineSmall,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: loc.templateName,
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
                  // Type toggle
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => isIncome = true),
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: isIncome ? NeoColors.success : neo.background,
                              border: Border.all(color: neo.ink, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '+ ${loc.income}',
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
                            height: 44,
                            decoration: BoxDecoration(
                              color: !isIncome ? NeoColors.secondary : neo.background,
                              border: Border.all(color: neo.ink, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '- ${loc.expense}',
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
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: InputDecoration(
                      labelText: loc.category,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(color: neo.ink, width: 2),
                      ),
                    ),
                    items: [loc.food, loc.travel, loc.games, loc.coffee, loc.rides].map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (value) => setDialogState(() => selectedCategory = value!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: loc.note,
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
                  final amount = double.tryParse(amountController.text);
                  if (nameController.text.isEmpty || amount == null || amount <= 0) return;

                  final template = TransactionTemplateModel(
                    id: const Uuid().v4(),
                    name: nameController.text,
                    amount: amount,
                    category: selectedCategory,
                    type: isIncome ? 'income' : 'expense',
                    note: noteController.text.isEmpty ? null : noteController.text,
                  );
                  await provider.saveTemplate(template);
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

  void _showEditDialog(BuildContext context, template) {
    // Similar to create dialog but pre-filled
    _showCreateDialog(context);
  }

  void _showDeleteDialog(BuildContext context, template) {
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
        title: Text(loc.deleteTemplate),
        content: Text('Delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<AppProvider>().deleteTemplate(template.id!);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: neo.error),
            child: Text(loc.delete),
          ),
        ],
      ),
    );
  }

  void _useTemplate(BuildContext context, template) async {
    final provider = context.read<AppProvider>();
    await provider.useTemplate(template);

    // Create transaction from template
    final transaction = TransactionModel(
      title: template.name,
      amount: template.amount,
      date: DateTime.now(),
      category: template.category,
      type: template.type,
      note: template.note,
      walletId: provider.selectedWallet?.id,
    );

    await provider.addTransaction(transaction);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction added from ${template.name}'),
          backgroundColor: NeoColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSaveAsTemplateDialog(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;

    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: neo.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: neo.ink, width: 3),
        ),
        title: Text(loc.saveAsTemplate),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: loc.templateName,
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
            onPressed: () {
              Navigator.pop(context);
              // This would be called from quick add screen with current transaction data
              // For now, show a message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Use templates from quick add screen')),
              );
            },
            child: Text(loc.save),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
