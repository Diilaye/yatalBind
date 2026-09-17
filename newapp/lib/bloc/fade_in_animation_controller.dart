import 'package:get/get.dart';
import '/screen/nav_bar_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  FadeInAnimationController
//  NB : Le nouveau SplashScreen gère ses propres animations en interne.
//  Ce controller est conservé pour la compatibilité avec TFadeAnimation
//  utilisé ailleurs dans l'app.
// ─────────────────────────────────────────────────────────────────────────────

class FadeInAnimationController extends GetxController {
  static FadeInAnimationController get find => Get.find();

  RxBool animate = false.obs;

  @override
  void onInit() {
    super.onInit();
    startAnimation();
  }

  Future<void> startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    animate.value = true;
    // La durée est alignée sur la séquence du SplashScreen (6s)
    await Future.delayed(const Duration(milliseconds: 5500));
    Get.offAll(() => const NavBarScreen());
  }
}
