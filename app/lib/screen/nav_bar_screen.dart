import 'package:app/screen/Concours/concours.dart';
import 'package:app/screen/Contact/contact.dart';
import 'package:app/screen/Events/events.dart';
import 'package:app/screen/Gallery/gallery_screen.dart';
import 'package:app/screen/Home/home_screen.dart';
import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';

class NavBarScreen extends StatefulWidget {
  const NavBarScreen({super.key});

  @override
  State<NavBarScreen> createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen> {
  int currentIndex = 2;
  List screens = const [
    ConcoursScreen(),
    EventsScreen(),
    HomeScreen(),
    GalleryScreen(),
    ContactScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          setState(() {
            currentIndex = 2;
          });
        },
        shape: const CircleBorder(),
        backgroundColor: currentIndex == 2 ? yDarkColor : yAccentColor,
        child: (Icon(Icons.home, color: currentIndex == 2? yAccentColor : yDarkColor, size: 35,)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        elevation: 1,
        height: 60,
        color: yAccentColor,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10, clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: (){
                  setState(() {
                    currentIndex = 0;
                  });
                },
                icon: Icon(
                  Icons.grid_view_outlined,
                  size: 25,
                  color: currentIndex == 0 ? yDarkColor: yWhiteColor,
                )
            ),
            IconButton(
                onPressed: (){
                  setState(() {
                    currentIndex = 1;
                  });
                },
                icon: Icon(
                  Icons.event_available_outlined,
                  size: 25,
                  color: currentIndex == 1 ? yDarkColor: yWhiteColor,
                )
            ),
            SizedBox(width: 15,),
            IconButton(
                onPressed: (){
                  setState(() {
                    currentIndex = 3;
                  });
                },
                icon: Icon(
                  Icons.photo_library_outlined,
                  size: 25,
                  color: currentIndex == 3 ? yDarkColor: yWhiteColor,
                )
            ),
            IconButton(
                onPressed: (){
                  setState(() {
                    currentIndex = 4;
                  });
                },
                icon: Icon(
                  Icons.contact_mail_outlined,
                  size: 25,
                  color: currentIndex == 4 ? yDarkColor: yWhiteColor,
                )
            ),
          ],
        ),
      ),
      body: screens[currentIndex],
    );
  }
}