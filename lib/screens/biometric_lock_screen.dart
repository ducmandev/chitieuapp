import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../widgets/neo_button.dart';
import '../providers/app_provider.dart';
import 'main_layout.dart';
import 'login_screen.dart';

class BiometricLockScreen extends StatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    // Auto-trigger biometric on mount
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _goToMainLayout() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    }
  }

  void _goToLogin() {
    // Disable biometric so user won't get stuck in a loop
    context.read<AppProvider>().toggleBiometric(false);
    context.read<AppProvider>().logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    try {
      final loc = AppLocalizations.of(context)!;
      final didAuthenticate = await _auth.authenticate(
        localizedReason: loc.biometricPrompt,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow Windows Hello PIN, fingerprint, face
        ),
      );

      if (didAuthenticate) {
        _goToMainLayout();
      }
    } on PlatformException {
      // Platform doesn't support biometrics properly — skip lock
      _goToMainLayout();
    } catch (_) {
      // Authentication cancelled by user — stay on lock screen
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final neo = NeoTheme.of(context);
    return Scaffold(
      backgroundColor: neo.ink,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App title
              Text(
                loc.appTitle,
                style: NeoTypography.textTheme.displayLarge?.copyWith(
                  color: neo.primary,
                  fontSize: 48,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: neo.primary, width: 2),
                ),
                child: Text(
                  'LOCKED',
                  style: NeoTypography.mono.copyWith(
                    color: neo.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                  ),
                ),
              ),
              const SizedBox(height: 64),

              // Fingerprint icon with pulse animation
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: neo.primary.withValues(alpha: 0.1),
                    border: Border.all(color: neo.primary, width: 3),
                    borderRadius: BorderRadius.circular(80),
                    boxShadow: [
                      BoxShadow(
                        color: neo.primary.withValues(alpha: 0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(Icons.fingerprint, size: 80, color: neo.primary),
                ),
              ),
              const SizedBox(height: 48),

              // Prompt text
              Text(
                loc.biometricPrompt,
                style: NeoTypography.mono.copyWith(
                  color: neo.surface.withValues(alpha: 0.7),
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 32),

              // Unlock button
              SizedBox(
                width: 220,
                child: NeoButton(
                  backgroundColor: neo.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  borderRadius: BorderRadius.circular(8),
                  onPressed: _isAuthenticating ? () {} : _authenticate,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isAuthenticating
                            ? Icons.hourglass_top
                            : Icons.lock_open,
                        color: neo.inkOnCard,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isAuthenticating ? '...' : loc.unlockApp,
                        style: NeoTypography.textTheme.headlineMedium?.copyWith(
                          color: neo.inkOnCard,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Fallback: Login with account
              GestureDetector(
                onTap: _goToLogin,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: neo.surface.withValues(alpha: 0.38),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: neo.surface.withValues(alpha: 0.6),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        loc.loginWithAccount,
                        style: NeoTypography.mono.copyWith(
                          color: neo.surface.withValues(alpha: 0.6),
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
