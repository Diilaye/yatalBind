import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';

import '../../utils/images_string.dart';

class HomeImageSlider extends StatelessWidget {
  final Function (int) onChange;
  final int currentSlide;
  const HomeImageSlider({super.key, required this.currentSlide, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 220,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: PageView(
              scrollDirection: Axis.horizontal,
              allowImplicitScrolling: true,
              onPageChanged: onChange,
              physics: ClampingScrollPhysics(),
              children: [
                Image.asset(
                  slider1,
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  slider2,
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  slider3,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          bottom: 10,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    5,
                    (index) => AnimatedContainer(
                        duration: Duration(microseconds: 300),
                      width: currentSlide == index ? 15: 3,
                      height: 8,
                      margin: EdgeInsets.only(right: 3),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                        color: currentSlide == index ? yAccentColor : yDarkColor,
                        border: Border.all(color: yDarkColor)
                      ),
                    )
                ),
              ),
            )
        ),
      ],
    );
  }
}
