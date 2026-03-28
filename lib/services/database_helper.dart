import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/goal.dart';
import '../models/recurring_transaction.dart';
import '../models/wallet.dart';
import '../models/transaction_template.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  bool get _isSupported {
    if (kIsWeb) return false;
    return true;
  }

  Future<Database?> get database async {
    if (!_isSupported) return null;
    if (_database != null) return _database!;
    _database = await _initDB('chitieu.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String dbPath;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // For desktop platforms, use the application documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      dbPath = appDocDir.path;
    } else {
      // For mobile platforms
      dbPath = await getDatabasesPath();
    }

    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT';
    const realType = 'REAL NOT NULL';
    const realNullable = 'REAL';
    const intType = 'INTEGER NOT NULL';
    const intNullable = 'INTEGER';

    // Create transactions table with new columns
    await db.execute('''
CREATE TABLE transactions (
  id $idType,
  title $textType,
  amount $realType,
  date $textType,
  category $textType,
  type $textType,
  wallet_id $intNullable,
  note $textNullable,
  tags $textNullable,
  template_id $textNullable
)
''');

    // Create budgets table
    await db.execute('''
CREATE TABLE budgets (
  id $idType,
  category $textType,
  budget_limit $realType,
  period $textType,
  start_date $textNullable,
  is_active $intType
)
''');

    // Create goals table
    await db.execute('''
CREATE TABLE goals (
  id $idType,
  name $textType,
  target_amount $realType,
  current_amount $realNullable,
  deadline $textType,
  icon $textNullable,
  color $intNullable
)
''');

    // Create recurring_transactions table
    await db.execute('''
CREATE TABLE recurring_transactions (
  id $idType,
  title $textType,
  amount $realType,
  category $textType,
  type $textType,
  frequency $textType,
  next_due_date $textType,
  end_date $textNullable,
  is_active $intType,
  note $textNullable,
  day_of_month $intNullable,
  day_of_week $intNullable
)
''');

    // Create wallets table
    await db.execute('''
CREATE TABLE wallets (
  id $idType,
  name $textType,
  balance $realType,
  type $textType,
  icon $textNullable,
  color $intNullable,
  is_default $intType
)
''');

    // Create transaction_templates table
    await db.execute('''
CREATE TABLE transaction_templates (
  id $textType,
  name $textType,
  amount $realType,
  category $textType,
  type $textType,
  note $textNullable,
  created_at $textType,
  usage_count $intType
)
''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Add new columns to existing transactions table
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE transactions ADD COLUMN wallet_id INTEGER');
      await db.execute('ALTER TABLE transactions ADD COLUMN note TEXT');
      await db.execute('ALTER TABLE transactions ADD COLUMN tags TEXT');
      await db.execute('ALTER TABLE transactions ADD COLUMN template_id TEXT');

      // Create new tables
      await db.execute('''
CREATE TABLE IF NOT EXISTS budgets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category TEXT NOT NULL,
  budget_limit REAL NOT NULL,
  period TEXT NOT NULL,
  start_date TEXT,
  is_active INTEGER NOT NULL
)
''');

      await db.execute('''
CREATE TABLE IF NOT EXISTS goals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  target_amount REAL NOT NULL,
  current_amount REAL,
  deadline TEXT NOT NULL,
  icon TEXT,
  color INTEGER
)
''');

      await db.execute('''
CREATE TABLE IF NOT EXISTS recurring_transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  amount REAL NOT NULL,
  category TEXT NOT NULL,
  type TEXT NOT NULL,
  frequency TEXT NOT NULL,
  next_due_date TEXT NOT NULL,
  end_date TEXT,
  is_active INTEGER NOT NULL,
  note TEXT,
  day_of_month INTEGER,
  day_of_week INTEGER
)
''');

      await db.execute('''
CREATE TABLE IF NOT EXISTS wallets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  balance REAL NOT NULL,
  type TEXT NOT NULL,
  icon TEXT,
  color INTEGER,
  is_default INTEGER NOT NULL
)
''');

      await db.execute('''
CREATE TABLE IF NOT EXISTS transaction_templates (
  id TEXT NOT NULL,
  name TEXT NOT NULL,
  amount REAL NOT NULL,
  category TEXT NOT NULL,
  type TEXT NOT NULL,
  note TEXT,
  created_at TEXT NOT NULL,
  usage_count INTEGER NOT NULL
)
''');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // TRANSACTIONS
  // ═══════════════════════════════════════════════════════════════════════════════

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    if (db == null) return -1;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await instance.database;
    if (db == null) return [];
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByWallet(int walletId) async {
    final db = await instance.database;
    if (db == null) return [];
    final result = await db.query(
      'transactions',
      where: 'wallet_id = ?',
      whereArgs: [walletId],
      orderBy: 'date DESC',
    );
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllTransactions() async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.delete('transactions');
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // BUDGETS
  // ═══════════════════════════════════════════════════════════════════════════════

  Future<int> insertBudget(BudgetModel budget) async {
    final db = await instance.database;
    if (db == null) return -1;
    return await db.insert('budgets', budget.toMap());
  }

  Future<List<BudgetModel>> getAllBudgets() async {
    final db = await instance.database;
    if (db == null) return [];
    final result = await db.query('budgets');
    return result.map((json) => BudgetModel.fromMap(json)).toList();
  }

  Future<List<BudgetModel>> getActiveBudgets() async {
    final db = await instance.database;
    if (db == null) return [];
    final result = await db.query(
      'budgets',
      where: 'is_active = ?',
      whereArgs: [1],
    );
    return result.map((json) => BudgetModel.fromMap(json)).toList();
  }

  Future<BudgetModel?> getBudgetByCategory(String category) async {
    final db = await instance.database;
    if (db == null) return null;
    final result = await db.query(
      'budgets',
      where: 'category = ? AND is_active = ?',
      whereArgs: [category, 1],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return BudgetModel.fromMap(result.first);
  }

  Future<int> updateBudget(BudgetModel budget) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(int id) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // GOALS
  // ═══════════════════════════════════════════════════════════════════════════════

  Future<int> insertGoal(GoalModel goal) async {
    final db = await instance.database;
    if (db == null) return -1;
    return await db.insert('goals', goal.toMap());
  }

  Future<List<GoalModel>> getAllGoals() async {
    final db = await instance.database;
    if (db == null) return [];
    final result = await db.query('goals', orderBy: 'deadline ASC');
    return result.map((json) => GoalModel.fromMap(json)).toList();
  }

  Future<GoalModel?> getGoal(int id) async {
    final db = await instance.database;
    if (db == null) return null;
    final result = await db.query('goals', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return GoalModel.fromMap(result.first);
  }

  Future<int> updateGoal(GoalModel goal) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> updateGoalProgress(int id, double amount) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.update(
      'goals',
      {'current_amount': amount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // RECURRING TRANSACTIONS
  // ═══════════════════════════════════════════════════════════════════════════════

  Future<int> insertRecurring(RecurringTransactionModel recurring) async {
    final db = await instance.database;
    if (db == null) return -1;
    return await db.insert('recurring_transactions', recurring.toMap());
  }

  Future<List<RecurringTransactionModel>> getAllRecurring() async {
    final db = await instance.database;
    if (db == null) return [];
    final result = await db.query('recurring_transactions', orderBy: 'next_due_date ASC');
    return result.map((json) => RecurringTransactionModel.fromMap(json)).toList();
  }

  Future<List<RecurringTransactionModel>> getActiveRecurring() async {
    final db = await instance.database;
    if (db == null) return [];
    final result = await db.query(
      'recurring_transactions',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'next_due_date ASC',
    );
    return result.map((json) => RecurringTransactionModel.fromMap(json)).toList();
  }

  Future<List<RecurringTransactionModel>> getDueRecurring() async {
    final db = await instance.database;
    if (db == null) return [];
    final now = DateTime.now().toIso8601String();
    final result = await db.query(
      'recurring_transactions',
      where: 'is_active = ? AND next_due_date <= ?',
      whereArgs: [1, now],
      orderBy: 'next_due_date ASC',
    );
    return result.map((json) => RecurringTransactionModel.fromMap(json)).toList();
  }

  Future<int> updateRecurring(RecurringTransactionModel recurring) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.update(
      'recurring_transactions',
      recurring.toMap(),
      where: 'id = ?',
      whereArgs: [recurring.id],
    );
  }

  Future<int> updateRecurringNextDueDate(int id, DateTime nextDue) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.update(
      'recurring_transactions',
      {'next_due_date': nextDue.toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteRecurring(int id) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.delete('recurring_transactions', where: 'id = ?', whereArgs: [id]);
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // WALLETS
  // ═══════════════════════════════════════════════════════════════════════════════

  Future<int> insertWallet(WalletModel wallet) async {
    final db = await instance.database;
    if (db == null) return -1;
    return await db.insert('wallets', wallet.toMap());
  }

  Future<List<WalletModel>> getAllWallets() async {
    final db = await instance.database;
    if (db == null) return [];
    final result = await db.query('wallets', orderBy: 'is_default DESC');
    return result.map((json) => WalletModel.fromMap(json)).toList();
  }

  Future<WalletModel?> getDefaultWallet() async {
    final db = await instance.database;
    if (db == null) return null;
    final result = await db.query(
      'wallets',
      where: 'is_default = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return WalletModel.fromMap(result.first);
  }

  Future<WalletModel?> getWallet(int id) async {
    final db = await instance.database;
    if (db == null) return null;
    final result = await db.query('wallets', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return WalletModel.fromMap(result.first);
  }

  Future<int> updateWallet(WalletModel wallet) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.update(
      'wallets',
      wallet.toMap(),
      where: 'id = ?',
      whereArgs: [wallet.id],
    );
  }

  Future<int> updateWalletBalance(int id, double newBalance) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.update(
      'wallets',
      {'balance': newBalance},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> adjustWalletBalance(int id, double amount) async {
    final db = await instance.database;
    if (db == null) return 0;
    await db.rawUpdate(
      'UPDATE wallets SET balance = balance + ? WHERE id = ?',
      [amount, id],
    );
    return 1;
  }

  Future<int> setDefaultWallet(int id) async {
    final db = await instance.database;
    if (db == null) return 0;
    // Remove default from all wallets
    await db.update('wallets', {'is_default': 0});
    // Set new default
    return await db.update(
      'wallets',
      {'is_default': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteWallet(int id) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.delete('wallets', where: 'id = ?', whereArgs: [id]);
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // TRANSACTION TEMPLATES
  // ═══════════════════════════════════════════════════════════════════════════════

  Future<int> insertTemplate(TransactionTemplateModel template) async {
    final db = await instance.database;
    if (db == null) return -1;
    return await db.insert('transaction_templates', template.toMap());
  }

  Future<List<TransactionTemplateModel>> getAllTemplates() async {
    final db = await instance.database;
    if (db == null) return [];
    final result = await db.query('transaction_templates', orderBy: 'usage_count DESC');
    return result.map((json) => TransactionTemplateModel.fromMap(json)).toList();
  }

  Future<TransactionTemplateModel?> getTemplate(String id) async {
    final db = await instance.database;
    if (db == null) return null;
    final result = await db.query('transaction_templates', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return TransactionTemplateModel.fromMap(result.first);
  }

  Future<int> updateTemplate(TransactionTemplateModel template) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.update(
      'transaction_templates',
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  Future<int> incrementTemplateUsage(String id) async {
    final db = await instance.database;
    if (db == null) return 0;
    await db.rawUpdate(
      'UPDATE transaction_templates SET usage_count = usage_count + 1 WHERE id = ?',
      [id],
    );
    return 1;
  }

  Future<int> deleteTemplate(String id) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.delete('transaction_templates', where: 'id = ?', whereArgs: [id]);
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // COMMON
  // ═══════════════════════════════════════════════════════════════════════════════

  Future close() async {
    final db = await instance.database;
    if (db != null) {
      db.close();
    }
  }
}
