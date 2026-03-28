import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/goal.dart';
import '../models/recurring_transaction.dart';
import '../models/wallet.dart';
import '../models/transaction_template.dart';
import '../services/database_helper.dart';
import '../services/prefs_helper.dart';

class AppProvider extends ChangeNotifier {
  // ─── Existing State ─────────────────────────────────────────────────────────────
  List<TransactionModel> _transactions = [];
  double _initialBalance = 0.0;
  double _monthlyCap = 5000000.0;
  String? _username;
  String? _displayName;
  bool _isLoading = true;
  Locale _locale = const Locale('en');
  String _currency = 'USD';
  bool _biometricEnabled = false;
  bool _appLockEnabled = false;
  bool _darkMode = false;
  bool _hapticEnabled = true;
  bool _soundAlerts = true;
  String? _joinDate;
  String? _avatarPath;
  bool _onboardingCompleted = false;

  // ─── New State ───────────────────────────────────────────────────────────────────
  List<BudgetModel> _budgets = [];
  List<GoalModel> _goals = [];
  List<RecurringTransactionModel> _recurringTransactions = [];
  List<WalletModel> _wallets = [];
  List<TransactionTemplateModel> _templates = [];
  WalletModel? _selectedWallet;

  // ─── Getters ────────────────────────────────────────────────────────────────────

  // Existing getters
  List<TransactionModel> get transactions => _transactions;
  double get initialBalance => _initialBalance;
  double get monthlyCap => _monthlyCap;
  String? get username => _username;
  String? get displayName => _displayName;
  bool get isLoading => _isLoading;
  Locale get locale => _locale;
  String get currency => _currency;
  bool get biometricEnabled => _biometricEnabled;
  bool get appLockEnabled => _appLockEnabled;
  bool get darkMode => _darkMode;
  bool get hapticEnabled => _hapticEnabled;
  bool get soundAlerts => _soundAlerts;
  String? get joinDate => _joinDate;
  String? get avatarPath => _avatarPath;
  bool get onboardingCompleted => _onboardingCompleted;

  // New getters
  List<BudgetModel> get budgets => _budgets;
  List<GoalModel> get goals => _goals;
  List<RecurringTransactionModel> get recurringTransactions => _recurringTransactions;
  List<WalletModel> get wallets => _wallets;
  List<TransactionTemplateModel> get templates => _templates;
  WalletModel? get selectedWallet => _selectedWallet;
  List<dynamic> get customCategories => []; // TODO: Implement category management

  // Computed properties
  String get currencySymbol {
    switch (_currency) {
      case 'VND':
        return '₫';
      case 'USD':
      default:
        return '\$';
    }
  }

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

  // Budget computed properties
  List<BudgetModel> get activeBudgets =>
      _budgets.where((b) => b.isActive == true).toList();

  // Goals computed properties
  List<GoalModel> get activeGoals =>
      _goals.where((g) => !g.isCompleted).toList();
  List<GoalModel> get completedGoals =>
      _goals.where((g) => g.isCompleted).toList();

  // Wallet computed properties
  WalletModel? get defaultWallet {
    try {
      return _wallets.firstWhere((w) => w.isDefault);
    } catch (e) {
      return _wallets.isNotEmpty ? _wallets.first : null;
    }
  }

  double get totalWalletBalance {
    return _wallets.fold(0.0, (sum, w) => sum + w.balance);
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

    // Load new data
    _budgets = await DatabaseHelper.instance.getAllBudgets();
    _goals = await DatabaseHelper.instance.getAllGoals();
    _recurringTransactions = await DatabaseHelper.instance.getAllRecurring();
    _wallets = await DatabaseHelper.instance.getAllWallets();
    _templates = await DatabaseHelper.instance.getAllTemplates();

    // Set selected wallet to default
    _selectedWallet = defaultWallet;

    // Initialize default wallet if none exists
    if (_wallets.isEmpty) {
      final defaultWallet = WalletModel(
        name: _currency == 'VND' ? 'Ví tiền mặt' : 'Cash Wallet',
        balance: _initialBalance,
        type: 'cash',
        isDefault: true,
      );
      await addWallet(defaultWallet);
    }

    final langCode = await PrefsHelper.getLanguage();
    _locale = Locale(langCode ?? 'en');
    final currencyCode = await PrefsHelper.getCurrency();
    _currency = currencyCode ?? 'USD';
    _biometricEnabled = await PrefsHelper.getBiometricEnabled();
    _appLockEnabled = await PrefsHelper.getAppLockEnabled();
    _darkMode = await PrefsHelper.getDarkMode();
    _hapticEnabled = await PrefsHelper.getHapticEnabled();
    _soundAlerts = await PrefsHelper.getSoundAlerts();
    _joinDate = await PrefsHelper.getJoinDate();
    _avatarPath = await PrefsHelper.getAvatarPath();
    _onboardingCompleted = await PrefsHelper.getOnboardingCompleted();

    // Process due recurring transactions
    await processDueRecurring();

    _isLoading = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // AUTH
  // ═══════════════════════════════════════════════════════════════════════════════

  Future<void> login(
    String username,
    double initialBalance,
    double monthlyCap,
  ) async {
    await PrefsHelper.saveUsername(username);
    await PrefsHelper.saveInitialBalance(initialBalance);
    await PrefsHelper.saveMonthlyCap(monthlyCap);

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

  // ═══════════════════════════════════════════════════════════════════════════════
  // TRANSACTIONS
  // ═══════════════════════════════════════════════════════════════════════════════

  Future<void> addTransaction(TransactionModel transaction) async {
    final id = await DatabaseHelper.instance.insertTransaction(transaction);
    transaction.id = id == -1 ? DateTime.now().millisecondsSinceEpoch : id;

    // Adjust wallet balance
    if (transaction.walletId != null) {
      final amount = transaction.type == 'income'
          ? transaction.amount
          : -transaction.amount;
      await DatabaseHelper.instance.adjustWalletBalance(transaction.walletId!, amount);
      await loadWallets();
    }

    _transactions.insert(0, transaction);
    _transactions.sort((a, b) => b.date.compareTo(a.date));

    if (_hapticEnabled) {
      HapticFeedback.heavyImpact();
    }

    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await DatabaseHelper.instance.updateTransaction(transaction);

    // Find and update in list
    final index = _transactions.indexWhere((tx) => tx.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
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

  Future<void> importTransactions(List<TransactionModel> txs) async {
    for (var tx in txs) {
      final id = await DatabaseHelper.instance.insertTransaction(tx);
      tx.id = id == -1 ? DateTime.now().millisecondsSinceEpoch : id;
      _transactions.add(tx);
    }
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // BUDGETS
  // ═══════════════════════════════════════════════════════════════════════════════

  Future<void> loadBudgets() async {
    _budgets = await DatabaseHelper.instance.getAllBudgets();
    notifyListeners();
  }

  Future<void> addBudget(BudgetModel budget) async {
    final id = await DatabaseHelper.instance.insertBudget(budget);
    budget.id = id;
    _budgets.add(budget);
    notifyListeners();
  }

  Future<void> updateBudget(BudgetModel budget) async {
    await DatabaseHelper.instance.updateBudget(budget);
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgets[index] = budget;
    }
    notifyListeners();
  }

  Future<void> deleteBudget(int id) async {
    await DatabaseHelper.instance.deleteBudget(id);
    _budgets.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  double getBudgetSpending(String category) {
    final now = DateTime.now();
    double total = 0;
    for (var tx in _transactions) {
      if (tx.type == 'expense' &&
          tx.category == category &&
          tx.date.year == now.year &&
          tx.date.month == now.month) {
        total += tx.amount;
      }
    }
    return total;
  }

  BudgetModel? getBudgetForCategory(String category) {
    try {
      return _budgets.firstWhere(
        (b) => b.category == category && b.isActive == true,
      );
    } catch (e) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // GOALS
  // ═══════════════════════════════════════════════════════════════════════════════

  Future<void> loadGoals() async {
    _goals = await DatabaseHelper.instance.getAllGoals();
    notifyListeners();
  }

  Future<void> addGoal(GoalModel goal) async {
    final id = await DatabaseHelper.instance.insertGoal(goal);
    goal.id = id;
    _goals.add(goal);
    notifyListeners();
  }

  Future<void> updateGoal(GoalModel goal) async {
    await DatabaseHelper.instance.updateGoal(goal);
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
    }
    notifyListeners();
  }

  Future<void> updateGoalProgress(int id, double amount) async {
    await DatabaseHelper.instance.updateGoalProgress(id, amount);
    final goal = _goals.firstWhere((g) => g.id == id);
    goal.currentAmount = amount;
    notifyListeners();
  }

  Future<void> addToGoal(int id, double amount) async {
    final goal = _goals.firstWhere((g) => g.id == id);
    final newAmount = goal.currentAmount + amount;
    await updateGoalProgress(id, newAmount);
  }

  Future<void> deleteGoal(int id) async {
    await DatabaseHelper.instance.deleteGoal(id);
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // RECURRING TRANSACTIONS
  // ═══════════════════════════════════════════════════════════════════════════════

  Future<void> loadRecurring() async {
    _recurringTransactions = await DatabaseHelper.instance.getAllRecurring();
    notifyListeners();
  }

  Future<void> addRecurring(RecurringTransactionModel recurring) async {
    final id = await DatabaseHelper.instance.insertRecurring(recurring);
    recurring.id = id;
    _recurringTransactions.add(recurring);
    notifyListeners();
  }

  Future<void> updateRecurring(RecurringTransactionModel recurring) async {
    await DatabaseHelper.instance.updateRecurring(recurring);
    final index = _recurringTransactions.indexWhere((r) => r.id == recurring.id);
    if (index != -1) {
      _recurringTransactions[index] = recurring;
    }
    notifyListeners();
  }

  Future<void> deleteRecurring(int id) async {
    await DatabaseHelper.instance.deleteRecurring(id);
    _recurringTransactions.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  Future<void> processDueRecurring() async {
    final dueTransactions = await DatabaseHelper.instance.getDueRecurring();

    for (var recurring in dueTransactions) {
      // Check if should end
      if (recurring.shouldEnd()) {
        recurring.isActive = false;
        await updateRecurring(recurring);
        continue;
      }

      // Create the transaction
      final tx = TransactionModel(
        title: recurring.title,
        amount: recurring.amount,
        date: recurring.nextDueDate,
        category: recurring.category,
        type: recurring.type,
        walletId: _selectedWallet?.id,
      );
      await addTransaction(tx);

      // Calculate next due date
      final nextDue = recurring.calculateNextDueDate();
      await DatabaseHelper.instance.updateRecurringNextDueDate(recurring.id!, nextDue);
      recurring.nextDueDate = nextDue;
    }

    if (dueTransactions.isNotEmpty) {
      await loadRecurring();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // WALLETS
  // ═══════════════════════════════════════════════════════════════════════════════

  Future<void> loadWallets() async {
    _wallets = await DatabaseHelper.instance.getAllWallets();
    if (_selectedWallet == null && _wallets.isNotEmpty) {
      _selectedWallet = defaultWallet;
    }
    notifyListeners();
  }

  Future<void> addWallet(WalletModel wallet) async {
    final id = await DatabaseHelper.instance.insertWallet(wallet);
    wallet.id = id;
    _wallets.add(wallet);
    if (_wallets.length == 1) {
      _selectedWallet = wallet;
    }
    notifyListeners();
  }

  Future<void> updateWallet(WalletModel wallet) async {
    await DatabaseHelper.instance.updateWallet(wallet);
    final index = _wallets.indexWhere((w) => w.id == wallet.id);
    if (index != -1) {
      _wallets[index] = wallet;
    }
    if (_selectedWallet?.id == wallet.id) {
      _selectedWallet = wallet;
    }
    notifyListeners();
  }

  Future<void> selectWallet(WalletModel? wallet) async {
    _selectedWallet = wallet;
    notifyListeners();
  }

  Future<void> setDefaultWallet(int id) async {
    await DatabaseHelper.instance.setDefaultWallet(id);
    for (var w in _wallets) {
      w.isDefault = (w.id == id);
    }
    _selectedWallet = _wallets.firstWhere((w) => w.id == id);
    notifyListeners();
  }

  Future<void> transferBetweenWallets(int fromId, int toId, double amount) async {
    await DatabaseHelper.instance.adjustWalletBalance(fromId, -amount);
    await DatabaseHelper.instance.adjustWalletBalance(toId, amount);
    await loadWallets();
  }

  Future<void> deleteWallet(int id) async {
    await DatabaseHelper.instance.deleteWallet(id);
    _wallets.removeWhere((w) => w.id == id);
    if (_selectedWallet?.id == id) {
      _selectedWallet = defaultWallet;
    }
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // TEMPLATES
  // ═══════════════════════════════════════════════════════════════════════════════

  Future<void> loadTemplates() async {
    _templates = await DatabaseHelper.instance.getAllTemplates();
    notifyListeners();
  }

  Future<void> saveTemplate(TransactionTemplateModel template) async {
    await DatabaseHelper.instance.insertTemplate(template);
    _templates.add(template);
    notifyListeners();
  }

  Future<void> deleteTemplate(String id) async {
    await DatabaseHelper.instance.deleteTemplate(id);
    _templates.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> useTemplate(TransactionTemplateModel template) async {
    await DatabaseHelper.instance.incrementTemplateUsage(template.id!);
    template.usageCount++;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // SETTINGS
  // ═══════════════════════════════════════════════════════════════════════════════

  Future<void> updateMonthlyCap(double newCap) async {
    await PrefsHelper.saveMonthlyCap(newCap);
    _monthlyCap = newCap;
    notifyListeners();
  }

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

  Future<void> toggleAppLock(bool enabled) async {
    await PrefsHelper.saveAppLockEnabled(enabled);
    _appLockEnabled = enabled;
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
      HapticFeedback.heavyImpact();
    }
    notifyListeners();
  }

  Future<void> toggleSoundAlerts() async {
    _soundAlerts = !_soundAlerts;
    await PrefsHelper.saveSoundAlerts(_soundAlerts);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // PROFILE
  // ═══════════════════════════════════════════════════════════════════════════════

  Future<void> updateDisplayName(String name) async {
    await PrefsHelper.saveDisplayName(name);
    _displayName = name;
    notifyListeners();
  }

  Future<void> updateAvatarPath(String path) async {
    await PrefsHelper.saveAvatarPath(path);
    _avatarPath = path;
    notifyListeners();
  }

  Future<void> setOnboardingComplete() async {
    await PrefsHelper.saveOnboardingCompleted();
    _onboardingCompleted = true;
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

  // ═══════════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════════

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
