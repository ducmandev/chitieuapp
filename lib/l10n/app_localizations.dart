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

  /// No description provided for @navBudgets.
  ///
  /// In en, this message translates to:
  /// **'BUDGETS'**
  String get navBudgets;

  /// No description provided for @navGoals.
  ///
  /// In en, this message translates to:
  /// **'GOALS'**
  String get navGoals;

  /// No description provided for @navWallets.
  ///
  /// In en, this message translates to:
  /// **'WALLETS'**
  String get navWallets;

  /// No description provided for @navTemplates.
  ///
  /// In en, this message translates to:
  /// **'TEMPLATES'**
  String get navTemplates;

  /// No description provided for @navStatistics.
  ///
  /// In en, this message translates to:
  /// **'STATISTICS'**
  String get navStatistics;

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

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'EDIT'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get delete;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'ADD'**
  String get add;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'CREATE'**
  String get create;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'UPDATE'**
  String get update;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM'**
  String get confirm;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get done;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'BUDGETS'**
  String get budgets;

  /// No description provided for @budgetLimit.
  ///
  /// In en, this message translates to:
  /// **'BUDGET LIMIT'**
  String get budgetLimit;

  /// No description provided for @setBudget.
  ///
  /// In en, this message translates to:
  /// **'SET BUDGET'**
  String get setBudget;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'PERIOD'**
  String get period;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'REMAINING'**
  String get remaining;

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'OVER BUDGET'**
  String get overBudget;

  /// No description provided for @setCategoryBudget.
  ///
  /// In en, this message translates to:
  /// **'Set spending limit for'**
  String get setCategoryBudget;

  /// No description provided for @noBudgets.
  ///
  /// In en, this message translates to:
  /// **'No budgets set'**
  String get noBudgets;

  /// No description provided for @addBudget.
  ///
  /// In en, this message translates to:
  /// **'ADD BUDGET'**
  String get addBudget;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'EDIT BUDGET'**
  String get editBudget;

  /// No description provided for @deleteBudget.
  ///
  /// In en, this message translates to:
  /// **'DELETE BUDGET'**
  String get deleteBudget;

  /// No description provided for @budgetWarning.
  ///
  /// In en, this message translates to:
  /// **'Budget Warning'**
  String get budgetWarning;

  /// No description provided for @budgetWarningMsg.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used 80% of your budget for'**
  String get budgetWarningMsg;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'GOALS'**
  String get goals;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'GOAL NAME'**
  String get goalName;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'TARGET AMOUNT'**
  String get targetAmount;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'SAVED'**
  String get saved;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'PROGRESS'**
  String get progress;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'DEADLINE'**
  String get deadline;

  /// No description provided for @addGoal.
  ///
  /// In en, this message translates to:
  /// **'ADD GOAL'**
  String get addGoal;

  /// No description provided for @noGoals.
  ///
  /// In en, this message translates to:
  /// **'No goals set'**
  String get noGoals;

  /// No description provided for @goalCompleted.
  ///
  /// In en, this message translates to:
  /// **'GOAL COMPLETED!'**
  String get goalCompleted;

  /// No description provided for @congratsGoal.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You\'ve reached your goal'**
  String get congratsGoal;

  /// No description provided for @addToSavings.
  ///
  /// In en, this message translates to:
  /// **'ADD TO SAVINGS'**
  String get addToSavings;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'days left'**
  String get daysLeft;

  /// No description provided for @deleteGoal.
  ///
  /// In en, this message translates to:
  /// **'DELETE GOAL'**
  String get deleteGoal;

  /// No description provided for @recurring.
  ///
  /// In en, this message translates to:
  /// **'RECURRING'**
  String get recurring;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'FREQUENCY'**
  String get frequency;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @nextDue.
  ///
  /// In en, this message translates to:
  /// **'NEXT DUE'**
  String get nextDue;

  /// No description provided for @isActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get isActive;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'END DATE'**
  String get endDate;

  /// No description provided for @addRecurring.
  ///
  /// In en, this message translates to:
  /// **'ADD RECURRING'**
  String get addRecurring;

  /// No description provided for @noRecurring.
  ///
  /// In en, this message translates to:
  /// **'No recurring transactions'**
  String get noRecurring;

  /// No description provided for @editRecurring.
  ///
  /// In en, this message translates to:
  /// **'EDIT RECURRING'**
  String get editRecurring;

  /// No description provided for @deleteRecurring.
  ///
  /// In en, this message translates to:
  /// **'DELETE RECURRING'**
  String get deleteRecurring;

  /// No description provided for @recurringProcessed.
  ///
  /// In en, this message translates to:
  /// **'Recurring transaction processed'**
  String get recurringProcessed;

  /// No description provided for @wallets.
  ///
  /// In en, this message translates to:
  /// **'WALLETS'**
  String get wallets;

  /// No description provided for @walletName.
  ///
  /// In en, this message translates to:
  /// **'WALLET NAME'**
  String get walletName;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'BALANCE'**
  String get balance;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'TYPE'**
  String get type;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get credit;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// No description provided for @defaultWallet.
  ///
  /// In en, this message translates to:
  /// **'DEFAULT'**
  String get defaultWallet;

  /// No description provided for @addWallet.
  ///
  /// In en, this message translates to:
  /// **'ADD WALLET'**
  String get addWallet;

  /// No description provided for @noWallets.
  ///
  /// In en, this message translates to:
  /// **'No wallets found'**
  String get noWallets;

  /// No description provided for @editWallet.
  ///
  /// In en, this message translates to:
  /// **'EDIT WALLET'**
  String get editWallet;

  /// No description provided for @deleteWallet.
  ///
  /// In en, this message translates to:
  /// **'DELETE WALLET'**
  String get deleteWallet;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'TRANSFER'**
  String get transfer;

  /// No description provided for @transferBetween.
  ///
  /// In en, this message translates to:
  /// **'Transfer between wallets'**
  String get transferBetween;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'FROM'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'TO'**
  String get to;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get amount;

  /// No description provided for @setDefault.
  ///
  /// In en, this message translates to:
  /// **'SET AS DEFAULT'**
  String get setDefault;

  /// No description provided for @templates.
  ///
  /// In en, this message translates to:
  /// **'TEMPLATES'**
  String get templates;

  /// No description provided for @templateName.
  ///
  /// In en, this message translates to:
  /// **'TEMPLATE NAME'**
  String get templateName;

  /// No description provided for @useTemplate.
  ///
  /// In en, this message translates to:
  /// **'USE TEMPLATE'**
  String get useTemplate;

  /// No description provided for @saveAsTemplate.
  ///
  /// In en, this message translates to:
  /// **'SAVE AS TEMPLATE'**
  String get saveAsTemplate;

  /// No description provided for @noTemplates.
  ///
  /// In en, this message translates to:
  /// **'No templates yet'**
  String get noTemplates;

  /// No description provided for @templateSaved.
  ///
  /// In en, this message translates to:
  /// **'Template saved'**
  String get templateSaved;

  /// No description provided for @deleteTemplate.
  ///
  /// In en, this message translates to:
  /// **'DELETE TEMPLATE'**
  String get deleteTemplate;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'SEARCH'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'FILTER'**
  String get filter;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'DATE RANGE'**
  String get dateRange;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'SORT BY'**
  String get sortBy;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'RESULTS'**
  String get results;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get searchPlaceholder;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get last30Days;

  /// No description provided for @last90Days.
  ///
  /// In en, this message translates to:
  /// **'Last 90 Days'**
  String get last90Days;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get newestFirst;

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get oldestFirst;

  /// No description provided for @highestAmount.
  ///
  /// In en, this message translates to:
  /// **'Highest Amount'**
  String get highestAmount;

  /// No description provided for @lowestAmount.
  ///
  /// In en, this message translates to:
  /// **'Lowest Amount'**
  String get lowestAmount;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By Category'**
  String get byCategory;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'REPORTS'**
  String get reports;

  /// No description provided for @exportPDF.
  ///
  /// In en, this message translates to:
  /// **'EXPORT PDF'**
  String get exportPDF;

  /// No description provided for @generateReport.
  ///
  /// In en, this message translates to:
  /// **'GENERATE REPORT'**
  String get generateReport;

  /// No description provided for @monthlyReport.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY REPORT'**
  String get monthlyReport;

  /// No description provided for @yearlyReport.
  ///
  /// In en, this message translates to:
  /// **'YEARLY REPORT'**
  String get yearlyReport;

  /// No description provided for @reportSummary.
  ///
  /// In en, this message translates to:
  /// **'SUMMARY'**
  String get reportSummary;

  /// No description provided for @reportIncome.
  ///
  /// In en, this message translates to:
  /// **'TOTAL INCOME'**
  String get reportIncome;

  /// No description provided for @reportExpense.
  ///
  /// In en, this message translates to:
  /// **'TOTAL EXPENSE'**
  String get reportExpense;

  /// No description provided for @reportNet.
  ///
  /// In en, this message translates to:
  /// **'NET SAVINGS'**
  String get reportNet;

  /// No description provided for @shareReport.
  ///
  /// In en, this message translates to:
  /// **'SHARE REPORT'**
  String get shareReport;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'STATISTICS'**
  String get statistics;

  /// No description provided for @spendingTrend.
  ///
  /// In en, this message translates to:
  /// **'SPENDING TREND'**
  String get spendingTrend;

  /// No description provided for @incomeVsExpense.
  ///
  /// In en, this message translates to:
  /// **'INCOME VS EXPENSE'**
  String get incomeVsExpense;

  /// No description provided for @topCategories.
  ///
  /// In en, this message translates to:
  /// **'TOP CATEGORIES'**
  String get topCategories;

  /// No description provided for @last6Months.
  ///
  /// In en, this message translates to:
  /// **'LAST 6 MONTHS'**
  String get last6Months;

  /// No description provided for @last12Months.
  ///
  /// In en, this message translates to:
  /// **'LAST 12 MONTHS'**
  String get last12Months;

  /// No description provided for @averageSpending.
  ///
  /// In en, this message translates to:
  /// **'AVERAGE SPENDING'**
  String get averageSpending;

  /// No description provided for @monthOverMonth.
  ///
  /// In en, this message translates to:
  /// **'MONTH OVER MONTH'**
  String get monthOverMonth;

  /// No description provided for @onboarding.
  ///
  /// In en, this message translates to:
  /// **'ONBOARDING'**
  String get onboarding;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'WELCOME'**
  String get welcome;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'FINISH'**
  String get finish;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'GET STARTED'**
  String get getStarted;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Track Your Spending'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Keep tabs on where your money goes with Neo.Cash'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Set Budgets'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Create budgets for each category to stay on track'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Reach Your Goals'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Set savings goals and watch your progress grow'**
  String get onboardingDesc3;

  /// No description provided for @categoryManagement.
  ///
  /// In en, this message translates to:
  /// **'CATEGORIES'**
  String get categoryManagement;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'ADD CATEGORY'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'EDIT CATEGORY'**
  String get editCategory;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'DELETE CATEGORY'**
  String get deleteCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY NAME'**
  String get categoryName;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'SELECT ICON'**
  String get selectIcon;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'SELECT COLOR'**
  String get selectColor;

  /// No description provided for @categoryType.
  ///
  /// In en, this message translates to:
  /// **'TYPE'**
  String get categoryType;

  /// No description provided for @categoryWarning.
  ///
  /// In en, this message translates to:
  /// **'This category has transactions. Are you sure?'**
  String get categoryWarning;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'NOTE'**
  String get note;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'TAGS'**
  String get tags;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTag;

  /// No description provided for @noTags.
  ///
  /// In en, this message translates to:
  /// **'No tags'**
  String get noTags;

  /// No description provided for @attachReceipt.
  ///
  /// In en, this message translates to:
  /// **'ATTACH RECEIPT'**
  String get attachReceipt;

  /// No description provided for @changeReceipt.
  ///
  /// In en, this message translates to:
  /// **'CHANGE RECEIPT'**
  String get changeReceipt;

  /// No description provided for @removeReceipt.
  ///
  /// In en, this message translates to:
  /// **'REMOVE RECEIPT'**
  String get removeReceipt;

  /// No description provided for @selectWallet.
  ///
  /// In en, this message translates to:
  /// **'SELECT WALLET'**
  String get selectWallet;

  /// No description provided for @allWallets.
  ///
  /// In en, this message translates to:
  /// **'ALL WALLETS'**
  String get allWallets;

  /// No description provided for @encryption.
  ///
  /// In en, this message translates to:
  /// **'ENCRYPTION'**
  String get encryption;

  /// No description provided for @exportEncrypted.
  ///
  /// In en, this message translates to:
  /// **'EXPORT ENCRYPTED BACKUP'**
  String get exportEncrypted;

  /// No description provided for @importEncrypted.
  ///
  /// In en, this message translates to:
  /// **'IMPORT ENCRYPTED BACKUP'**
  String get importEncrypted;

  /// No description provided for @backupPassword.
  ///
  /// In en, this message translates to:
  /// **'BACKUP PASSWORD'**
  String get backupPassword;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'ENTER PASSWORD'**
  String get enterPassword;

  /// No description provided for @passwordsMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords match'**
  String get passwordsMatch;

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully'**
  String get backupCreated;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored successfully'**
  String get backupRestored;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup operation failed'**
  String get backupFailed;

  /// No description provided for @selectStartDate.
  ///
  /// In en, this message translates to:
  /// **'SELECT START DATE'**
  String get selectStartDate;

  /// No description provided for @selectEndDate.
  ///
  /// In en, this message translates to:
  /// **'SELECT END DATE'**
  String get selectEndDate;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'APPLY'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'RESET'**
  String get reset;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'PREVIOUS'**
  String get previous;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY'**
  String get category;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'TITLE'**
  String get title;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get date;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'REMOVE'**
  String get remove;

  /// No description provided for @importCsv.
  ///
  /// In en, this message translates to:
  /// **'IMPORT CSV'**
  String get importCsv;
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
