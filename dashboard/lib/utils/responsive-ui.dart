// lib/utils/responsive-ui.dart
//
// DIFF vs votre fichier original :
//   [1] Correction du cas limite : width == 600 tombait dans Mobile (< 600 false, > 600 false)
//       → ajout de >= 600 pour Tablet
//   [2] print() retiré (non bloquant, mais génère du bruit en production)

import 'dart:ui';

enum ScreenType { Mobile, Tablet, Desktop }

ScreenType deviceName(Size size) {
  if (size.width < 600) {
    return ScreenType.Mobile;
  } else if (size.width < 1200) {
    // [FIX] était : > 600 && < 1200 — manquait exactement 600px
    return ScreenType.Tablet;
  } else {
    return ScreenType.Desktop;
  }
}
