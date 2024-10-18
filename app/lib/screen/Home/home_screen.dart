import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yWhiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BIENVENUE', 
                            style: TextStyle(
                              color: yAccentColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            '10 Oct, 2024',
                            style: TextStyle(color: yAccentColor),
                          )
                        ],
                      ),
                      Icon(
                        Icons.sign_language_outlined,
                        color: yAccentColor,
                      ),
                    ],
                  ),
                  //NOTIFICATIONS
                  Container(
                    decoration: BoxDecoration(
                      color: yDarkColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(12),
                    // ignore: prefer_const_constructors
                    child: Icon(
                      Icons.message_outlined,
                      color: yAccentColor,
                    )
                  )
                ],
              ),

              const SizedBox(height: 25,),
              //search button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(color: yAccentColor, borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(12),
                    // ignore: prefer_const_constructors
                    child: Row(
                      children: const [
                        Icon(
                          Icons.search,
                          color: yDarkColor,
                          ),
                          SizedBox(width: 8,),
                        Text(
                          'Rechercher',
                          style: TextStyle(
                            color: yWhiteColor
                          ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(color: yAccentColor, borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.settings_input_composite_sharp, color: yDarkColor,),
                  ),
                ],
              ),

              const SizedBox(height: 25,),
              //SLIDER 

            ],
          ),
        ),
      ),
    );
  }
}