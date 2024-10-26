import 'package:flutter/material.dart';

class ConcoursSlider extends StatelessWidget {
  final Function(int) onChange;
  final String image;

  const ConcoursSlider({super.key, required this.onChange, required this.image});

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      height: 250,
      child: PageView.builder(
        onPageChanged: onChange,
        itemBuilder: (context, index){
          return Image.asset(image);
      },
      ),
    );
  }
}
