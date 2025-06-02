import 'package:app/bloc/fade_in_animation_controller.dart';
import 'package:app/utils/images_string.dart';
import 'package:app/utils/text_string.dart';
import 'package:app/widgets/fade_in_animation/animation_widget.dart';
import 'package:app/widgets/fade_in_animation/fade_in_animation_model.dart';
import 'package:get/get.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:app/screen/nav_bar_screen.dart';
import 'package:app/utils/colors.dart' as color;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FadeInAnimationController());
    final size = MediaQuery.of(context).size;

    controller.startAnimation();

    return Scaffold(
      backgroundColor: color.AppColor.yAccentColor,
      body: Stack(
        children: [
          TFadeAnimation(

              animatePosition: TAnimationPosition(topAfter: 80, topBefore: 0, leftAfter: 90, leftBefore: 0),
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
                            color: color.AppColor.yWhiteColor
                          ),
                        ),
                      ),
                    ],
                  ),
              ),
          ),
          TFadeAnimation(

            animatePosition: TAnimationPosition(topAfter: 120, topBefore: 0, leftAfter: 18, leftBefore: 0),
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
                          color: color.AppColor.yWhiteColor
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          //SPLASH IMAGE C3S
          TFadeAnimation(
              animatePosition: TAnimationPosition(topAfter: size.height*0.21, topBefore: 0, leftAfter: size.width*0.2, leftBefore: 0),
              durationInMs: 2000,
              child: Obx(
              ()=>AnimatedPositioned(
                  child: const Image(
                    image: AssetImage(YSplashLogo),
                    height: 160,
                  ),
                  bottom: controller.animate.value?300:0,
                  duration: const Duration(milliseconds: 2500)
              ),
              ),
          ),
          TFadeAnimation(
            animatePosition: TAnimationPosition(topAfter: size.height*0.26, topBefore: 0, leftAfter: 0, leftBefore: 20),
            durationInMs: 2000,
            child: Obx(
                  ()=>AnimatedPositioned(
                  child: Lottie.asset(
                      "json/Animation.json",
                    fit: BoxFit.fill,
                    ),
                  right: controller.animate.value? 300:0,
                  duration: const Duration(milliseconds: 2500)
              ),
            ),

          ),
          //SPLASH LOGO YAATAL
          TFadeAnimation(
            animatePosition: TAnimationPosition(bottomAfter: size.height*-0.03, bottomBefore: 0, leftAfter: size.width*0.01, leftBefore: 0),
            durationInMs: 2000,
            child: Obx(
                  ()=>AnimatedPositioned(
                  child: const Image(
                    image: AssetImage(ySplashImage),

                  ),
                  bottom: controller.animate.value?300:0,
                  duration: const Duration(milliseconds: 2500)
              ),
            ),
          ),
        ],
      ),
    );
  }
}
