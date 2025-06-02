import 'dart:developer';

import '/bloc/youtube/player.dart';
import 'package:flutter/material.dart';
import '/models/category.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      width: double.infinity,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final videoId = YoutubePlayer.convertUrlToId(categories[index].url!);
          return InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Player(videoId: videoId!)));
            },
            child: Column(
              children: [
                Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: AssetImage(categories[index].image),
                        fit: BoxFit.cover),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(categories[index].titre,
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(
          width: 20,
        ),
      ),
    );
  }
}
