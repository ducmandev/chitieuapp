import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../providers/app_provider.dart';
import '../models/transaction.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';
import '../app_config.dart';
import '../utils/category_utils.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context, neo)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildWelcomeSection(context, neo),
                      const SizedBox(height: 24),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildNetWorthSection(context, neo),
                            ),
                            const SizedBox(width: 24),
                            Expanded(child: _buildMonthlyCap(context, neo)),
                          ],
                        )
                      else ...[
                        _buildNetWorthSection(context, neo),
                        const SizedBox(height: 24),
                        _buildMonthlyCap(context, neo),
                      ],
                      const SizedBox(height: 32),
                      _buildLatestRegrets(context, neo),
                      const SizedBox(height: 80),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NeoThemeData neo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: neo.background,
        border: Border(bottom: BorderSide(color: neo.ink, width: 3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: NeoColors.primary,
                  border: Border.all(color: neo.ink, width: 2),
                  boxShadow: [
                    BoxShadow(color: neo.ink, offset: const Offset(2, 2)),
                  ],
                ),
                child: const Icon(Icons.attach_money, size: 28),
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.appTitle.toUpperCase(),
                style: NeoTypography.textTheme.displaySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  letterSpacing: -1.5,
                  color: neo.textMain,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: neo.ink,
                child: Text(
                  AppConfig.displayVersion,
                  style: NeoTypography.mono.copyWith(
                    color: neo.background,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () async {
                  await context.read<AppProvider>().logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: neo.surface,
                    border: Border.all(color: neo.ink, width: 2),
                    boxShadow: [
                      BoxShadow(color: neo.ink, offset: const Offset(2, 2)),
                    ],
                  ),
                  child: Icon(Icons.logout, color: neo.textMain),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, NeoThemeData neo) {
    final provider = context.watch<AppProvider>();
    final username =
        provider.username?.toUpperCase() ??
        AppLocalizations.of(context)!.debtor.toUpperCase();

    final now = DateTime.now();
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
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final dateStr =
        '${months[now.month - 1]} ${now.day} // ${days[now.weekday - 1]}';
    final isBroke = provider.netWorth < 0;

    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: neo.ink, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    username,
                    style: NeoTypography.mono.copyWith(
                      color: neo.textSub,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    dateStr,
                    style: NeoTypography.mono.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: neo.textMain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Transform.rotate(
              angle: -0.05,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isBroke ? neo.error : NeoColors.success,
                  border: Border.all(color: neo.ink),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isBroke
                        ? AppLocalizations.of(context)!.statusBroke
                        : AppLocalizations.of(context)!.statusBallin,
                    style: NeoTypography.mono.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetWorthSection(BuildContext context, NeoThemeData neo) {
    final provider = context.watch<AppProvider>();
    final nwStr = _formatCurrency(provider.netWorth, provider.currencySymbol);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Dotted pattern decoration
        Positioned(
          top: -24,
          right: -24,
          width: 100,
          height: 100,
          child: CustomPaint(
            painter: DottedPatternPainter(
              dotColor: neo.ink.withValues(alpha: 0.18),
            ),
          ),
        ),
        // Rectangular cyan container (zigzag is created by overlay on top)
        Container(
          decoration: BoxDecoration(
            color: NeoColors.tertiary,
            border: Border.all(color: neo.ink, width: 4),
          ),
          padding: const EdgeInsets.only(
            top: 40,
            left: 32,
            right: 32,
            bottom: 40,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: neo.surface,
                    border: Border.all(color: neo.ink),
                    boxShadow: [
                      BoxShadow(color: neo.ink, offset: const Offset(2, 2)),
                    ],
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.netWorth,
                    style: NeoTypography.mono.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: neo.textMain,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  nwStr,
                  style: NeoTypography.textTheme.displayMedium?.copyWith(
                    fontSize: nwStr.length > 8 ? 32 : 48,
                    letterSpacing: -2,
                    color: NeoColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      color: NeoColors.ink,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: NeoColors.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+12%',
                            style: NeoTypography.mono.copyWith(
                              color: NeoColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.vsLastMonth,
                      style: NeoTypography.mono.copyWith(
                        fontSize: 12,
                        color: NeoColors.ink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Background-colored overlay that masks cyan edges into zigzag shape
        Positioned.fill(
          child: CustomPaint(
            painter: ZigzagOverlayPainter(backgroundColor: neo.background),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyCap(BuildContext context, NeoThemeData neo) {
    final provider = context.watch<AppProvider>();
    final spent = provider.currentMonthSpent;
    final cap = provider.monthlyCap;
    final left = cap - spent;
    final pct = cap > 0 ? (spent / cap).clamp(0.0, 1.0) : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomLeft,
                child: Text(
                  AppLocalizations.of(context)!.monthlyCap,
                  style: NeoTypography.textTheme.titleLarge?.copyWith(
                    textBaseline: TextBaseline.alphabetic,
                    color: neo.textMain,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${(pct * 100).toStringAsFixed(0)}${AppLocalizations.of(context)!.fried}',
                style: NeoTypography.mono.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: neo.textMain,
                ),
              ),
            ),
          ],
        ),
        Container(
          height: 56, // Fixed height for consistent look
          decoration: BoxDecoration(
            color: neo.surface,
            border: Border.all(color: neo.ink, width: 3),
            boxShadow: [BoxShadow(color: neo.ink, offset: const Offset(4, 4))],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Progress fill
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: pct,
                child: Container(
                  decoration: BoxDecoration(
                    color: pct > 0.9 ? neo.error : NeoColors.primary,
                    border: Border(
                      right: BorderSide(
                        color: neo.ink,
                        width: (pct > 0.0 && pct < 1.0) ? 3 : 0,
                      ),
                    ),
                  ),
                  child: ClipRect(
                    child: CustomPaint(painter: DiagonalStripePainter()),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            color: NeoColors.ink,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Text(
                              '${AppLocalizations.of(context)!.spent}: ${_formatCurrency(spent, provider.currencySymbol)}',
                              style: NeoTypography.mono.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            color: NeoColors.ink,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Text(
                              '${AppLocalizations.of(context)!.left}: ${_formatCurrency(left, provider.currencySymbol)}',
                              style: NeoTypography.mono.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
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
      ],
    );
  }

  Widget _buildLatestRegrets(BuildContext context, NeoThemeData neo) {
    final provider = context.watch<AppProvider>();
    final txs = provider.transactions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: NeoColors.secondary,
            border: Border.all(color: neo.ink, width: 3),
            boxShadow: [BoxShadow(color: neo.ink, offset: const Offset(4, 4))],
          ),
          child: MarqueeWidget(
            text: AppLocalizations.of(context)!.latestRegrets,
            style: NeoTypography.mono.copyWith(
              color: Colors.white, // White text on secondary bg is intentional
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: neo.surface,
            border: Border.all(color: neo.ink, width: 3),
            boxShadow: [BoxShadow(color: neo.ink, offset: const Offset(4, 4))],
          ),
          child: txs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.noRegretsYet,
                      style: NeoTypography.mono.copyWith(
                        color: neo.textSub,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: txs.asMap().entries.map((entry) {
                    final int idx = entry.key;
                    final TransactionModel tx = entry.value;
                    final isLast = idx == txs.length - 1;
                    return Column(
                      children: [
                        _buildTransactionItem(
                          neo,
                          CategoryUtils.getCategoryIcon(tx.category),
                          CategoryUtils.getCategoryColor(tx.category),
                          tx.title.isNotEmpty ? tx.title : tx.category,
                          '${tx.date.hour}:${tx.date.minute.toString().padLeft(2, '0')} • ${tx.category}',
                          '${tx.type == 'income' ? "+" : "-"}${_formatCurrency(tx.amount, provider.currencySymbol)}',
                          tx.type == 'income'
                              ? NeoColors.success
                              : NeoColors.secondary,
                        ),
                        if (!isLast)
                          Divider(
                            color: neo.inkOnCard,
                            thickness: 2,
                            height: 2,
                          ),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
    NeoThemeData neo,
    IconData icon,
    Color bgColor,
    String title,
    String subtitle,
    String amount,
    Color amountColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: neo.inkOnCard, width: 2),
              boxShadow: [
                BoxShadow(color: neo.inkOnCard, offset: const Offset(2, 2)),
              ],
            ),
            child: Icon(icon, color: NeoColors.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: NeoTypography.textTheme.titleMedium?.copyWith(
                    height: 1,
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
}

// ─── Painters (unchanged) ──────────────────────────────────────────────────────

// --- Paints background-colored triangles on top/bottom edges to create zigzag ---
class ZigzagOverlayPainter extends CustomPainter {
  final Color backgroundColor;
  final double zigzagHeight;
  final int teethCount;

  ZigzagOverlayPainter({
    required this.backgroundColor,
    this.zigzagHeight = 18,
    this.teethCount = 14,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final toothWidth = size.width / teethCount;

    // Top edge: paint inverted triangles (pointing DOWN into cyan)
    // These fill the space between zigzag peaks
    for (int i = 0; i < teethCount; i++) {
      final x = toothWidth * i;
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + toothWidth / 2, zigzagHeight)
        ..lineTo(x + toothWidth, 0)
        ..close();
      canvas.drawPath(path, paint);
    }

    // Bottom edge: paint triangles (pointing UP into cyan)
    for (int i = 0; i < teethCount; i++) {
      final x = toothWidth * i;
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + toothWidth / 2, size.height - zigzagHeight)
        ..lineTo(x + toothWidth, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- Custom Painter for zigzag border outline ---
class ZigzagBorderPainter extends CustomPainter {
  final Color borderColor;
  final double zigzagHeight;
  final int teethCount;
  final double strokeWidth;

  ZigzagBorderPainter({
    required this.borderColor,
    this.zigzagHeight = 18,
    this.teethCount = 14,
    this.strokeWidth = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.miter;

    final path = Path();
    final toothWidth = size.width / teethCount;

    // Top zigzag
    path.moveTo(0, zigzagHeight);
    for (int i = 0; i < teethCount; i++) {
      final x = toothWidth * i;
      path.lineTo(x + toothWidth / 2, 0);
      path.lineTo(x + toothWidth, zigzagHeight);
    }

    // Right side
    path.lineTo(size.width, size.height - zigzagHeight);

    // Bottom zigzag (right to left)
    for (int i = teethCount; i > 0; i--) {
      final x = toothWidth * i;
      path.lineTo(x - toothWidth / 2, size.height);
      path.lineTo(x - toothWidth, size.height - zigzagHeight);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DottedPatternPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;
  final double dotRadius;

  DottedPatternPainter({
    this.dotColor = const Color(0xFFD1D1D1),
    this.spacing = 8.0,
    this.dotRadius = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DiagonalStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NeoColors.ink.withValues(alpha: 0.25)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const spacing = 16.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, size.height),
        Offset(i + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MarqueeWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const MarqueeWidget({super.key, required this.text, this.style});

  @override
  State<MarqueeWidget> createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  late final ScrollController _scrollController;
  Timer? _timer;
  final GlobalKey _textKey = GlobalKey();
  double _singleWidth = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = _textKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) _singleWidth = box.size.width;
      _startScrolling();
    });
  }

  void _startScrolling() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!mounted || !_scrollController.hasClients) return;
      final current = _scrollController.offset + 1;
      if (_singleWidth > 0 && current >= _singleWidth) {
        _scrollController.jumpTo(current - _singleWidth);
      } else {
        _scrollController.jumpTo(current);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: [
            Text(key: _textKey, '${widget.text}   ', style: widget.style),
            Text('${widget.text}   ', style: widget.style),
          ],
        ),
      ),
    );
  }
}
