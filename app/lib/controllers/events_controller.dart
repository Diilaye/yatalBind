import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../core/services/network_service.dart';
import '../core/exceptions/app_exceptions.dart';
import 'base_controller.dart';

/// Contrôleur pour la gestion des événements et vidéos YouTube
class EventsController extends BaseController {
  
  // État des vidéos
  final RxList<Map<String, dynamic>> _videos = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get videos => _videos;

  // État de lecture
  final RxBool _playArea = false.obs;
  bool get playArea => _playArea.value;

  // Contrôleur YouTube
  YoutubePlayerController? _youtubeController;
  YoutubePlayerController? get youtubeController => _youtubeController;

  final RxBool _isPlayerReady = false.obs;
  bool get isPlayerReady => _isPlayerReady.value;

  @override
  void onInit() {
    super.onInit();
    _loadVideos();
  }

  @override
  void onClose() {
    _youtubeController?.dispose();
    super.onClose();
  }

  /// Charge les vidéos depuis le fichier JSON local
  Future<void> _loadVideos() async {
    try {
      setLoading(true);
      
      const String videoJsonPath = "json/videoinfo.json";
      final String response = await rootBundle.loadString(videoJsonPath);
      final data = json.decode(response);
      
      if (data['videos'] != null) {
        _videos.assignAll(List<Map<String, dynamic>>.from(data['videos']));
      }
      
    } catch (error) {
              handleError(NetworkException(
          message: 'Erreur lors du chargement des évènements',
          details: e.toString(),
        ));
    } finally {
      setLoading(false);
    }
  }

  /// Sélectionne et joue une vidéo
  void selectVideo(String videoUrl) {
    try {
      final String? videoId = YoutubePlayer.convertUrlToId(videoUrl);
      if (videoId == null) {
        showError('URL de vidéo invalide');
        return;
      }

      _createController(videoId);
      _playArea.value = true;
      
    } catch (error) {
      showError('Erreur lors de la lecture de la vidéo');
    }
  }

  /// Crée un nouveau contrôleur YouTube
  void _createController(String videoId) {
    // Dispose du contrôleur précédent s'il existe
    _youtubeController?.dispose();
    
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        enableCaption: true,
      ),
    )..addListener(_onPlayerStateChange);
    
    _isPlayerReady.value = false;
  }

  /// Gestionnaire des changements d'état du lecteur
  void _onPlayerStateChange() {
    if (_youtubeController != null && Get.isRegistered<EventsController>()) {
      // Logique de gestion d'état du lecteur
      if (_youtubeController!.value.isReady && !_isPlayerReady.value) {
        _isPlayerReady.value = true;
      }
    }
  }

  /// Ferme le lecteur vidéo
  void closePlayer() {
    _playArea.value = false;
    _youtubeController?.pause();
  }

  /// Met en pause/reprend la vidéo
  void togglePlayPause() {
    if (_youtubeController?.value.isPlaying == true) {
      _youtubeController?.pause();
    } else {
      _youtubeController?.play();
    }
  }

  /// Recharge la liste des vidéos
  Future<void> refreshVideos() async {
    await _loadVideos();
    showSuccess('Liste des vidéos mise à jour');
  }
}