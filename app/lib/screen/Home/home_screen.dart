import 'package:app/screen/Concours/concours.dart';
import 'package:app/screen/Events/events.dart';
import 'package:app/utils/colors.dart';
import 'package:app/widgets/app_bar_widget/search_bar_widget.dart';
import 'package:app/widgets/cart_widget.dart';
import 'package:app/widgets/category_widget.dart';
import 'package:app/widgets/concours/concours_list_widget.dart';
import 'package:app/widgets/slider_widget/home_image_slider.dart';
import 'package:app/widgets/slider_widget/image_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../widgets/app_bar_widget/home_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentSlide = 0;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: yWhiteColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30,),
              //Pour la barre en haut
              CustomAppBar(),
              SizedBox(height: 20,),
              //Pour la barre de recherche
              SearchBarWidget(),
              SizedBox(height: 40,),
              //Pour le Slider
              HomeImageSlider(
              currentSlide: currentSlide,
              onChange: (value){
                setState(() {
                  currentSlide = value;
                });
              }),
              const SizedBox(height: 20,),
              //Pour les categories
              CategoryWidget(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Evenements Précédents',
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>EventsScreen()));
                    },
                    child: Text(
                      "VOIR TOUT",
                       style: TextStyle(
                         fontFamily: 'Poppins',
                         fontWeight: FontWeight.w500,
                         fontSize: 16,
                         color: yDarkColor
                       ),
                    ),
                  ),
                ],
              ),
              //pour l'affichage des concours précédents
              Cart(),
              const SizedBox(height: 20,),
              //Pour l'affichage des infos en rapport avec le concours
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Concours Yaatal Mbinde',
                    style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800
                    ),
                  ),
                  InkWell(
                    onTap: (){
                     Get.to(ConcoursScreen());
                    },
                    child: Text(
                      "VOIR TOUT",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: yDarkColor
                      ),
                    ),
                  ),
                ],
              ),
              ConcoursWidget(),
              const SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }
}


