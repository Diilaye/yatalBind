import '/screen/Concours/participate_screen.dart';
import '/screen/nav_bar_screen.dart';
import '/utils/colors.dart';
import '/utils/images_string.dart';
import '/widgets/app_bar_widget/page_app_bar.dart';
import '/widgets/concours/concours_info.dart';
import '/widgets/myprogress_bar.dart';
import 'package:flutter/material.dart';

class ConcoursScreen extends StatefulWidget {
  const ConcoursScreen({super.key});

  @override
  State<ConcoursScreen> createState() => _ConcoursScreenState();
}

class _ConcoursScreenState extends State<ConcoursScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: yWhiteColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ParticipateScreen()));
        },
        elevation: 10,
        backgroundColor: yDarkColor,
        label: const Text(
          "Participer",
          style: TextStyle(
              color: yWhiteColor,
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800),
        ),
        icon: const Icon(
          Icons.add_outlined,
          color: yWhiteColor,
          size: 35,
        ),
        shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: yAccentColor)),
      ),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: ListView(
          children: [
            // PageAppBar(),
            SizedBox(
              height: 1000,
              child: Stack(
                children: [
                  Container(
                    height: size.height * 0.49,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(welcomeScreen),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    child: CircleAvatar(
                      backgroundColor: yDarkColor,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => NavBarScreen()));
                        },
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: yWhiteColor,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    //top: size.height * 0.49,
                    child: Container(
                      height: size.height * 0.75,
                      width: size.width,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(80),
                        ),
                        color: yWhiteColor,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 50,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text(
                                        "INFORMATIONS",
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                          fontSize: 18,
                                        ),
                                      ),
                                      //PROGRESS BAR
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          MyProgressIndicatorValue(
                                              name: "Taux de Partication",
                                              amount: "+1000 P",
                                              percentage: "(90)%",
                                              color: yAccentColor,
                                              data: 0.8),
                                          MyProgressIndicatorValue(
                                              name: "Regions",
                                              amount: "+14",
                                              percentage: "(90)%",
                                              color: yDarkColor,
                                              data: 0.8),
                                          MyProgressIndicatorValue(
                                              name: "Garçons",
                                              amount: "+700",
                                              percentage: "(70)%",
                                              color: yAccentColor,
                                              data: 0.7),
                                          MyProgressIndicatorValue(
                                              name: "Filles",
                                              amount: "+300",
                                              percentage: "(90)%",
                                              color: Colors.purpleAccent,
                                              data: 0.8),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      //Liste des Infos utiles
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Resultats Concours',
                                            style: TextStyle(
                                                fontSize: 25,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w800),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ConcoursScreen()));
                                            },
                                            child: const Text(
                                              "VOIR TOUT",
                                              style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                  color: yDarkColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                      ConcoursInfoWidget(),
                                      //SECTION INFOS DU POURQUOI
                                      const SizedBox(
                                        height: 23,
                                      ),
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "POURQUOI YAATAL MBINDE AL XURANE?",
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 23,
                                      ),
                                      ConcoursInfoWidget(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: size.height * 0.5,
                    child: ClipPath(
                      clipper: MyClipper(),
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: const BoxDecoration(
                          color: yWhiteColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.quadraticBezierTo(0, size.height, 0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
