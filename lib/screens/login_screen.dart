import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_text_field.dart';
import '../services/prefs_helper.dart';
import 'register_screen.dart';
import 'main_layout.dart';
import 'onboarding_screen.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final loc = AppLocalizations.of(context)!;
    final provider = context.read<AppProvider>();

    final hasAccount = await PrefsHelper.hasRegisteredUser();
    if (!context.mounted) return;

    if (!hasAccount) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(loc.noAccount)),
      );
      return;
    }

    final isValid = await PrefsHelper.checkCredentials(username, password);
    if (!context.mounted) return;

    if (!isValid) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(loc.invalidCredentials)),
      );
      return;
    }

    await provider.login(username, 0.0, 5000000.0);
    if (!context.mounted) return;

    if (!provider.onboardingCompleted) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
    }
  }

  void _loginWithBiometrics() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final loc = AppLocalizations.of(context)!;
    final provider = context.read<AppProvider>();

    final hasAccount = await PrefsHelper.hasRegisteredUser();
    if (!context.mounted) return;

    if (!hasAccount) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(loc.noAccount)),
      );
      return;
    }

    // Check if biometric was enabled by the user previously
    if (!provider.biometricEnabled) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(loc.biometricNotEnabled),
        ),
      );
      return;
    }

    try {
      final auth = LocalAuthentication();
      final canCheck = await auth.canCheckBiometrics;
      final isSupported = await auth.isDeviceSupported();
      if (!context.mounted) return;

      if (!canCheck && !isSupported) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(loc.biometricNotAvailable),
          ),
        );
        return;
      }

      final didAuthenticate = await auth.authenticate(
        localizedReason: loc.biometricPrompt,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      if (!context.mounted) return;

      if (didAuthenticate) {
        // Proceed login with a default local session since biometric passed
        final username = await PrefsHelper.getRegisteredUser() ?? 'User';
        if (!context.mounted) return;

        await provider.login(username, 0.0, 5000000.0);
        if (!context.mounted) return;

        if (!provider.onboardingCompleted) {
          navigator.pushReplacement(
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        } else {
          navigator.pushReplacement(
            MaterialPageRoute(builder: (context) => const MainLayout()),
          );
        }
      }
    } on PlatformException catch (e) {
      debugPrint('Biometric Error: $e');
      if (!context.mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(loc.biometricNotAvailable),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final neo = NeoTheme.of(context);
    return Scaffold(
      backgroundColor: neo.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  _buildLogo(neo),
                  const SizedBox(height: 48),
                  _buildTitle(context, neo),
                  const SizedBox(height: 32),
                  _buildForm(context, neo),
                  const SizedBox(height: 48),
                  _buildFooter(context, neo),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(NeoThemeData neo) {
    return Center(
      child: Transform.rotate(
        angle: -0.05,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: neo.primary,
            border: Border.all(color: neo.inkOnCard, width: 4),
            boxShadow: [
              BoxShadow(color: neo.inkOnCard, offset: const Offset(6, 6)),
            ],
          ),
          child: Icon(Icons.flash_on, size: 64, color: neo.inkOnCard),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, NeoThemeData neo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.appTitle,
          style: NeoTypography.textTheme.displayLarge?.copyWith(
            fontSize: 48,
            letterSpacing: -2,
            height: 1,
            color: neo.textMain,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: neo.ink,
          child: Text(
            AppLocalizations.of(context)!.loginSystem,
            style: NeoTypography.mono.copyWith(
              color: neo.tertiary,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, NeoThemeData neo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NeoTextField(
          controller: _usernameController,
          labelText: AppLocalizations.of(context)!.usernameOrEmail,
          hintText: AppLocalizations.of(context)!.usernameHint,
          prefixIcon: Icons.person,
        ),
        const SizedBox(height: 24),
        NeoTextField(
          controller: _passwordController,
          labelText: AppLocalizations.of(context)!.password,
          hintText: AppLocalizations.of(context)!.passwordHint,
          isPassword: true,
          prefixIcon: Icons.lock,
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.comingSoon)),
              );
            },
            style: TextButton.styleFrom(foregroundColor: neo.textMain),
            child: Text(
              AppLocalizations.of(context)!.forgotPassword,
              style: NeoTypography.mono.copyWith(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                color: neo.textMain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        NeoButton(
          backgroundColor: neo.secondary,
          padding: const EdgeInsets.symmetric(vertical: 20),
          onPressed: _login,
          child: Text(
            AppLocalizations.of(context)!.loginNow,
            style: NeoTypography.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Biometric Login Button
        Builder(
          builder: (context) {
            final isBioEnabled = context.watch<AppProvider>().biometricEnabled;
            if (!isBioEnabled) return const SizedBox.shrink();

            return NeoButton(
              backgroundColor: neo.surface,
              padding: const EdgeInsets.symmetric(vertical: 20),
              onPressed: _loginWithBiometrics,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fingerprint, color: neo.textMain, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.useBiometric,
                    style: NeoTypography.textTheme.headlineMedium?.copyWith(
                      color: neo.textMain,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, NeoThemeData neo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.noAccount,
          style: NeoTypography.mono.copyWith(
            fontWeight: FontWeight.bold,
            color: neo.textMain,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: neo.tertiary,
              border: Border.all(color: neo.inkOnCard, width: 2),
            ),
            child: Text(
              AppLocalizations.of(context)!.register,
              style: NeoTypography.mono.copyWith(
                fontWeight: FontWeight.bold,
                color: neo.inkOnCard,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
