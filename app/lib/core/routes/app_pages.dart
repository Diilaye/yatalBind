import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../screen/splash_screen.dart';
import '../../screen/nav_bar_screen.dart';
import '../../screen/Home/home_screen.dart';
import '../../screen/Concours/concours.dart';
import '../../screen/Concours/participate_screen.dart';
import '../../screen/Concours/pdfviewer_screen.dart';
import '../../screen/Events/events.dart';
import '../../screen/Events/video_player_screen.dart';
import '../../screen/Events/video_screen.dart';
import '../../screen/Contact/contact.dart';
import '../../screen/Gallery/gallery_screen.dart';
import '../../screen/nav_bar_screen.dart';

import '../../controllers/events_controller.dart';
import '../../controllers/participate_controller.dart';
import '../../controllers/contact_controller.dart';
import '../../bloc/fade_in_animation_controller.dart';

import 'app_routes.dart';

/// Gestionnaire de navigation de l'application
class AppPages {
  static final List<GetPage> pages = [
    // Page de démarrage
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => FadeInAnimationController());
      }),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // Navigation principale
    GetPage(
      name: AppRoutes.navbar,
      page: () => NavBarScreen(),
      transition: Transition.cupertino,
    ),
    
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      transition: Transition.cupertino,
    ),
    
    // Pages de concours
    GetPage(
      name: AppRoutes.concours,
      page: () => const ConcoursScreen(),
      transition: Transition.rightToLeft,
    ),
    
    GetPage(
      name: AppRoutes.concoursParticipate,
      page: () => ParticipateScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ParticipateController());
      }),
      transition: Transition.rightToLeft,
    ),
    
    GetPage(
      name: AppRoutes.concoursPdf,
      page: () {
        final String filePath = Get.arguments as String? ?? '';
        return PDFViewerWidget(filePath: filePath);
      },
      transition: Transition.rightToLeft,
    ),
    
    // Pages d'événements
    GetPage(
      name: AppRoutes.events,
      page: () => const EventsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EventsController());
      }),
      transition: Transition.rightToLeft,
    ),
    
    GetPage(
      name: AppRoutes.videoPlayer,
      page: () {
        final String videoId = Get.arguments as String? ?? '';
        return VideoPlayerScreen(videoId: videoId);
      },
      transition: Transition.downToUp,
    ),
    
    GetPage(
      name: AppRoutes.eventVideo,
      page: () {
        final String videoId = Get.arguments as String? ?? '';
        return VideoScreen(id: videoId);
      },
      transition: Transition.downToUp,
    ),
    
    // Page de contact
    GetPage(
      name: AppRoutes.contact,
      page: () => ContactScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ContactController());
      }),
      transition: Transition.rightToLeft,
    ),
    
    // Page de galerie
    GetPage(
      name: AppRoutes.gallery,
      page: () => const GalleryScreen(),
      transition: Transition.rightToLeft,
    ),
    
    // Page d'authentification
    GetPage(
      name: AppRoutes.auth,
      page: () => const NavBarScreen(),
      transition: Transition.cupertino,
    ),
    
    // Page d'erreur 404
    GetPage(
      name: AppRoutes.notFound,
      page: () => const NotFoundPage(),
    ),
  ];
  
  // Page initiale
  static String get initialRoute => AppRoutes.splash;
}

/// Page d'erreur 404
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page non trouvée'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Page non trouvée',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'La page que vous recherchez n\'existe pas.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}