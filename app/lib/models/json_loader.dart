import 'dart:convert';
import 'package:flutter/services.dart';
import 'video_model.dart';

Future<List<VideoModel>> loadVideos() async {
  final String response = await rootBundle.loadString('json/videoinfo.json');
  final data = json.decode(response);
  return (data['videos'] as List)
      .map((video) => VideoModel.fromJson(video))
      .toList();
}
