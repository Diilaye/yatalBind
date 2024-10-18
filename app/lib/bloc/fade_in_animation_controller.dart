import 'package:app/screen/Home/home_screen.dart';
import 'package:app/screen/nav_bar_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FadeInAnimationController extends GetxController{

  static FadeInAnimationController get find =>Get.find();

  RxBool animate = false.obs;

  /*@override
  void initState() {
    // TODO: implement initState
    startAnimation();
  }*/

   
  Future startAnimation() async{
    await Future.delayed(Duration(milliseconds: 500));
     animate.value = true;
    await Future.delayed(Duration(milliseconds: 5000));
    //Navigator.pushReplacement(context, MaterialPageRoute(builder: WelcomeScreen));
    Get.to(NavBarScreen());
  }
}