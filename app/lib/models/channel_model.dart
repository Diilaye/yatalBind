class Channel {
  String id; 
  String title;
  String profilPictureUrl;
  String subscriberCount;
  String videoCount;
  String uploadPlaylistId;
  List<Video> videos;

  Channel(
    this.id,
    this.title,
    this.profilPictureUrl,
    this.subscriberCount,
    this.videoCount,
    this.uploadPlaylistId,
    this.videos,
  );

   Channel.fromJson(Map<String, dynamic> map){
      id= map['id'];
      title= map['snippet']['title']; 
      profilPictureUrl= map['snippet']['thumbnails']['default']['url']; 
      subscriberCount= map['stattistics']['subscriberCount']; 
      videoCount= map['statistics']['videoCount'];
      uploadPlaylistId= map['contentDetails']['relatedPlaylits']['uploads'];
  }
}