import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../widgets/neo_card.dart';
import '../widgets/neo_button.dart';
import '../models/goal.dart';
import '../providers/app_provider.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';
import 'dart:math' as math;

class GoalProgressCard extends StatelessWidget {
  final GoalModel goal;
  final bool isReadOnly;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAddSavings;

  const GoalProgressCard({
    super.key,
    required this.goal,
    this.isReadOnly = false,
    this.onEdit,
    this.onDelete,
    this.onAddSavings,
  });

  @override
  Widget build(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;
    final provider = context.watch<AppProvider>();

    final progress = goal.progress;
    final daysLeft = goal.daysRemaining;
    final isCompleted = goal.isCompleted;

    return NeoCard(
      backgroundColor: goal.color ?? neo.surface,
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
                    Text(
                      goal.name,
                      style: NeoTypography.textTheme.titleLarge?.copyWith(
                        height: 1,
                        color: isCompleted ? Colors.white : neo.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCompleted
                          ? loc.goalCompleted
                          : '$daysLeft ${loc.daysLeft}',
                      style: NeoTypography.mono.copyWith(
                        fontSize: 12,
                        color: isCompleted ? Colors.white70 : neo.textSub,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isReadOnly && (onEdit != null || onDelete != null))
                Row(
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: Icon(Icons.edit,
                            size: 20,
                            color: isCompleted ? Colors.white : neo.textSub),
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
                            size: 20,
                            color: isCompleted ? Colors.white : neo.textSub),
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
          const SizedBox(height: 16),
          // Circular progress
          Row(
            children: [
              // Progress circle
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CustomPaint(
                      painter: _CircularProgressPainter(
                        progress: progress,
                        backgroundColor: neo.background,
                        progressColor: isCompleted
                            ? Colors.white
                            : NeoColors.success,
                        borderColor: neo.ink,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: NeoTypography.numbers.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.white : neo.textMain,
                        ),
                      ),
                      Text(
                        loc.progress,
                        style: NeoTypography.mono.copyWith(
                          fontSize: 9,
                          color: isCompleted ? Colors.white70 : neo.textSub,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Amount details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAmountRow(
                      context,
                      loc.saved,
                      goal.currentAmount,
                      provider.currencySymbol,
                      isCompleted,
                      neo,
                    ),
                    const SizedBox(height: 4),
                    _buildAmountRow(
                      context,
                      loc.targetAmount,
                      goal.targetAmount,
                      provider.currencySymbol,
                      isCompleted,
                      neo,
                    ),
                    if (!isCompleted && goal.targetAmount - goal.currentAmount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Need: ${provider.currencySymbol}${_formatCurrency(goal.targetAmount - goal.currentAmount)} more',
                          style: NeoTypography.mono.copyWith(
                            fontSize: 11,
                            color: isCompleted ? Colors.white70 : neo.textSub,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // Add savings button
          if (!isCompleted && !isReadOnly && onAddSavings != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                child: NeoButton(
                  backgroundColor: neo.background,
                  onPressed: onAddSavings ?? () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_circle_outline, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        loc.addToSavings,
                        style: NeoTypography.mono.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Celebration for completed goals
          if (isCompleted)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: neo.ink,
                  border: Border.all(color: NeoColors.primary, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🎉 ',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      loc.congratsGoal,
                      style: NeoTypography.mono.copyWith(
                        color: NeoColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    BuildContext context,
    String label,
    double amount,
    String symbol,
    bool isCompleted,
    NeoThemeData neo,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: NeoTypography.mono.copyWith(
            fontSize: 12,
            color: isCompleted ? Colors.white70 : neo.textSub,
          ),
        ),
        Text(
          '$symbol${_formatCurrency(amount)}',
          style: NeoTypography.numbers.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isCompleted ? Colors.white : neo.textMain,
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

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final Color borderColor;

  _CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius - 4, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // Border circle
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      oldDelegate is! _CircularProgressPainter ||
      oldDelegate.progress != progress;
}
