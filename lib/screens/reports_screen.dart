import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_card.dart';
import '../providers/app_provider.dart';
import '../models/transaction.dart';
import '../services/pdf_generator_service.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'monthly'; // 'monthly', 'yearly'
  DateTime _selectedDate = DateTime.now();
  bool _isGenerating = false;

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildPeriodSelector(context, neo, loc),
                    const SizedBox(height: 16),
                    _buildMonthSelector(context, neo, loc),
                    const SizedBox(height: 24),
                    _buildReportSummary(context, neo, loc),
                    const SizedBox(height: 24),
                    _buildGenerateButton(context, neo, loc),
                    const SizedBox(height: 24),
                    _buildRecentReports(context, neo, loc),
                  ],
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
              loc.reports,
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
    return Row(
      children: [
        Expanded(
          child: _buildPeriodOption(context, loc.monthlyReport, 'monthly', neo),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPeriodOption(context, loc.yearlyReport, 'yearly', neo),
        ),
      ],
    );
  }

  Widget _buildPeriodOption(BuildContext context, String label, String value, NeoThemeData neo) {
    final isSelected = _selectedPeriod == value;

    return NeoButton(
      backgroundColor: isSelected ? NeoColors.primary : neo.surface,
      padding: const EdgeInsets.symmetric(vertical: 16),
      onPressed: () {
        setState(() {
          _selectedPeriod = value;
        });
      },
      child: Column(
        children: [
          Icon(
            value == 'monthly' ? Icons.calendar_view_month : Icons.calendar_today,
            color: isSelected ? NeoColors.ink : neo.textMain,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: NeoTypography.mono.copyWith(
              fontWeight: FontWeight.bold,
              color: isSelected ? NeoColors.ink : neo.textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context, NeoThemeData neo, AppLocalizations loc) {
    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedPeriod == 'monthly' ? loc.month : loc.year,
            style: NeoTypography.mono.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: neo.textSub,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NeoButton(
                backgroundColor: neo.background,
                padding: const EdgeInsets.all(8),
                onPressed: _previousPeriod,
                child: Icon(Icons.chevron_left, color: neo.textMain),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _showDatePicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: neo.ink, width: 2),
                    ),
                    child: Text(
                      _formatPeriodDate(),
                      style: NeoTypography.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: neo.textMain,
                      ),
                    ),
                  ),
                ),
              ),
              NeoButton(
                backgroundColor: neo.background,
                padding: const EdgeInsets.all(8),
                onPressed: _nextPeriod,
                child: Icon(Icons.chevron_right, color: neo.textMain),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportSummary(BuildContext context, NeoThemeData neo, AppLocalizations loc) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final summary = _calculateSummary(provider.transactions);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.reportSummary,
              style: NeoTypography.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: neo.textMain,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    loc.reportIncome,
                    '${provider.currencySymbol}${summary.income.toStringAsFixed(0)}',
                    Icons.arrow_downward,
                    NeoColors.success,
                    neo,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    loc.reportExpense,
                    '${provider.currencySymbol}${summary.expense.toStringAsFixed(0)}',
                    Icons.arrow_upward,
                    NeoColors.secondary,
                    neo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryCard(
              context,
              loc.reportNet,
              '${provider.currencySymbol}${summary.net.toStringAsFixed(0)}',
              Icons.account_balance_wallet,
              summary.net >= 0 ? NeoColors.primary : NeoColors.error,
              neo,
              isFullWidth: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    NeoThemeData neo, {
    bool isFullWidth = false,
  }) {
    return NeoCard(
      backgroundColor: color.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: neo.ink, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: NeoColors.ink, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: NeoTypography.mono.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: neo.textSub,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: NeoTypography.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(BuildContext context, NeoThemeData neo, AppLocalizations loc) {
    return NeoButton(
      backgroundColor: NeoColors.secondary,
      padding: const EdgeInsets.symmetric(vertical: 16),
      onPressed: _isGenerating ? null : () => _generateReport(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isGenerating)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else
            const Icon(Icons.picture_as_pdf, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(
            _isGenerating ? 'GENERATING...' : loc.exportPDF,
            style: NeoTypography.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReports(BuildContext context, NeoThemeData neo, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT REPORTS',
          style: NeoTypography.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: neo.textSub,
          ),
        ),
        const SizedBox(height: 16),
        NeoCard(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.folder_open, size: 48, color: neo.textSub),
                const SizedBox(height: 12),
                Text(
                  'No reports generated yet',
                  style: NeoTypography.textTheme.bodyMedium?.copyWith(
                    color: neo.textSub,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Generate your first report above',
                  style: NeoTypography.mono.copyWith(
                    color: neo.textSub,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _previousPeriod() {
    setState(() {
      if (_selectedPeriod == 'monthly') {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
      } else {
        _selectedDate = DateTime(_selectedDate.year - 1);
      }
    });
  }

  void _nextPeriod() {
    final now = DateTime.now();
    setState(() {
      if (_selectedPeriod == 'monthly') {
        final nextMonth = DateTime(_selectedDate.year, _selectedDate.month + 1);
        if (nextMonth.isBefore(DateTime(now.year, now.month + 1))) {
          _selectedDate = nextMonth;
        }
      } else {
        final nextYear = DateTime(_selectedDate.year + 1);
        if (nextYear.year <= now.year) {
          _selectedDate = nextYear;
        }
      }
    });
  }

  Future<void> _showDatePicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatPeriodDate() {
    if (_selectedPeriod == 'monthly') {
      return DateFormat('MMMM yyyy').format(_selectedDate);
    } else {
      return '${_selectedDate.year}';
    }
  }

  _ReportSummary _calculateSummary(List<TransactionModel> transactions) {
    DateTime startDate;
    DateTime endDate;

    if (_selectedPeriod == 'monthly') {
      startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
      endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    } else {
      startDate = DateTime(_selectedDate.year, 1, 1);
      endDate = DateTime(_selectedDate.year + 1, 1, 1);
    }

    final periodTransactions = transactions.where((t) {
      return t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             t.date.isBefore(endDate);
    }).toList();

    final income = periodTransactions
        .where((t) => t.type == 'income')
        .fold<double>(0, (sum, t) => sum + t.amount);

    final expense = periodTransactions
        .where((t) => t.type == 'expense')
        .fold<double>(0, (sum, t) => sum + t.amount);

    return _ReportSummary(
      income: income,
      expense: expense,
      net: income - expense,
    );
  }

  Future<void> _generateReport() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final provider = context.read<AppProvider>();
      final summary = _calculateSummary(provider.transactions);

      // Get transactions for the period
      DateTime startDate;
      DateTime endDate;

      if (_selectedPeriod == 'monthly') {
        startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
        endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
      } else {
        startDate = DateTime(_selectedDate.year, 1, 1);
        endDate = DateTime(_selectedDate.year + 1, 1, 1);
      }

      final periodTransactions = provider.transactions.where((t) {
        return t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
               t.date.isBefore(endDate);
      }).toList();

      // Generate PDF
      final pdfService = PdfGeneratorService();
      final pdfData = await pdfService.generateReport(
        period: _formatPeriodDate(),
        income: summary.income,
        expense: summary.expense,
        net: summary.net,
        transactions: periodTransactions,
        currencySymbol: provider.currencySymbol,
      );

      if (mounted) {
        _showShareOptions(pdfData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _showShareOptions(List<int> pdfData) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: neo.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: neo.ink, width: 3),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              loc.shareReport,
              style: NeoTypography.textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            _buildShareOption(
              context,
              Icons.save_alt,
              'Save to Files',
              () async {
                // In a real app, you would save the PDF to device storage
                // For now, just show a success message
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Report saved successfully'),
                    backgroundColor: NeoColors.success,
                  ),
                );
              },
              neo,
            ),
            const SizedBox(height: 12),
            _buildShareOption(
              context,
              Icons.share,
              'Share',
              () async {
                // In a real app, you would use share_plus package to share
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Share feature coming soon'),
                  ),
                );
              },
              neo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
    NeoThemeData neo,
  ) {
    return NeoButton(
      backgroundColor: neo.background,
      padding: const EdgeInsets.symmetric(vertical: 16),
      onPressed: onTap,
      child: Row(
        children: [
          Icon(icon, color: neo.textMain),
          const SizedBox(width: 16),
          Text(
            label,
            style: NeoTypography.textTheme.titleMedium?.copyWith(
              color: neo.textMain,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportSummary {
  final double income;
  final double expense;
  final double net;

  _ReportSummary({
    required this.income,
    required this.expense,
    required this.net,
  });
}
