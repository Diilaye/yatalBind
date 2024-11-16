class VideoModel{
  final String title;
  final String time;
  final String thumbnail;
  final String videoUrl;

  VideoModel({
    required this.title,
    required this.thumbnail,
    required this.time,
    required this.videoUrl
  });

  factory VideoModel.fromJson(Map<String, dynamic>json){
    return VideoModel(
      title: json['title'],
      time: json['time'],
      thumbnail: json['thumbnail'],
      videoUrl: json['videoUrl'],
    );
  }

  
}