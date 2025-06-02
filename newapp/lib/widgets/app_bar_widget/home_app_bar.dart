import 'package:flutter/material.dart';
import 'package:arabic_font/arabic_font.dart';
import '../../utils/colors.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            style: IconButton.styleFrom(
                backgroundColor: yAccentColor,
                padding: EdgeInsets.all(20)
            ),
            onPressed: (){},
            iconSize: 30,
            icon: const Icon(Icons.notifications_outlined,size: 20, color: yWhiteColor,)
        ),
        const Text(
          "مسابقة C3S الوطنية في رسم القرآن الكريم والخط المحلي",
          style: ArabicTextStyle(
            arabicFont: ArabicFont.dinNextLTArabic,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),

        )
      ],
    );
  }
}