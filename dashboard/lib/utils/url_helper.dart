// lib/utils/url_helper.dart — VERSION PROXY
// Remplace l'ancienne version

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:url_launcher/url_launcher.dart';

import 'url_helper_stub.dart'
    if (dart.library.html) 'url_helper_web.dart'
    if (dart.library.io) 'url_helper_io.dart';

const String _kApiBaseUrl = 'https://api.yaatalmbindumalxuran.sn';

class UrlHelper {
  UrlHelper._();

  // ── Résolution URL brute → URL absolue ─────────────────────────────────────
  static String resolve(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    final base = _kApiBaseUrl.replaceAll(RegExp(r'/$'), '');
    final p = raw.startsWith('/') ? raw : '/$raw';
    return '$base$p';
  }

  // ── Détection Cloudinary PDF (bloqué plan Free) ────────────────────────────
  static bool _isCloudinaryPdf(String url) {
    return url.contains('res.cloudinary.com') &&
        url.contains('/image/upload/') &&
        url.toLowerCase().endsWith('.pdf');
  }

  // ── URL via proxy serveur (contourne blocage Cloudinary plan Free) ──────────
  static String _proxyUrl(String url, {bool download = false}) {
    final encoded = Uri.encodeComponent(url);
    final base = '$_kApiBaseUrl/api/v1/proxy/file?url=$encoded';
    return download ? '$base&download=1' : base;
  }

  // ── URL de téléchargement ──────────────────────────────────────────────────
  static String resolveDownload(String? raw) {
    final url = resolve(raw);
    if (url.isEmpty) return '';

    // PDFs Cloudinary → proxy avec download=1
    if (_isCloudinaryPdf(url)) return _proxyUrl(url, download: true);

    // Cloudinary images → fl_attachment
    if (url.contains('cloudinary.com') && url.contains('/upload/')) {
      return url.replaceFirst('/upload/', '/upload/fl_attachment/');
    }

    // Serveur local → ?download=1
    return url.contains('?') ? '$url&download=1' : '$url?download=1';
  }

  // ── Ouverture ───────────────────────────────────────────────────────────────
  static Future<void> open(String url) async {
    if (url.isEmpty) return;
    try {
      // PDFs Cloudinary → passer par le proxy
      final effectiveUrl = _isCloudinaryPdf(url) ? _proxyUrl(url) : url;

      if (kIsWeb) {
        openInBrowser(effectiveUrl);
        return;
      }
      final uri = Uri.parse(effectiveUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      _debugPrint('open', url, e);
    }
  }

  // ── Téléchargement ──────────────────────────────────────────────────────────
  static Future<void> download(String url) async {
    if (url.isEmpty) return;
    try {
      final dlUrl = resolveDownload(url);
      if (kIsWeb) {
        downloadInBrowser(dlUrl);
        return;
      }
      final uri = Uri.parse(dlUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      _debugPrint('download', url, e);
    }
  }

  static void _debugPrint(String action, String url, Object e) {
    assert(() {
      debugPrint('[UrlHelper] $action error for $url : $e');
      return true;
    }());
  }
}
