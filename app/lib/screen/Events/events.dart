import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../utils/colors.dart' as app_colors;
import '../../controllers/events_controller.dart';
import '../../services/youtube_service.dart' as yt_service;
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EventsController controller = Get.find<EventsController>();
    
    return Scaffold(
      body: Obx(() => _buildBody(controller)),
    );
  }

  Widget _buildBody(EventsController controller) {
    return Container(
      decoration: controller.playArea
          ? BoxDecoration(color: app_colors.AppColor.yCardBgColor)
          : BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3F48CC).withValues(alpha: 0.1),
                  app_colors.AppColor.ySecondaryColor
                ],
                begin: const FractionalOffset(0.0, 0.4),
                end: Alignment.topRight,
              ),
            ),
      child: Column(
        children: [
          _buildHeaderOrPlayer(controller),
          Expanded(child: _buildVideoList(controller)),
        ],
      ),
    );
  }

  Widget _buildHeaderOrPlayer(EventsController controller) {
    return controller.playArea
        ? _buildVideoPlayer(controller)
        : _buildHeader();
  }

  Widget _buildVideoPlayer(EventsController controller) {
    final youtubeController = controller.youtubeController;
    
    return Column(
      children: [
        _buildPlayerHeader(controller),
        if (youtubeController != null)
          Container(
            child: YoutubePlayer(
              controller: youtubeController,
              showVideoProgressIndicator: true,
              onReady: () {
                // Géré par le contrôleur
              },
            ),
          )
        else
          const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildPlayerHeader(EventsController controller) {
    return Container(
      height: 100,
      padding: const EdgeInsets.only(top: 50, left: 30, right: 30),
      child: Row(
        children: [
          InkWell(
            onTap: controller.closePlayer,
            child: Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: app_colors.AppColor.yAccentColor,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: controller.togglePlayPause,
            child: Icon(
              Icons.info_outline,
              size: 20,
              color: app_colors.AppColor.yAccentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 70, left: 30, right: 30),
      width: double.infinity,
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Get.back(),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: app_colors.AppColor.yWhiteColor,
                  size: 20,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.info_outline,
                color: app_colors.AppColor.yWhiteColor,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            "Événements",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              color: app_colors.AppColor.yWhiteColor,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Découvrez nos contenus vidéos",
            style: TextStyle(
              fontSize: 16,
              color: app_colors.AppColor.yWhiteColor,
            ),
          ),
          const SizedBox(height: 30),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Container(
          width: 200,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                app_colors.AppColor.ySecondaryColor,
                app_colors.AppColor.yDarkColor,
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library_outlined,
                size: 20,
                color: app_colors.AppColor.yAccentColor,
              ),
              const SizedBox(width: 5),
              Text(
                "Toutes les vidéos",
                style: TextStyle(
                  fontSize: 16,
                  color: app_colors.AppColor.yWhiteColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 60),
        Container(
          width: 200,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                app_colors.AppColor.ySecondaryColor,
                app_colors.AppColor.yDarkColor,
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.handyman_outlined,
                size: 20,
                color: app_colors.AppColor.yAccentColor,
              ),
              const SizedBox(width: 5),
              Text(
                "100 Vidéos",
                style: TextStyle(
                  fontSize: 16,
                  color: app_colors.AppColor.yWhiteColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoList(EventsController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: app_colors.AppColor.ySecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              "Aucune vidéo disponible",
              style: TextStyle(
                fontSize: 18,
                color: app_colors.AppColor.ySecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: controller.refreshVideos,
              child: const Text("Actualiser"),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: app_colors.AppColor.yWhiteColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(70),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        itemCount: controller.videos.length,
        itemBuilder: (context, index) {
          final video = controller.videos[index];
          return _buildVideoCard(video, controller);
        },
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video, EventsController controller) {
    final String? videoId = yt_service.YoutubeService.getVideoIdFromUrl(video["videoUrl"] ?? "");
    
    return GestureDetector(
      onTap: () {
        if (video["videoUrl"] != null) {
          controller.selectVideo(video["videoUrl"]);
        }
      },
      child: Container(
        height: 135,
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 170,
              height: 135,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 40,
                    color: app_colors.AppColor.ySecondaryColor.withAlpha(50),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: videoId != null
                    ? yt_service.YoutubeService.buildThumbnailWidget(
                        videoId: videoId,
                        width: 170,
                        height: 135,
                        quality: yt_service.ThumbnailQuality.medium,
                      )
                    : Container(
                        color: app_colors.AppColor.ySecondaryColor.withAlpha(75),
                        child: const Icon(Icons.play_circle_fill, size: 50),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            // Contenu
            Expanded(
              child: Container(
                height: 135,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video["title"] ?? "Titre non disponible",
                      maxLines: 3,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      video["description"] ?? "Description non disponible",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: app_colors.AppColor.yTextColor.withAlpha(150),
                      ),
                    ),
                    const Spacer(),
                    // Durée et vues
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: app_colors.AppColor.yAccentColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            video["time"] ?? "00:00",
                            style: TextStyle(
                              fontSize: 10,
                              color: app_colors.AppColor.yAccentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.play_circle_fill,
                          color: app_colors.AppColor.yAccentColor,
                          size: 20,
                        ),
                      ],
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
}