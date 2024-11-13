import 'dart:convert';
import 'dart:developer';

import 'package:app/screen/nav_bar_screen.dart';
import 'package:app/utils/colors.dart' as color;
import 'package:app/utils/images_string.dart';
import 'package:app/widgets/app_bar_widget/page_app_bar.dart';
import 'package:app/widgets/cart_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {

  List plays = [];
  bool _playArea = false;
  late VideoPlayerController _controller;
  _initData() async {
    await DefaultAssetBundle.of(context).loadString("json/videoinfo.json").then((value){
      setState(() {
        plays = json.decode(value);
      });
    });
  }

  @override
  void initState(){
    super.initState();
    _initData();
  }

  @override
  void dispose(){
    super.dispose();
    _controller.dispose();
  }
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
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
            _playArea==false?Container(
              padding: const EdgeInsets.only(top: 70, left: 30, right: 30),
              width: MediaQuery.of(context).size.width,
              height: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap:(){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>NavBarScreen()));
                        },
                        child: Icon(
                            Icons.arrow_back_ios,
                          size: 20,
                          color: color.AppColor.yWhiteColor,
                        ),
                      ),
                      Expanded(child: Container()),
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: color.AppColor.yWhiteColor,
                      ),
                    ],
                  ),
                  SizedBox(height: 30,),
                  Text(
                    'Vos Videos',
                    style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                      color: color.AppColor.yWhiteColor
                    ),
                  ),
                  SizedBox(height: 15,),
                  Text(
                    'Yaatal Mbindoum Al Xurane',
                    style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                        color: color.AppColor.yWhiteColor
                    ),
                  ),
                  const SizedBox(height: 50,),
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
                              "68 min",
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
                        width: 250,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
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
                                  fontSize: 16,
                                  color: color.AppColor.yWhiteColor
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 20,),
                ],
              ),
            ):Container(
              child: Column(
                children: [
                  //Video playing
                  Container(
                    height: 100,
                    padding: const EdgeInsets.only(top: 50, left: 30, right: 30),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: (){

                          },
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
                    SizedBox(height: 30,),
                    Row(
                      children: [
                        SizedBox(width: 30,),
                        Text(
                          "Liste des videos",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: color.AppColor.yDarkColor
                          ),
                        ),
                        Expanded(child: Container()),
                        Row(
                          children: [
                            Icon(
                              Icons.loop,
                              size: 30,
                              color: color.AppColor.yAccentColor,
                            ),
                            SizedBox(width: 10,),
                            Text(
                              "3 videos",
                              style: TextStyle(
                                fontSize: 15,
                                color: color.AppColor.yOnBoardingPage1Color
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 20,),
                      ],
                    ),
                    Expanded(
                      child: _listView(),
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
    final controller = _controller;
    if(controller!=null && controller.value.isInitialized){
      return Container(
        height: 300,
        width: 300,
        child: VideoPlayer(controller),
      );
    }else{
      return Text(
        "Video en Chargement",
      );
    }
  }
  _onSelectedVideo(int index){
    final controller = VideoPlayerController.network(plays[index]["videoUrl"]);
    _controller = controller;
    setState(() {
    });
    controller..initialize().then((_){
      controller.play();
      setState(() {
      });
    });
  }
  _listView(){
    return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        itemCount: plays.length,
        itemBuilder: (_, int index){
          return GestureDetector(
            onTap: (){
              _onSelectedVideo(index);
              debugPrint(index.toString());
              setState(() {
                if(_playArea==false){
                  _playArea = true;
                }
              });
            },
            child: _buildCardVideo(index),
          );
        });
  }
  _buildCardVideo(int index){
    return Container(
      height: 135,
      child: Column(
        children: [
          //Affichage des videos
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage(
                        plays[index]["thumbnail"]
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plays[index]["title"],
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Text(
                      plays[index]["time"],
                      style: TextStyle(
                          color: color.AppColor.yTextGray
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 18,),

          //Sperated videos widget
          Row(
            children: [
              Container(
                width: 80,
                height: 20,
                decoration: BoxDecoration(
                  color: color.AppColor.yAccentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "15 Rest",
                    style: TextStyle(
                        color: color.AppColor.yCardBgColor
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for(int i=0; i<70; i++)
                    i.isEven? Container(
                      width: 3,
                      height: 1,
                      decoration: BoxDecoration(
                          color:color.AppColor.yAccentColor
                      ),
                    ):Container(
                      width: 3,
                      height: 2,
                      color: color.AppColor.yCardBgColor,
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
