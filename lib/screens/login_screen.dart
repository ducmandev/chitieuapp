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

    final hasAccount = await PrefsHelper.hasRegisteredUser();
    if (!hasAccount) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noAccount)),
        );
      }
      return;
    }

    final isValid = await PrefsHelper.checkCredentials(username, password);
    if (!isValid) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
      }
      return;
    }

    if (!mounted) return;
    await context.read<AppProvider>().login(username, 0.0, 5000000.0);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
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
                const SnackBar(content: Text('Feature coming soon...')),
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
