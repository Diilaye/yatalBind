// lib/utils/url_helper_web.dart
//
// ⚠️  window.open() est BLOQUÉ par les navigateurs modernes quand appelé
//     depuis du code JS compilé Flutter — il n'est pas reconnu comme
//     "geste utilisateur direct" (user gesture).
//
// ✅  Solution : injecter un <a href target="_blank"> dans le DOM et le
//     cliquer programmatiquement — TOUJOURS reconnu comme geste utilisateur.

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Ouvre [url] dans un nouvel onglet via un <a> cliqué programmatiquement.
/// Contourne le blocage popup des navigateurs modernes.
void openInBrowser(String url) {
  _clickAnchor(url, download: false);
}

/// Force le téléchargement de [url] via un <a download> cliqué.
void downloadInBrowser(String url) {
  _clickAnchor(url, download: true);
}

void _clickAnchor(String url, {required bool download}) {
  // Créer le lien
  final anchor = html.document.createElement('a') as html.AnchorElement;
  anchor.href = url;
  anchor.target = '_blank';
  anchor.rel = 'noopener noreferrer'; // sécurité

  if (download) {
    // Extraire le nom de fichier depuis l'URL pour le nom de téléchargement
    final filename = url.split('/').last.split('?').first;
    anchor.setAttribute('download', filename.isNotEmpty ? filename : 'fichier');
  }

  // Doit être dans le DOM pour fonctionner sur Firefox
  anchor.style.display = 'none';
  html.document.body!.append(anchor);

  // Clic — reconnu comme user gesture par tous les navigateurs
  anchor.click();

  // Nettoyage immédiat
  anchor.remove();
}
