import 'package:yaatal_mbindum/bloc/controllers/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arabic_font/arabic_font.dart';
import '../../utils/colors.dart';

class CustomAppBar extends StatelessWidget {
  CustomAppBar({super.key});

  final LanguageController langController = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bouton notifications
            IconButton(
                style: IconButton.styleFrom(
                    backgroundColor: yWhiteColor, padding: EdgeInsets.all(20)),
                onPressed: () {},
                iconSize: 30,
                icon: const Icon(
                  Icons.notifications_outlined,
                  size: 20,
                  color: yAccentColor,
                )),

            // Titre de l'app (au centre)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  'app_title'.tr,
                  textAlign: TextAlign.center,
                  style: langController.currentLanguage.value == 'ar'
                      ? const ArabicTextStyle(
                          arabicFont: ArabicFont.dinNextLTArabic,
                          fontSize: 12,
                          color: yWhiteColor,
                          fontWeight: FontWeight.bold,
                        )
                      : const TextStyle(
                          fontSize: 12,
                          color: yWhiteColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                ),
              ),
            ),

            // Sélecteur de langue
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: yWhiteColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: yWhiteColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: langController.currentLanguage.value,
                  icon:
                      const Icon(Icons.language, color: yWhiteColor, size: 18),
                  dropdownColor: yWhiteColor,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: yDarkColor,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'fr',
                      child: Text('Français'),
                    ),
                    DropdownMenuItem(
                      value: 'ar',
                      child: Text('العربية'),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      langController.changeLanguage(newValue);
                    }
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
