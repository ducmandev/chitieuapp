import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../widgets/neo_card.dart';
import '../widgets/neo_button.dart';
import '../providers/app_provider.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';
import '../utils/category_utils.dart';

// Tab modes for the breakdown view
enum _ViewMode { expense, income }

class BreakdownScreen extends StatefulWidget {
  const BreakdownScreen({super.key});

  @override
  State<BreakdownScreen> createState() => _BreakdownScreenState();
}

class _BreakdownScreenState extends State<BreakdownScreen> {
  bool isMonth = true;
  _ViewMode _viewMode = _ViewMode.expense;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final loc = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    // Filter transactions for the selected period
    final filteredTransactions = provider.transactions.where((t) {
      if (isMonth) {
        return t.date.month == currentMonth && t.date.year == currentYear;
      } else {
        return t.date.year == currentYear;
      }
    }).toList();

    // Expense calculations
    final totalExpense = filteredTransactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);

    final categoryExpenseTotals = <String, double>{};
    for (var t in filteredTransactions.where((t) => t.type == 'expense')) {
      categoryExpenseTotals[t.category] =
          (categoryExpenseTotals[t.category] ?? 0.0) + t.amount;
    }
    final sortedExpenseCategories = categoryExpenseTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Income calculations
    final totalIncome = filteredTransactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);

    final categoryIncomeTotals = <String, double>{};
    for (var t in filteredTransactions.where((t) => t.type == 'income')) {
      categoryIncomeTotals[t.category] =
          (categoryIncomeTotals[t.category] ?? 0.0) + t.amount;
    }
    final sortedIncomeCategories = categoryIncomeTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Stats
    final daysInPeriod = isMonth
        ? DateTime(currentYear, currentMonth + 1, 0).day
        : 365;
    final daysPassed = isMonth
        ? now.day
        : now.difference(DateTime(currentYear, 1, 1)).inDays + 1;
    final dailyAverage = daysPassed > 0 ? totalExpense / daysPassed : 0.0;
    final projected = dailyAverage * daysInPeriod;
    final cap = isMonth ? provider.monthlyCap : provider.monthlyCap * 12;
    final savings = cap - totalExpense;
    final hasSavings = savings > 0 && cap > 0;

    final neo = NeoTheme.of(context);
    return Scaffold(
      backgroundColor: neo.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, loc),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: ListView(
                    padding: const EdgeInsets.only(
                      top: 24,
                      bottom: 100,
                      left: 16,
                      right: 16,
                    ),
                    children: [
                      // ── View mode tabs (Expense / Income) ──────────────
                      _buildViewModeToggle(context, loc),
                      const SizedBox(height: 24),

                      if (_viewMode == _ViewMode.expense) ...[
                        // ── Total Blown ────────────────────────────────
                        _buildTotalAmount(
                          context,
                          provider,
                          isMonth ? loc.totalBlown : loc.totalBlownYear,
                          totalExpense,
                          NeoColors.primary,
                        ),
                        const SizedBox(height: 16),

                        // ── Stats card ─────────────────────────────────
                        _buildStatsCard(
                          context,
                          loc,
                          provider,
                          dailyAverage,
                          projected,
                          cap,
                        ),
                        const SizedBox(height: 24),

                        if (sortedExpenseCategories.isNotEmpty) ...[
                          _buildPizzaChart(
                            sortedExpenseCategories,
                            totalExpense,
                          ),
                          const SizedBox(height: 24),
                          _buildLegend(context, sortedExpenseCategories),
                        ] else ...[
                          _buildEmptyState(context, loc.noExpenses),
                        ],

                        // ── Savings zone ───────────────────────────────
                        if (hasSavings &&
                            sortedExpenseCategories.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildSavingsZoneCard(
                            context,
                            loc,
                            provider,
                            savings,
                          ),
                        ],

                        const SizedBox(height: 32),
                        _buildSectionTitle(context, loc.spendingZones),
                        const SizedBox(height: 16),
                        ...sortedExpenseCategories.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildCategoryCard(
                              context,
                              loc,
                              provider,
                              entry.key,
                              loc.expense,
                              entry.value,
                              cap,
                              CategoryUtils.getCategoryColor(entry.key),
                              CategoryUtils.getCategoryIcon(entry.key),
                              neo.surface,
                            ),
                          );
                        }),
                      ] else ...[
                        // ── Total Income ───────────────────────────────
                        _buildTotalAmount(
                          context,
                          provider,
                          loc.totalIncome,
                          totalIncome,
                          Colors.green.shade400,
                        ),
                        const SizedBox(height: 24),

                        if (sortedIncomeCategories.isNotEmpty) ...[
                          _buildPizzaChart(
                            sortedIncomeCategories,
                            totalIncome,
                            isIncome: true,
                          ),
                          const SizedBox(height: 24),
                          _buildLegend(
                            context,
                            sortedIncomeCategories,
                            isIncome: true,
                          ),
                        ] else ...[
                          _buildEmptyState(context, loc.noIncome),
                        ],

                        const SizedBox(height: 32),
                        _buildSectionTitle(context, loc.incomeZones),
                        const SizedBox(height: 16),
                        ...sortedIncomeCategories.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildCategoryCard(
                              context,
                              loc,
                              provider,
                              entry.key,
                              loc.income,
                              entry.value,
                              totalIncome,
                              CategoryUtils.getCategoryColor(entry.key),
                              CategoryUtils.getCategoryIcon(entry.key),
                              neo.surface,
                              isIncome: true,
                            ),
                          );
                        }),
                      ],

                      const SizedBox(height: 16),
                      _buildDigDeeper(context, loc),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations loc) {
    final neo = NeoTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: neo.background,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              color: neo.ink,
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Text(
                loc.breakdown,
                style: NeoTypography.textTheme.displayMedium?.copyWith(
                  letterSpacing: -1,
                  fontSize: 28,
                  height: 1,
                ),
              ),
                NeoButton(
                padding: const EdgeInsets.all(8),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.calendarComingSoon)),
                  );
                },
                child: const Icon(Icons.calendar_month, size: 28),
              ),
                ],
              ),
            ),
          ],
          ),
          const SizedBox(height: 24),

          // Month / Year period toggle
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isMonth = true),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isMonth ? NeoColors.primary : neo.surface,
                      border: Border.all(color: neo.ink, width: 3),
                      boxShadow: [
                        BoxShadow(color: neo.ink, offset: const Offset(4, 4)),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      loc.month,
                      style: NeoTypography.textTheme.titleMedium?.copyWith(
                        color: isMonth ? NeoColors.ink : neo.textMain,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isMonth = false),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: !isMonth ? NeoColors.primary : neo.surface,
                      border: Border(
                        top: BorderSide(color: neo.ink, width: 3),
                        bottom: BorderSide(color: neo.ink, width: 3),
                        right: BorderSide(color: neo.ink, width: 3),
                      ),
                      boxShadow: [
                        BoxShadow(color: neo.ink, offset: const Offset(4, 4)),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      loc.year,
                      style: NeoTypography.textTheme.titleMedium?.copyWith(
                        color: !isMonth ? NeoColors.ink : neo.textMain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── View Mode Toggle (Expense / Income) ───────────────────────────────────

  Widget _buildViewModeToggle(BuildContext context, AppLocalizations loc) {
    final neo = NeoTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _viewMode = _ViewMode.expense),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: _viewMode == _ViewMode.expense
                    ? NeoColors.ink
                    : neo.surface,
                border: Border.all(color: neo.ink, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                loc.expense,
                style: NeoTypography.mono.copyWith(
                  color: _viewMode == _ViewMode.expense
                      ? NeoColors.primary
                      : neo.textMain,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _viewMode = _ViewMode.income),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: _viewMode == _ViewMode.income
                    ? NeoColors.ink
                    : neo.surface,
                border: Border(
                  top: BorderSide(color: neo.ink, width: 2),
                  bottom: BorderSide(color: neo.ink, width: 2),
                  right: BorderSide(color: neo.ink, width: 2),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                loc.income,
                style: NeoTypography.mono.copyWith(
                  color: _viewMode == _ViewMode.income
                      ? NeoColors.success
                      : neo.textMain,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Total Amount Display ──────────────────────────────────────────────────

  Widget _buildTotalAmount(
    BuildContext context,
    AppProvider provider,
    String label,
    double amount,
    Color highlightColor,
  ) {
    final neo = NeoTheme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: NeoTypography.mono.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 2,
            color: neo.textSub,
          ),
        ),
        const SizedBox(height: 8),
        Transform.rotate(
          angle: -0.05,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: NeoColors.ink,
              border: Border.all(color: neo.ink, width: 3),
              boxShadow: [
                BoxShadow(color: neo.ink, offset: const Offset(4, 4)),
              ],
            ),
            child: Text(
              '${provider.currencySymbol}${_formatCurrency(amount)}',
              style: NeoTypography.numbers.copyWith(
                color: highlightColor,
                fontSize: 32,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Stats Card ────────────────────────────────────────────────────────────

  Widget _buildStatsCard(
    BuildContext context,
    AppLocalizations loc,
    AppProvider provider,
    double dailyAverage,
    double projected,
    double cap,
  ) {
    final neo = NeoTheme.of(context);
    final sym = provider.currencySymbol;
    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              loc.dailyAverage,
              '$sym${_formatCurrency(dailyAverage)}',
              Icons.today,
              neo.textMain,
              neo,
            ),
          ),
          Container(width: 3, height: 48, color: neo.inkOnCard),
          Expanded(
            child: _buildStatItem(
              loc.projected,
              '$sym${_formatCurrency(projected)}',
              Icons.trending_up,
              projected > cap && cap > 0 ? neo.error : NeoColors.success,
              neo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color valueColor,
    NeoThemeData neo,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: neo.textSub),
              const SizedBox(width: 4),
              Text(
                label,
                style: NeoTypography.mono.copyWith(
                  fontSize: 10,
                  color: neo.textSub,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: NeoTypography.numbers.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Pizza Chart ───────────────────────────────────────────────────────────

  Widget _buildPizzaChart(
    List<MapEntry<String, double>> data,
    double totalAmount, {
    bool isIncome = false,
  }) {
    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(200, 200),
            painter: PizzaChartPainter(
              data,
              totalAmount,
              isIncome: isIncome,
              inkColor: NeoTheme.of(context).ink,
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: NeoTheme.of(context).background,
              shape: BoxShape.circle,
              border: Border.all(color: NeoTheme.of(context).ink, width: 3),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.pie_chart,
              size: 32,
              color: NeoTheme.of(context).ink,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Legend ────────────────────────────────────────────────────────────────

  Widget _buildLegend(
    BuildContext context,
    List<MapEntry<String, double>> data, {
    bool isIncome = false,
  }) {
    final topData = data.take(4).toList();
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: topData.map((e) {
        return _buildLegendItem(
          context,
          CategoryUtils.getCategoryColor(e.key),
          e.key,
        );
      }).toList(),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    final neo = NeoTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: neo.ink, width: 3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: NeoTypography.mono.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: neo.textMain,
          ),
        ),
      ],
    );
  }

  // ─── Empty State ───────────────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context, String message) {
    final neo = NeoTheme.of(context);
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: neo.textSub),
          const SizedBox(height: 12),
          Text(
            '$message...',
            style: NeoTypography.mono.copyWith(color: neo.textSub),
          ),
        ],
      ),
    );
  }

  // ─── Section Title ─────────────────────────────────────────────────────────

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: NeoTypography.textTheme.titleLarge?.copyWith(
            fontSize: 20,
            color: NeoTheme.of(context).textMain,
          ),
        ),
        Container(width: 160, height: 3, color: NeoTheme.of(context).ink),
      ],
    );
  }

  // ─── Savings Zone Card ─────────────────────────────────────────────────────

  Widget _buildSavingsZoneCard(
    BuildContext context,
    AppLocalizations loc,
    AppProvider provider,
    double savings,
  ) {
    final neo = NeoTheme.of(context);
    return NeoCard(
      backgroundColor: neo.surface,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.shade400,
              border: Border.all(color: NeoColors.ink, width: 3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.savings, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.goodJob,
                  style: NeoTypography.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    height: 1,
                  ),
                ),
                Text(
                  loc.goodJobDesc,
                  style: NeoTypography.mono.copyWith(
                    fontSize: 11,
                    color: neo.textSub,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${provider.currencySymbol}${_formatCurrency(savings)}',
            style: NeoTypography.numbers.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: NeoColors.success,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Category Card ─────────────────────────────────────────────────────────

  Widget _buildCategoryCard(
    BuildContext context,
    AppLocalizations loc,
    AppProvider provider,
    String title,
    String subtitle,
    double spent,
    double limit,
    Color iconBg,
    IconData icon,
    Color bg, {
    bool isIncome = false,
  }) {
    final neo = NeoTheme.of(context);
    final percent = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final isViolation = !isIncome && spent > limit && limit > 0;
    final cardBg = isViolation ? neo.error : bg;
    final titleColor = isViolation ? Colors.white : neo.textMain;
    final subtitleColor = isViolation ? Colors.white70 : neo.textSub;
    final valueColor = isViolation ? Colors.white : neo.textMain;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        NeoCard(
          backgroundColor: cardBg,
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: iconBg,
                          border: Border.all(color: neo.ink, width: 3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(icon, color: neo.ink),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: NeoTypography.textTheme.titleMedium
                                ?.copyWith(
                                  fontSize: 18,
                                  height: 1,
                                  color: titleColor,
                                ),
                          ),
                          Text(
                            subtitle,
                            style: NeoTypography.mono.copyWith(
                              fontSize: 12,
                              color: subtitleColor,
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1,
                          color: valueColor,
                        ),
                      ),
                      if (!isIncome)
                        Text(
                          '${loc.left} ${provider.currencySymbol}${_formatCurrency(limit - spent > 0 ? limit - spent : 0)}',
                          style: NeoTypography.mono.copyWith(
                            fontSize: 12,
                            color: subtitleColor,
                          ),
                        ),
                      if (isIncome)
                        Text(
                          '${(spent / (limit > 0 ? limit : spent) * 100).toStringAsFixed(1)}%',
                          style: NeoTypography.mono.copyWith(
                            fontSize: 12,
                            color: NeoColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isViolation ? neo.ink : neo.surface,
                  border: Border.all(color: neo.ink, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isIncome ? Colors.green.shade400 : iconBg,
                      border: Border(
                        right: BorderSide(color: neo.ink, width: 3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (isViolation) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'YOU ARE ${provider.currencySymbol}${_formatCurrency(spent - limit)} ${loc.overLimit}.',
                        style: NeoTypography.mono.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (isViolation)
          Positioned(
            right: -8,
            top: 16,
            child: Transform.rotate(
              angle: 0.785398, // 45 degrees
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

  // ─── Dig Deeper ────────────────────────────────────────────────────────────

  Widget _buildDigDeeper(BuildContext context, AppLocalizations loc) {
    final neo = NeoTheme.of(context);
    return Column(
      children: [
        Icon(Icons.expand_more, size: 40, color: neo.textSub),
        Text(
          loc.digDeeper,
          style: NeoTypography.mono.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: neo.textSub,
          ),
        ),
      ],
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

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

// ─── Pie Chart Painter ────────────────────────────────────────────────────────

class PizzaChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> data;
  final double totalAmount;
  final bool isIncome;
  final Color inkColor;

  PizzaChartPainter(
    this.data,
    this.totalAmount, {
    this.isIncome = false,
    required this.inkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width,
      height: size.height,
    );

    final fillPaint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = inkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    double startAngle = -math.pi / 2;

    for (var entry in data) {
      if (totalAmount == 0) continue;
      double sweepAngle = 2 * math.pi * (entry.value / totalAmount);
      fillPaint.color = isIncome
          ? CategoryUtils.getCategoryColor(entry.key).withValues(alpha: 0.8)
          : CategoryUtils.getCategoryColor(entry.key);
      canvas.drawArc(rect, startAngle, sweepAngle, true, fillPaint);
      canvas.drawArc(rect, startAngle, sweepAngle, true, borderPaint);
      startAngle += sweepAngle;
    }

    final path = Path()..addArc(rect, 0, 2 * math.pi);
    canvas.drawShadow(path, inkColor, 4, true);
  }

  @override
  bool shouldRepaint(covariant PizzaChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.totalAmount != totalAmount ||
        oldDelegate.isIncome != isIncome;
  }
}
