import 'package:flutter/material.dart';
import 'colors.dart';

/// Context-aware color tokens for the neo-brutalist design system.
/// Access via: `final neo = NeoTheme.of(context);`
class NeoThemeData extends ThemeExtension<NeoThemeData> {
  final Color background; // scaffold / page background
  final Color surface; // card / elevated surface
  final Color textMain; // primary body text
  final Color textSub; // secondary / caption text
  final Color ink; // borders and shadows on the scaffold
  final Color inkOnCard; // borders on card surfaces (stays black in dark)
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color error;
  final Color success;

  const NeoThemeData({
    required this.background,
    required this.surface,
    required this.textMain,
    required this.textSub,
    required this.ink,
    required this.inkOnCard,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.error,
    required this.success,
  });

  // ─── Preset instances (used in ThemeData.extensions) ─────────────────────

  static const NeoThemeData light = NeoThemeData(
    background: NeoColors.backgroundLight,
    surface: NeoColors.surfaceLight,
    textMain: NeoColors.textMainLight,
    textSub: NeoColors.textSubLight,
    ink: NeoColors.inkLight,
    inkOnCard: NeoColors.inkLight,
    primary: NeoColors.primary,
    secondary: NeoColors.secondary,
    tertiary: NeoColors.tertiary,
    error: NeoColors.error,
    success: NeoColors.success,
  );

  static const NeoThemeData dark = NeoThemeData(
    background: NeoColors.backgroundDark,
    surface: NeoColors.surfaceDark,
    textMain: NeoColors.textMainDark,
    textSub: NeoColors.textSubDark,
    ink: NeoColors.inkDark, // inverted — visible on dark bg
    inkOnCard: NeoColors.inkDark, // stays bright so borders show on dark cards
    primary: NeoColors.primary,
    secondary: NeoColors.secondary,
    tertiary: NeoColors.tertiary,
    error: NeoColors.error,
    success: NeoColors.success,
  );

  // ─── ThemeExtension implementation ────────────────────────────────────────

  @override
  NeoThemeData copyWith({
    Color? background,
    Color? surface,
    Color? textMain,
    Color? textSub,
    Color? ink,
    Color? inkOnCard,
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? error,
    Color? success,
  }) => NeoThemeData(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    textMain: textMain ?? this.textMain,
    textSub: textSub ?? this.textSub,
    ink: ink ?? this.ink,
    inkOnCard: inkOnCard ?? this.inkOnCard,
    primary: primary ?? this.primary,
    secondary: secondary ?? this.secondary,
    tertiary: tertiary ?? this.tertiary,
    error: error ?? this.error,
    success: success ?? this.success,
  );

  @override
  NeoThemeData lerp(NeoThemeData? other, double t) {
    if (other == null) return this;
    return NeoThemeData(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textMain: Color.lerp(textMain, other.textMain, t)!,
      textSub: Color.lerp(textSub, other.textSub, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkOnCard: Color.lerp(inkOnCard, other.inkOnCard, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }

  // ─── Convenience accessor ──────────────────────────────────────────────────

  static NeoThemeData of(BuildContext context) =>
      Theme.of(context).extension<NeoThemeData>() ?? NeoThemeData.light;
}

/// Short alias so screens can write `NeoTheme.of(context)`.
typedef NeoTheme = NeoThemeData;
