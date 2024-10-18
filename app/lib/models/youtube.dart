class YoutubeViewer{
  final urls;
  final thumbnail;
  final description;

  YoutubeViewer({
    required this.urls,
    required this.thumbnail,
    required this.description
  });
}

final List<YoutubeViewer> videos = [
  YoutubeViewer(urls: "https://www.youtube.com/watch?v=mG3Kp6S3nIw", thumbnail: "Plateau Spéciale 6e", description: "description"),
  YoutubeViewer(urls: "https://www.youtube.com/watch?v=qkZmW_7l8v0", thumbnail: "1ere Laureat Concours", description: "description"),
  YoutubeViewer(urls: "https://www.youtube.com/watch?v=Ov_uRtp2ztM", thumbnail: "Exposition sur la calligraphie", description: "description"),
  YoutubeViewer(urls: "https://www.youtube.com/watch?v=Ov_uRtp2ztM", thumbnail: "Correction Finale Nationnale", description: "description"),
  YoutubeViewer(urls: "https://www.youtube.com/watch?v=qEIYpXdK3fw", thumbnail: "1ere Laureat Sokhna Aicha", description: "description"),
  YoutubeViewer(urls: "https://www.youtube.com/watch?v=qbKETC4l2P0", thumbnail: "Kureelou Yaatal Mbinde", description: "description"),
];