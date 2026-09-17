import '/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arabic_font/arabic_font.dart';
import 'package:yaatal_mbindum/bloc/controllers/language_controller.dart';

class SearchBarWidget extends StatelessWidget {
  SearchBarWidget({super.key});

  final LanguageController langController = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          height: 55,
          width: double.infinity,
          decoration: BoxDecoration(
            color: yWhiteColor,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                color: yAccentColor,
                size: 30,
              ),
              const SizedBox(
                width: 10,
              ),
              Flexible(
                flex: 4,
                child: TextField(
                  decoration: InputDecoration(
                      hintText: 'app_search'.tr,
                      hintStyle: langController.currentLanguage.value == 'ar'
                          ? const ArabicTextStyle(
                              arabicFont: ArabicFont.dinNextLTArabic,
                              fontSize: 16,
                            )
                          : const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                            ),
                      border: InputBorder.none),
                ),
              ),
              Container(
                height: 25,
                width: 1.5,
                color: yAccentColor,
              ),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.tune,
                    color: yAccentColor,
                  )),
            ],
          ),
        ));
  }
}
