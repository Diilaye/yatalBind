import 'package:app/utils/data.dart';
import 'package:app/utils/images_string.dart';
import 'package:app/utils/images_viewer_helper.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageSlider extends StatelessWidget {
  const ImageSlider({super.key});

  @override
  Widget build(BuildContext context) {
    Size size;
    double height, width;

    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

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
                    height: 220,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        CarouselSlider(
                            items: AppData.innerStyleImages.map((imagePath){
                              return Builder(
                                  builder: (BuildContext context){
                                    return ImageViewerHelper.show(
                                        context: context,
                                        url: imagePath,
                                    );
                                  },
                              );
                            }).toList(),
                            options: CarouselOptions(
                              enlargeCenterPage: true,
                            ),
                        ),
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
