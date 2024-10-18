import 'package:app/bloc/youtube/player.dart';
import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

final  videos = [
  "https://www.youtube.com/watch?v=mG3Kp6S3nIw",
  "https://www.youtube.com/watch?v=qkZmW_7l8v0",
  "https://www.youtube.com/watch?v=Ov_uRtp2ztM",
  "https://www.youtube.com/watch?v=Ov_uRtp2ztM",
  "https://www.youtube.com/watch?v=qEIYpXdK3fw",
  "https://www.youtube.com/watch?v=qbKETC4l2P0",
];

class Cart extends StatelessWidget {
  const Cart({super.key});


  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: (){

      },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: yCardBgColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 15,
                ),
                Center(
                  child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        childAspectRatio: 0.78,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20
                      ),
                      itemCount: videos.length,
                      itemBuilder: (context, index){
                        final videoId = YoutubePlayer.convertUrlToId(videos[index]);
                        return InkWell(
                          onTap: (){
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (context)=>Player(videoId: videoId!))
                            );
                          },
                          child: Image.network(YoutubePlayer.getThumbnail(videoId: videoId!))
                        );
                      }
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
