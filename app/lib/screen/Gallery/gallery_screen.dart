import 'package:app/widgets/cart_photo.dart';
import 'package:app/widgets/cart_widget.dart';
import 'package:app/widgets/concours/concours_info.dart';
import 'package:flutter/material.dart';
import 'package:app/utils/colors.dart' as color;

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.AppColor.yAccentColor.withOpacity(0.8),
              color.AppColor.ySecondaryColor
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top:70, left: 30, right: 30),
              width: MediaQuery.of(context).size.width,
              height: 300,
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  Text(
                   "Gallerie",
                   style: TextStyle(
                     fontSize: 25,
                     fontFamily: 'Poppins',
                     fontWeight: FontWeight.w800,
                     color: color.AppColor.yWhiteColor,
                   ),
                 ),
                 const SizedBox(height: 15,),
                 Text(
                   'Yaatal Mbindoum Al Xurane',
                   style: TextStyle(
                       fontSize: 25,
                       fontFamily: 'Poppins',
                       fontWeight: FontWeight.w800,
                       color: color.AppColor.yWhiteColor
                   ),
                 ),
                 const SizedBox(height: 50,),
                 Row(
                   children: [
                     Container(
                       width: 130,
                       height: 30,
                       //creation du cercle arrondi
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(10),
                         gradient: LinearGradient(
                             colors: [
                               color.AppColor.ySecondaryColor,
                               color.AppColor.yDarkColor
                             ],
                           begin: Alignment.bottomLeft,
                           end: Alignment.bottomRight
                         ),
                       ),
                       //text du cercle
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(
                             Icons.photo_library_outlined,
                             size: 20,
                             color: color.AppColor.yAccentColor,
                           ),
                           const SizedBox(height: 5,),
                           Text(
                             "+100 photos",
                             style: TextStyle(
                               fontSize: 16,
                               color: color.AppColor.yWhiteColor
                             ),
                           ),
                         ],
                       ),
                     ),
                     const SizedBox(width: 25,),
                     Container(
                       width: 210,
                       height: 30,
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(10),
                         gradient: LinearGradient(
                             colors: [
                               color.AppColor.ySecondaryColor,
                               color.AppColor.yDarkColor
                             ],
                             begin: Alignment.bottomLeft,
                             end: Alignment.bottomRight
                         ),
                       ),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(
                             Icons.handyman_outlined,
                             size: 20,
                             color: color.AppColor.yAccentColor,
                           ),
                           const SizedBox(height: 5,),
                           Text(
                             "Tous les événements",
                             style: TextStyle(
                                 fontSize: 16,
                                 color: color.AppColor.yWhiteColor
                             ),
                           ),
                         ],
                       ),
                     ),
                   ],
                 ),
               ],
              ),
            ),
            //pARTIE CONTENANT LES IMAGES
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: color.AppColor.yWhiteColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(70),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 30,),
                    Row(
                      children: [
                        SizedBox(width: 20,),
                        Text(
                          "VOIR LES PHOTOS",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: color.AppColor.yDarkColor,
                          ),
                        ),
                        Expanded(child: Container()),
                        Row(
                          children: [
                            Icon(
                              Icons.loop_outlined,
                              size: 30,
                              color: color.AppColor.yDarkColor,
                            ),
                            Text(
                              "Actualiser",
                              style: TextStyle(
                                fontSize: 15,
                                color: color.AppColor.yOnBoardingPage1Color
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 10,),

                      ],

                    ),
                    Expanded(child: CartPhoto()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
