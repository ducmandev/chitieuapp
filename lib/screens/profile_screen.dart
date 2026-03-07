import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../widgets/neo_card.dart';
import '../widgets/neo_button.dart';
import '../providers/app_provider.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  final TextEditingController _currentPassCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _savingName = false;
  bool _savingPassword = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _nameCtrl = TextEditingController(text: provider.profileName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // ─── Avatar initials ───────────────────────────────────────────────────────

  String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words[0].isNotEmpty ? words[0][0].toUpperCase() : '?';
    }
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }

  Color _avatarColor(String name) {
    final colors = [
      NeoColors.primary,
      NeoColors.secondary,
      NeoColors.tertiary,
      Colors.green.shade400,
      Colors.deepPurple.shade300,
      Colors.orange.shade400,
    ];
    final code = name.isNotEmpty ? name.codeUnitAt(0) : 0;
    return colors[code % colors.length];
  }

  // ─── Save name ─────────────────────────────────────────────────────────────

  Future<void> _saveName() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _savingName = true);
    await context.read<AppProvider>().updateDisplayName(name);
    setState(() => _savingName = false);
    if (mounted) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: NeoColors.ink,
          content: Text(
            '✓ SAVED',
            style: NeoTypography.mono.copyWith(
              color: NeoColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ─── Save password ─────────────────────────────────────────────────────────

  Future<void> _savePassword() async {
    final loc = AppLocalizations.of(context)!;
    final current = _currentPassCtrl.text;
    final newPass = _newPassCtrl.text;
    final confirm = _confirmPassCtrl.text;

    if (newPass != confirm) {
      _showError(loc.passwordMismatch);
      return;
    }
    if (newPass.length < 4) {
      _showError('Password must be at least 4 characters.');
      return;
    }

    setState(() => _savingPassword = true);
    final success = await context.read<AppProvider>().updatePassword(
      current,
      newPass,
    );
    setState(() => _savingPassword = false);

    if (!mounted) return;

    if (success) {
      _currentPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: NeoColors.ink,
          content: Text(
            loc.passwordChanged,
            style: NeoTypography.mono.copyWith(
              color: NeoColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      _showError(loc.wrongPassword);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: NeoColors.error,
        content: Text(
          msg,
          style: NeoTypography.mono.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final loc = AppLocalizations.of(context)!;
    final name = provider.profileName;
    final neo = NeoTheme.of(context);

    return Scaffold(
      backgroundColor: neo.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, loc),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 100),
                    children: [
                      // ── Avatar ────────────────────────────────────────
                      _buildAvatarSection(name, loc, neo),
                      const SizedBox(height: 40),

                      // ── Display name ──────────────────────────────────
                      _buildSectionLabel(loc.displayName, context),
                      const SizedBox(height: 12),
                      _buildNeoTextField(
                        controller: _nameCtrl,
                        hint: 'Enter your name...',
                        icon: Icons.person,
                        ctx: context,
                      ),
                      const SizedBox(height: 12),
                      AbsorbPointer(
                        absorbing: _savingName,
                        child: NeoButton(
                          onPressed: () => _saveName(),
                          backgroundColor: neo.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: _savingName
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: neo.ink,
                                  ),
                                )
                              : Text(
                                  loc.saveChanges,
                                  style: NeoTypography.mono.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // ── Password section ──────────────────────────────
                      _buildSectionLabel(loc.changePassword, context),
                      const SizedBox(height: 12),
                      _buildNeoTextField(
                        controller: _currentPassCtrl,
                        hint: loc.currentPassword,
                        icon: Icons.lock_outline,
                        obscure: _obscureCurrent,
                        toggleObscure: () =>
                            setState(() => _obscureCurrent = !_obscureCurrent),
                        ctx: context,
                      ),
                      const SizedBox(height: 12),
                      _buildNeoTextField(
                        controller: _newPassCtrl,
                        hint: loc.newPassword,
                        icon: Icons.lock,
                        obscure: _obscureNew,
                        toggleObscure: () =>
                            setState(() => _obscureNew = !_obscureNew),
                        ctx: context,
                      ),
                      const SizedBox(height: 12),
                      _buildNeoTextField(
                        controller: _confirmPassCtrl,
                        hint: loc.confirmNewPassword,
                        icon: Icons.lock_reset,
                        obscure: _obscureConfirm,
                        toggleObscure: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        ctx: context,
                      ),
                      const SizedBox(height: 12),
                      AbsorbPointer(
                        absorbing: _savingPassword,
                        child: NeoButton(
                          onPressed: () => _savePassword(),
                          backgroundColor: neo.ink,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: _savingPassword
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: neo.primary,
                                  ),
                                )
                              : Text(
                                  loc.changePassword,
                                  style: NeoTypography.mono.copyWith(
                                    color: neo.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 40),
                      // ── Account info (read-only) ──────────────────────
                      _buildInfoCard(context, provider, loc),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Widgets ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, AppLocalizations loc) {
    final neo = NeoTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: neo.background,
        border: Border(bottom: BorderSide(color: neo.ink, width: 3)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: neo.surface,
                border: Border.all(color: neo.ink, width: 3),
                boxShadow: [
                  BoxShadow(color: neo.ink, offset: const Offset(3, 3)),
                ],
              ),
              child: Icon(Icons.arrow_back, color: neo.textMain),
            ),
          ),
          const SizedBox(width: 16),
          Transform(
            transform: Matrix4.skewX(-0.1),
            child: Text(
              loc.editProfile,
              style: NeoTypography.textTheme.displayMedium?.copyWith(
                fontStyle: FontStyle.italic,
                letterSpacing: -1,
                fontSize: 26,
                height: 1,
                color: neo.textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(
    String name,
    AppLocalizations loc,
    NeoThemeData neo,
  ) {
    final initials = _initials(name);
    final avatarColor = _avatarColor(name);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Shadow layer
            Positioned(
              top: 8,
              left: 8,
              child: Container(width: 100, height: 100, color: neo.ink),
            ),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: avatarColor,
                border: Border.all(color: neo.inkOnCard, width: 3),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: NeoTypography.numbers.copyWith(
                  fontSize: 36,
                  color: NeoColors.ink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: NeoTypography.textTheme.headlineMedium?.copyWith(
            height: 1,
            color: neo.textMain,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          loc.tapToChange,
          style: NeoTypography.mono.copyWith(
            fontSize: 10,
            color: neo.textSub,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label, BuildContext context) {
    final neo = NeoTheme.of(context);
    return Row(
      children: [
        Container(width: 4, height: 20, color: neo.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: NeoTypography.mono.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 2,
            color: neo.textMain,
          ),
        ),
      ],
    );
  }

  Widget _buildNeoTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    VoidCallback? toggleObscure,
    BuildContext? ctx,
  }) {
    final neo = ctx != null ? NeoTheme.of(ctx) : NeoThemeData.light;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: neo.surface,
        border: Border.all(color: neo.inkOnCard, width: 3),
        boxShadow: [
          BoxShadow(color: neo.inkOnCard, offset: const Offset(4, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: double.infinity,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: neo.inkOnCard, width: 3)),
            ),
            child: Icon(icon, color: neo.textMain),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              style: NeoTypography.textTheme.titleMedium?.copyWith(
                color: neo.textMain,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: NeoTypography.mono.copyWith(
                  color: neo.textSub,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          if (toggleObscure != null)
            GestureDetector(
              onTap: toggleObscure,
              child: Container(
                width: 52,
                height: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: neo.inkOnCard, width: 3),
                  ),
                ),
                child: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: neo.textMain,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    AppProvider provider,
    AppLocalizations loc,
  ) {
    final neo = NeoTheme.of(context);
    return NeoCard(
      backgroundColor: neo.surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.userProfile,
            style: NeoTypography.mono.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 2,
              color: neo.textSub,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            Icons.account_circle,
            'LOGIN ID',
            provider.username ?? '—',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: neo.inkOnCard),
          ),
          _buildInfoRow(
            context,
            Icons.calendar_month,
            loc.joined,
            provider.joinDate ?? '—',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final neo = NeoTheme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: neo.textSub),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: NeoTypography.mono.copyWith(
                fontSize: 10,
                color: neo.textSub,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: NeoTypography.textTheme.titleMedium?.copyWith(
                fontSize: 16,
                height: 1.2,
                color: neo.textMain,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
