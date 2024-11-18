import 'dart:io';
import 'dart:convert';

import 'package:app/models/channel_model.dart';
import 'package:app/models/video_model.dart';
import 'package:app/models/videos_list.dart';
import 'package:app/utils/constant.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ApiServices{

  ApiServices._instantiate();

  static final ApiServices services = ApiServices._instantiate();

  String  _nextPageToken = '';
  final String _baseUrl = 'www.googleapis.com';



      Future<Channel> getChannelInfo({String channelId}) async{

        Map<String, String> parameters = {
          'part': 'snippet,contentDetails,statistics',
          'id': channelId,
          'key': Constants.API_KEY
        };

        Uri uri = Uri.https(
          _baseUrl,
          '/youtube/v3/channels',
          parameters,
        );
    
      Map<String, String> headers = {
        HttpHeaders.contentTypeHeader:'application/json',
      };
      //GET CHANNNEL
      var response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body)['items'][0];
        Channel channel = Channel.fromJson(data);

        //fetch first batch of videos from uploads playlist
        channel.videos = await fetchVideosFromPlaylists(
          playlistId: channel.uploadPlaylistId,
        );
        return channel;
      }else{
        throw json.decode(response.body)['error']['message'];
 
    }
  }
  Future<Videos> fetchVideosFromPlaylists({required String playListId})async{
    Map<String, String> parameters = {
      'part':'snippet',
      'playlistId':playListId,
      'maxResults':'8',
      'pageToken':_nextPageToken,
      'key': Constants.API_KEY,
    };

    Uri uri = Uri.https(_baseUrl, '/youtube/v3/channels', parameters);
      
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader:'application/json',
    };
     
      Response response = http.get(uri, headers: headers) as Response;
      print(response.body);
      VideoList videoList = videoListFromJson(response.body);
      return videoList;
    }
}

