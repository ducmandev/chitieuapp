# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Neo.Cash is a personal finance manager built with Flutter, featuring a Neo-Brutalism design system. The app tracks expenses, manages budgets, handles multiple wallets, and supports recurring transactions.

## Development Commands

```bash
# Install dependencies
flutter pub get

# Run the app (specify platform)
flutter run -d macos
flutter run -d windows
flutter run -d chrome

# Generate localization files after modifying ARB files
flutter gen-l10n

# Build for release
flutter build macos
flutter build windows
flutter build apk

# Run tests
flutter test
```

## Architecture

### State Management
- **Provider** pattern with `AppProvider` as the central state container
- Located in `lib/providers/app_provider.dart`
- Manages all application data: transactions, budgets, goals, wallets, recurring transactions, templates
- Handles user settings: language, currency, theme, biometric auth

### Data Layer
- **SQLite** via `sqflite` package (mobile) and `sqflite_common_ffi` (desktop)
- `DatabaseHelper` singleton in `lib/services/database_helper.dart`
- Database version is 2 - see `_onUpgrade()` for migration logic
- All models use `toMap()` and `fromMap()` for serialization

### Models
All models in `lib/models/` follow this pattern:
- `TransactionModel` - transactions with wallet association
- `BudgetModel` - category-based spending limits
- `GoalModel` - savings goals with progress tracking
- `RecurringTransactionModel` - automated recurring transactions
- `WalletModel` - multiple wallet/account support
- `TransactionTemplateModel` - reusable transaction templates

### Theme System
- **Neo-Brutalism design** with high-contrast colors and bold borders
- Access via `NeoTheme.of(context)` in widgets
- Light/dark theme support via `NeoThemeData.light` and `NeoThemeData.dark`
- Color tokens in `lib/theme/colors.dart`
- Custom `ThemeExtension` pattern defined in `lib/theme/neo_theme.dart`

### Localization
- ARB files in `lib/l10n/`: `app_en.arb` (English) and `app_vi.arb` (Vietnamese)
- Supported locales: `en`, `vi`
- Run `flutter gen-l10n` after modifying ARB files
- Currency symbols: `USD` ($), `VND` (₫)

### Navigation
- `MainLayout` serves as the navigation hub
- Bottom navigation for mobile (`NeoBottomNav`)
- Side navigation for desktop (`NeoSideNav`)
- Routes: Home/Dashboard, Transactions, Statistics/Reports, Settings

## Key Patterns

### Adding a New Feature
1. Create model in `lib/models/` with `toMap()`/`fromMap()`
2. Add database table in `DatabaseHelper._createDB()` and upgrade path in `_onUpgrade()`
3. Add CRUD methods in `DatabaseHelper` (grouped by comment sections)
4. Add state and methods in `AppProvider` (grouped by comment sections)
5. Create screen in `lib/screens/` and widgets in `lib/widgets/`

### Wallet System
- Transactions are linked to wallets via `walletId`
- Adding a transaction automatically adjusts wallet balance
- `selectedWallet` tracks current active wallet in AppProvider
- Default wallet is auto-created on first login

### Recurring Transactions
- Processed on app startup via `processDueRecurring()`
- Calculates next due date and creates transaction automatically
- Supports daily, weekly, monthly, yearly frequencies
- Can have optional end dates

### Category Utilities
- `CategoryUtils` provides icons and colors for categories
- Supports both English and Vietnamese category names
- Located in `lib/utils/category_utils.dart`

## Platform Support

The app supports mobile (Android, iOS) and desktop (macOS, Windows, Linux). Desktop platforms use `sqflite_common_ffi` for database support.

## Important Notes

- Default currency is USD, default balance is 5,000,000 (VND equivalent)
- Biometric lock is optional and platform-dependent
- Haptic feedback is enabled by default and can be toggled
- The app uses Material 3 (`useMaterial3: true`)
- Date format in database: ISO 8601 string
- Boolean values stored as INTEGER (0/1) in SQLite
