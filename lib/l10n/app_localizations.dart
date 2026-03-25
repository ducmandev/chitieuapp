import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'NEO.CASH'**
  String get appTitle;

  /// No description provided for @loginSystem.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM LOGIN'**
  String get loginSystem;

  /// No description provided for @usernameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'USERNAME OR EMAIL'**
  String get usernameOrEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get password;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your alias'**
  String get usernameHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Secret phrase'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'FORGOT PASSWORD?'**
  String get forgotPassword;

  /// No description provided for @loginNow.
  ///
  /// In en, this message translates to:
  /// **'LOGIN NOW'**
  String get loginNow;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'NO ACCOUNT? '**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'REGISTER'**
  String get register;

  /// No description provided for @joinTheCult.
  ///
  /// In en, this message translates to:
  /// **'JOIN THE CULT'**
  String get joinTheCult;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your regrets today.'**
  String get registerSubtitle;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'EMAIL ADDRESS'**
  String get emailAddress;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'hello@world.com'**
  String get emailHint;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'CREATE PASSWORD'**
  String get createPassword;

  /// No description provided for @createPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Make it hard to guess'**
  String get createPasswordHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM PASSWORD'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Type it again'**
  String get confirmPasswordHint;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get createAccount;

  /// No description provided for @alreadyRegret.
  ///
  /// In en, this message translates to:
  /// **'ALREADY REGRET THIS? '**
  String get alreadyRegret;

  /// No description provided for @statusBroke.
  ///
  /// In en, this message translates to:
  /// **'STATUS: BROKE'**
  String get statusBroke;

  /// No description provided for @statusBallin.
  ///
  /// In en, this message translates to:
  /// **'STATUS: BALLIN'**
  String get statusBallin;

  /// No description provided for @debtor.
  ///
  /// In en, this message translates to:
  /// **'DEBTOR'**
  String get debtor;

  /// No description provided for @netWorth.
  ///
  /// In en, this message translates to:
  /// **'NET WORTH'**
  String get netWorth;

  /// No description provided for @vsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'VS LAST MONTH'**
  String get vsLastMonth;

  /// No description provided for @monthlyCap.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY CAP'**
  String get monthlyCap;

  /// No description provided for @fried.
  ///
  /// In en, this message translates to:
  /// **'% FRIED'**
  String get fried;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'SPENT'**
  String get spent;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'LEFT'**
  String get left;

  /// No description provided for @latestRegrets.
  ///
  /// In en, this message translates to:
  /// **'LATEST REGRETS /// WHERE DID THE MONEY GO? ///'**
  String get latestRegrets;

  /// No description provided for @noRegretsYet.
  ///
  /// In en, this message translates to:
  /// **'NO REGRETS YET.'**
  String get noRegretsYet;

  /// No description provided for @viewDamage.
  ///
  /// In en, this message translates to:
  /// **'VIEW THE DAMAGE ->'**
  String get viewDamage;

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'QUICK ADD'**
  String get quickAdd;

  /// No description provided for @amountToBurn.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT TO BURN'**
  String get amountToBurn;

  /// No description provided for @commit.
  ///
  /// In en, this message translates to:
  /// **'COMMIT'**
  String get commit;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'FOOD'**
  String get food;

  /// No description provided for @travel.
  ///
  /// In en, this message translates to:
  /// **'TRAVEL'**
  String get travel;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'GAMES'**
  String get games;

  /// No description provided for @coffee.
  ///
  /// In en, this message translates to:
  /// **'COFFEE'**
  String get coffee;

  /// No description provided for @rides.
  ///
  /// In en, this message translates to:
  /// **'RIDES'**
  String get rides;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'INCOME'**
  String get income;

  /// No description provided for @paperTrail.
  ///
  /// In en, this message translates to:
  /// **'PAPER TRAIL'**
  String get paperTrail;

  /// No description provided for @statementOfRegret.
  ///
  /// In en, this message translates to:
  /// **'STATEMENT OF REGRET'**
  String get statementOfRegret;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'YESTERDAY'**
  String get yesterday;

  /// No description provided for @endOfTheLine.
  ///
  /// In en, this message translates to:
  /// **'END OF THE LINE'**
  String get endOfTheLine;

  /// No description provided for @noMoreRegrets.
  ///
  /// In en, this message translates to:
  /// **'NO MORE REGRETS TO SHOW.'**
  String get noMoreRegrets;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settings;

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'USER PROFILE'**
  String get userProfile;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY BUDGET'**
  String get monthlyBudget;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get language;

  /// No description provided for @languageDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose your suffering'**
  String get languageDesc;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'DANGER ZONE'**
  String get dangerZone;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'CLEAR ALL DATA'**
  String get clearAllData;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'LOGOUT'**
  String get logout;

  /// No description provided for @breakdown.
  ///
  /// In en, this message translates to:
  /// **'BREAKDOWN'**
  String get breakdown;

  /// No description provided for @totalBlown.
  ///
  /// In en, this message translates to:
  /// **'TOTAL BLOWN THIS MONTH'**
  String get totalBlown;

  /// No description provided for @spendingZones.
  ///
  /// In en, this message translates to:
  /// **'SPENDING ZONES'**
  String get spendingZones;

  /// No description provided for @goodJob.
  ///
  /// In en, this message translates to:
  /// **'SAVINGS ZONE'**
  String get goodJob;

  /// No description provided for @goodJobDesc.
  ///
  /// In en, this message translates to:
  /// **'You didn\'t spend it all. Yet.'**
  String get goodJobDesc;

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'DAILY AVERAGE'**
  String get dailyAverage;

  /// No description provided for @projected.
  ///
  /// In en, this message translates to:
  /// **'PROJECTED'**
  String get projected;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get navHome;

  /// No description provided for @navTransactions.
  ///
  /// In en, this message translates to:
  /// **'TAPE'**
  String get navTransactions;

  /// No description provided for @navBreakdown.
  ///
  /// In en, this message translates to:
  /// **'BREAKDOWN'**
  String get navBreakdown;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get navSettings;

  /// No description provided for @systemPrefs.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM PREFS'**
  String get systemPrefs;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'DARK MODE'**
  String get darkMode;

  /// No description provided for @saveYourEyes.
  ///
  /// In en, this message translates to:
  /// **'SAVE YOUR EYES'**
  String get saveYourEyes;

  /// No description provided for @hapticShock.
  ///
  /// In en, this message translates to:
  /// **'HAPTIC SHOCK'**
  String get hapticShock;

  /// No description provided for @feelTheSpending.
  ///
  /// In en, this message translates to:
  /// **'FEEL THE SPENDING'**
  String get feelTheSpending;

  /// No description provided for @loudAlerts.
  ///
  /// In en, this message translates to:
  /// **'LOUD ALERTS'**
  String get loudAlerts;

  /// No description provided for @screamAtMe.
  ///
  /// In en, this message translates to:
  /// **'SCREAM AT ME'**
  String get screamAtMe;

  /// No description provided for @rawData.
  ///
  /// In en, this message translates to:
  /// **'RAW DATA'**
  String get rawData;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'EXPORT CSV'**
  String get exportCsv;

  /// No description provided for @nukeData.
  ///
  /// In en, this message translates to:
  /// **'NUKE DATA'**
  String get nukeData;

  /// No description provided for @longPressToDetonate.
  ///
  /// In en, this message translates to:
  /// **'LONG PRESS TO DETONATE'**
  String get longPressToDetonate;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'VERSION'**
  String get version;

  /// No description provided for @madeWithRage.
  ///
  /// In en, this message translates to:
  /// **'MADE WITH RAGE & COFFEE'**
  String get madeWithRage;

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'JOINED'**
  String get joined;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'MONTH'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'YEAR'**
  String get year;

  /// No description provided for @digDeeper.
  ///
  /// In en, this message translates to:
  /// **'DIG DEEPER'**
  String get digDeeper;

  /// No description provided for @biometricLock.
  ///
  /// In en, this message translates to:
  /// **'BIOMETRIC LOCK'**
  String get biometricLock;

  /// No description provided for @biometricDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock with fingerprint or face'**
  String get biometricDesc;

  /// No description provided for @biometricPrompt.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity'**
  String get biometricPrompt;

  /// No description provided for @unlockApp.
  ///
  /// In en, this message translates to:
  /// **'UNLOCK'**
  String get unlockApp;

  /// No description provided for @biometricNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric not available on this device'**
  String get biometricNotAvailable;

  /// No description provided for @loginWithAccount.
  ///
  /// In en, this message translates to:
  /// **'LOGIN WITH ACCOUNT'**
  String get loginWithAccount;

  /// No description provided for @appLockBackground.
  ///
  /// In en, this message translates to:
  /// **'APP LOCK'**
  String get appLockBackground;

  /// No description provided for @appLockBackgroundDesc.
  ///
  /// In en, this message translates to:
  /// **'Require auth when resuming app'**
  String get appLockBackgroundDesc;

  /// No description provided for @totalBlownYear.
  ///
  /// In en, this message translates to:
  /// **'TOTAL BLOWN THIS YEAR'**
  String get totalBlownYear;

  /// No description provided for @noExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded'**
  String get noExpenses;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'EXPENSE'**
  String get expense;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'TOTAL INCOME'**
  String get totalIncome;

  /// No description provided for @noIncome.
  ///
  /// In en, this message translates to:
  /// **'No income recorded'**
  String get noIncome;

  /// No description provided for @incomeZones.
  ///
  /// In en, this message translates to:
  /// **'INCOME ZONES'**
  String get incomeZones;

  /// No description provided for @calendarComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Calendar feature coming soon!'**
  String get calendarComingSoon;

  /// No description provided for @overLimit.
  ///
  /// In en, this message translates to:
  /// **'OVER LIMIT'**
  String get overLimit;

  /// No description provided for @violation.
  ///
  /// In en, this message translates to:
  /// **'VIOLATION'**
  String get violation;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'EDIT PROFILE'**
  String get editProfile;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'CURRENCY'**
  String get currency;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordMismatch;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChanged;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect.'**
  String get wrongPassword;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'DISPLAY NAME'**
  String get displayName;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get saveChanges;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'CHANGE PASSWORD'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @tapToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap to change avatar'**
  String get tapToChange;

  /// No description provided for @advancedSettings.
  ///
  /// In en, this message translates to:
  /// **'ADVANCED SETTINGS'**
  String get advancedSettings;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get close;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get invalidCredentials;

  /// No description provided for @biometricNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric login is not enabled'**
  String get biometricNotEnabled;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon...'**
  String get comingSoon;

  /// No description provided for @useBiometric.
  ///
  /// In en, this message translates to:
  /// **'USE BIOMETRICS'**
  String get useBiometric;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
