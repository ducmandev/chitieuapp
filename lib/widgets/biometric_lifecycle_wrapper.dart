import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/neo_theme.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';

class BiometricLifecycleWrapper extends StatefulWidget {
  final Widget child;

  const BiometricLifecycleWrapper({super.key, required this.child});

  @override
  State<BiometricLifecycleWrapper> createState() =>
      _BiometricLifecycleWrapperState();
}

class _BiometricLifecycleWrapperState extends State<BiometricLifecycleWrapper>
    with WidgetsBindingObserver {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isLocked = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App went to background
      final provider = context.read<AppProvider>();
      if (provider.appLockEnabled && provider.username != null) {
        setState(() {
          _isLocked = true;
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      // App came to foreground
      if (_isLocked && !_isAuthenticating) {
        _authenticate();
      }
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
          biometricOnly: false,
        ),
      );

      if (didAuthenticate) {
        if (mounted) {
          setState(() {
            _isLocked = false;
          });
        }
      }
    } on PlatformException {
      // Device might not support it properly or user cancelled repeatedly
      // We will allow unlock if it throws platform exception to mirror previous logic
      if (mounted) {
        setState(() {
          _isLocked = false;
        });
      }
    } catch (_) {
      // Authentication cancelled by user
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isLocked) Positioned.fill(child: _buildLockOverlay(context)),
      ],
    );
  }

  Widget _buildLockOverlay(BuildContext context) {
    final neo = NeoTheme.of(context);

    return Material(
      color: neo.ink,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 80, color: neo.primary),
              const SizedBox(height: 24),
              Text(
                'LOCKED',
                style: TextStyle(
                  color: neo.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 48),
              if (_isAuthenticating)
                CircularProgressIndicator(color: neo.primary)
              else
                ElevatedButton.icon(
                  onPressed: _authenticate,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('UNLOCK'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neo.primary,
                    foregroundColor: neo.inkOnCard,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
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
