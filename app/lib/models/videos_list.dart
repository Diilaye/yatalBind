// To parse this JSON data, do
//
//     final videoList = videoListFromJson(jsonString);

import 'dart:convert';

VideoList videoListFromJson(String str) => VideoList.fromJson(json.decode(str));

String videoListToJson(VideoList data) => json.encode(data.toJson());
class VideoList {

  VideoList({
    this.kind,
    this.etag,
    this.nextPageToken,
    this.videos,
    this.pageInfo,
});
  String? kind;
  String? etag;
  String? nextPageToken;
  List<VideoItem>? videos;
  PageInfo? pageInfo;

  factory VideoList.fromJson(Map<String, dynamic> json) => VideoList(
    kind: json["kind"],
    etag: json["etag"],
    nextPageToken: json["nextPageToken"],
    videos: List<VideoItem>.from(json["items"].map((x) => VideoItem.fromJson(x))),
    pageInfo: PageInfo.fromJson(json["pageInfo"]),
  );

  Map<String, dynamic> toJson() => {
    "kind": kind,
    "etag": etag,
    "nextPageToken": nextPageToken,
    "items": List<dynamic>.from(videos!.map((x) => x.toJson())),
    "pageInfo": pageInfo!.toJson(),
  };
}

class VideoItem {
  String? kind;
  String? etag;
  String? id;
  Video? video;

  VideoItem({
    this.kind,
    this.etag,
    this.id,
    this.video,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) => VideoItem(
    kind: json["kind"],
    etag: json["etag"],
    id: json["id"],
    video: Video.fromJson(json["snippet"]),
  );

  Map<String, dynamic> toJson() => {
    "kind": kind,
    "etag": etag,
    "id": id,
    "snippet": video!.toJson(),
  };
}

class Video {
  DateTime? publishedAt;
  String? channelId;
  String? title;
  String? description;
  Thumbnails? thumbnails;
  String? channelTitle;
  String? playlistId;
  int? position;
  ResourceId? resourceId;
  String? videoOwnerChannelTitle;
  String? videoOwnerChannelId;

  Video({
    this.publishedAt,
    this.channelId,
    this.title,
    this.description,
    this.thumbnails,
    this.channelTitle,
    this.playlistId,
    this.position,
    this.resourceId,
    this.videoOwnerChannelTitle,
    this.videoOwnerChannelId,
  });

  factory Video.fromJson(Map<String, dynamic> json) => Video(
    publishedAt: DateTime.parse(json["publishedAt"]),
    channelId: json["channelId"],
    title: json["title"],
    description: json["description"],
    thumbnails: Thumbnails.fromJson(json["thumbnails"]),
    channelTitle: json["channelTitle"],
    playlistId: json["playlistId"],
    position: json["position"],
    resourceId: ResourceId.fromJson(json["resourceId"]),
    videoOwnerChannelTitle: json["videoOwnerChannelTitle"],
    videoOwnerChannelId: json["videoOwnerChannelId"],
  );

  Map<String, dynamic> toJson() => {
    "publishedAt": publishedAt!.toIso8601String(),
    "channelId": channelId,
    "title": title,
    "description": description,
    "thumbnails": thumbnails!.toJson(),
    "channelTitle": channelTitle,
    "playlistId": playlistId,
    "position": position,
    "resourceId": resourceId!.toJson(),
    "videoOwnerChannelTitle": videoOwnerChannelTitle,
    "videoOwnerChannelId": videoOwnerChannelId,
  };
}

class ResourceId {
  String? kind;
  String? videoId;

  ResourceId({
    this.kind,
    this.videoId,
  });

  factory ResourceId.fromJson(Map<String, dynamic> json) => ResourceId(
    kind: json["kind"],
    videoId: json["videoId"],
  );

  Map<String, dynamic> toJson() => {
    "kind": kind,
    "videoId": videoId,
  };
}

class Thumbnails {
  late Default thumbnailsDefault;
  late Default medium;
  late Default high;
  late Default standard;
  late Default maxres;

  Thumbnails(
    this.thumbnailsDefault,
    this.medium,
    this.high,
    this.standard,
    this.maxres,
  );

  Thumbnails.fromJson(Map<String, dynamic> json){
    thumbnailsDefault= Default.fromJson(json["default"]);
    medium= Default.fromJson(json["medium"]);
    high= Default.fromJson(json["high"]);
    standard= Default.fromJson(json["standard"]);
    maxres= Default.fromJson(json["maxres"]);
  }

  Map<String, dynamic> toJson() => {
    "default": thumbnailsDefault.toJson(),
    "medium": medium.toJson(),
    "high": high.toJson(),
    "standard": standard.toJson(),
    "maxres": maxres.toJson(),
  };
}

class Default {
  late String url;
  late int width;
  late int height;

  Default(
    this.url,
    this.width,
    this.height,
  );

  Default.fromJson(Map<String, dynamic> json){
    url= json["url"];
    width= json["width"];
    height= json["height"];
  }

  Map<String, dynamic> toJson() => {
    "url": url,
    "width": width,
    "height": height,
  };
}

class PageInfo {
  late int totalResults;
  late int resultsPerPage;

  PageInfo(
    this.totalResults,
    this.resultsPerPage,
  );

  PageInfo.fromJson(Map<String, dynamic> json){
    totalResults= json["totalResults"];
    resultsPerPage= json["resultsPerPage"];
  }

  Map<String, dynamic> toJson() => {
    "totalResults": totalResults,
    "resultsPerPage": resultsPerPage,
  };
}
