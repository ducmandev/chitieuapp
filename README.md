# Neo.Cash - Personal Finance Manager

A modern, Neo-Brutalism-styled personal finance manager built with Flutter. Track your expenses, manage your budget, and visualize your spending habits with a unique, high-contrast aesthetic.

## Features

- **Neo-Brutalism UI**: A striking design system featuring high-contrast colors, bold typography, and glassmorphism effects.
- **Transaction Management**: Add, view, and delete daily transactions.
- **Budget Tracking**: Set a monthly spending cap and monitor your progress.
- **Data Persistence**: Uses `sqflite` for local database storage and `shared_preferences` for user settings.
- **Responsive Design**: Optimized for both desktop (Windows/Linux/Mac) and mobile.

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher.
- For desktop development:
  - Windows: Visual Studio with C++ Desktop Development workload.
  - Linux: CMake and Ninja.
  - macOS: Xcode.

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd chitieuapp
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## Usage

- **Login**: The app starts with a login screen. You can enter any username to proceed. The default initial balance is 5,000,000 VND.
- **Navigation**: Use the bottom navigation bar to switch between Home, Tape (Transactions), Stats, and Settings.
- **Add Transactions**: Navigate to the Home screen and tap the large '+' button to add a new expense or income.
- **Settings**: Adjust your monthly budget cap and view your account details.

## Project Structure

- `lib/main.dart`: Entry point of the application.
- `lib/providers/app_provider.dart`: Manages application state and user data.
- `lib/screens/`: Contains all the UI screens.
- `lib/theme/`: Defines the Neo-Brutalism color palette and typography.
- `lib/widgets/`: Reusable UI components.
- `lib/services/`: Handles database and preference operations.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
