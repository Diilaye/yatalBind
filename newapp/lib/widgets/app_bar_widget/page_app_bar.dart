import '/screen/Home/home_screen.dart';
import '/screen/nav_bar_screen.dart';
import '/utils/colors.dart';
import 'package:flutter/material.dart';

class PageAppBar extends StatefulWidget {
  const PageAppBar({super.key});

  @override
  State<PageAppBar> createState() => _PageAppBarState();
}

class _PageAppBarState extends State<PageAppBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          IconButton(
              style: IconButton.styleFrom(
                  backgroundColor: yAccentColor, padding: EdgeInsets.all(15)),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => NavBarScreen()));
              },
              iconSize: 30,
              icon: const Icon(
                Icons.arrow_back_ios,
                color: yWhiteColor,
              ))
        ],
      ),
    );
  }
}
