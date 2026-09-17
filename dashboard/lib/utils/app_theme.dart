// lib/utils/app_theme.dart

import 'package:flutter/material.dart';

// ─── Palette de couleurs ──────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  static const Color accent = Color(0xFF084D27);
  static const Color accentLight = Color(0xFF0E7A3E);
  static const Color bg = Color(0xFFF1F5F8);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE4E9EF);
  static const Color textMuted = Color(0xFF8A96A3);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textBody = Color(0xFF4A5568);
  static const Color noir = Color(0xFF1A1A1A);
  static const Color blanc = Colors.white;

  // Tags
  static const Color tagBlue = Color(0xFFE8F0FE);
  static const Color tagBlueFg = Color(0xFF1A56DB);
  static const Color tagGreen = Color(0xFFE6F4EA);
  static const Color tagGreenFg = Color(0xFF1E7E34);
  static const Color tagRed = Color(0xFFFFEBEE);
  static const Color tagRedFg = Color(0xFFC62828);
  static const Color tagPurple = Color(0xFFF3E5F5);
  static const Color tagPurpleFg = Color(0xFF8E24AA);
}

// ─── Texte styles ────────────────────────────────────────────────────────────

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle pageTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: AppColors.noir,
    letterSpacing: 1.2,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 13,
    color: AppColors.textMuted,
  );

  static const TextStyle tableHeader = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
    letterSpacing: 0.6,
  );

  static const TextStyle cellPrimary = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle cellSecondary = TextStyle(
    fontSize: 12,
    color: AppColors.textBody,
  );

  static const TextStyle cellMuted = TextStyle(
    fontSize: 12,
    color: AppColors.textMuted,
  );

  static const TextStyle mono = TextStyle(
    fontSize: 12,
    color: AppColors.textMuted,
    fontFamily: 'monospace',
  );
}

// ─── Décorations réutilisables ────────────────────────────────────────────────

class AppDecorations {
  AppDecorations._();

  static BoxDecoration card({double radius = 12}) => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration tag(Color bg) => BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      );

  static InputDecoration searchField({
    required String hint,
    Widget? prefix,
    Widget? suffix,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        prefixIcon: prefix,
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.bg,
        contentPadding: EdgeInsets.zero,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      );
}
