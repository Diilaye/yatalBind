import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/exceptions/app_exceptions.dart';

/// Classe de base pour tous les contrôleurs
abstract class BaseController extends GetxController {
  // État de chargement
  final RxBool _isLoading = false.obs;
  RxBool get isLoading => _isLoading;
  
  // État d'erreur
  final RxString _errorMessage = ''.obs;
  final RxBool _hasError = false.obs;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;
  
  // État de succès
  final RxString _successMessage = ''.obs;
  String get successMessage => _successMessage.value;
  
  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }
  
  /// Initialisation personnalisée pour chaque contrôleur
  void _initializeController() {
    // À surcharger dans les contrôleurs enfants si nécessaire
  }
  
  /// Définir l'état de chargement
  void setLoading(bool loading) {
    _isLoading.value = loading;
    if (loading) {
      clearError();
    }
  }
  
  /// Gestion des erreurs
  void handleError(dynamic error, {String? customMessage}) {
    String message = customMessage ?? 'Une erreur est survenue';
    
    if (error is AppException) {
      message = error.message;
    } else if (error is Exception) {
      message = error.toString();
    }
    
    _errorMessage.value = message;
    _hasError.value = true;
    _isLoading.value = false;
    
    Get.snackbar(
      'Erreur',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
    
    print('Erreur dans ${runtimeType.toString()}: $message');
  }

  /// Afficher un message de succès
  void showSuccess(String message) {
    _successMessage.value = message;
    Get.snackbar(
      'Succès',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Afficher un message d'information
  void showInfo(String message) {
    Get.snackbar(
      'Information',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
  
  /// Effacer l'erreur
  void clearError() {
    _errorMessage.value = '';
    _hasError.value = false;
  }
  
  /// Effacer le message de succès
  void clearSuccess() {
    _successMessage.value = '';
  }
  
  /// Vérifier si une opération est en cours
  bool get isBusy => _isLoading.value;
  
  @override
  void onClose() {
    // Nettoyage automatique
    _isLoading.close();
    _errorMessage.close();
    _hasError.close();
    _successMessage.close();
    super.onClose();
  }
}