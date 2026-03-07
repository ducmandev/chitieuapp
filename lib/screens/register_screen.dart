import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../widgets/neo_button.dart';
import '../widgets/neo_text_field.dart';
import '../services/prefs_helper.dart';
import 'main_layout.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _register() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (username.isEmpty || password.isEmpty || password != confirm) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid inputs or passwords do not match'),
          ),
        );
      }
      return;
    }

    await PrefsHelper.registerUser(username, password);

    if (!mounted) return;
    await context.read<AppProvider>().login(username, 0.0, 5000000.0);
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final neo = NeoTheme.of(context);
    return Scaffold(
      backgroundColor: neo.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: NeoButton(
          padding: EdgeInsets.zero,
          backgroundColor: neo.surface,
          onPressed: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: neo.textMain),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTitle(context, neo),
                  const SizedBox(height: 32),
                  _buildForm(context, neo),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, NeoThemeData neo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.rotate(
          angle: -0.05,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: neo.tertiary,
              border: Border.all(color: neo.inkOnCard, width: 3),
              boxShadow: [
                BoxShadow(color: neo.inkOnCard, offset: const Offset(4, 4)),
              ],
            ),
            child: Text(
              AppLocalizations.of(context)!.joinTheCult,
              style: NeoTypography.textTheme.headlineMedium?.copyWith(
                letterSpacing: 2,
                color: neo.inkOnCard,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.registerSubtitle,
          style: NeoTypography.mono.copyWith(color: neo.textSub, fontSize: 16),
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
          labelText: AppLocalizations.of(context)!.emailAddress,
          hintText: AppLocalizations.of(context)!.emailHint,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email,
        ),
        const SizedBox(height: 24),
        NeoTextField(
          controller: _passwordController,
          labelText: AppLocalizations.of(context)!.createPassword,
          hintText: AppLocalizations.of(context)!.createPasswordHint,
          isPassword: true,
          prefixIcon: Icons.lock,
        ),
        const SizedBox(height: 24),
        NeoTextField(
          controller: _confirmController,
          labelText: AppLocalizations.of(context)!.confirmPassword,
          hintText: AppLocalizations.of(context)!.confirmPasswordHint,
          isPassword: true,
          prefixIcon: Icons.verified_user,
        ),
        const SizedBox(height: 32),
        NeoButton(
          backgroundColor: neo.primary,
          padding: const EdgeInsets.symmetric(vertical: 20),
          onPressed: _register,
          child: Text(
            AppLocalizations.of(context)!.createAccount,
            style: NeoTypography.textTheme.headlineMedium?.copyWith(
              color: neo.inkOnCard,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.alreadyRegret,
              style: NeoTypography.mono.copyWith(
                fontWeight: FontWeight.bold,
                color: neo.textMain,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(
                  context,
                )!.loginNow.split(' ')[0], // just 'LOGIN' roughly
                style: NeoTypography.mono.copyWith(
                  fontWeight: FontWeight.bold,
                  color: neo.secondary,
                  decoration: TextDecoration.underline,
                  decorationThickness: 2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
