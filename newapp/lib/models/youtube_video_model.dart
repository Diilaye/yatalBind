// lib/models/youtube_video_model.dart

class YoutubeVideoModel {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final String duration; // ex: "12:34"
  final String viewCount; // ex: "1 234 vues"
  final String publishedAt; // ex: "12 jan. 2024"
  final String? description;

  const YoutubeVideoModel({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
    required this.viewCount,
    required this.publishedAt,
    this.description,
  });

  // ── Depuis l'API YouTube Data v3 (videos.list) ────────────────────────────
  factory YoutubeVideoModel.fromYoutubeApi(Map<String, dynamic> json) {
    final snippet = json['snippet'] as Map<String, dynamic>? ?? {};
    final contentDetails =
        json['contentDetails'] as Map<String, dynamic>? ?? {};
    final statistics = json['statistics'] as Map<String, dynamic>? ?? {};

    final thumbs = snippet['thumbnails'] as Map<String, dynamic>? ?? {};
    final thumb = (thumbs['high'] as Map<String, dynamic>?) ??
        (thumbs['medium'] as Map<String, dynamic>?) ??
        (thumbs['default'] as Map<String, dynamic>?) ??
        {};

    return YoutubeVideoModel(
      videoId: json['id'] as String? ?? '',
      title: snippet['title'] as String? ?? '',
      thumbnailUrl: thumb['url'] as String? ?? '',
      duration: _parseDuration(contentDetails['duration'] as String? ?? ''),
      viewCount: _formatViews(statistics['viewCount'] as String? ?? '0'),
      publishedAt: _formatDate(snippet['publishedAt'] as String? ?? ''),
      description: snippet['description'] as String?,
    );
  }

  // ── Depuis le JSON local (fallback) ───────────────────────────────────────
  factory YoutubeVideoModel.fromLocalJson(Map<String, dynamic> json) {
    final url = json['videoUrl'] as String? ?? '';
    final videoId = _extractIdFromUrl(url);
    return YoutubeVideoModel(
      videoId: videoId,
      title: json['title'] as String? ?? '',
      thumbnailUrl: json['thumbnail'] as String? ?? '',
      duration: json['time'] as String? ?? '',
      viewCount: '',
      publishedAt: '',
      description: null,
    );
  }

  // ── Helpers de parsing ────────────────────────────────────────────────────

  /// ISO 8601 duration → "MM:SS" ou "HH:MM:SS"
  static String _parseDuration(String iso) {
    if (iso.isEmpty) return '';
    final match = RegExp(
      r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?',
    ).firstMatch(iso);
    if (match == null) return '';
    final h = int.tryParse(match.group(1) ?? '0') ?? 0;
    final m = int.tryParse(match.group(2) ?? '0') ?? 0;
    final s = int.tryParse(match.group(3) ?? '0') ?? 0;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  /// "1234567" → "1,2 M vues" ou "12 345 vues"
  static String _formatViews(String raw) {
    final n = int.tryParse(raw) ?? 0;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)} M vues';
    if (n >= 1000) return '${(n ~/ 1000)} k vues';
    return '$n vues';
  }

  /// ISO date → "12 jan. 2024"
  static String _formatDate(String iso) {
    if (iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      const months = [
        '',
        'jan.',
        'fév.',
        'mar.',
        'avr.',
        'mai',
        'juin',
        'juil.',
        'aoû.',
        'sep.',
        'oct.',
        'nov.',
        'déc.',
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  static String _extractIdFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return '';
    if (uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v']!;
    }
    final segs = uri.pathSegments;
    if (segs.isNotEmpty) return segs.last;
    return '';
  }
}
