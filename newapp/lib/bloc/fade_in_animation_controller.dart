import '/screen/Home/home_screen.dart';
import '/screen/nav_bar_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// class FadeInAnimationController extends GetxController{

//   static FadeInAnimationController get find =>Get.find();

//   RxBool animate = false.obs;

//   @override
//   void initState() {
//     // TODO: implement initState
//     startAnimation();
//   }

//   Future startAnimation() async{
//     await Future.delayed(Duration(milliseconds: 500));
//      animate.value = true;
//     await Future.delayed(Duration(milliseconds: 5000));
//     //Navigator.pushReplacement(context, MaterialPageRoute(builder: WelcomeScreen));
//     Get.to(NavBarScreen());
//   }
// }

class FadeInAnimationController extends GetxController {
  static FadeInAnimationController get find => Get.find();

  RxBool animate = false.obs;

  @override
  void onInit() {
    startAnimation();
    super.onInit();
  }

  Future startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    animate.value = true;
    await Future.delayed(const Duration(milliseconds: 5000));
    Get.to(() => const NavBarScreen()); // Navigation vers NavBarScreen
  }
}
