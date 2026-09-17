import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  YAATAL MBINDE — Nouvelle Charte Chromatique
//  Thème : Vert Émeraude + Blanc Cassé (Spirituel)
// ─────────────────────────────────────────────

// Couleurs principales
const Color yAccentColor = Color(0xFF0D6B4E); // Vert émeraude profond
const Color ySecondaryColor = Color(0xFF14A074); // Vert émeraude moyen
const Color yTertiaryColor = Color(0xFF1DC68F); // Vert émeraude clair

// Couleurs neutres
const Color yWhiteColor = Color(0xFFF8F4EC); // Blanc cassé chaud
const Color yOffWhite = Color(0xFFEEE8D8); // Blanc cassé secondaire
const Color yDarkColor = Color(0xFF0B2E20); // Vert très sombre (quasi-noir)
const Color yDarkSoftColor = Color(0xFF1A4A32); // Vert sombre doux

// Couleurs d'accentuation
const Color yGoldColor = Color(0xFFD4A843); // Or doux spirituel
const Color yGoldLight = Color(0xFFF0CB6A); // Or clair
const Color yCardBgColor = Color(0xFF0F3D2A); // Fond carte sombre
const Color yOverlayColor = Color(0x990B2E20); // Overlay sombre 60%

// Couleurs sémantiques
const Color ySuccessColor = Color(0xFF2ECC71);
const Color yErrorColor = Color(0xFFE74C3C);
const Color yWarningColor = Color(0xFFF39C12);

// Dégradés prédéfinis
const LinearGradient yPrimaryGradient = LinearGradient(
  colors: [Color(0xFF0D6B4E), Color(0xFF14A074)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient yGoldGradient = LinearGradient(
  colors: [Color(0xFFD4A843), Color(0xFFF0CB6A), Color(0xFFD4A843)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient yDarkGradient = LinearGradient(
  colors: [Color(0xFF0B2E20), Color(0xFF0D6B4E)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

// Ombres
List<BoxShadow> yCardShadow = [
  BoxShadow(
    color: const Color(0xFF0B2E20).withOpacity(0.18),
    blurRadius: 20,
    offset: const Offset(0, 8),
  ),
];

List<BoxShadow> yGoldShadow = [
  BoxShadow(
    color: const Color(0xFFD4A843).withOpacity(0.35),
    blurRadius: 16,
    offset: const Offset(0, 6),
  ),
];

// ThemeData centralisé
ThemeData yaatalTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: yAccentColor,
      onPrimary: yWhiteColor,
      secondary: yGoldColor,
      onSecondary: yDarkColor,
      error: yErrorColor,
      onError: yWhiteColor,
      background: yDarkColor,
      onBackground: yWhiteColor,
      surface: yCardBgColor,
      onSurface: yWhiteColor,
    ),
    scaffoldBackgroundColor: yDarkColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: yWhiteColor,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: yWhiteColor,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: yGoldColor,
        foregroundColor: yDarkColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w800,
          color: yWhiteColor),
      headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          color: yWhiteColor),
      bodyLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          color: yWhiteColor),
      bodyMedium: TextStyle(
          fontFamily: 'Poppins', fontWeight: FontWeight.w400, color: yOffWhite),
    ),
  );
}
