import 'package:flutter/material.dart';

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
          "مرحباً بكم",
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 25,
              fontWeight: FontWeight.w600
          ),

        )
      ],
    );
  }
}