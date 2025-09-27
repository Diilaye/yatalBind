import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/videos_list.dart';
import '../models/youtube.dart';
import '../utils/constant.dart';

/// Service pour la gestion des vidéos YouTube et des thumbnails
class YoutubeService extends GetxService {
  static YoutubeService get to => Get.find();

  static const String CHANNEL_ID = 'UC-knB_7H32RI6bIE3l0vw4Q';
  static const String _baseUrl = 'www.googleapis.com';

  /// Récupère les informations du canal
  Future<Channelnfo> getChannelInfo() async {
    try {
      final Map<String, String> parameters = {
        'part': 'snippet,ContentDetails',
        'channelId': CHANNEL_ID,
        'maxResults': '10',
        'key': Constants.API_KEY,
      };

      final Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: 'application/json',
      };

      final Uri uri = Uri.https(_baseUrl, '/youtube/v3/channels', parameters);
      final http.Response response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return channelnfoFromJson(response.body);
      } else {
        throw Exception('Erreur lors de la récupération des informations du canal');
      }
    } catch (error) {
      throw Exception('Erreur service YouTube: $error');
    }
  }

  /// Récupère la liste des vidéos d'une playlist
  Future<VideoList> getVideosList({
    required String playListId,
    required String pageToken,
  }) async {
    try {
      final Map<String, String> parameters = {
        'part': 'snippet',
        'playlistId': playListId,
        'maxResults': '10',
        'pageToken': pageToken,
        'key': Constants.API_KEY,
      };

      final Map<String, String> headers = {
        HttpHeaders.contentTypeHeader: 'application/json',
      };

      final Uri uri = Uri.https(_baseUrl, '/youtube/v3/playlistItems', parameters);
      final http.Response response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return videoListFromJson(response.body);
      } else {
        throw Exception('Erreur lors de la récupération des vidéos');
      }
    } catch (error) {
      throw Exception('Erreur récupération vidéos: $error');
    }
  }

  /// Génère une URL de thumbnail YouTube depuis un ID de vidéo
  static String getThumbnailUrl(String videoId, {ThumbnailQuality quality = ThumbnailQuality.medium}) {
    String qualityStr = _getQualityString(quality);
    return 'https://img.youtube.com/vi/$videoId/$qualityStr.jpg';
  }

  /// Extrait l'ID de vidéo depuis une URL YouTube
  static String? getVideoIdFromUrl(String url) {
    final RegExp regex = RegExp(
      r'(?:https?://)?(?:www\.)?(?:youtube\.com/(?:[^/]+/.+/|(?:v|e(?:mbed)?)/|.*[?&]v=)|youtu\.be/)([^"&?/ ]{11})',
    );
    
    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  /// Valide si une URL YouTube est valide
  static bool isValidYouTubeUrl(String url) {
    return getVideoIdFromUrl(url) != null;
  }

  /// Crée un widget d'image thumbnail pour YouTube compatible avec le web
  static Widget buildThumbnailWidget({
    required String videoId,
    required double width,
    required double height,
    ThumbnailQuality quality = ThumbnailQuality.medium,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? loadingWidget,
    Widget? errorWidget,
  }) {
    final String thumbnailUrl = getThumbnailUrl(videoId, quality: quality);

    Widget imageWidget = Image.network(
      thumbnailUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return loadingWidget ?? _defaultLoadingWidget(width, height);
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _defaultErrorWidget(width, height);
      },
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  /// Widget de chargement par défaut
  static Widget _defaultLoadingWidget(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  /// Widget d'erreur par défaut
  static Widget _defaultErrorWidget(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.error_outline, color: Colors.red, size: 32),
      ),
    );
  }

  /// Retourne la chaîne de qualité appropriée
  static String _getQualityString(ThumbnailQuality quality) {
    switch (quality) {
      case ThumbnailQuality.low:
        return 'default';
      case ThumbnailQuality.medium:
        return 'mqdefault';
      case ThumbnailQuality.high:
        return 'hqdefault';
      case ThumbnailQuality.max:
        return 'maxresdefault';
      case ThumbnailQuality.standard:
        return 'sddefault';
    }
  }

  /// Génère un lien vers la vidéo YouTube
  static String getVideoUrl(String videoId) {
    return 'https://www.youtube.com/watch?v=$videoId';
  }

  /// Génère un lien embed pour la vidéo
  static String getEmbedUrl(String videoId, {Map<String, String>? parameters}) {
    String url = 'https://www.youtube.com/embed/$videoId';
    
    if (parameters != null && parameters.isNotEmpty) {
      final queryParams = parameters.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      url += '?$queryParams';
    }
    
    return url;
  }
}

/// Énumération pour les qualités de thumbnail
enum ThumbnailQuality {
  low,
  medium,
  high,
  standard,
  max,
}