import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../core/services/network_service.dart';
import '../core/exceptions/app_exceptions.dart';
import 'base_controller.dart';

/// Contrôleur pour la participation aux concours
class ParticipateController extends BaseController {
  
  // Clé du formulaire
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Contrôleurs de texte
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();
  final TextEditingController professorController = TextEditingController();

  // Variables réactives
  final Rx<LatLng?> _currentPosition = Rx<LatLng?>(null);
  LatLng? get currentPosition => _currentPosition.value;

  final Rx<File?> _extractFile = Rx<File?>(null);
  File? get extractFile => _extractFile.value;

  final Rx<File?> _profileImage = Rx<File?>(null);
  File? get profileImage => _profileImage.value;

  final RxBool _isSubmitting = false.obs;
  bool get isSubmitting => _isSubmitting.value;

  // Services
  final ImagePicker _picker = ImagePicker();
  final NetworkService _networkService = Get.find<NetworkService>();

  @override
  void onClose() {
    // Nettoyer les contrôleurs
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    birthDateController.dispose();
    addressController.dispose();
    schoolController.dispose();
    professorController.dispose();
    super.onClose();
  }

  /// Sélectionne une image de profil depuis la galerie ou la caméra
  Future<void> pickProfileImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        _profileImage.value = File(pickedFile.path);
        showSuccess('Image de profil sélectionnée');
      }
    } catch (error) {
      handleError(NetworkException(
        message: 'Erreur lors de la sélection de l\'image: $error',
      ));
    }
  }

  /// Sélectionne le fichier d'extrait de naissance
  Future<void> pickExtractFile() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      
      if (pickedFile != null) {
        _extractFile.value = File(pickedFile.path);
        showSuccess('Extrait de naissance sélectionné');
      }
    } catch (error) {
      handleError(NetworkException(
        message: 'Erreur lors de la sélection du fichier: $error',
      ));
    }
  }

  /// Sélectionne la date de naissance
  Future<void> selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    
    if (picked != null) {
      birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  /// Met à jour la position actuelle
  void updatePosition(LatLng position) {
    _currentPosition.value = position;
  }

  /// Valide et soumet le formulaire
  Future<void> submitApplication() async {
    if (!_validateForm()) return;

    try {
      _isSubmitting.value = true;
      setLoading(true);

      // Préparer les données du formulaire
      final participantData = _prepareFormData();
      
      // Envoyer la demande
      final response = await _networkService.post(
        '/api/participate',
        participantData,
      );

      if (response.containsKey('success') && response['success'] == true) {
        showSuccess('Votre candidature a été soumise avec succès !');
        _resetForm();
        Get.back(); // Retourner à l'écran précédent
      } else {
        throw NetworkException(
          message: response['message'] ?? 'Erreur lors de la soumission',
        );
      }

    } catch (error) {
      handleError(error);
    } finally {
      _isSubmitting.value = false;
      setLoading(false);
    }
  }

  /// Valide le formulaire
  bool _validateForm() {
    if (!formKey.currentState!.validate()) {
            handleError('Erreur lors de la validation des données');
      return false;
    }

    if (_extractFile.value == null) {
      showError('Veuillez sélectionner l\'extrait de naissance');
      return false;
    }

    if (_currentPosition.value == null) {
      showError('Veuillez sélectionner votre position géographique');
      return false;
    }

    return true;
  }

  /// Prépare les données du formulaire
  Map<String, dynamic> _prepareFormData() {
    return {
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'phone': phoneController.text.trim(),
      'birthDate': birthDateController.text.trim(),
      'address': addressController.text.trim(),
      'school': schoolController.text.trim(),
      'professor': professorController.text.trim(),
      'latitude': _currentPosition.value?.latitude,
      'longitude': _currentPosition.value?.longitude,
      'extractFile': _extractFile.value?.path,
      'profileImage': _profileImage.value?.path,
    };
  }

  /// Remet à zéro le formulaire
  void _resetForm() {
    formKey.currentState?.reset();
    firstNameController.clear();
    lastNameController.clear();
    phoneController.clear();
    birthDateController.clear();
    addressController.clear();
    schoolController.clear();
    professorController.clear();
    _currentPosition.value = null;
    _extractFile.value = null;
    _profileImage.value = null;
  }

  /// Validation pour le nom
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
  }

  /// Validation pour le téléphone
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    // Validation basique pour les numéros sénégalais
    if (!RegExp(r'^(\+221|221)?[0-9]{9}$').hasMatch(value.replaceAll(' ', ''))) {
      return 'Numéro de téléphone invalide';
    }
    return null;
  }

  /// Validation pour l'email (optionnel)
  String? validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!GetUtils.isEmail(value)) {
        return 'Email invalide';
      }
    }
    return null;
  }
}