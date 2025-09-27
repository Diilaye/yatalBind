import 'package:app/bloc/fade_in_animation_controller.dart';
import 'package:app/widgets/fade_in_animation/fade_in_animation_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class TFadeAnimation extends StatelessWidget {
  TFadeAnimation({
    super.key,
    required this.animatePosition,
    required this.durationInMs, 
    required this.child,
  });

  final controller = Get.put(FadeInAnimationController());
  final int durationInMs;
  final Widget child;
  final TAnimationPosition? animatePosition;

  @override
  Widget build(BuildContext context) {
    return Obx( () => AnimatedPositioned(
        duration: Duration(milliseconds: durationInMs),
        top: controller.animate ? animatePosition!.topAfter : animatePosition!.topBefore,
        left: controller.animate ? animatePosition!.leftAfter : animatePosition!.leftBefore,
        bottom: controller.animate ? animatePosition!.bottomAfter : animatePosition!.bottomBefore,
        right: controller.animate ? animatePosition!.rightAfter : animatePosition!.rightBefore,
        child: 
         AnimatedOpacity(
          duration: Duration(milliseconds: durationInMs),
          opacity: controller.animate ? 1 : 0,
          child: child,
           /**/
         ),  
      ),
    );
  }
}
