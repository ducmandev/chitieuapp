import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../widgets/neo_button.dart';
import '../widgets/goal_progress_card.dart';
import '../providers/app_provider.dart';
import '../models/goal.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

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
                          _buildActiveGoalsSection(context, provider, neo, loc),
                          const SizedBox(height: 24),
                          _buildCompletedGoalsSection(context, provider, neo, loc),
                          const SizedBox(height: 16),
                          _buildAddGoalButton(context, neo, loc),
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
              loc.goals,
              style: NeoTypography.textTheme.displayMedium?.copyWith(
                fontStyle: FontStyle.italic,
                letterSpacing: -1,
                color: neo.textMain,
              ),
            ),
          ),
          NeoButton(
            padding: const EdgeInsets.all(8),
            onPressed: () => _showFilterOptions(context),
            child: Icon(Icons.filter_list, color: neo.textMain, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveGoalsSection(
    BuildContext context,
    AppProvider provider,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    final activeGoals = provider.activeGoals;

    if (activeGoals.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: neo.surface,
          border: Border.all(color: neo.ink, width: 3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag_outlined, size: 48, color: neo.textSub),
            const SizedBox(height: 12),
            Text(
              loc.noGoals,
              style: NeoTypography.mono.copyWith(color: neo.textSub),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 16, height: 16, color: NeoColors.primary),
            const SizedBox(width: 16),
            Text(
              'IN PROGRESS',
              style: NeoTypography.textTheme.titleLarge?.copyWith(
                color: neo.textMain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...activeGoals.map((goal) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GoalProgressCard(
              goal: goal,
              onEdit: () => _showEditGoalDialog(context, goal),
              onDelete: () => _showDeleteGoalDialog(context, goal),
              onAddSavings: () => _showAddSavingsDialog(context, goal),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCompletedGoalsSection(
    BuildContext context,
    AppProvider provider,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    final completedGoals = provider.completedGoals;

    if (completedGoals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 16, height: 16, color: NeoColors.success),
            const SizedBox(width: 16),
            Text(
              'COMPLETED',
              style: NeoTypography.textTheme.titleLarge?.copyWith(
                color: neo.textMain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...completedGoals.take(3).map((goal) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GoalProgressCard(
              goal: goal,
              isReadOnly: true,
              onDelete: () => _showDeleteGoalDialog(context, goal),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAddGoalButton(
    BuildContext context,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    return NeoButton(
      backgroundColor: neo.surface,
      padding: const EdgeInsets.symmetric(vertical: 16),
      onPressed: () => _showAddGoalDialog(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.flag, size: 24),
          const SizedBox(width: 8),
          Text(
            loc.addGoal,
            style: NeoTypography.textTheme.titleLarge?.copyWith(
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;

    final nameController = TextEditingController();
    final targetController = TextEditingController();
    DateTime? selectedDeadline;

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
              loc.addGoal,
              style: NeoTypography.textTheme.headlineSmall,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: loc.goalName,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(color: neo.ink, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: targetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: loc.targetAmount,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(color: neo.ink, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (date != null) {
                        setDialogState(() {
                          selectedDeadline = date;
                        });
                      }
                    },
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: neo.ink, width: 2),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(Icons.calendar_today, color: neo.textSub),
                          const SizedBox(width: 12),
                          Text(
                            selectedDeadline != null
                                ? '${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}'
                                : loc.deadline,
                            style: NeoTypography.textTheme.titleMedium?.copyWith(
                              color: selectedDeadline != null
                                  ? neo.textMain
                                  : neo.textSub,
                            ),
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
                  if (nameController.text.isEmpty) return;
                  final target = double.tryParse(targetController.text);
                  if (target == null || target <= 0) return;
                  if (selectedDeadline == null) return;

                  final goal = GoalModel(
                    name: nameController.text,
                    targetAmount: target,
                    deadline: selectedDeadline!,
                  );
                  await context.read<AppProvider>().addGoal(goal);
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

  void _showEditGoalDialog(BuildContext context, goal) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;

    final nameController = TextEditingController(text: goal.name);
    final targetController = TextEditingController(text: goal.targetAmount.toString());
    DateTime? selectedDeadline = goal.deadline;

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
              loc.edit,
              style: NeoTypography.textTheme.headlineSmall,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: loc.goalName,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(color: neo.ink, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: targetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: loc.targetAmount,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(color: neo.ink, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDeadline,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (date != null) {
                        setDialogState(() {
                          selectedDeadline = date;
                        });
                      }
                    },
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: neo.ink, width: 2),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(Icons.calendar_today, color: neo.textSub),
                          const SizedBox(width: 12),
                          Text(
                            '${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}',
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
                  if (nameController.text.isEmpty) return;
                  final target = double.tryParse(targetController.text);
                  if (target == null || target <= 0) return;

                  final updatedGoal = goal.copyWith(
                    name: nameController.text,
                    targetAmount: target,
                    deadline: selectedDeadline!,
                  );
                  await context.read<AppProvider>().updateGoal(updatedGoal);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(loc.save),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddSavingsDialog(BuildContext context, goal) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;

    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: neo.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: neo.ink, width: 3),
        ),
        title: Text(loc.addToSavings),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${goal.name}: ${loc.saved} ${context.read<AppProvider>().currencySymbol}${goal.currentAmount.toStringAsFixed(0)} / ${goal.targetAmount.toStringAsFixed(0)}',
              style: NeoTypography.textTheme.titleMedium,
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) return;

              await context.read<AppProvider>().addToGoal(goal.id!, amount);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(loc.add),
          ),
        ],
      ),
    );
  }

  void _showDeleteGoalDialog(BuildContext context, goal) {
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
        title: Text(loc.deleteGoal),
        content: Text('Remove "${goal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<AppProvider>().deleteGoal(goal.id!);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(loc.delete),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
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
                        loc.filter,
                        style: NeoTypography.textTheme.titleLarge?.copyWith(
                          color: neo.surface,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  _buildFilterOption(context, neo, 'All Goals', true),
                  _buildFilterOption(context, neo, 'Active Only', false),
                  _buildFilterOption(context, neo, 'Completed Only', false),
                  Container(height: 3, color: neo.ink),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: neo.surface,
                      child: Center(
                        child: Text(
                          '✕  ${loc.close}',
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

  Widget _buildFilterOption(
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
                if (isSelected) Icon(Icons.check, color: NeoColors.ink),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
