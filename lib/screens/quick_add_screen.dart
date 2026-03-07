import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../widgets/neo_card.dart';
import '../widgets/neo_button.dart';
import '../providers/app_provider.dart';
import '../models/transaction.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';

class QuickAddScreen extends StatefulWidget {
  const QuickAddScreen({super.key});

  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  String _amountStr = '0';
  String? _selectedCategory;
  bool _isIncome = false;
  Timer? _backspaceHoldTimer;

  @override
  void dispose() {
    _backspaceHoldTimer?.cancel();
    super.dispose();
  }

  /// Format number string with dot thousand separators (Vietnamese style)
  String _formatDisplay(String raw) {
    if (raw.contains('.')) {
      // Has decimal point — split and format integer part only
      final parts = raw.split('.');
      final intPart = _addThousandSeparators(parts[0]);
      return '$intPart.${parts[1]}';
    }
    return _addThousandSeparators(raw);
  }

  String _addThousandSeparators(String s) {
    if (s.length <= 3) return s;
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buf.write(s[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buf.write('.');
      }
    }
    return buf.toString().split('').reversed.join();
  }

  void _onNumpadPress(String val) {
    setState(() {
      if (val == '<') {
        if (_amountStr.length > 1) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        } else {
          _amountStr = '0';
        }
      } else if (val == '.') {
        if (!_amountStr.contains('.')) {
          _amountStr += '.';
        }
      } else {
        if (_amountStr == '0') {
          _amountStr = val;
        } else {
          if (_amountStr.length < 10) {
            _amountStr += val;
          }
        }
      }
    });
  }

  void _commitTransaction() async {
    final amount = double.tryParse(_amountStr) ?? 0.0;
    if (amount <= 0) return;

    final loc = AppLocalizations.of(context)!;
    final cat = _selectedCategory ?? (_isIncome ? loc.income : loc.food);

    final tx = TransactionModel(
      title: '', // Default to empty
      amount: amount,
      date: DateTime.now(),
      category: cat,
      type: _isIncome ? 'income' : 'expense',
    );

    await context.read<AppProvider>().addTransaction(tx);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    final key = event.logicalKey;

    // Handle backspace hold-to-clear
    if (key == LogicalKeyboardKey.backspace) {
      if (event is KeyDownEvent) {
        _onNumpadPress('<');
        _backspaceHoldTimer?.cancel();
        _backspaceHoldTimer = Timer(const Duration(milliseconds: 500), () {
          setState(() {
            _amountStr = '0';
          });
        });
        return KeyEventResult.handled;
      } else if (event is KeyUpEvent) {
        _backspaceHoldTimer?.cancel();
        return KeyEventResult.handled;
      }
    }

    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _commitTransaction();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.period ||
        key == LogicalKeyboardKey.numpadDecimal) {
      _onNumpadPress('.');
      return KeyEventResult.handled;
    } else if (key.keyLabel.isNotEmpty &&
        RegExp(r'^[0-9]$').hasMatch(key.keyLabel)) {
      _onNumpadPress(key.keyLabel);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final neo = NeoTheme.of(context);
    return Center(
      child: Focus(
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            decoration: BoxDecoration(
              color: neo.background,
              borderRadius: const BorderRadius.all(Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTopbar(context, neo),
                  _buildDisplayArea(context),
                  _buildCategorySlider(context, neo),
                  _buildNumpadArea(context, neo),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopbar(BuildContext context, NeoThemeData neo) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NeoButton(
                padding: const EdgeInsets.all(8),
                backgroundColor: neo.surface,
                onPressed: () => Navigator.pop(context),
                child: Icon(Icons.close, color: neo.textMain, size: 28),
              ),
              const SizedBox(width: 44),
            ],
          ),
          Transform.rotate(
            angle: 0.02,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: neo.primary,
                border: Border.all(color: neo.ink, width: 3),
                boxShadow: [
                  BoxShadow(color: neo.ink, offset: const Offset(4, 4)),
                ],
              ),
              child: Text(
                AppLocalizations.of(context)!.quickAdd,
                style: NeoTypography.textTheme.headlineMedium?.copyWith(
                  letterSpacing: 2,
                  color: neo.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayArea(BuildContext context) {
    final neo = NeoTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: NeoCard(
        backgroundColor: neo.ink,
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 90),
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppLocalizations.of(context)!.amountToBurn,
                style: NeoTypography.mono.copyWith(
                  color: neo.primary.withValues(alpha: 0.8),
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      context.watch<AppProvider>().currencySymbol,
                      style: NeoTypography.textTheme.displayMedium?.copyWith(
                        color: neo.primary.withValues(alpha: 0.5),
                        fontSize: 32,
                      ),
                    ),
                    Text(
                      _formatDisplay(_amountStr),
                      style: NeoTypography.textTheme.displayMedium?.copyWith(
                        color: neo.primary,
                        fontSize: 56,
                        letterSpacing: -2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySlider(BuildContext context, NeoThemeData neo) {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildIncomeExpenseToggle(context, neo),
            const SizedBox(width: 12),
            if (!_isIncome) ...[
              _buildCategoryChip(context, neo, loc.food, Icons.lunch_dining),
              const SizedBox(width: 12),
              _buildCategoryChip(context, neo, loc.travel, Icons.train),
              const SizedBox(width: 12),
              _buildCategoryChip(context, neo, loc.games, Icons.sports_esports),
              const SizedBox(width: 12),
              _buildCategoryChip(context, neo, loc.coffee, Icons.local_cafe),
              const SizedBox(width: 12),
              _buildCategoryChip(context, neo, loc.rides, Icons.directions_car),
            ] else ...[
              _buildCategoryChip(
                context,
                neo,
                loc.income,
                Icons.account_balance_wallet,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseToggle(BuildContext context, NeoThemeData neo) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isIncome = !_isIncome;
          _selectedCategory = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isIncome ? neo.success : neo.secondary,
          border: Border.all(color: neo.ink, width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(_isIncome ? Icons.add : Icons.remove, color: neo.ink),
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    NeoThemeData neo,
    String label,
    IconData icon,
  ) {
    bool isActive =
        _selectedCategory == label ||
        (_selectedCategory == null &&
            ((!_isIncome && label == AppLocalizations.of(context)!.food) ||
                (_isIncome && label == AppLocalizations.of(context)!.income)));
    return NeoButton(
      backgroundColor: isActive ? neo.primary : neo.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: BorderRadius.circular(24),
      borderWidth: isActive ? 3.0 : 2.0,
      shadowOffset: isActive ? 4.0 : 2.0,
      onPressed: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Row(
        children: [
          Icon(icon, color: neo.textMain),
          const SizedBox(width: 8),
          Text(
            label,
            style: NeoTypography.textTheme.titleMedium?.copyWith(
              height: 1,
              color: neo.textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumpadArea(BuildContext context, NeoThemeData neo) {
    return Container(
      decoration: BoxDecoration(
        color: neo.surface,
        border: Border(top: BorderSide(color: neo.ink, width: 3)),
      ),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.5,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildNumpadBtn(context, neo, '1'),
                _buildNumpadBtn(context, neo, '2'),
                _buildNumpadBtn(context, neo, '3'),
                _buildNumpadBtn(context, neo, '4'),
                _buildNumpadBtn(context, neo, '5'),
                _buildNumpadBtn(context, neo, '6'),
                _buildNumpadBtn(context, neo, '7'),
                _buildNumpadBtn(context, neo, '8'),
                _buildNumpadBtn(context, neo, '9'),
                _buildNumpadBtn(context, neo, '.'),
                _buildNumpadBtn(context, neo, '0'),
                _buildNumpadBtn(context, neo, '<', isDelete: true),
              ],
            ),
            const SizedBox(height: 12),
            NeoButton(
              backgroundColor: neo.secondary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              borderRadius: BorderRadius.circular(8),
              onPressed: _commitTransaction,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.commit,
                    style: NeoTypography.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpadBtn(
    BuildContext context,
    NeoThemeData neo,
    String label, {
    bool isDelete = false,
  }) {
    final button = NeoButton(
      backgroundColor: isDelete
          ? neo.error.withValues(alpha: 0.2)
          : neo.background,
      borderRadius: BorderRadius.circular(8),
      padding: EdgeInsets.zero,
      onPressed: () => _onNumpadPress(label),
      child: Center(
        child: isDelete
            ? Icon(Icons.backspace, size: 28, color: neo.textMain)
            : Text(
                label,
                style: NeoTypography.textTheme.displayMedium?.copyWith(
                  fontSize: 32,
                  color: neo.textMain,
                ),
              ),
      ),
    );

    if (isDelete) {
      return GestureDetector(
        onLongPress: () {
          setState(() {
            _amountStr = '0';
          });
        },
        child: button,
      );
    }

    return button;
  }
}
