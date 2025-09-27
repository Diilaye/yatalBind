import 'package:flutter/material.dart';import 'dart:ui';



/// Liste des couleurs de l'application/// Liste des couleurs de l'application

class AppColor {class AppColor {

  static const Color yPrimaryColor = Color(0xFF3F48CC);  static Color yPrimaryColor = const Color(0xFF000000);

  static const Color ySecondaryColor = Color(0xFFFFE24B);  static Color ySecondaryColor = const Color(0xFFFFF400);

  static const Color yAccentColor = Color(0xFFff7f7f);  static Color yAccentColor = const Color.fromARGB(255, 2, 79, 21);

  static Color yAccentGradientdColor = const Color.fromARGB(163, 2, 79, 21);

  // Couleurs du texte

  static const Color yTextColor = Color(0xFF333333);  static Color yCardBgColor = const Color(0xFFF7F6F1);

  static const Color yTextLightColor = Color(0xFF666666);  static Color yWhiteColor = const Color(0xFFFFFFFF);

  static const Color yTextDark = Color(0xFF000000);  static Color yDarkColor = const Color(0xFF000000);

  static const Color yTextGray = Color(0xFF393838);  static Color yTextDark = const Color(0xFF000000);

  static const Color yErrorColor = Colors.red;  static Color yTextGray = const Color(0xFF393838);

  

  // Couleurs de fond  import 'package:flutter/material.dart';

  static const Color yBackgroundColor = Color(0xFFF5F5F5);

  static const Color yCardColor = Colors.white;// Couleurs principales

  static const Color yCardBgColor = Color(0xFFF7F6F1);  static Color yTextColor = const Color(0xFF333333);

  static const Color yWhiteColor = Color(0xFFFFFFFF);  static Color yErrorColor = const Color(0xFFD32F2F);

  static const Color yDarkColor = Color(0xFF000000);  static Color ySuccessColor = const Color(0xFF388E3C);

  static Color yWarningColor = const Color(0xFFF57C00);

  // Couleurs d'onboarding  static Color yInfoColor = const Color(0xFF1976D2);

  static const Color yOnBoardingPage1Color = Color.fromARGB(255, 0, 0, 0);

  static const Color yOnBoardingPage2Color = Color.fromARGB(255, 2, 79, 21);  // Couleurs d'onboarding

  static const Color yOnBoardingPage3Color = Color(0Xffffffff);  static Color yOnBoardingPage1Color = const Color.fromARGB(255, 0, 0, 0);

    static Color yOnBoardingPage2Color = const Color.fromARGB(255, 2, 79, 21);

  // Couleurs gradient  static Color yOnBoardingPage3Color = const Color(0xFFFFFFFF);

  static const Color yAccentGradientdColor = Color.fromARGB(163, 2, 79, 21);}

}

// Couleurs globales (compatibilité)

// Couleurs principales pour usage directconst yPrimaryColor = Color(0xFF000000);

const Color yPrimaryColor = Color(0xFF3F48CC);const ySecondaryColor = Color(0xFFFFF400);

const Color ySecondaryColor = Color(0xFFFFE24B);const yAccentColor = Color.fromARGB(255, 2, 79, 21);

const Color yAccentColor = Color(0xFFff7f7f);

const yCardBgColor = Color(0xFFF7F6F1);

// Couleurs du texteconst yWhiteColor = Color(0xFFFFFFFF);

const Color yTextColor = Color(0xFF333333);const yDarkColor = Color(0xFF000000);

const Color yTextLightColor = Color(0xFF666666);

const Color yErrorColor = Colors.red;// Couleurs d'onboarding

const yOnBoardingPage1Color = Color.fromARGB(255, 0, 0, 0);

// Couleurs de fondconst yOnBoardingPage2Color = Color.fromARGB(255, 2, 79, 21);

const Color yBackgroundColor = Color(0xFFF5F5F5);const yOnBoardingPage3Color = Color(0Xffffffff);
const Color yCardColor = Colors.white;
const Color yWhiteColor = Color(0xFFFFFFFF);
const Color yDarkColor = Color(0xFF000000);

// Couleurs d'onboarding
const Color yOnBoardingPage1Color = Color.fromARGB(255, 0, 0, 0);
const Color yOnBoardingPage2Color = Color.fromARGB(255, 2, 79, 21);
const Color yOnBoardingPage3Color = Color(0Xffffffff);