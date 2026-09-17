import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  static const String LANGUAGE_KEY = 'selected_language';

  // Observable pour la langue courante
  var currentLanguage = 'fr'.obs;
  var isRTL = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadLanguage();
  }

  // Charger la langue sauvegardée
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(LANGUAGE_KEY) ?? 'fr';
    await changeLanguage(savedLanguage);
  }

  // Changer la langue
  Future<void> changeLanguage(String languageCode) async {
    currentLanguage.value = languageCode;
    isRTL.value = languageCode == 'ar';

    // Sauvegarder dans SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LANGUAGE_KEY, languageCode);

    // Mettre à jour la locale de GetX
    Locale locale = Locale(languageCode);
    await Get.updateLocale(locale);
  }

  // Obtenir le texte d'affichage de la langue
  String getLanguageDisplayText() {
    return currentLanguage.value == 'fr' ? 'Français' : 'العربية';
  }
}
