import 'package:flutter/material.dart';

class NeoColors {
  // Vibrant Accents (Dùng chung)
  static const Color primary = Color(0xFFFFF500); // Warning Yellow
  static const Color secondary = Color(0xFFFF00D6); // Electric Pink
  static const Color tertiary = Color(0xFF00D1FF); // Cyan
  static const Color error = Color(0xFFFF3333); // Red
  static const Color success = Color(0xFF4ADE80); // Green (from Savings bar)

  // Light Theme Neutrals
  static const Color backgroundLight = Color(0xFFF2F0E9); // Bone/Off-white
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textMainLight = Color(0xFF000000);
  static const Color textSubLight = Color(0xFF555555);
  static const Color inkLight = Color(0xFF000000);

  // Dark Theme Neutrals
  static const Color backgroundDark = Color(0xFF111111);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textMainDark = Color(0xFFF2F0E9);
  static const Color textSubDark = Color(0xFF9E9E9E);
  static const Color inkDark = Color(
    0xFFE0E0E0,
  ); // Bright border/ink for dark mode visibility

  // Legacy aliases to prevent breaking files not using NeoTheme.of directly
  static const Color surface = surfaceLight;
  static const Color ink = inkLight;
}
