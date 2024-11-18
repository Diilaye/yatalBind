class YoutubeModel {
 String id;
 String title;
 String thumbnailUrl;
 String channelTitle;

  YoutubeModel(
    this.id,
    this.title,
    this.thumbnailUrl,
     this.channelTitle,
  );

   YoutubeModel.fromJson(Map<String, dynamic> snippet){
 
      id: snippet['resourceId']['videoId'];
      title: snippet['title'];
      thumbnailUrl: snippet['thumbnails']['high']['url'];
      channelTitle: snippet['channelTitle'];
   
  }
}