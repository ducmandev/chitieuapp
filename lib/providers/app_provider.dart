import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction.dart';
import '../services/database_helper.dart';
import '../services/prefs_helper.dart';

class AppProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  double _initialBalance = 0.0;
  double _monthlyCap = 5000000.0;
  String? _username;
  String? _displayName;
  bool _isLoading = true;
  Locale _locale = const Locale('en');
  String _currency = 'USD';
  bool _biometricEnabled = false;
  bool _darkMode = false;
  bool _hapticEnabled = true;
  bool _soundAlerts = true;
  String? _joinDate;

  // ─── Getters ────────────────────────────────────────────────────────────────

  List<TransactionModel> get transactions => _transactions;
  double get initialBalance => _initialBalance;
  double get monthlyCap => _monthlyCap;
  String? get username => _username;
  String? get displayName => _displayName;
  bool get isLoading => _isLoading;
  Locale get locale => _locale;
  String get currency => _currency;
  bool get biometricEnabled => _biometricEnabled;
  bool get darkMode => _darkMode;
  bool get hapticEnabled => _hapticEnabled;
  bool get soundAlerts => _soundAlerts;
  String? get joinDate => _joinDate;

  String get currencySymbol {
    switch (_currency) {
      case 'VND':
        return '₫';
      case 'USD':
      default:
        return '\$';
    }
  }

  /// The visible name shown in UI: displayName if set, otherwise username.
  String get profileName => (_displayName != null && _displayName!.isNotEmpty)
      ? _displayName!
      : (_username ?? 'USER');

  double get netWorth {
    double total = _initialBalance;
    for (var tx in _transactions) {
      if (tx.type == 'income') {
        total += tx.amount;
      } else {
        total -= tx.amount;
      }
    }
    return total;
  }

  double get currentMonthSpent {
    double total = 0;
    final now = DateTime.now();
    for (var tx in _transactions) {
      if (tx.type == 'expense' &&
          tx.date.year == now.year &&
          tx.date.month == now.month) {
        total += tx.amount;
      }
    }
    return total;
  }

  AppProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    _username = await PrefsHelper.getUsername();
    _displayName = await PrefsHelper.getDisplayName();
    _initialBalance = await PrefsHelper.getInitialBalance();
    _monthlyCap = await PrefsHelper.getMonthlyCap();
    _transactions = await DatabaseHelper.instance.getAllTransactions();
    final langCode = await PrefsHelper.getLanguage();
    _locale = Locale(langCode ?? 'en');
    final currencyCode = await PrefsHelper.getCurrency();
    _currency = currencyCode ?? 'USD';
    _biometricEnabled = await PrefsHelper.getBiometricEnabled();
    _darkMode = await PrefsHelper.getDarkMode();
    _hapticEnabled = await PrefsHelper.getHapticEnabled();
    _soundAlerts = await PrefsHelper.getSoundAlerts();
    _joinDate = await PrefsHelper.getJoinDate();

    _isLoading = false;
    notifyListeners();
  }

  // ─── Auth ──────────────────────────────────────────────────────────────────

  Future<void> login(
    String username,
    double initialBalance,
    double monthlyCap,
  ) async {
    await PrefsHelper.saveUsername(username);
    await PrefsHelper.saveInitialBalance(initialBalance);
    await PrefsHelper.saveMonthlyCap(monthlyCap);

    // Save join date on first login (register)
    if (_joinDate == null) {
      final now = DateTime.now();
      final joinStr =
          '${_monthAbbr(now.month)} ${now.day.toString().padLeft(2, '0')}, ${now.year}';
      await PrefsHelper.saveJoinDate(joinStr);
      _joinDate = joinStr;
    }

    _username = username;
    _initialBalance = initialBalance;
    _monthlyCap = monthlyCap;
    notifyListeners();
  }

  Future<void> logout() async {
    await PrefsHelper.removeUsername();
    _username = null;
    notifyListeners();
  }

  // ─── Transactions ─────────────────────────────────────────────────────────

  Future<void> addTransaction(TransactionModel transaction) async {
    final id = await DatabaseHelper.instance.insertTransaction(transaction);
    transaction.id = id == -1 ? DateTime.now().millisecondsSinceEpoch : id;
    _transactions.insert(0, transaction);
    _transactions.sort((a, b) => b.date.compareTo(a.date));

    // Haptic on every added transaction when enabled
    if (_hapticEnabled) {
      HapticFeedback.heavyImpact();
    }

    notifyListeners();
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }

  Future<void> nukeData() async {
    await DatabaseHelper.instance.deleteAllTransactions();
    _transactions.clear();
    notifyListeners();
  }

  Future<void> updateMonthlyCap(double newCap) async {
    await PrefsHelper.saveMonthlyCap(newCap);
    _monthlyCap = newCap;
    notifyListeners();
  }

  // ─── Settings ─────────────────────────────────────────────────────────────

  Future<void> changeLanguage(String languageCode) async {
    await PrefsHelper.saveLanguage(languageCode);
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> changeCurrency(String currencyCode) async {
    await PrefsHelper.saveCurrency(currencyCode);
    _currency = currencyCode;
    notifyListeners();
  }

  Future<void> toggleBiometric(bool enabled) async {
    await PrefsHelper.saveBiometricEnabled(enabled);
    _biometricEnabled = enabled;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _darkMode = !_darkMode;
    await PrefsHelper.saveDarkMode(_darkMode);
    notifyListeners();
  }

  Future<void> toggleHaptic() async {
    _hapticEnabled = !_hapticEnabled;
    await PrefsHelper.saveHapticEnabled(_hapticEnabled);
    if (_hapticEnabled) {
      HapticFeedback.heavyImpact(); // immediate feedback when turning on
    }
    notifyListeners();
  }

  Future<void> toggleSoundAlerts() async {
    _soundAlerts = !_soundAlerts;
    await PrefsHelper.saveSoundAlerts(_soundAlerts);
    notifyListeners();
  }

  // ─── Profile ──────────────────────────────────────────────────────────────

  Future<void> updateDisplayName(String name) async {
    await PrefsHelper.saveDisplayName(name);
    _displayName = name;
    notifyListeners();
  }

  Future<bool> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final stored = await PrefsHelper.getPassword();
    if (stored != currentPassword) return false;
    await PrefsHelper.savePassword(newPassword);
    return true;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _monthAbbr(int month) {
    const abbrs = [
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
    return abbrs[month - 1];
  }
}
