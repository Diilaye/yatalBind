// To parse this JSON data, do
//
//     final channelnfo = channelnfoFromJson(jsonString);

import 'dart:convert';

Channelnfo channelnfoFromJson(String str) => Channelnfo.fromJson(json.decode(str));

String channelnfoToJson(Channelnfo data) => json.encode(data.toJson());

class Channelnfo {
  late String kind;
  late String etag;
  late PageInfo pageInfo;
  late List<Item> items;

  Channelnfo(
    this.kind,
    this.etag,
    this.pageInfo,
    this.items,
  );

  Channelnfo.fromJson(Map<String, dynamic> json) {
    kind= json["kind"];
    etag= json["etag"];
    pageInfo= PageInfo.fromJson(json["pageInfo"]);
    items= List<Item>.from(json["items"].map((x) => Item.fromJson(x)));
  }
  

  Map<String, dynamic> toJson() => {
    "kind": kind,
    "etag": etag,
    "pageInfo": pageInfo.toJson(),
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class Item {
  late String kind;
  late String etag;
  late String id;
  late Snippet snippet;
  late ContentDetails contentDetails;
  late Statistics statistics;

  Item(
    this.kind,
    this.etag,
    this.id,
    this.snippet,
    this.contentDetails,
    this.statistics,
  );

  Item.fromJson(Map<String, dynamic> json) {
    kind= json["kind"];
    etag= json["etag"];
    id= json["id"];
    snippet= Snippet.fromJson(json["snippet"]);
    contentDetails= ContentDetails.fromJson(json["contentDetails"]);
    statistics= Statistics.fromJson(json["statistics"]);
  }

  Map<String, dynamic> toJson() => {
    "kind": kind,
    "etag": etag,
    "id": id,
    "snippet": snippet.toJson(),
    "contentDetails": contentDetails.toJson(),
    "statistics": statistics.toJson(),
  };
}

class ContentDetails {
  late RelatedPlaylists relatedPlaylists;

  ContentDetails(
    this.relatedPlaylists,
  );

  ContentDetails.fromJson(Map<String, dynamic> json) {
    relatedPlaylists= RelatedPlaylists.fromJson(json["relatedPlaylists"]);
  }

  Map<String, dynamic> toJson() => {
    "relatedPlaylists": relatedPlaylists.toJson(),
  };
}

class RelatedPlaylists {
  late String likes;
  late String uploads;

  RelatedPlaylists(
    this.likes,
    this.uploads,
  );

  RelatedPlaylists.fromJson(Map<String, dynamic> json) {
    likes= json["likes"];
    uploads= json["uploads"];
  }

  Map<String, dynamic> toJson() => {
    "likes": likes,
    "uploads": uploads,
  };
}

class Snippet {
  late String title;
  late String description;
  late String customUrl;
  late DateTime publishedAt;
  late Thumbnails thumbnails;
  late Localized localized;
  late String country;

  Snippet(
    this.title,
    this.description,
    this.customUrl,
    this.publishedAt,
    this.thumbnails,
    this.localized,
    this.country,
  );

  Snippet.fromJson(Map<String, dynamic> json) {
    title= json["title"];
    description= json["description"];
    customUrl= json["customUrl"];
    publishedAt= DateTime.parse(json["publishedAt"]);
    thumbnails= Thumbnails.fromJson(json["thumbnails"]);
    localized= Localized.fromJson(json["localized"]);
    country= json["country"];
  }

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "customUrl": customUrl,
    "publishedAt": publishedAt.toIso8601String(),
    "thumbnails": thumbnails.toJson(),
    "localized": localized.toJson(),
    "country": country,
  };
}

class Localized {
  late String title;
  late String description;

  Localized(
    this.title,
    this.description,
  );

  Localized.fromJson(Map<String, dynamic> json) {
    title= json["title"];
    description= json["description"];
  }

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
  };
}

class Thumbnails {
  late Default thumbnailsDefault;
  late Default medium;
  late Default high;

  Thumbnails(
    this.thumbnailsDefault,
    this.medium,
    this.high,
  );

  Thumbnails.fromJson(Map<String, dynamic> json) {
    thumbnailsDefault= Default.fromJson(json["default"]);
    medium= Default.fromJson(json["medium"]);
    high= Default.fromJson(json["high"]);
  }

  Map<String, dynamic> toJson() => {
    "default": thumbnailsDefault.toJson(),
    "medium": medium.toJson(),
    "high": high.toJson(),
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

class Statistics {
  late String viewCount;
  late String subscriberCount;
  late bool hiddenSubscriberCount;
  late String videoCount;

  Statistics(
    this.viewCount,
    this.subscriberCount,
    this.hiddenSubscriberCount,
    this.videoCount,
  );

  Statistics.fromJson(Map<String, dynamic> json) {
    viewCount= json["viewCount"];
    subscriberCount= json["subscriberCount"];
    hiddenSubscriberCount= json["hiddenSubscriberCount"];
    videoCount= json["videoCount"];
  }

  Map<String, dynamic> toJson() => {
    "viewCount": viewCount,
    "subscriberCount": subscriberCount,
    "hiddenSubscriberCount": hiddenSubscriberCount,
    "videoCount": videoCount,
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
