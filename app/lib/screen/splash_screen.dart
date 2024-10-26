import 'package:app/bloc/fade_in_animation_controller.dart';
import 'package:app/widgets/fade_in_animation/animation_widget.dart';
import 'package:app/widgets/fade_in_animation/fade_in_animation_model.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:app/utils/size.dart';
import 'package:app/utils/text_string.dart';
import 'package:app/utils/colors.dart';
import 'package:app/utils/images_string.dart';


class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);

  
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FadeInAnimationController());
    controller.startAnimation();

    return Scaffold(
      backgroundColor: yWhiteColor,
      body: Stack(
        children:  [
          TFadeAnimation(
            durationInMs: 1600,
            animatePosition: TAnimationPosition(
              topAfter: 60, topBefore: -10, leftBefore: -10, leftAfter: 55,
            ),
            child:Align(
                       alignment: AlignmentDirectional(0.78, 0),
                       child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: AlignmentDirectional(0, 1),
                child: Text(
                  yAppStartName,
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontFamily: 'Poppins',
                    color: Color(0xFF034E0F),
                    fontSize: 120,
                    fontWeight: FontWeight.bold
                  ),
                             
                  ),
              ),
           
            Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                yAppMidlleName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontFamily: 'Poppins',
                  fontSize: 36,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600
                ),
              ),
               Text(
                yAppName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontFamily: 'Poppins',
                  fontSize: 36,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600
                ),
              ),
            ],
                       ),
            ],
                       ),
                     ),
          ),
           Positioned(
            top: 0,
            left: 0,
            child: Image(image: AssetImage(ySplashTopIcon)),
          ),
         
          TFadeAnimation(
            durationInMs: 2000,
            animatePosition: TAnimationPosition(topBefore: 100, topAfter: 220, leftAfter: yDefaultSize, leftBefore: -80),
            child: Obx(
              () => AnimatedPositioned(
                duration: const Duration(milliseconds: 3600),
                bottom: controller.animate.value ? 300:0,
                child: const Image(image: AssetImage(ySplashImage),),
              ),
            ),
          ),
          TFadeAnimation(
            durationInMs: 2000,
            animatePosition: TAnimationPosition(bottomBefore: 50, bottomAfter: 110, leftAfter: 55, leftBefore: -80),
            child: Obx(
                  () => AnimatedPositioned(
                duration: const Duration(milliseconds: 3600),
                bottom: controller.animate.value ? 300:0,
                child:Image(image: AssetImage(YSplashLogo), height: 200,),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            right: yDefaultSize,
            child:Container(
              width: ySplashContainerSize,
              height: ySplashContainerSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
              color: yPrimaryColor,
              ),
            ),
          ),
        ],
      )
    );
  }
 
}

