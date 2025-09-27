import 'package:get/get.dart';
import '../controllers/base_controller.dart';
import '../core/routes/app_routes.dart';

/// Contrôleur pour les animations de fade in de l'écran de démarrage
class FadeInAnimationController extends BaseController {
  static FadeInAnimationController get find => Get.find();

  // État de l'animation
  final RxBool _animate = false.obs;
  bool get animate => _animate.value;

  // Durées configurables
  static const Duration _initialDelay = Duration(milliseconds: 500);
  static const Duration _animationDuration = Duration(milliseconds: 2500);
  static const Duration _totalDuration = Duration(milliseconds: 5000);

  @override
  void onInit() {
    super.onInit();
    // Démarrer automatiquement l'animation
    startAnimation();
  }

  /// Démarre l'animation de fade in et navigue vers l'écran principal
  Future<void> startAnimation() async {
    try {
      // Délai initial
      await Future.delayed(_initialDelay);
      
      // Démarrer l'animation
      _animate.value = true;
      
      // Attendre la fin de l'animation
      await Future.delayed(_totalDuration);
      
      // Naviguer vers l'écran principal
      await Get.offAllNamed(AppRoutes.navbar);
      
    } catch (error) {
            handleError('Erreur lors du démarrage de l\'animation');
    }
  }

  /// Force la navigation (pour skip l'animation)
  void skipAnimation() {
    Get.offAllNamed(AppRoutes.navbar);
  }

  @override
  void onClose() {
    _animate.close();
    super.onClose();
  }
}