import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/services/network_service.dart';
import '../core/exceptions/app_exceptions.dart';
import 'base_controller.dart';

/// Modèle pour les données de contact
class ContactData {
  final String name;
  final String surname;
  final String email;
  final String phone;
  final String message;

  ContactData({
    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'surname': surname,
      'email': email,
      'phone': phone,
      'message': message,
    };
  }
}

/// Contrôleur pour l'écran de contact
class ContactController extends BaseController {
  
  // Clé du formulaire
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Contrôleurs de texte
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  // Contrôleur de carte
  final Completer<GoogleMapController> mapController = Completer<GoogleMapController>();

  // Variables réactives
  final RxBool _isSubmitting = false.obs;
  bool get isSubmitting => _isSubmitting.value;

  // Adresses du groupe Yaatal Mbinde
  final List<LatLng> addresses = [
    const LatLng(14.7229682, -17.4356641), // Dakar - Siège principal
    const LatLng(14.7537825, -17.4355525), // Dakar - Antenne Médina
    const LatLng(14.7796272, -17.3158438), // Dakar - Antenne Parcelles
    const LatLng(14.7613031, -17.3018858), // Dakar - Antenne Yoff
    const LatLng(14.6928, -17.4467),       // Dakar - Antenne Plateau
  ];

  // Configuration de la carte
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(14.7229682, -17.4356641), // Centré sur Dakar
    zoom: 11.0,
  );

  CameraPosition get initialCameraPosition => _initialCameraPosition;

  // Marqueurs pour les adresses
  final RxSet<Marker> _markers = <Marker>{}.obs;
  Set<Marker> get markers => _markers;

  // Services
  final NetworkService _networkService = Get.find<NetworkService>();

  @override
  void onInit() {
    super.onInit();
    _initializeMarkers();
  }

  @override
  void onClose() {
    // Nettoyer les contrôleurs
    nameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    messageController.dispose();
    super.onClose();
  }

  /// Initialise les marqueurs sur la carte
  void _initializeMarkers() {
    final List<String> locationNames = [
      'Siège Principal - Yaatal Mbinde',
      'Antenne Médina',
      'Antenne Parcelles Assainies',
      'Antenne Yoff',
      'Antenne Plateau',
    ];

    for (int i = 0; i < addresses.length && i < locationNames.length; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId('location_$i'),
          position: addresses[i],
          infoWindow: InfoWindow(
            title: locationNames[i],
            snippet: 'Centre Yaatal Mbinde',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }
  }

  /// Callback pour l'initialisation de la carte
  void onMapCreated(GoogleMapController controller) {
    if (!mapController.isCompleted) {
      mapController.complete(controller);
    }
  }

  /// Valide et envoie le message de contact
  Future<void> sendMessage() async {
    if (!_validateForm()) return;

    try {
      _isSubmitting.value = true;
      setLoading(true);

      final contactData = ContactData(
        name: nameController.text.trim(),
        surname: surnameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        message: messageController.text.trim(),
      );

      final response = await _networkService.post(
        '/api/contact',
        {
          'name': name,
          'email': email,
          'subject': subject,
          'message': messageText,
        },
      );

      if (response.containsKey('success') && response['success'] == true) {
        showSuccess('Votre message a été envoyé avec succès !');
        _resetForm();
      } else {
        throw NetworkException(
          message: response['message'] ?? 'Erreur lors de l\'envoi du message',
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
      showError('Veuillez corriger les erreurs dans le formulaire');
      return false;
    }
    return true;
  }

  /// Remet à zéro le formulaire
  void _resetForm() {
    formKey.currentState?.reset();
    nameController.clear();
    surnameController.clear();
    emailController.clear();
    phoneController.clear();
    messageController.clear();
  }

  /// Centre la carte sur une adresse spécifique
  Future<void> focusOnLocation(int index) async {
    if (index < 0 || index >= addresses.length) return;

    try {
      final GoogleMapController controller = await mapController.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: addresses[index],
            zoom: 15.0,
          ),
        ),
      );
    } catch (error) {
      showError('Impossible de centrer la carte sur cette position');
    }
  }

  /// Validation pour le nom/prénom
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
  }

  /// Validation pour l'email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Email invalide';
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

  /// Validation pour le message
  String? validateMessage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    if (value.length < 10) {
      return 'Le message doit contenir au moins 10 caractères';
    }
    return null;
  }

  /// Ouvre l'application de téléphone avec un numéro
  void callNumber(String number) {
    // TODO: Implémenter l'ouverture de l'application téléphone
    showInfo('Appel vers: $number');
  }

  /// Ouvre l'application email
  void sendEmail(String email) {
    // TODO: Implémenter l'ouverture de l'application email
    showInfo('Email vers: $email');
  }
}