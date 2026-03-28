import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';
import '../providers/app_provider.dart';
import '../utils/category_utils.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = '6months'; // '6months', '12months'
  String _selectedChart = 'trend'; // 'trend', 'incomeVsExpense', 'categories'

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
            _buildPeriodSelector(context, neo, loc),
            _buildChartTypeSelector(context, neo, loc),
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, child) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildMainChart(context, provider, neo, loc),
                        const SizedBox(height: 16),
                        _buildSummaryCards(context, provider, neo, loc),
                        const SizedBox(height: 16),
                        _buildCategoryBreakdown(context, provider, neo, loc),
                      ],
                    ),
                  );
                },
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
              loc.statistics,
              style: NeoTypography.textTheme.displayMedium?.copyWith(
                fontStyle: FontStyle.italic,
                letterSpacing: -1,
                color: neo.textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, NeoThemeData neo, AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            '${loc.period}: ',
            style: NeoTypography.mono.copyWith(
              fontWeight: FontWeight.bold,
              color: neo.textSub,
            ),
          ),
          const SizedBox(width: 8),
          _buildPeriodChip(context, loc.last6Months, '6months'),
          const SizedBox(width: 8),
          _buildPeriodChip(context, loc.last12Months, '12months'),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(BuildContext context, String label, String value) {
    final neo = NeoTheme.of(context);
    final isSelected = _selectedPeriod == value;

    return NeoButton(
      backgroundColor: isSelected ? NeoColors.primary : neo.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onPressed: () {
        setState(() {
          _selectedPeriod = value;
        });
      },
      child: Text(
        label,
        style: NeoTypography.mono.copyWith(
          fontWeight: FontWeight.bold,
          color: isSelected ? NeoColors.ink : neo.textMain,
        ),
      ),
    );
  }

  Widget _buildChartTypeSelector(BuildContext context, NeoThemeData neo, AppLocalizations loc) {
    final charts = [
      {'value': 'trend', 'label': loc.spendingTrend, 'icon': Icons.show_chart},
      {'value': 'incomeVsExpense', 'label': loc.incomeVsExpense, 'icon': Icons.bar_chart},
      {'value': 'categories', 'label': loc.topCategories, 'icon': Icons.pie_chart},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: charts.map((chart) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildChartTypeChip(
              context,
              chart['label'] as String,
              chart['value'] as String,
              chart['icon'] as IconData,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartTypeChip(BuildContext context, String label, String value, IconData icon) {
    final neo = NeoTheme.of(context);
    final isSelected = _selectedChart == value;

    return NeoButton(
      backgroundColor: isSelected ? NeoColors.secondary : neo.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onPressed: () {
        setState(() {
          _selectedChart = value;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : neo.textMain),
          const SizedBox(width: 8),
          Text(
            label,
            style: NeoTypography.mono.copyWith(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : neo.textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainChart(
    BuildContext context,
    AppProvider provider,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    switch (_selectedChart) {
      case 'trend':
        return _buildTrendChart(context, provider, neo, loc);
      case 'incomeVsExpense':
        return _buildIncomeVsExpenseChart(context, provider, neo, loc);
      case 'categories':
        return _buildCategoriesChart(context, provider, neo, loc);
      default:
        return _buildTrendChart(context, provider, neo, loc);
    }
  }

  Widget _buildTrendChart(
    BuildContext context,
    AppProvider provider,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    final data = _getTrendData(provider.transactions);

    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.spendingTrend,
            style: NeoTypography.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: neo.textMain,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _calculateHorizontalInterval(data),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: neo.ink.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              data[value.toInt()].label,
                              style: NeoTypography.mono.copyWith(
                                fontSize: 10,
                                color: neo.textSub,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      interval: _calculateInterval(data.length),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '${provider.currencySymbol}${value.toInt()}',
                            style: NeoTypography.mono.copyWith(
                              fontSize: 10,
                              color: neo.textSub,
                            ),
                          ),
                        );
                      },
                      reservedSize: 50,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: 0,
                maxY: _calculateMaxY(data),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.amount);
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        NeoColors.secondary.withValues(alpha: 0.8),
                        NeoColors.secondary,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: NeoColors.secondary,
                          strokeWidth: 2,
                          strokeColor: neo.background,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          NeoColors.secondary.withValues(alpha: 0.3),
                          NeoColors.secondary.withValues(alpha: 0.0),
                        ],
                      ),
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

  Widget _buildIncomeVsExpenseChart(
    BuildContext context,
    AppProvider provider,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    final data = _getIncomeVsExpenseData(provider.transactions);

    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.incomeVsExpense,
            style: NeoTypography.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: neo.textMain,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              data[value.toInt()].label,
                              style: NeoTypography.mono.copyWith(
                                fontSize: 10,
                                color: neo.textSub,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      interval: _calculateInterval(data.length),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '${provider.currencySymbol}${value.toInt()}',
                            style: NeoTypography.mono.copyWith(
                              fontSize: 10,
                              color: neo.textSub,
                            ),
                          ),
                        );
                      },
                      reservedSize: 50,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.income,
                        color: NeoColors.success,
                        width: 12,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: entry.value.expense,
                        color: NeoColors.secondary,
                        width: 12,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(context, NeoColors.success, loc.income),
              const SizedBox(width: 24),
              _buildLegend(context, NeoColors.secondary, loc.expense),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesChart(
    BuildContext context,
    AppProvider provider,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    final data = _getCategoriesData(provider.transactions);

    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.topCategories,
            style: NeoTypography.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: neo.textMain,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: data.asMap().entries.map((entry) {
                  final value = entry.value;
                  return PieChartSectionData(
                    color: value.color,
                    value: value.amount,
                    title: '${value.percentage.toStringAsFixed(0)}%',
                    radius: 80,
                    titleStyle: NeoTypography.mono.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...data.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: item.color,
                      border: Border.all(color: neo.ink, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.category,
                      style: NeoTypography.textTheme.bodyMedium?.copyWith(
                        color: neo.textMain,
                      ),
                    ),
                  ),
                  Text(
                    '${provider.currencySymbol}${item.amount.toStringAsFixed(0)}',
                    style: NeoTypography.mono.copyWith(
                      fontWeight: FontWeight.bold,
                      color: neo.textMain,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    AppProvider provider,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    final avgSpending = _calculateAverageSpending(provider.transactions);
    final monthOverMonth = _calculateMonthOverMonthChange(provider.transactions);

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            loc.averageSpending,
            '${provider.currencySymbol}${avgSpending.toStringAsFixed(0)}',
            Icons.trending_up,
            neo,
            loc.month,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            context,
            loc.monthOverMonth,
            monthOverMonth >= 0 ? '+${monthOverMonth.toStringAsFixed(0)}%' : '${monthOverMonth.toStringAsFixed(0)}%',
            monthOverMonth >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
            neo,
            '',
            color: monthOverMonth >= 0 ? NeoColors.success : NeoColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    NeoThemeData neo,
    String subtitle,
    {Color? color}
  ) {
    final displayColor = color ?? NeoColors.primary;

    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: displayColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: NeoTypography.mono.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: neo.textSub,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: NeoTypography.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: displayColor,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: NeoTypography.mono.copyWith(
                fontSize: 10,
                color: neo.textSub,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    BuildContext context,
    AppProvider provider,
    NeoThemeData neo,
    AppLocalizations loc,
  ) {
    final data = _getCategoriesData(provider.transactions);

    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${loc.topCategories} ${loc.breakdown}',
            style: NeoTypography.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: neo.textMain,
            ),
          ),
          const SizedBox(height: 16),
          ...data.asMap().entries.map((entry) {
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CategoryUtils.getCategoryIcon(item.category),
                            size: 16,
                            color: item.color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.category,
                            style: NeoTypography.textTheme.bodyMedium?.copyWith(
                              color: neo.textMain,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${provider.currencySymbol}${item.amount.toStringAsFixed(0)}',
                        style: NeoTypography.mono.copyWith(
                          fontWeight: FontWeight.bold,
                          color: neo.textMain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: item.amount / data[0].amount,
                      backgroundColor: neo.ink.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(item.color),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: NeoTypography.mono.copyWith(
            fontSize: 12,
            color: NeoTheme.of(context).textMain,
          ),
        ),
      ],
    );
  }

  // Data calculation methods

  List<_TrendDataPoint> _getTrendData(List transactions) {
    final months = _selectedPeriod == '6months' ? 6 : 12;
    final now = DateTime.now();
    final data = <_TrendDataPoint>[];

    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);

      final monthTransactions = transactions.where((t) {
        return t.date.isAfter(month.subtract(const Duration(days: 1))) &&
               t.date.isBefore(nextMonth);
      }).toList();

      final totalSpending = monthTransactions
          .where((t) => t.type == 'expense')
          .fold<double>(0, (sum, t) => sum + t.amount);

      final monthLabel = DateFormat('MMM').format(month);
      data.add(_TrendDataPoint(monthLabel, totalSpending));
    }

    return data;
  }

  List<_IncomeVsExpenseDataPoint> _getIncomeVsExpenseData(List transactions) {
    final months = _selectedPeriod == '6months' ? 6 : 12;
    final now = DateTime.now();
    final data = <_IncomeVsExpenseDataPoint>[];

    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);

      final monthTransactions = transactions.where((t) {
        return t.date.isAfter(month.subtract(const Duration(days: 1))) &&
               t.date.isBefore(nextMonth);
      }).toList();

      final income = monthTransactions
          .where((t) => t.type == 'income')
          .fold<double>(0, (sum, t) => sum + t.amount);

      final expense = monthTransactions
          .where((t) => t.type == 'expense')
          .fold<double>(0, (sum, t) => sum + t.amount);

      final monthLabel = DateFormat('MMM').format(month);
      data.add(_IncomeVsExpenseDataPoint(monthLabel, income, expense));
    }

    return data;
  }

  List<_CategoryDataPoint> _getCategoriesData(List transactions) {
    final months = _selectedPeriod == '6months' ? 6 : 12;
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - months, 1);

    final categoryTotals = <String, double>{};

    for (final t in transactions) {
      if (t.type == 'expense' && t.date.isAfter(startDate)) {
        categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
      }
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = sortedEntries.fold<double>(0.0, (sum, e) => sum + e.value);

    return sortedEntries.take(6).map((entry) {
      final percentage = total > 0 ? (entry.value / total) * 100 : 0.0;
      return _CategoryDataPoint(
        entry.key,
        entry.value,
        CategoryUtils.getCategoryColor(entry.key),
        percentage,
      );
    }).toList();
  }

  double _calculateAverageSpending(List transactions) {
    final months = _selectedPeriod == '6months' ? 6 : 12;
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - months, 1);

    final totalSpending = transactions
        .where((t) => t.type == 'expense' && t.date.isAfter(startDate))
        .fold<double>(0, (sum, t) => sum + t.amount);

    return totalSpending / months;
  }

  double _calculateMonthOverMonthChange(List transactions) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);

    final thisMonthSpending = transactions
        .where((t) => t.type == 'expense' && t.date.isAfter(thisMonth.subtract(const Duration(days: 1))))
        .fold<double>(0, (sum, t) => sum + t.amount);

    final lastMonthSpending = transactions
        .where((t) => t.type == 'expense' &&
               t.date.isAfter(lastMonth.subtract(const Duration(days: 1))) &&
               t.date.isBefore(thisMonth))
        .fold<double>(0, (sum, t) => sum + t.amount);

    if (lastMonthSpending == 0) return 0;
    return ((thisMonthSpending - lastMonthSpending) / lastMonthSpending) * 100;
  }

  double _calculateMaxY(List<_TrendDataPoint> data) {
    if (data.isEmpty) return 100;
    final maxValue = data.map((d) => d.amount).reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.2).ceilToDouble();
  }

  double _calculateHorizontalInterval(List<_TrendDataPoint> data) {
    final maxY = _calculateMaxY(data);
    final interval = maxY / 4;
    // Ensure interval is never zero or negative
    return interval > 0 ? interval : 25;
  }

  double _calculateInterval(int length) {
    if (length <= 6) return 1;
    return (length / 6).ceilToDouble();
  }
}

class _TrendDataPoint {
  final String label;
  final double amount;

  _TrendDataPoint(this.label, this.amount);
}

class _IncomeVsExpenseDataPoint {
  final String label;
  final double income;
  final double expense;

  _IncomeVsExpenseDataPoint(this.label, this.income, this.expense);
}

class _CategoryDataPoint {
  final String category;
  final double amount;
  final Color color;
  final double percentage;

  _CategoryDataPoint(this.category, this.amount, this.color, this.percentage);
}
