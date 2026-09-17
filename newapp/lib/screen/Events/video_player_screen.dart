// lib/screen/video_player_screen.dart

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '/utils/colors.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key, required this.videoId});
  final String videoId;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  // ❌ SUPPRIMÉ : get videoId => null;  ← c'était le bug critique

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId, // ✅ widget.videoId obligatoire
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        enableCaption: false,
        forceHD: false,
      ),
    )..addListener(_listener);
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {});
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // YoutubePlayerBuilder gère correctement le plein écran sur Android
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: yGoldColor,
        progressColors: const ProgressBarColors(
          playedColor: yGoldColor,
          handleColor: yGoldLight,
          bufferedColor: Colors.white24,
          backgroundColor: Colors.black26,
        ),
        onReady: () {
          debugPrint('[VideoPlayer] Prêt : ${widget.videoId}');
          setState(() => _isPlayerReady = true);
        },
        onEnded: (_) => Navigator.of(context).pop(),
      ),
      builder: (context, player) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            widget.videoId,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ),
        body: Center(child: player),
      ),
    );
  }
}
