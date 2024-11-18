import 'package:app/models/videos_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:app/utils/colors.dart' as color;
import 'package:app/models/youtube.dart';
import 'package:app/services/youtube_service.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {

  bool _playArea = false;
  late Channelnfo _channelnfo;
  late Item _item;
  late bool _loading;
  late VideoList _videoList;
  late String _playListId;
  late String _nextPageToken;

  @override
  void initState() {
    super.initState();
    _loading= true;
    _nextPageToken = '';
    _videoList = VideoList();
    _videoList.videos = <VideoList>[].cast<VideoItem>();
    _getChannelInfo();
  }

  _getChannelInfo() async{
    _channelnfo = await YoutubeService.getChannelInfo();
    _item = _channelnfo.items[0];
    _playListId = _item.contentDetails.relatedPlaylists.uploads;
    print('playlistid: $_playListId');
    await _loadVideos();
    setState((){
      _loading = false;
    });
    
  }
  _loadVideos() async {
    VideoList tempVideoList = YoutubeService.getVideosList(
      playListId: _playListId, 
      pageToken: _nextPageToken
      ) as VideoList;
      _nextPageToken = tempVideoList.nextPageToken!;
      _videoList.videos!.addAll(tempVideoList.videos as Iterable<VideoItem>);
      print('videos: ${_videoList.videos!.length}');
      setState(() {
        
      });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //BackgroundGradient
        decoration: _playArea==false?BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.AppColor.yAccentColor.withOpacity(0.8),
              color.AppColor.ySecondaryColor
            ],
            begin: const FractionalOffset(0.0, 0.4),
            end: Alignment.topRight,
          ),
        ):BoxDecoration(
           color: color.AppColor.yAccentGradientdColor,
        ),
        child: Column(
          children: [
            //Partie affichage ecran video player
            _playArea==false?Container(
              padding: const EdgeInsets.only(top: 70, left: 30, right: 30),
              width: MediaQuery.of(context).size.width,
              height: 300,
              
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Container()),
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: color.AppColor.yWhiteColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Text(
                    'Vos Videos',
                    style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                        color: color.AppColor.yWhiteColor
                    ),
                  ),
                  const SizedBox(height: 15,),
                  Text(
                    'Yaatal Mbindoum Al Xurane',
                    style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                        color: color.AppColor.yWhiteColor
                    ),
                  ),
                  const SizedBox(height: 40,),
                  //Premiere cercle pour la durée totale des temps
                  Row(
                    children: [
                      Container(
                        width: 110,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [
                              color.AppColor.ySecondaryColor,
                              color.AppColor.yDarkColor
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.bottomRight
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer,
                              size: 20,
                              color: color.AppColor.yAccentColor,
                            ),
                            const SizedBox(height: 5,),
                            Text(
                              "10H30min",
                              style: TextStyle(
                                fontSize: 16,
                                color: color.AppColor.yWhiteColor
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20,),
                      Container(
                        width: 200,
                        height: 30,
                            decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [
                              color.AppColor.ySecondaryColor,
                              color.AppColor.yDarkColor
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.bottomRight
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.handyman_outlined,
                              size: 20,
                              color: color.AppColor.yAccentColor,
                            ),
                            const SizedBox(height: 5,),
                            Text(
                              "Youtube Channel, List",
                              style: TextStyle(
                                  fontSize: 13,
                                  color: color.AppColor.yWhiteColor
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  //
                ],
              ),
            )
            :Container(
              child: Column(
                children: [
                  Container(
                    height: 100,
                    padding: const EdgeInsets.only(top: 50, left: 30, right: 30),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: (){},
                           child: Icon(Icons.arrow_back_ios, size: 20, color: color.AppColor.yDarkColor,),
                        ),
                        Expanded(child: Container()),
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: color.AppColor.yDarkColor,
                        ),
                      ],
                    ),
                  ),
                  _playView(context),
                ],
              ),
            ),
            //Partie liste des videos
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: color.AppColor.yWhiteColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(70),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30,),
                    Row(
                      children: [
                        SizedBox(width: 30,),
                        Text(
                          "LISTE DES VIDEOS",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color.AppColor.yAccentColor
                          ),
                        ),
                        Expanded(child: Container()),
                        Row(
                          children: [
                            Icon(Icons.loop, size: 30, color: color.AppColor.yAccentColor,),
                          ],
                        ),
                        const SizedBox(width: 10,),
                      ],
                    ),
                    //Partie qui va generer la liste des videos
                    Expanded(
                      child: Column(
                        children: [
                          _buildInfoView(),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                              itemCount: _videoList.videos!.length,
                              itemBuilder: (context, index){
                                VideoItem videoItem = _videoList.videos![index];
                                return GestureDetector(
                                  onTap: (){},
                                  child: Container(
                                    child: Row(
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: videoItem.video!.thumbnails!.thumbnailsDefault.url,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                                
                              }
                            ),
                          ),
                        ],
                      ),
                      
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

    Widget _playView(BuildContext context){
    final controller = "_controller";
    if(controller == ""){
      return const Placeholder();
    }else{
      return  const Placeholder();
    }
  }
  _buildInfoView(){
    return _loading 
    ? CircularProgressIndicator()
    :Container(
      child: Card(
        child: Row(
          children: [
            CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              _item.snippet.thumbnails.medium.url
            ),
            ),
            SizedBox(width: 20,),
            Text(
              _item.snippet.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _item.statistics.videoCount,
            ),
          ],
        ),
      ),
    );
  }
}
