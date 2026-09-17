// lib/bloc/events_bloc.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaatal_mbindum/models/youtube_video_model.dart';
import 'package:yaatal_mbindum/services/youtube_service.dart';

enum VideoLoadState { idle, loading, loaded, error }

class EventsBloc with ChangeNotifier {
  final YoutubeService _service = YoutubeService();

  List<YoutubeVideoModel> _videos = [];
  VideoLoadState _loadState = VideoLoadState.idle;
  String? _errorMessage;
  bool _usedFallback = false;
  YoutubeVideoModel? _currentVideo;
  bool _isPlaying = false;

  List<YoutubeVideoModel> get videos => _videos;
  VideoLoadState get loadState => _loadState;
  String? get errorMessage => _errorMessage;
  bool get usedFallback => _usedFallback;
  YoutubeVideoModel? get currentVideo => _currentVideo;
  bool get isPlaying => _isPlaying;
  bool get hasVideos => _videos.isNotEmpty;

  int get totalDurationMinutes {
    int total = 0;
    for (final v in _videos) {
      final parts = v.duration.split(':');
      if (parts.length == 3) {
        total +=
            (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
      } else if (parts.length == 2) {
        total += (int.tryParse(parts[0]) ?? 0);
      }
    }
    return total;
  }

  EventsBloc() {
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    _loadState = VideoLoadState.loading;
    _errorMessage = null;
    _usedFallback = false;
    notifyListeners();

    try {
      final apiVideos = await _service.fetchChannelVideos(maxResults: 50);
      if (apiVideos.isNotEmpty) {
        _videos = apiVideos;
        _loadState = VideoLoadState.loaded;
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('[EventsBloc] Erreur API YouTube : $e');
    }

    // ── Fallback JSON local ──────────────────────────────────────────────
    debugPrint('[EventsBloc] API YouTube vide → fallback JSON local');
    try {
      // ✅ Chemin corrigé : assets/json/ selon pubspec.yaml
      final raw = await rootBundle.loadString('assets/json/videoinfo.json');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final list = (data['videos'] as List<dynamic>? ?? [])
          .map(
              (e) => YoutubeVideoModel.fromLocalJson(e as Map<String, dynamic>))
          .toList();

      if (list.isEmpty) {
        debugPrint('[EventsBloc] JSON local vide ou mal formé');
        _loadState = VideoLoadState.error;
        _errorMessage = 'Aucune vidéo dans le fichier local.';
      } else {
        _videos = list;
        _loadState = VideoLoadState.loaded;
        _usedFallback = true;
        debugPrint('[EventsBloc] ${list.length} vidéos chargées depuis JSON');
      }
    } catch (e) {
      _videos = [];
      _loadState = VideoLoadState.error;
      _errorMessage = 'Impossible de charger les vidéos.';
      debugPrint('[EventsBloc] Fallback JSON erreur : $e');
      // ⬆ Ce message vous dira exactement ce qui cloche
    }

    notifyListeners();
  }

  Future<void> refresh() => fetchVideos();

  void selectVideo(YoutubeVideoModel video) {
    _currentVideo = video;
    _isPlaying = true;
    notifyListeners();
  }

  void closePlayer() {
    _isPlaying = false;
    _currentVideo = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
