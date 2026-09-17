// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Déclenche le téléchargement d'un fichier dans le navigateur.
///
/// [url]      — URL complète du fichier (Cloudinary, serveur, etc.)
/// [fileName] — Nom affiché dans la boîte de dialogue de téléchargement
///              du navigateur (ex: "moussa_diallo_15-03-2025.pdf")
///
/// Comportement selon l'origine du fichier :
/// - **Même domaine** : l'attribut `download` force le nom et le téléchargement.
/// - **Autre domaine (Cloudinary, S3…)** : le navigateur peut ouvrir le fichier
///   dans un nouvel onglet au lieu de le télécharger (restriction CORS sur
///   l'attribut `download`). Pour forcer le téléchargement Cloudinary,
///   ajoutez `?fl_attachment=nom.pdf` à l'URL avant d'appeler cette fonction.
void downloadFile({required String url, required String fileName}) {
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName) // nom du fichier dans le navigateur
    ..setAttribute('target', '_blank') // fallback : ouvre dans un onglet
    ..click(); // déclenche le téléchargement
}
