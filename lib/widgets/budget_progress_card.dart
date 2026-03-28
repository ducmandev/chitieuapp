import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../widgets/neo_card.dart';
import '../utils/category_utils.dart';
import '../providers/app_provider.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';

class BudgetProgressCard extends StatelessWidget {
  final String category;
  final double limit;
  final double spent;
  final String period;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BudgetProgressCard({
    super.key,
    required this.category,
    required this.limit,
    required this.spent,
    this.period = 'monthly',
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;
    final provider = context.watch<AppProvider>();

    final remaining = limit - spent;
    final percent = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = spent > limit;
    final isWarning = percent >= 0.8 && !isOverBudget;

    final cardColor = isOverBudget
        ? neo.error
        : isWarning
            ? NeoColors.secondary
            : neo.surface;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onEdit,
          child: NeoCard(
            backgroundColor: cardColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: CategoryUtils.getCategoryColor(category),
                            border: Border.all(color: neo.ink, width: 3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            CategoryUtils.getCategoryIcon(category),
                            color: NeoColors.ink,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: NeoTypography.textTheme.titleLarge?.copyWith(
                                height: 1,
                                color: isOverBudget || isWarning
                                    ? Colors.white
                                    : neo.textMain,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              period == 'monthly' ? loc.monthly : loc.weekly,
                              style: NeoTypography.mono.copyWith(
                                fontSize: 12,
                                color: isOverBudget || isWarning
                                    ? Colors.white70
                                    : neo.textSub,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${provider.currencySymbol}${_formatCurrency(spent)}',
                          style: NeoTypography.numbers.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isOverBudget || isWarning
                                ? Colors.white
                                : neo.textMain,
                          ),
                        ),
                        Text(
                          '/ ${provider.currencySymbol}${_formatCurrency(limit)}',
                          style: NeoTypography.mono.copyWith(
                            fontSize: 14,
                            color: isOverBudget || isWarning
                                ? Colors.white70
                                : neo.textSub,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress bar
                Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: isOverBudget || isWarning
                        ? neo.ink
                        : neo.background,
                    border: Border.all(color: neo.ink, width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: percent.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isOverBudget
                                ? Colors.white
                                : CategoryUtils.getCategoryColor(category),
                            border: Border(
                              right: BorderSide(
                                color: neo.ink,
                                width: percent > 0 && percent < 1 ? 3 : 0,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '${(percent * 100).toStringAsFixed(0)}%',
                          style: NeoTypography.mono.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isOverBudget || isWarning
                                ? Colors.white
                                : percent > 0.5
                                    ? Colors.white
                                    : neo.textMain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Remaining / Over
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isOverBudget
                          ? '${loc.overBudget}: ${provider.currencySymbol}${_formatCurrency(remaining.abs())}'
                          : '${loc.remaining}: ${provider.currencySymbol}${_formatCurrency(remaining)}',
                      style: NeoTypography.mono.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isOverBudget || isWarning
                            ? Colors.white
                            : neo.textSub,
                      ),
                    ),
                    if (onEdit != null || onDelete != null)
                      Row(
                        children: [
                          if (onEdit != null)
                            IconButton(
                              icon: Icon(Icons.edit,
                                  size: 18,
                                  color: isOverBudget || isWarning
                                      ? Colors.white
                                      : neo.textSub),
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
                                  size: 18,
                                  color: isOverBudget || isWarning
                                      ? Colors.white
                                      : neo.textSub),
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
              ],
            ),
          ),
        ),
        if (isOverBudget)
          Positioned(
            right: -8,
            top: 16,
            child: Transform.rotate(
              angle: 0.785398,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: neo.ink,
                  border: const Border.symmetric(
                    horizontal: BorderSide(color: Colors.white, width: 2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: neo.ink.withValues(alpha: 0.2),
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  loc.violation,
                  style: NeoTypography.mono.copyWith(
                    color: NeoColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
