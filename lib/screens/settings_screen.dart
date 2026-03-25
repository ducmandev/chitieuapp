import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';
import '../theme/typography.dart';
import '../widgets/neo_card.dart';
import 'package:chitieuapp/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/transaction.dart';
import '../app_config.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final neo = NeoTheme.of(context);
    return Scaffold(
      backgroundColor: neo.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: ListView(
                    padding: const EdgeInsets.only(
                      top: 24,
                      bottom: 100,
                      left: 20,
                      right: 20,
                    ),
                    children: [
                      _buildProfileCard(context),
                      _buildSectionTitle(
                        context,
                        AppLocalizations.of(context)!.systemPrefs,
                        NeoColors.primary,
                      ),
                      const SizedBox(height: 16),
                      _buildLanguageSelect(context),
                      const SizedBox(height: 12),
                      _buildDarkModeToggle(context),
                      _buildSectionTitle(
                        context,
                        AppLocalizations.of(context)!.rawData,
                        NeoColors.tertiary,
                        true,
                      ),
                      const SizedBox(height: 16),
                      _buildCurrencySelect(context),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildExportButton(context)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildImportButton(context)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildLogoutButton(context),
                      const SizedBox(height: 32),
                      _buildDangerZoneSection(context),
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

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final neo = NeoTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: neo.background,
        border: Border(bottom: BorderSide(color: neo.ink, width: 3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Transform(
            transform: Matrix4.skewX(-0.1),
            child: Text(
              AppLocalizations.of(context)!.settings,
              style: NeoTypography.textTheme.displayMedium?.copyWith(
                fontStyle: FontStyle.italic,
                letterSpacing: -1,
                fontSize: 28,
                height: 1,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showAdvancedSettings(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: NeoColors.secondary,
                border: Border.all(color: neo.ink, width: 2),
              ),
              child: const Icon(Icons.settings, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Profile Card ──────────────────────────────────────────────────────────

  Widget _buildProfileCard(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final loc = AppLocalizations.of(context)!;
    final neo = NeoTheme.of(context);

    final name = provider.profileName;

    // Avatar color based on first letter
    final avatarColors = [
      NeoColors.primary,
      NeoColors.secondary,
      NeoColors.tertiary,
      Colors.green.shade400,
      Colors.deepPurple.shade300,
    ];
    final avatarColor = name.isNotEmpty
        ? avatarColors[name.codeUnitAt(0) % avatarColors.length]
        : NeoColors.tertiary;

    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    final netVal = provider.netWorth;
    final statusText = netVal >= 0 ? loc.statusBallin : loc.statusBroke;

    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
      },
      child: Stack(
        children: [
          Positioned.fill(top: 4, left: 4, child: Container(color: neo.ink)),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: neo.surface,
              border: Border.all(color: neo.inkOnCard, width: 3),
            ),
            child: Row(
              children: [
                // Avatar with initials
                Stack(
                  children: [
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        width: 72,
                        height: 72,
                        color: neo.inkOnCard,
                      ),
                    ),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: provider.avatarPath == null ? avatarColor : neo.inkOnCard,
                        border: Border.all(color: neo.inkOnCard, width: 3),
                        image: provider.avatarPath != null
                            ? DecorationImage(
                                image: FileImage(
                                    File(provider.avatarPath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: provider.avatarPath == null
                          ? Text(
                              initials.isEmpty ? '?' : initials,
                              style: NeoTypography.numbers.copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: NeoColors.ink, // Avatar text always black
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        color: neo.inkOnCard,
                        child: Text(
                          statusText,
                          style: NeoTypography.mono.copyWith(
                            color: neo.surface,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: NeoTypography.textTheme.headlineMedium?.copyWith(
                          height: 1,
                          fontSize: 20,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${loc.joined}: ${provider.joinDate ?? '—'}',
                        style: NeoTypography.mono.copyWith(
                          color: neo.textSub,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit chevron
                Icon(Icons.chevron_right, color: neo.textMain),
              ],
            ),
          ),
          // "EDIT" badge top-right
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: NeoColors.primary,
              child: Text(
                loc.editProfile,
                style: NeoTypography.mono.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: NeoColors.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section Title ─────────────────────────────────────────────────────────

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    Color bgTag, [
    bool rotateRight = false,
  ]) {
    final neo = NeoTheme.of(context);
    final isTransparent = bgTag == Colors.transparent;
    return Row(
      children: [
        Container(width: 16, height: 16, color: neo.ink),
        const SizedBox(width: 16),
        Transform.rotate(
          angle: rotateRight ? 0.02 : -0.02,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: bgTag,
              border: Border.all(color: neo.inkOnCard, width: 2),
              boxShadow: [
                BoxShadow(color: neo.ink, offset: const Offset(2, 2)),
              ],
            ),
            child: Text(
              title,
              style: NeoTypography.textTheme.titleLarge?.copyWith(
                color: isTransparent ? neo.textMain : NeoColors.ink,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Container(height: 4, color: neo.ink)),
      ],
    );
  }

  // ─── Language Select ───────────────────────────────────────────────────────

  Widget _buildLanguageSelect(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final loc = AppLocalizations.of(context)!;
    final currentLang = provider.locale.languageCode;
    final displayLabel = currentLang == 'en' ? loc.english : loc.vietnamese;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.language,
          style: NeoTypography.textTheme.titleMedium?.copyWith(
            fontSize: 18,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          loc.languageDesc,
          style: NeoTypography.mono.copyWith(
            fontSize: 12,
            color: NeoTheme.of(context).textSub,
          ),
        ),
        const SizedBox(height: 12),
        _buildNeoDropdownButton(
          context: context,
          icon: Icons.language,
          label: displayLabel,
          onTap: () => _showNeoBottomSheet(
            context: context,
            title: loc.language,
            options: [
              _NeoOption(
                value: 'en',
                label: loc.english,
                icon: Icons.language,
                isSelected: currentLang == 'en',
              ),
              _NeoOption(
                value: 'vi',
                label: loc.vietnamese,
                icon: Icons.language,
                isSelected: currentLang == 'vi',
              ),
            ],
            onSelected: (val) =>
                context.read<AppProvider>().changeLanguage(val),
          ),
        ),
      ],
    );
  }

  // ─── Currency Select ───────────────────────────────────────────────────────

  Widget _buildCurrencySelect(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final loc = AppLocalizations.of(context)!;
    final cur = provider.currency;
    final displayLabel = cur == 'USD' ? 'USD (\$)' : 'VNĐ (₫)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.currency,
          style: NeoTypography.textTheme.titleMedium?.copyWith(
            fontSize: 18,
            height: 1,
          ),
        ),
        const SizedBox(height: 12),
        _buildNeoDropdownButton(
          context: context,
          icon: Icons.attach_money,
          label: displayLabel,
          onTap: () => _showNeoBottomSheet(
            context: context,
            title: loc.currency,
            options: [
              _NeoOption(
                value: 'USD',
                label: 'USD (\$)',
                icon: Icons.attach_money,
                isSelected: cur == 'USD',
              ),
              _NeoOption(
                value: 'VND',
                label: 'VNĐ (₫)',
                icon: Icons.currency_exchange,
                isSelected: cur == 'VND',
              ),
            ],
            onSelected: (val) =>
                context.read<AppProvider>().changeCurrency(val),
          ),
        ),
      ],
    );
  }

  // ─── Neo Dropdown Button ───────────────────────────────────────────────────

  Widget _buildNeoDropdownButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final neo = NeoTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: neo.surface,
          border: Border.all(color: neo.inkOnCard, width: 3),
          boxShadow: [BoxShadow(color: neo.ink, offset: const Offset(4, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: neo.inkOnCard, width: 3),
                ),
              ),
              child: Icon(icon, color: neo.textMain),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(label, style: NeoTypography.textTheme.titleMedium),
              ),
            ),
            Container(
              width: 52,
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: neo.inkOnCard, width: 3),
                ),
              ),
              child: Icon(Icons.expand_more, color: neo.textMain, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Neo Bottom Sheet ──────────────────────────────────────────────────────

  void _showNeoBottomSheet({
    required BuildContext context,
    required String title,
    required List<_NeoOption> options,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _NeoBottomSheet(
        title: title,
        options: options,
        onSelected: (val) {
          onSelected(val);
          Navigator.pop(context);
        },
      ),
    );
  }

  // ─── Toggle: Biometric ─────────────────────────────────────────────────────

  Widget _buildBiometricToggle(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isEnabled = provider.biometricEnabled;
    final loc = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () async {
        if (!isEnabled) {
          try {
            final auth = LocalAuthentication();
            final canCheck = await auth.canCheckBiometrics;
            final isSupported = await auth.isDeviceSupported();
            if (!canCheck && !isSupported) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.biometricNotAvailable)),
                );
              }
              return;
            }
          } on PlatformException {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.biometricNotAvailable)),
              );
            }
            return;
          }
        }
        if (!context.mounted) return;
        context.read<AppProvider>().toggleBiometric(!isEnabled);
      },
      child: _buildToggleCard(
        context,
        title: loc.biometricLock,
        subtitle: loc.biometricDesc,
        isEnabled: isEnabled,
        leadingIcon: Icons.fingerprint,
        activeTrackColor: NeoColors.success,
      ),
    );
  }

  // ─── Toggle: App Lock Background ───────────────────────────────────────────

  Widget _buildAppLockToggle(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isEnabled = provider.appLockEnabled;
    final loc = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        context.read<AppProvider>().toggleAppLock(!isEnabled);
      },
      child: _buildToggleCard(
        context,
        title: loc.appLockBackground,
        subtitle: loc.appLockBackgroundDesc,
        isEnabled: isEnabled,
        leadingIcon: Icons.phonelink_lock,
        activeTrackColor: NeoColors.tertiary,
      ),
    );
  }

  // ─── Advanced Settings Bottom Sheet ──────────────────────────────────────────

  void _showAdvancedSettings(BuildContext context) {
    final neo = NeoTheme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: neo.surface,
                border: Border.all(color: neo.inkOnCard, width: 3),
                boxShadow: [
                  BoxShadow(color: neo.inkOnCard, offset: const Offset(6, 6)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: neo.inkOnCard,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.advancedSettings,
                      style: NeoTypography.textTheme.titleLarge?.copyWith(
                        color: neo.surface,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Consumer<AppProvider>(
                        builder: (ctx, provider, child) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildBiometricToggle(ctx),
                              const SizedBox(height: 12),
                              _buildAppLockToggle(ctx),
                              const SizedBox(height: 12),
                              _buildHapticToggle(ctx),
                              const SizedBox(height: 12),
                              _buildSoundAlertsToggle(ctx),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  Container(height: 3, color: neo.inkOnCard),
                  GestureDetector(
                    onTap: () => Navigator.pop(sheetContext),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: neo.surface,
                      child: Center(
                        child: Text(
                          '✕  ${AppLocalizations.of(context)!.close}',
                          style: NeoTypography.mono.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 2,
                            color: neo.textMain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Toggle: Dark Mode ─────────────────────────────────────────────────────

  Widget _buildDarkModeToggle(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final loc = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => context.read<AppProvider>().toggleDarkMode(),
      child: _buildToggleCard(
        context,
        title: loc.darkMode,
        subtitle: loc.saveYourEyes,
        isEnabled: provider.darkMode,
        leadingIcon: Icons.dark_mode,
      ),
    );
  }

  // ─── Toggle: Haptic ────────────────────────────────────────────────────────

  Widget _buildHapticToggle(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final loc = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => context.read<AppProvider>().toggleHaptic(),
      child: _buildToggleCard(
        context,
        title: loc.hapticShock,
        subtitle: loc.feelTheSpending,
        isEnabled: provider.hapticEnabled,
        leadingIcon: Icons.vibration,
      ),
    );
  }

  // ─── Toggle: Sound Alerts ─────────────────────────────────────────────────

  Widget _buildSoundAlertsToggle(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final loc = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => context.read<AppProvider>().toggleSoundAlerts(),
      child: _buildToggleCard(
        context,
        title: loc.loudAlerts,
        subtitle: loc.screamAtMe,
        isEnabled: provider.soundAlerts,
        leadingIcon: Icons.volume_up,
      ),
    );
  }

  // ─── Generic Toggle Card ──────────────────────────────────────────────────

  Widget _buildToggleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isEnabled,
    IconData? leadingIcon,
    Color? activeTrackColor,
  }) {
    final neo = NeoTheme.of(context);
    final trackColor = activeTrackColor ?? neo.ink;
    return NeoCard(
      backgroundColor: neo.surface,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (leadingIcon != null) ...[
                  Icon(
                    leadingIcon,
                    color: isEnabled ? NeoColors.primary : neo.textMain,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NeoTypography.textTheme.titleMedium?.copyWith(
                          fontSize: 17,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: NeoTypography.mono.copyWith(
                          fontSize: 12,
                          color: neo.textSub,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Neo toggle switch
          Container(
            width: 60,
            height: 32,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isEnabled ? trackColor : neo.ink,
              border: Border.all(color: neo.inkOnCard, width: 2),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              alignment: isEnabled
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isEnabled ? NeoColors.primary : neo.surface,
                  border: Border.all(color: neo.inkOnCard, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Export / Import ────────────────────────────────────────────────────────

  Future<void> _exportCsv(BuildContext context) async {
    final provider = context.read<AppProvider>();
    final txs = provider.transactions;
    if (txs.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No transactions to export.')),
        );
      }
      return;
    }

    List<List<dynamic>> rows = [
      ['Title', 'Amount', 'Type', 'Category', 'Date']
    ];

    for (var tx in txs) {
      rows.add([
        tx.title,
        tx.amount,
        tx.type,
        tx.category,
        tx.date.toIso8601String(),
      ]);
    }

    String csvData = CsvCodec().encode(rows);

    try {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save CSV',
        fileName: 'chitieu_transactions.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
        bytes: Uint8List.fromList(utf8.encode(csvData)),
      );

      if (outputFile != null) {
        // On mobile, if we provide bytes, the file is already saved.
        // On desktop, it returns the path.
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: NeoColors.success,
              content: Text('CSV Exported successfully.'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: NeoColors.error,
            content: Text('Failed to export CSV: $e'),
          ),
        );
      }
    }
  }

  Future<void> _importCsv(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final input = await file.readAsString();
        List<List<dynamic>> fields =
            CsvCodec(lineDelimiter: '\n').decode(input);

        if (fields.isEmpty) return;
        
        // Remove header
        final header = fields.removeAt(0);
        if (header.length < 5) {
          throw Exception('Invalid CSV format. Missing columns.');
        }

        List<TransactionModel> newTxs = [];
        for (var row in fields) {
          if (row.length < 5) continue;
          
          final date = DateTime.tryParse(row[4].toString());
          if (date != null) {
            newTxs.add(
              TransactionModel(
                title: row[0].toString(),
                amount: double.tryParse(row[1].toString()) ?? 0,
                type: row[2].toString(),
                category: row[3].toString(),
                date: date,
              ),
            );
          }
        }

        if (newTxs.isNotEmpty && context.mounted) {
          await context.read<AppProvider>().importTransactions(newTxs);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: NeoColors.success,
                content: Text('Imported ${newTxs.length} transactions.'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: NeoColors.error,
            content: Text('Failed to import CSV: $e'),
          ),
        );
      }
    }
  }

  Widget _buildExportButton(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => _exportCsv(context),
      child: Builder(
        builder: (ctx) {
          final neo = NeoTheme.of(ctx);
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.upload, size: 24),
                const SizedBox(width: 8),
                Text(
                  loc.exportCsv,
                  style: NeoTypography.textTheme.titleMedium?.copyWith(
                    letterSpacing: 1,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImportButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _importCsv(context),
      child: Builder(
        builder: (ctx) {
          final neo = NeoTheme.of(ctx);
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.download, size: 24),
                const SizedBox(width: 8),
                Text(
                  'IMPORT CSV', // no localization needed for MVP unless specified
                  style: NeoTypography.textTheme.titleMedium?.copyWith(
                    letterSpacing: 1,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Logout Button ─────────────────────────────────────────────────────────

  Widget _buildLogoutButton(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final neo = NeoTheme.of(context);
    return GestureDetector(
      onTap: () {
        context.read<AppProvider>().logout();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: neo.surface,
          border: Border.all(color: neo.inkOnCard, width: 3),
          boxShadow: [
            BoxShadow(color: neo.inkOnCard, offset: const Offset(4, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, size: 24),
            const SizedBox(width: 8),
            Text(
              loc.logout,
              style: NeoTypography.textTheme.titleLarge?.copyWith(
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Danger Zone ──────────────────────────────────────────────────────────

  Widget _buildDangerZoneSection(BuildContext context) {
    final neo = NeoTheme.of(context);
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.warning, color: NeoColors.error, size: 32),
            const SizedBox(width: 16),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: NeoColors.error, width: 4),
                ),
              ),
              child: Text(
                loc.dangerZone,
                style: NeoTypography.textTheme.titleLarge?.copyWith(
                  color: NeoColors.error,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: NeoColors.error.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Stack(
          children: [
            Positioned.fill(top: 4, left: 4, child: Container(color: neo.ink)),
            GestureDetector(
              onLongPress: () {
                context.read<AppProvider>().nukeData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('DATA DETONATED SUCCESSFULLY')),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: NeoColors.error,
                  border: Border.all(color: neo.ink, width: 3),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.nukeData,
                      style: NeoTypography.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: neo.ink,
                        border: Border.all(color: Colors.white),
                      ),
                      child: Text(
                        loc.longPressToDetonate,
                        style: NeoTypography.mono.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          '${loc.version} ${AppConfig.fullVersion}\n${loc.madeWithRage}',
          textAlign: TextAlign.center,
          style: NeoTypography.mono.copyWith(
            color: NeoTheme.of(context).textSub,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ─── Neo Option Model ─────────────────────────────────────────────────────────

class _NeoOption {
  final String value;
  final String label;
  final IconData icon;
  final bool isSelected;
  const _NeoOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.isSelected,
  });
}

// ─── Neo Bottom Sheet Widget ──────────────────────────────────────────────────

class _NeoBottomSheet extends StatelessWidget {
  final String title;
  final List<_NeoOption> options;
  final ValueChanged<String> onSelected;

  const _NeoBottomSheet({
    required this.title,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 48,
            height: 5,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade400, // Safe neutral for both modes
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Sheet body
          Builder(
            builder: (ctx) {
              final neo = NeoTheme.of(ctx);
              return Container(
                decoration: BoxDecoration(
                  color: neo.surface,
                  border: Border.all(color: neo.inkOnCard, width: 3),
                  boxShadow: [
                    BoxShadow(color: neo.inkOnCard, offset: const Offset(6, 6)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title bar
                    Container(
                      color: neo.inkOnCard,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Text(
                        title,
                        style: NeoTypography.textTheme.titleLarge?.copyWith(
                          color: neo.surface,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    // Options
                    ...options.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final opt = entry.value;
                      return Column(
                        children: [
                          if (idx > 0)
                            Container(height: 3, color: neo.inkOnCard),
                          GestureDetector(
                            onTap: () => onSelected(opt.value),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              color: opt.isSelected
                                  ? NeoColors.primary
                                  : neo.surface,
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: opt.isSelected
                                          ? neo.inkOnCard
                                          : neo.surface,
                                      border: Border.all(
                                        color: neo.inkOnCard,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      opt.icon,
                                      size: 18,
                                      color: opt.isSelected
                                          ? neo.surface
                                          : neo.textMain,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      opt.label,
                                      style: NeoTypography.textTheme.titleMedium
                                          ?.copyWith(
                                            fontSize: 18,
                                            height: 1,
                                            color: opt.isSelected
                                                ? NeoColors.ink
                                                : neo.textMain,
                                          ),
                                    ),
                                  ),
                                  if (opt.isSelected)
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: neo.inkOnCard,
                                        border: Border.all(
                                          color: neo.inkOnCard,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: NeoColors.primary,
                                        size: 18,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    // Cancel
                    Container(height: 3, color: neo.inkOnCard),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        color: neo.surface,
                        child: Center(
                          child: Text(
                            '✕  CANCEL',
                            style: NeoTypography.mono.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 2,
                              color: neo.textMain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
