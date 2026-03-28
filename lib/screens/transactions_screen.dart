import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../widgets/neo_button.dart';
import '../providers/app_provider.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';
import '../utils/category_utils.dart';
import 'search_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedType = 'ALL'; // 'ALL', 'INCOME', 'EXPENSE'
  List<String> _selectedCategories = [];

  String _formatCurrency(double amount, String symbol) {
    String numStr = amount.abs().toStringAsFixed(0);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    numStr = numStr.replaceAllMapped(reg, (Match m) => '${m[1]},');
    return '${amount < 0 ? "-" : ""}$symbol$numStr';
  }

  @override
  Widget build(BuildContext context) {
    final neo = NeoTheme.of(context);
    return Scaffold(
      backgroundColor: neo.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, neo),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(
                  top: 24,
                  bottom: 100,
                  left: 16,
                  right: 16,
                ),
                children: [_buildReceiptContainer(context, neo)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NeoThemeData neo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: neo.surface,
        border: Border(bottom: BorderSide(color: neo.ink, width: 3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Transform.rotate(
            angle: -0.05,
            child: Text(
              AppLocalizations.of(context)!.paperTrail,
              style: NeoTypography.textTheme.headlineMedium?.copyWith(
                fontStyle: FontStyle.italic,
                letterSpacing: -1,
                color: neo.textMain,
              ),
            ),
          ),
          Row(
            children: [
              NeoButton(
                padding: const EdgeInsets.all(8),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                  );
                },
                child: Icon(Icons.search, size: 24, color: neo.textMain),
              ),
              const SizedBox(width: 8),
              NeoButton(
                padding: const EdgeInsets.all(8),
                onPressed: () {
                  _showFilterBottomSheet(context);
                },
                child: Icon(Icons.filter_alt, size: 24, color: neo.textMain),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptContainer(BuildContext context, NeoThemeData neo) {
    final provider = context.watch<AppProvider>();
    final allTxs = provider.transactions;

    final txs = allTxs.where((tx) {
      if (_selectedType != 'ALL' && tx.type.toUpperCase() != _selectedType) {
        return false;
      }
      if (_selectedCategories.isNotEmpty &&
          !_selectedCategories.contains(tx.category)) {
        return false;
      }
      return true;
    }).toList();

    List<Widget> receiptItems = [];
    receiptItems.add(_buildReceiptHeader(context, neo));

    if (txs.isEmpty) {
      receiptItems.add(
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            AppLocalizations.of(context)!.noRegretsYet,
            style: NeoTypography.mono.copyWith(
              color: neo.textSub,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else {
      String lastDateStr = '';
      for (int i = 0; i < txs.length; i++) {
        final tx = txs[i];
        final isLast = i == txs.length - 1;

        final dateStr = '${tx.date.year}-${tx.date.month}-${tx.date.day}';

        if (dateStr != lastDateStr) {
          final now = DateTime.now();
          final isToday =
              tx.date.year == now.year &&
              tx.date.month == now.month &&
              tx.date.day == now.day;

          final yesterday = now.subtract(const Duration(days: 1));
          final isYesterday =
              tx.date.year == yesterday.year &&
              tx.date.month == yesterday.month &&
              tx.date.day == yesterday.day;

          final months = [
            'JAN',
            'FEB',
            'MAR',
            'APR',
            'MAY',
            'JUN',
            'JUL',
            'AUG',
            'SEP',
            'OCT',
            'NOV',
            'DEC',
          ];
          String mainText = isToday
              ? AppLocalizations.of(context)!.today
              : isYesterday
              ? AppLocalizations.of(context)!.yesterday
              : '${months[tx.date.month - 1]} ${tx.date.day}';
          String subText = isToday || isYesterday
              ? '${months[tx.date.month - 1]} ${tx.date.day}'
              : '${tx.date.year}';

          receiptItems.add(_buildDateSeparator(mainText, subText));
          lastDateStr = dateStr;
        }

        receiptItems.add(
          _buildTransactionItem(
            CategoryUtils.getCategoryIcon(tx.category),
            CategoryUtils.getCategoryColor(tx.category),
            tx.title.isNotEmpty ? tx.title : tx.category,
            '${tx.category} • ${tx.date.hour}:${tx.date.minute.toString().padLeft(2, '0')}',
            '${tx.type == 'income' ? "+" : "-"}${_formatCurrency(tx.amount, provider.currencySymbol)}',
            tx.type == 'income' ? NeoColors.success : NeoColors.secondary,
            neo,
          ),
        );

        if (!isLast) {
          final nextTx = txs[i + 1];
          if (nextTx.date.year == tx.date.year &&
              nextTx.date.month == tx.date.month &&
              nextTx.date.day == tx.date.day) {
            receiptItems.add(_buildDottedDivider(neo));
          }
        }
      }
    }

    receiptItems.add(_buildEndState(context, neo));

    return Stack(
      children: [
        Positioned.fill(
          top: 8,
          left: 8,
          child: Container(
            color: NeoColors.ink,
            margin: const EdgeInsets.only(bottom: 24),
          ),
        ),
        Column(
          children: [
            Container(
              height: 16,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: const Color(0xFF1A1A1A),
            ),
            Container(
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: const Color(0xFF4A4A4A),
            ),
            Container(
              decoration: BoxDecoration(
                color: neo.surface,
                border: Border.symmetric(
                  vertical: BorderSide(color: neo.ink, width: 3),
                ),
              ),
              child: Column(children: receiptItems),
            ),
            _buildJaggedBottom(neo),
          ],
        ),
      ],
    );
  }

  Widget _buildReceiptHeader(BuildContext context, NeoThemeData neo) {
    final provider = context.watch<AppProvider>();
    final spentStr = _formatCurrency(
      provider.currentMonthSpent,
      provider.currencySymbol,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Transform.rotate(
            angle: 0.05,
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: NeoColors.primary,
                border: Border.all(color: neo.ink, width: 3),
              ),
              child: Icon(Icons.receipt_long, size: 40, color: neo.ink),
            ),
          ),
          Text(
            AppLocalizations.of(context)!.statementOfRegret,
            style: NeoTypography.mono.copyWith(
              color: neo.textSub,
              fontSize: 14,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${AppLocalizations.of(context)!.spent}: ',
                  style: NeoTypography.textTheme.headlineLarge?.copyWith(
                    fontSize: 24,
                    color: neo.textMain,
                  ),
                ),
                TextSpan(
                  text: spentStr,
                  style: NeoTypography.textTheme.headlineLarge?.copyWith(
                    fontSize: 32,
                    color: NeoColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(String mainText, String subText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: NeoColors.ink, // Black divider
        border: Border.symmetric(
          horizontal: BorderSide(color: NeoColors.ink, width: 3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '[ $mainText ]',
            style: NeoTypography.mono.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            subText,
            style: NeoTypography.mono.copyWith(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    IconData icon,
    Color bgColor,
    String title,
    String subtitle,
    String amount,
    Color amountColor,
    NeoThemeData neo,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: neo.ink, width: 3),
              boxShadow: [
                BoxShadow(color: neo.ink, offset: const Offset(2, 2)),
              ],
            ),
            child: Icon(
              icon,
              color: bgColor == NeoColors.secondary || bgColor == NeoColors.ink
                  ? Colors.white
                  : NeoColors.ink,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: NeoTypography.textTheme.titleMedium?.copyWith(
                    height: 1,
                    fontSize: 18,
                    color: neo.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: NeoTypography.mono.copyWith(
                    color: neo.textSub,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: NeoTypography.mono.copyWith(
              color: amountColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDottedDivider(NeoThemeData neo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: List.generate(
          30,
          (index) => Expanded(
            child: Container(
              height: 2,
              color: index % 2 == 0
                  ? neo.ink.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEndState(BuildContext context, NeoThemeData neo) {
    return Container(
      width: double.infinity,
      color: neo.surface,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.account_balance_wallet, size: 64, color: neo.textSub),
              Positioned(
                top: -16,
                right: -16,
                child: Transform.rotate(
                  angle: 0.2,
                  child: Icon(Icons.bug_report, size: 32, color: neo.textMain),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.endOfTheLine,
            style: NeoTypography.textTheme.titleLarge?.copyWith(
              fontSize: 20,
              color: neo.textMain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.noMoreRegrets,
            style: NeoTypography.mono.copyWith(
              color: neo.textSub,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final provider = context.read<AppProvider>();
    final allTxs = provider.transactions;
    final Set<String> allCategories = allTxs.map((e) => e.category).toSet();
    final neo = NeoTheme.of(context);

    String tempType = _selectedType;
    List<String> tempCategories = List.from(_selectedCategories);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.only(
                top: 24,
                left: 16,
                right: 16,
                bottom: 40,
              ),
              decoration: BoxDecoration(
                color: neo.surface,
                border: Border(
                  top: BorderSide(color: neo.inkOnCard, width: 4),
                  left: BorderSide(color: neo.inkOnCard, width: 4),
                  right: BorderSide(color: neo.inkOnCard, width: 4),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'FILTER TRANSACTIONS',
                          style: NeoTypography.textTheme.headlineLarge
                              ?.copyWith(fontSize: 24, color: neo.textMain),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 32,
                            color: neo.textMain,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'TYPE',
                      style: NeoTypography.mono.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: neo.textMain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: ['ALL', 'INCOME', 'EXPENSE'].map((type) {
                        final isSelected = tempType == type;
                        return GestureDetector(
                          onTap: () => setModalState(() {
                            tempType = type;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? NeoColors.primary
                                  : neo.surface,
                              border: Border.all(
                                color: neo.inkOnCard,
                                width: 3,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: neo.inkOnCard,
                                        offset: const Offset(2, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              type,
                              style: NeoTypography.mono.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? NeoColors.ink
                                    : neo.textSub, // Primary bg -> Black ink text
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'CATEGORIES',
                      style: NeoTypography.mono.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: neo.textMain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: allCategories.map((cat) {
                        final isSelected = tempCategories.contains(cat);
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                tempCategories.remove(cat);
                              } else {
                                tempCategories.add(cat);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? NeoColors.tertiary
                                  : neo.surface,
                              border: Border.all(
                                color: neo.inkOnCard,
                                width: 3,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: neo.inkOnCard,
                                        offset: const Offset(2, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              cat,
                              style: NeoTypography.mono.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? NeoColors.ink
                                    : neo.textSub, // Tertiary bg -> Black ink text
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 48),
                    Row(
                      children: [
                        Expanded(
                          child: NeoButton(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            onPressed: () {
                              setState(() {
                                _selectedType = 'ALL';
                                _selectedCategories.clear();
                              });
                              Navigator.pop(context);
                            },
                            child: Text(
                              'RESET',
                              style: NeoTypography.mono.copyWith(
                                color: NeoColors.ink,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: NeoButton(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            onPressed: () {
                              setState(() {
                                _selectedType = tempType;
                                _selectedCategories = List.from(tempCategories);
                              });
                              Navigator.pop(context);
                            },
                            child: Text(
                              'APPLY',
                              style: NeoTypography.mono.copyWith(
                                color: NeoColors.ink,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildJaggedBottom(NeoThemeData neo) {
    return SizedBox(
      height: 24,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: neo.ink, width: 3)),
            ),
          ),
          Positioned.fill(
            top: 3,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final count = (width / 20).ceil();
                return ClipRect(
                  child: OverflowBox(
                    maxWidth: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(count, (index) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.transparent,
                              child: CustomPaint(
                                painter: JaggedPainter(color: neo.surface),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class JaggedPainter extends CustomPainter {
  final Color color;
  const JaggedPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = color;
    var borderPaint = Paint()
      ..color = NeoColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);

    var strokePath = Path();
    strokePath.moveTo(0, 0);
    strokePath.lineTo(size.width / 2, size.height);
    strokePath.lineTo(size.width, 0);
    canvas.drawPath(strokePath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
