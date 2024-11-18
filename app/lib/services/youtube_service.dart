import 'dart:io';

import 'package:app/models/videos_list.dart';
import 'package:app/models/youtube.dart';
import 'package:app/utils/constant.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class YoutubeService{

  static const CHANNEL_ID = 'UC-knB_7H32RI6bIE3l0vw4Q';
  static const _baseUrl = 'www.googleapis.com';


  /*
  curl \
  'https://youtube.googleapis.com/youtube/v3/channels?part=snippet%2CcontentDetails%2Cstatistics&id=UC-knB_7H32RI6bIE3l0vw4Q&access_token=AIzaSyAoREHhRl8x_bTnu3ScBTlukLVaTQqnt74&key=[YOUR_API_KEY]' \
  --header 'Authorization: Bearer [YOUR_ACCESS_TOKEN]' \
  --header 'Accept: application/json' \
  --compressed
   */

    static Future<Channelnfo> getChannelInfo() async{
      Map<String, String> parameters = {
        'part': 'snippet,contentDetails,statistics',
        'id': CHANNEL_ID,
        'key': Constants.API_KEY
      };
      Map<String, String> headers = {
        HttpHeaders.contentTypeHeader:'application/json',
      };
      Uri uri = Uri.https(_baseUrl, '/youtube/v3/playlistItems', parameters);
      http.Response response = await http.get(uri, headers: headers);
      Channelnfo channel = channelnfoFromJson(response.body);
      return channel;
    }

    static Future<VideoList> getVideosList({required String playListId, required String pageToken})async{
      Map<String, String> parameters = {
        'part':'snippet',
        'playlistId':playListId,
        'maxResults': '10',
        'pageToken':pageToken,
        'key': Constants.API_KEY,
      };
      Map<String, String> headers = {
        HttpHeaders.contentTypeHeader:'application/json',
      };
      Uri uri = Uri.https(_baseUrl, '/youtube/v3/channels', parameters);
      http.Response response = await http.get(uri, headers: headers);
      VideoList videoList = videoListFromJson(response.body);
      return videoList;
    }
}