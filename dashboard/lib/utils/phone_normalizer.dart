// ─────────────────────────────────────────────────────────────────────────────
// lib/utils/phone_normalizer.dart
//
// Utilitaire de normalisation des numéros sénégalais
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

class PhoneNormalizer {
  // ── Regex ──────────────────────────────────────────────────────────────────
  static final RegExp _nonDigits = RegExp(r'\D');
  static final RegExp _senegalLocal = RegExp(r'^(77|78|75|76|70)\d{7}$');

  static String _normalize(String phone) {
    // 1. Supprimer tout ce qui n'est pas un chiffre
    final digits = phone.trim().replaceAll(_nonDigits, '');

    // 2. Retirer l'indicatif pays 221 si le numéro fait 12 chiffres
    //    221773412312 (12) → 773412312 (9)
    final local = digits.startsWith('221') && digits.length == 12
        ? digits.substring(3)
        : digits;

    // 3. Tronquer à 9 chiffres maximum
    return local.length > 9 ? local.substring(0, 9) : local;
  }

  // ── Public ────────────────────────────────────────────────────────────────

  /// Normalise un numéro (version publique — délègue à _normalize)
  static String normalize(String phone) => _normalize(phone);

  /// Vérifie si un numéro (avant ou après normalisation) est valide
  static bool isValid(String phone) =>
      _senegalLocal.hasMatch(_normalize(phone));

  /// Normalise une liste et filtre les numéros invalides
  /// Les invalides sont logués en debug et silencieusement ignorés
  static List<String> normalizeList(List<String> phones) {
    final result = <String>[];
    final invalid = <String>[];

    for (final phone in phones) {
      final normalized = _normalize(phone);
      if (_senegalLocal.hasMatch(normalized)) {
        result.add(normalized);
      } else {
        invalid.add(phone);
      }
    }

    if (invalid.isNotEmpty && kDebugMode) {
      print(
        '[PhoneNormalizer] ⚠️ ${invalid.length} numéro(s) invalide(s) ignoré(s): $invalid',
      );
    }

    return result;
  }
}
