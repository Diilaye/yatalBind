import 'dart:convert';
import 'dart:ui';

import '/bloc/youtube/player.dart';
import 'package:flutter/material.dart';
import '/utils/colors.dart' as color;
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List _videos = [];
  bool _playArea = false;
  late YoutubePlayerController _controller =
      YoutubePlayerController(initialVideoId: '');
  late bool _isPlayerReady;

  //Fetch videos from json file
  Future<void> getVideos() async {
    final String response =
        await DefaultAssetBundle.of(context).loadString("json/videoinfo.json");
    final data = await json.decode(response);
    setState(() {
      _videos = data['videos'];
    });
  }

  _getVideos() async {
    await DefaultAssetBundle.of(context)
        .loadString("json/videoinfo.json")
        .then((value) {
      _videos = json.decode(value);
    });
  }

  @override
  void initState() {
    super.initState();
    _isPlayerReady = false;
    getVideos();
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      //
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _playArea == false
            ? BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      color.AppColor.yAccentColor.withOpacity(0.9),
                      color.AppColor.ySecondaryColor
                    ],
                    begin: const FractionalOffset(0.0, 0.4),
                    end: Alignment.topRight),
              )
            : BoxDecoration(color: color.AppColor.yCardBgColor),
        //DEBU PARTIE LECTURE TITRE OU VIDEO
        child: Column(
          children: [
            _playArea == false
                ? Container(
                    padding: EdgeInsets.only(top: 70, left: 30, right: 30),
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_back_ios,
                              color: color.AppColor.yWhiteColor,
                              size: 20,
                            ),
                            Expanded(child: Container()),
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: color.AppColor.yWhiteColor,
                            ),
                          ],
                        ),
                        //Debut Titre Page
                        const SizedBox(
                          height: 30,
                        ),
                        Text(
                          "Votre Chaine",
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: color.AppColor.yWhiteColor),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "C3s Yaatal Mbinde Al Xurane",
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: color.AppColor.yWhiteColor),
                        ),
                        //Fin PARTIE Titre
                        const SizedBox(
                          height: 50,
                        ),
                        //LIGNE CONTENANT LES STATISTICS
                        Row(
                          children: [
                            Container(
                              width: 90,
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                    colors: [
                                      color.AppColor.ySecondaryColor,
                                      color.AppColor.yDarkColor
                                    ],
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 20,
                                    color: color.AppColor.yAccentColor,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "68min",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: color.AppColor.yWhiteColor),
                                  ),
                                ],
                              ),
                            ),
                            //FIN 1ERE STATS
                            const SizedBox(
                              width: 60,
                            ),
                            Container(
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                    colors: [
                                      color.AppColor.ySecondaryColor,
                                      color.AppColor.yDarkColor
                                    ],
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.handyman_outlined,
                                    size: 20,
                                    color: color.AppColor.yAccentColor,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "100 Videos",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: color.AppColor.yWhiteColor),
                                  ),
                                ],
                              ),
                            ),
                            //FIN 2IEME STATS
                          ],
                        ),
                      ],
                    ),
                  )
                : Container(
                    child: Column(
                      children: [
                        Container(
                          height: 100,
                          padding: const EdgeInsets.only(
                              top: 50, left: 30, right: 30),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  debugPrint("Tapped");
                                },
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  size: 20,
                                  color: color.AppColor.yAccentColor,
                                ),
                              ),
                              Expanded(child: Container()),
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: color.AppColor.yAccentColor,
                              ),
                            ],
                          ),
                        ),
                        _playView(context),
                      ],
                    ),
                  ),
            //FIN PARTIE LECTURE DU VIDEO OU TITRE

            //DEBUT PARTIE LISTE DES VIDEOS
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: color.AppColor.yWhiteColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(70),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    //Titre
                    Row(
                      children: [
                        const SizedBox(
                          width: 30,
                        ),
                        Text(
                          "LISTES DES VIDEOS",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: color.AppColor.yAccentColor),
                        ),
                        Expanded(child: Container()),
                        Row(
                          children: [
                            Icon(
                              Icons.loop,
                              size: 20,
                              color: color.AppColor.yAccentColor,
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    //AFFICHAGE DES VIDEOS DE LA CHAINE
                    Expanded(
                      child: _listView(),
                    ),
                  ],
                ),
              ),
            ),
            //FIN PARTIE LISTE DES VIDEOS
          ],
        ),
      ),
    );
  }

  //FONTION QUI RETOURNE LA VIDEO EN COURS
  _playView(BuildContext context) {
    return Container(
        child: YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      onReady: () {
        print('Player is ready.');
        _isPlayerReady = true;
        _controller.addListener(_listener);
      },
    ));
  }

  //FONTION QUI RETOURBNE LA VIDEO QU'ON VEUT REGARDER
  _onSelectedVideo(String id) {
    final controller = YoutubePlayerController(
      initialVideoId: id,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
      ),
    )..addListener(_listener);
    _controller = controller;
    setState(() {});
  }

  //FONCTION QUI RETOURNE LISTVIEWBULDER
  _listView() {
    return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        itemCount: _videos.length,
        itemBuilder: (_, int index) {
          return GestureDetector(
            onTap: () {
              final videoId =
                  YoutubePlayer.convertUrlToId(_videos[index]["videoUrl"]);
              _onSelectedVideo(videoId!);
              setState(() {
                if (_playArea == false) {
                  _playArea = true;
                }
              });
            },
            child: _buildCard(index),
          );
        });
  }

  //FONCTION QUI RETOURNE L'AFFICHAGE DES VIDEOS
  _buildCard(int index) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.19,
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.height * 0.10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(_videos[index]["thumbnail"]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _videos[index]["title"],
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Text(
                      _videos[index]["time"],
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w100,
                          color: color.AppColor.yDarkColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
          //TIRET DE SEPARATION ENTRE LES VIDEOS
          const SizedBox(
            height: 18,
          ),
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.16,
                height: MediaQuery.of(context).size.height * 0.03,
                decoration: BoxDecoration(
                  color: Color(0xFFeaeefc),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "15s rest",
                    style: TextStyle(
                      color: Color(0xff056111),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (int i = 0; i < 55; i++)
                    i.isEven
                        ? Container(
                            width: MediaQuery.of(context).size.width * 0.01,
                            height: MediaQuery.of(context).size.height * 0.01,
                            decoration: BoxDecoration(
                                color: Color(0xa3024f15),
                                borderRadius: BorderRadius.circular(3)),
                          )
                        : Container(
                            width: 3,
                            height: 1,
                            color: color.AppColor.yWhiteColor,
                          ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
