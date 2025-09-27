import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class YouTubeThumbnail extends StatelessWidget {
  final String videoId;
  final double? width;
  final double? height;
  final BoxFit fit;

  const YouTubeThumbnail({
    Key? key,
    required this.videoId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sur Flutter Web, utilisons une image de fallback ou un proxy
    if (kIsWeb) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 48,
              color: Colors.grey[600],
            ),
            SizedBox(height: 8),
            Text(
              'Vidéo YouTube',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              'ID: ${videoId.substring(0, 8)}...',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    } else {
      // Sur mobile, utilisez l'API YouTube normale
      final thumbnailUrl = YoutubePlayer.getThumbnail(videoId: videoId);
      
      return CachedNetworkImage(
        imageUrl: thumbnailUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[400],
              ),
              SizedBox(height: 8),
              Text(
                'Erreur de chargement',
                style: TextStyle(
                  color: Colors.red[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}