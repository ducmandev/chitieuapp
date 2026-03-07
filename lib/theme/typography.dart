import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeoTypography {
  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: GoogleFonts.archivoBlack(),
      displayMedium: GoogleFonts.archivoBlack(),
      displaySmall: GoogleFonts.spaceGrotesk(
        // For Neo.Cash Dashboard header
        fontWeight: FontWeight.w900,
      ),
      headlineLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
      headlineSmall: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
      titleMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
      titleSmall: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
      bodyLarge: GoogleFonts.spaceGrotesk(),
      bodyMedium: GoogleFonts.spaceGrotesk(),
      bodySmall: GoogleFonts.spaceGrotesk(),
      labelLarge: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
      labelMedium: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
      labelSmall: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
    );
  }

  // Specifically for the numbers/monospaced text in certain contexts
  static TextStyle get numbers => GoogleFonts.chivoMono();

  static TextStyle get mono => GoogleFonts.spaceMono();
}
