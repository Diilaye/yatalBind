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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.18,
                crossAxisSpacing: 18,
                mainAxisSpacing: 0
            ),
            itemCount: videos.length,
            itemBuilder: (context, index){
              final videoId = YoutubePlayer.convertUrlToId(videos[index]);
              return InkWell(
                  onTap: (){
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context)=>Player(videoId: videoId))
                    );
                  },
                  child: Image.network(YoutubePlayer.getThumbnail(videoId: videoId!))
              );
            }
        ),
      ],
    );
  }
}
