import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:app/models/channel_model.dart';
import 'package:app/models/video_model.dart';
import 'package:app/utils/constant.dart';

class APIService {
  APIService._instantiate();

  static final APIService instance = APIService._instantiate();

  final String _baseUrl = 'www.googleapis.com';
  String _nextPageToken = '';
  static const channelId = 'UC-knB_7H32RI6bIE3l0vw4Q';

  Future<Channel> fetchChannel() async {
    Map<String, String> parameters = {
      'part': 'snippet, contentDetails, statistics',
      'id': channelId,
      'key': Constants.API_KEY,
    };
    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/channels',
      parameters,
    );
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    // Get Channel
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body)['items'][0];
      Channel channel = Channel.fromMap(data);
      // Fetch first batch of videos from uploads playlist
      channel.video = await fetchVideosFromPlaylist(
        playlistId: channel.uploadPlaylistId,
      );
      return channel;
    } else {
      throw json.decode(response.body)['error']['message'];
    }
  }
  Future<List<Video>> fetchVideosFromPlaylist({String? playlistId}) async {
    Map<String, String> parameters = {
      'part': 'snippet',
      'playlistId': playlistId!,
      'maxResults': '8',
      'pageToken': _nextPageToken,
      'key': Constants.API_KEY,
    };
    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/playlistItems',
      parameters,
    );
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    // Get Playlist Videos
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      _nextPageToken = data['nextPageToken'] ?? '';
      List<dynamic> videosJson = data['items'];
      // Fetch first eight videos from uploads playlist
      List<Video> videos = [];
      videosJson.forEach(
            (json) => videos.add(
          Video.fromMap(json['snippet']),
        ),
      );
      return videos;
    } else if (response.statusCode == 403) {
      // Gestion de l'erreur de quota dépassé
      throw Exception('Quota API dépassé. Essayez plus tard ou augmentez votre quota.');
    }else {
      throw json.decode(response.body)['error']['message'];
    }
  }
}