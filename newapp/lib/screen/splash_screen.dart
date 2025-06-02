import '/bloc/fade_in_animation_controller.dart';
import '/utils/images_string.dart';
import '/utils/text_string.dart';
import '/widgets/fade_in_animation/animation_widget.dart';
import '/widgets/fade_in_animation/fade_in_animation_model.dart';
import 'package:get/get.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import '/screen/nav_bar_screen.dart';
import '/utils/colors.dart' as color;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FadeInAnimationController());
    final size = MediaQuery.of(context).size;

    // controller.startAnimation();

    return Scaffold(
      backgroundColor: color.AppColor.yAccentColor,
      body: Stack(
        children: [
          TFadeAnimation(
            animatePosition: TAnimationPosition(
                topAfter: 60, topBefore: 0, leftAfter: 90, leftBefore: 0),
            durationInMs: 800,
            child: Align(
              alignment: AlignmentDirectional(0.78, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: AlignmentDirectional(0, 1),
                    child: Text(
                      yAppStartName,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontFamily: 'Poppins',
                          fontSize: 30,
                          color: color.AppColor.yWhiteColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          TFadeAnimation(
            animatePosition: TAnimationPosition(
                topAfter: 100, topBefore: 0, leftAfter: 18, leftBefore: 0),
            durationInMs: 800,
            child: Align(
              alignment: AlignmentDirectional(0.78, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: AlignmentDirectional(0, 1),
                    child: Text(
                      yAppMidlleName,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontFamily: 'Poppins',
                          fontSize: 27,
                          color: color.AppColor.yWhiteColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          //SPLASH IMAGE C3S
          TFadeAnimation(
              animatePosition: TAnimationPosition(
                  topAfter: size.height * 0.21,
                  topBefore: 0,
                  leftAfter: size.width * 0.2,
                  leftBefore: 0),
              durationInMs: 2000,
              child: const Image(
                image: AssetImage(YSplashLogo),
                height: 160,
              )),

          //SPLASH LOGO YAATAL
          TFadeAnimation(
            animatePosition: TAnimationPosition(
                bottomAfter: size.height * -0.03,
                bottomBefore: 0,
                leftAfter: size.width * 0.01,
                leftBefore: 0),
            durationInMs: 2000,
            child: const Image(
              image: AssetImage(ySplashImage),
            ),
          ),
        ],
      ),
    );
  }
}
