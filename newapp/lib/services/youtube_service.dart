// lib/services/youtube_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yaatal_mbindum/models/youtube_video_model.dart';

class YoutubeService {
  static const String _apiKey = String.fromEnvironment(
    'YT_API_KEY',
    defaultValue: '', // ← Ne jamais mettre la clé ici
  );

  static const String _channelId = String.fromEnvironment(
    'YT_CHANNEL_ID',
    defaultValue: 'UC-knB_7H32RI6bIE3l0vw4Q',
  );

  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  Future<List<YoutubeVideoModel>> fetchChannelVideos(
      {int maxResults = 50}) async {
    if (_apiKey.isEmpty) {
      debugPrint(
        '[YoutubeService] ❌ YT_API_KEY non définie.\n'
        'Build avec : flutter build apk --dart-define=YT_API_KEY=VOTRE_CLE',
      );
      return [];
    }

    try {
      // Étape 1 : Recherche des IDs vidéos
      final searchUri = Uri.parse(
        '$_baseUrl/search'
        '?key=$_apiKey'
        '&channelId=$_channelId'
        '&part=snippet,id'
        '&order=date'
        '&type=video'
        '&maxResults=$maxResults',
      );

      debugPrint('[YoutubeService] GET $searchUri');
      final searchResp = await http.get(searchUri, headers: {
        'Accept': 'application/json'
      }).timeout(const Duration(seconds: 15));

      debugPrint('[YoutubeService] Search status: ${searchResp.statusCode}');

      if (searchResp.statusCode == 403) {
        final body = jsonDecode(searchResp.body);
        final reason = body['error']?['errors']?[0]?['reason'] ?? 'inconnu';
        debugPrint('[YoutubeService] ❌ 403 - Raison: $reason');
        // Raisons possibles : quotaExceeded, keyInvalid, forbidden
        return [];
      }

      if (searchResp.statusCode != 200) {
        debugPrint('[YoutubeService] ❌ HTTP ${searchResp.statusCode}');
        return [];
      }

      final searchBody = jsonDecode(searchResp.body) as Map<String, dynamic>;
      final items = (searchBody['items'] as List<dynamic>?) ?? [];

      if (items.isEmpty) {
        debugPrint('[YoutubeService] ⚠️ Aucune vidéo trouvée pour ce channel');
        return [];
      }

      final ids = items
          .map((e) => (e['id'] as Map<String, dynamic>)['videoId'] as String?)
          .whereType<String>()
          .join(',');

      // Étape 2 : Détails des vidéos (durée, vues, etc.)
      final videosUri = Uri.parse(
        '$_baseUrl/videos'
        '?key=$_apiKey'
        '&id=$ids'
        '&part=snippet,contentDetails,statistics',
      );

      final videosResp = await http.get(videosUri, headers: {
        'Accept': 'application/json'
      }).timeout(const Duration(seconds: 15));

      debugPrint('[YoutubeService] Videos status: ${videosResp.statusCode}');

      if (videosResp.statusCode != 200) return [];

      final videoItems =
          (jsonDecode(videosResp.body)['items'] as List<dynamic>?) ?? [];

      debugPrint('[YoutubeService] ✅ ${videoItems.length} vidéos chargées');

      return videoItems
          .map((v) =>
              YoutubeVideoModel.fromYoutubeApi(v as Map<String, dynamic>))
          .toList();
    } on Exception catch (e) {
      debugPrint('[YoutubeService] ❌ Exception: $e');
      return [];
    }
  }
}
