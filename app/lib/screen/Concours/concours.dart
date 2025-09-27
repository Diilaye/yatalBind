import 'package:app/screen/Concours/participate_screen.dart';
import 'package:app/utils/colors.dart';
import 'package:app/utils/images_string.dart';
import 'package:app/widgets/concours/concours_info.dart';
import 'package:app/widgets/myprogress_bar.dart';
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

    return  Scaffold(
      backgroundColor: yWhiteColor,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ParticipateScreen()));
          },
        elevation: 10,
        backgroundColor: yDarkColor,
        label: Text(
          "Participer", 
          style: TextStyle(
            color: yWhiteColor, 
            fontSize: 14, 
            fontFamily: 'Poppins', 
            fontWeight: FontWeight.w800
          ),
        ),
        icon: Icon(Icons.add_outlined, color: yWhiteColor, size: 24,),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          children: [
            // Header avec image de fond
            Stack(
              children: [
                Container(
                  height: size.height * 0.3,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(welcomeScreen),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Bouton retour
                Positioned(
                  top: 10,
                  left: 10,
                  child: CircleAvatar(
                    backgroundColor: yDarkColor.withOpacity(0.8),
                    child: InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: yWhiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Contenu principal
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  color: yWhiteColor,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      // Titre des informations
                      Center(
                        child: Text(
                          "INFORMATIONS",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            color: yDarkColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Section des statistiques
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: MyProgressIndicatorValue(
                                    name: "Participants",
                                    amount: "+1000",
                                    percentage: "(90)%",
                                    color: yAccentColor,
                                    data: 0.8
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: MyProgressIndicatorValue(
                                    name: "Régions",
                                    amount: "+14",
                                    percentage: "(100)%",
                                    color: yDarkColor,
                                    data: 1.0
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: MyProgressIndicatorValue(
                                    name: "Garçons",
                                    amount: "+700",
                                    percentage: "(70)%",
                                    color: yAccentColor,
                                    data: 0.7
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: MyProgressIndicatorValue(
                                    name: "Filles",
                                    amount: "+300",
                                    percentage: "(30)%",
                                    color: Colors.purpleAccent,
                                    data: 0.3
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      // Section des résultats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Résultats Concours',
                            style: TextStyle(
                              fontSize: 22,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              color: yDarkColor,
                            ),
                          ),
                          InkWell(
                            onTap: (){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Fonctionnalité à venir : Page détaillée des résultats'),
                                  backgroundColor: yAccentColor,
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: yDarkColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "VOIR TOUT",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: yDarkColor
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ConcoursInfoWidget(),
                      SizedBox(height: 30),
                      // Section "Pourquoi"
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [yAccentColor.withOpacity(0.1), yDarkColor.withOpacity(0.1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.help_outline, color: yDarkColor, size: 24),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "POURQUOI YAATAL MBINDE AL XURANE?",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: yDarkColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Text(
                              "Un concours qui valorise l'apprentissage du Coran et la culture islamique, favorisant l'épanouissement spirituel et intellectuel de notre jeunesse.",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}