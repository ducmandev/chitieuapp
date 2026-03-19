import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/colors.dart';
import 'theme/typography.dart';
import 'theme/neo_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_layout.dart';
import 'screens/biometric_lock_screen.dart';
import 'widgets/biometric_lifecycle_wrapper.dart';
import 'providers/app_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppProvider())],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: NeoColors.backgroundLight,
              body: Center(
                child: CircularProgressIndicator(color: NeoColors.primary),
              ),
            ),
          );
        }

        return MaterialApp(
          builder: (context, child) {
            return BiometricLifecycleWrapper(child: child!);
          },
          title: 'Neobrutalist Finance',
          debugShowCheckedModeBanner: false,
          locale: provider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('vi'), // Vietnamese
          ],
          themeMode: provider.darkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            scaffoldBackgroundColor: NeoColors.backgroundLight,
            colorScheme: ColorScheme.fromSeed(
              seedColor: NeoColors.primary,
              surface: NeoColors.surface,
              error: NeoColors.error,
            ),
            textTheme: NeoTypography.textTheme,
            extensions: const [NeoThemeData.light],
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF111111),
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: NeoColors.primary,
              surface: const Color(0xFF1E1E1E),
              error: NeoColors.error,
            ),
            cardColor: const Color(0xFF1E1E1E),
            textTheme: NeoTypography.textTheme.apply(
              bodyColor: const Color(0xFFF2F0E9),
              displayColor: const Color(0xFFF2F0E9),
            ),
            extensions: const [NeoThemeData.dark],
            useMaterial3: true,
          ),
          home: provider.username != null
              ? (provider.biometricEnabled
                    ? const BiometricLockScreen()
                    : const MainLayout())
              : const LoginScreen(),
        );
      },
    );
  }
}
