import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../bloc/fade_in_animation_controller.dart';
import '../utils/images_string.dart';
import '../utils/text_string.dart';
import '../utils/colors.dart' as app_colors;
import '../widgets/fade_in_animation/animation_widget.dart';
import '../widgets/fade_in_animation/fade_in_animation_model.dart';

/// Écran de démarrage de l'application
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FadeInAnimationController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: app_colors.yAccentColor,
      body: Stack(
        children: [
          // Bouton skip (optionnel en mode debug)
          if (GetPlatform.isWeb || GetPlatform.isDesktop)
            Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: controller.skipAnimation,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: app_colors.yWhiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            
          // Animation du titre principal
          TFadeAnimation(
            animatePosition: TAnimationPosition(
              topAfter: 80, 
              topBefore: 0, 
              leftAfter: 90, 
              leftBefore: 0
            ),
            durationInMs: 800,
            child: Align(
              alignment: const AlignmentDirectional(0.78, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: const AlignmentDirectional(0, 1),
                    child: Text(
                      yAppStartName,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: app_colors.yWhiteColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Animation du sous-titre
          TFadeAnimation(
            animatePosition: TAnimationPosition(
              topAfter: 120, 
              topBefore: 0, 
              leftAfter: 18, 
              leftBefore: 0
            ),
            durationInMs: 800,
            child: Align(
              alignment: const AlignmentDirectional(0.78, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: const AlignmentDirectional(0, 1),
                    child: Text(
                      yAppMidlleName,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 27,
                        fontWeight: FontWeight.w600,
                        color: app_colors.yWhiteColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Logo principal
          TFadeAnimation(
            animatePosition: TAnimationPosition(
              topAfter: size.height * 0.35, 
              topBefore: size.height * 0.5, 
              leftAfter: size.width * 0.2, 
              leftBefore: size.width * 0.1
            ),
            durationInMs: 1200,
            child: Center(
              child: Hero(
                tag: 'splash_logo',
                child: Image.asset(
                  YSplashLogo,
                  height: 160,
                  width: 160,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          
          // Animation Lottie
          TFadeAnimation(
            animatePosition: TAnimationPosition(
              topAfter: size.height * 0.26, 
              topBefore: 0, 
              leftAfter: 0, 
              leftBefore: 20
            ),
            durationInMs: 2000,
            child: Lottie.asset(
              "json/Animation.json",
              fit: BoxFit.fill,
            ),
          ),
          
          // Logo Yaatal secondaire
          TFadeAnimation(
            animatePosition: TAnimationPosition(
              bottomAfter: size.height * -0.03, 
              bottomBefore: 0, 
              leftAfter: size.width * 0.01, 
              leftBefore: 0
            ),
            durationInMs: 2000,
            child: Image.asset(
              ySplashImage,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
