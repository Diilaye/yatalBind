import 'package:app/utils/images_string.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageSlider extends StatelessWidget {
  const ImageSlider({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    return Stack(
      children: [
        SizedBox.expand(
          child: Column(
            children: [
              Column(
                children: [
                  ///Style Slider
                  const Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      "Slider Image",
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                  ),
                  SizedBox(
                    height: height * .25,
                    width: width,
                    child: Stack(
                      children: [
                        CarouselSlider(items: ['slider1', 'slider2', 'slider3'], options: options)
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
