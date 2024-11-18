class Videos{
  final String title;
  final String time;
  final String thumbnail;
  final String videoUrl;

  Videos({
    required this.title,
    required this.thumbnail,
    required this.time,
    required this.videoUrl
  });

  factory Videos.fromJson(Map<String, dynamic>json){
    return Videos(
      title: json['title'],
      time: json['time'],
      thumbnail: json['thumbnail'],
      videoUrl: json['videoUrl'],
    );
  }

  
}