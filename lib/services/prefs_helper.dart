import 'package:shared_preferences/shared_preferences.dart';

class PrefsHelper {
  static const String _keyUsername = 'username';
  static const String _keyInitialBalance = 'initial_balance';
  static const String _keyMonthlyCap = 'monthly_cap';

  // ─── Username ──────────────────────────────────────────────────────────────

  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  static Future<void> removeUsername() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsername);
  }

  // ─── Avatar ──────────────────────────────────────────────────────────────

  static Future<void> saveAvatarPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar_path', path);
  }

  static Future<String?> getAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('avatar_path');
  }

  // ─── Balance / Cap ─────────────────────────────────────────────────────────

  static Future<void> saveInitialBalance(double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyInitialBalance, balance);
  }

  static Future<double> getInitialBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyInitialBalance) ?? 0.0;
  }

  static Future<void> saveMonthlyCap(double cap) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMonthlyCap, cap);
  }

  static Future<double> getMonthlyCap() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyMonthlyCap) ?? 5000000.0;
  }

  // ─── Language / Currency ───────────────────────────────────────────────────

  static Future<void> saveLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);
  }

  static Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language_code');
  }

  static Future<void> saveCurrency(String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency_code', currencyCode);
  }

  static Future<String?> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('currency_code');
  }

  // ─── Auth ──────────────────────────────────────────────────────────────────

  static Future<void> registerUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reg_username', username);
    await prefs.setString('reg_password', password);
  }

  static Future<bool> hasRegisteredUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('reg_username');
  }

  static Future<String?> getRegisteredUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('reg_username');
  }

  static Future<bool> checkCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final regUser = prefs.getString('reg_username');
    final regPass = prefs.getString('reg_password');
    return regUser == username && regPass == password;
  }

  static Future<void> savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reg_password', password);
  }

  static Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('reg_password');
  }

  // ─── Biometric ─────────────────────────────────────────────────────────────

  static Future<void> saveBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enabled);
  }

  static Future<bool> getBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled') ?? false;
  }

  // ─── App Lock Background ───────────────────────────────────────────────────

  static Future<void> saveAppLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_lock_enabled', enabled);
  }

  static Future<bool> getAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('app_lock_enabled') ?? false;
  }

  // ─── Dark Mode ─────────────────────────────────────────────────────────────

  static Future<void> saveDarkMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', enabled);
  }

  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('dark_mode') ?? false;
  }

  // ─── Haptic Feedback ───────────────────────────────────────────────────────

  static Future<void> saveHapticEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptic_enabled', enabled);
  }

  static Future<bool> getHapticEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('haptic_enabled') ?? true;
  }

  // ─── Sound Alerts ──────────────────────────────────────────────────────────

  static Future<void> saveSoundAlerts(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_alerts', enabled);
  }

  static Future<bool> getSoundAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('sound_alerts') ?? true;
  }

  // ─── Display Name ──────────────────────────────────────────────────────────

  static Future<void> saveDisplayName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('display_name', name);
  }

  static Future<String?> getDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('display_name');
  }

  // ─── Join Date ─────────────────────────────────────────────────────────────

  static Future<void> saveJoinDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('join_date', date);
  }

  static Future<String?> getJoinDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('join_date');
  }

  // ─── Onboarding ─────────────────────────────────────────────────────────────

  static Future<void> saveOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }

  static Future<bool> getOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }
}
