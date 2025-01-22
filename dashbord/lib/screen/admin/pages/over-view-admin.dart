import 'package:dashbord/screen/admin/widgets/activity-card.dart';
import 'package:dashbord/screen/admin/widgets/stat-card.dart';
import 'package:dashbord/utils/coolors-by-dii.dart';
import 'package:dashbord/utils/font-familly-dii.dart';
import 'package:dashbord/utils/padding-global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OverViewAdmin extends StatelessWidget {
  const OverViewAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ListView(
      children: [
        paddingVerticalGlobal(size.height * .05),
        SizedBox(
          height: 150,
          child: Row(
            children: [
              paddingHorizontalGlobal(8),
              Expanded(
                child: StatCard(
                  title: "Visites",
                  total: 4000,
                  percentage: 50,
                  desc: "Nombre de visites journaliere",
                  label: "Nouvelles Visites",
                  increase: 7,
                  color: bleuMarine,
                ),
              ),
              paddingHorizontalGlobal(8),
              Expanded(
                child: StatCard(
                  title: "Participants",
                  total: 30,
                  percentage: 75,
                  desc: "Nombre de partecipants du concours ",
                  label: "nombre de participants",
                  increase: -17,
                  color: rouge,
                ),
              ),
              paddingHorizontalGlobal(8),
              Expanded(
                child: StatCard(
                  title: "Images digitaux",
                  total: 300,
                  percentage: 90,
                  desc: "Nombre de réaction journaliere sur les images",
                  label: "Nouvelles images",
                  increase: 20,
                  color: vertSport,
                ),
              ),
              paddingHorizontalGlobal(8),
            ],
          ),
        ),
        paddingVerticalGlobal(),
        SizedBox(
          height: 500,
          child: Row(
            children: [
              SizedBox(
                width: size.width * .01,
              ),
              Expanded(
                  flex: 2,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Activités du concours',
                              style: fontFammilyDii(context, 14, noir,
                                  FontWeight.bold, FontStyle.normal),
                            ),
                            const Spacer(),
                            Text(
                              '12 derniers mois',
                              style: fontFammilyDii(context, 10, noir,
                                  FontWeight.w300, FontStyle.normal),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Expanded(
                            child: Row(
                          children: [
                            const SizedBox(
                              width: 8,
                            ),
                            const Expanded(
                                child: Column(
                              children: [
                                SizedBox(
                                  height: 8,
                                ),
                                Expanded(child: Text('+ M ')),
                                Expanded(child: Text('8 M ')),
                                Expanded(child: Text('6 M ')),
                                Expanded(child: Text('4 M ')),
                                Expanded(child: Text('2 M ')),
                                Expanded(child: Text('0 M ')),
                              ],
                            )),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                                child: Column(
                              children: [
                                Expanded(
                                    flex: 5,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          color: noir.withOpacity(.5)),
                                    )),
                                const SizedBox(
                                  height: 8,
                                ),
                                const Text('Jan'),
                                const SizedBox(
                                  height: 4,
                                )
                              ],
                            )),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                                child: Container(
                              child: Column(
                                children: [
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            color: noir.withOpacity(.5)),
                                      )),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Text('Fev'),
                                  const SizedBox(
                                    height: 4,
                                  )
                                ],
                              ),
                            )),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                                child: Container(
                              child: Column(
                                children: [
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            color: noir.withOpacity(.5)),
                                      )),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Text('Mar'),
                                  const SizedBox(
                                    height: 4,
                                  )
                                ],
                              ),
                            )),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                                child: Container(
                              child: Column(
                                children: [
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            color: noir.withOpacity(.5)),
                                      )),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Text('Avr'),
                                  const SizedBox(
                                    height: 4,
                                  )
                                ],
                              ),
                            )),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                                child: Container(
                              child: Column(
                                children: [
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            color: noir.withOpacity(.5)),
                                      )),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Text('Mai'),
                                  const SizedBox(
                                    height: 4,
                                  )
                                ],
                              ),
                            )),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                                child: Container(
                              child: Column(
                                children: [
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            color: noir.withOpacity(.5)),
                                      )),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Text('Jui'),
                                  const SizedBox(
                                    height: 4,
                                  )
                                ],
                              ),
                            )),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                                child: Container(
                              child: Column(
                                children: [
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            color: noir.withOpacity(.5)),
                                      )),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Text('Jul'),
                                  const SizedBox(
                                    height: 4,
                                  )
                                ],
                              ),
                            )),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                                child: Container(
                              child: Column(
                                children: [
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            color: noir.withOpacity(.5)),
                                      )),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Text('Aou'),
                                  const SizedBox(
                                    height: 4,
                                  )
                                ],
                              ),
                            )),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                                child: Container(
                              child: Column(
                                children: [
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            color: noir.withOpacity(.5)),
                                      )),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Text('Sep'),
                                  const SizedBox(
                                    height: 4,
                                  )
                                ],
                              ),
                            )),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                                child: Container(
                              child: Column(
                                children: [
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            color: noir.withOpacity(.5)),
                                      )),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Text('Oct'),
                                  const SizedBox(
                                    height: 4,
                                  )
                                ],
                              ),
                            )),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                                child: Container(
                              child: Column(
                                children: [
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            color: noir.withOpacity(.5)),
                                      )),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Text('Nov'),
                                  const SizedBox(
                                    height: 4,
                                  )
                                ],
                              ),
                            )),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                                child: Container(
                              child: Column(
                                children: [
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            color: noir.withOpacity(.5)),
                                      )),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Text('Dec'),
                                  const SizedBox(
                                    height: 4,
                                  )
                                ],
                              ),
                            )),
                            const SizedBox(
                              width: 8,
                            ),
                          ],
                        )),
                        SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
                  )),
              SizedBox(
                width: size.width * .01,
              ),
              Expanded(
                  child: Column(
                children: [
                  Expanded(
                      flex: 2,
                      child: ActivyEmission(
                        title: "Suivis concours",
                        pourcentages: [55, 60, 80],
                        labels: const ["Complete", "In progess", "Taches"],
                        colors: [rouge, vertSport, bleuMarine],
                        // legendes: const ["Complete", "In progess", "Taches"],
                      )),
                ],
              )),
              SizedBox(
                width: size.width * .01,
              ),
            ],
          ),
        ),
        paddingVerticalGlobal(8),
        // SizedBox(
        //   height: 500,
        //   width: size.width,
        //   child: Card(
        //     elevation: 4,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //     child: Column(
        //       children: [
        //         paddingVerticalGlobal(8),
        //         Row(
        //           children: [
        //             paddingHorizontalGlobal(8),
        //             Text(
        //               "Journal d'Article",
        //               style: fontFammilyDii(
        //                   context, 14, noir, FontWeight.bold, FontStyle.normal),
        //             ),
        //           ],
        //         ),
        //         paddingVerticalGlobal(8),
        //         Row(
        //           children: [
        //             paddingHorizontalGlobal(8),
        //             Expanded(
        //                 child: Row(children: [
        //               Text(
        //                 'ID',
        //                 style: fontFammilyDii(context, 14, noir,
        //                     FontWeight.w500, FontStyle.normal),
        //               )
        //             ])),
        //             Expanded(
        //                 child: Row(
        //               children: [
        //                 Text(
        //                   'Author',
        //                   style: fontFammilyDii(context, 14, noir,
        //                       FontWeight.w500, FontStyle.normal),
        //                 ),
        //               ],
        //             )),
        //             Expanded(
        //                 child: Row(
        //               children: [
        //                 Text(
        //                   'Date',
        //                   style: fontFammilyDii(context, 14, noir,
        //                       FontWeight.w500, FontStyle.normal),
        //                 ),
        //               ],
        //             )),
        //             Expanded(
        //                 child: Row(
        //               children: [
        //                 Row(
        //                   children: [
        //                     Center(
        //                         child: Text(
        //                       'Catégorie',
        //                       style: fontFammilyDii(context, 14, noir,
        //                           FontWeight.w500, FontStyle.normal),
        //                     )),
        //                   ],
        //                 ),
        //               ],
        //             )),
        //             Expanded(
        //                 child: Row(
        //               children: [
        //                 Text(
        //                   'Titre',
        //                   style: fontFammilyDii(context, 14, noir,
        //                       FontWeight.w500, FontStyle.normal),
        //                 ),
        //               ],
        //             )),
        //             Expanded(
        //                 child: Row(
        //               children: [
        //                 Text(
        //                   'Status',
        //                   style: fontFammilyDii(context, 14, noir,
        //                       FontWeight.w500, FontStyle.normal),
        //                 ),
        //               ],
        //             )),
        //             Expanded(
        //                 child: Row(
        //               children: [
        //                 Text(
        //                   '...',
        //                   style: fontFammilyDii(context, 14, noir,
        //                       FontWeight.w500, FontStyle.normal),
        //                 ),
        //               ],
        //             )),
        //             paddingHorizontalGlobal(8),
        //           ],
        //         ),
        //         paddingVerticalGlobal(8),
        //         Expanded(
        //             child: Row(
        //           children: [
        //             paddingHorizontalGlobal(8),
        //             Expanded(
        //               child: ListView(
        //                 children: List.generate(
        //                     20,
        //                     (int index) => Container(
        //                           height: 50,
        //                           color: (index % 2) == 0 ? blanc : gris,
        //                           child: Row(
        //                             children: [
        //                               paddingHorizontalGlobal(8),
        //                               Expanded(
        //                                   child: Row(children: [
        //                                 Text(
        //                                   "#790841",
        //                                   style: fontFammilyDii(
        //                                       context,
        //                                       14,
        //                                       noir,
        //                                       FontWeight.w500,
        //                                       FontStyle.normal),
        //                                 )
        //                               ])),
        //                               Expanded(
        //                                   child: Row(
        //                                 children: [
        //                                   CircleAvatar(
        //                                     backgroundColor: bleuMarine,
        //                                     radius: 16,
        //                                     child: Center(
        //                                       child: Text(
        //                                         'SA',
        //                                         style: fontFammilyDii(
        //                                             context,
        //                                             10,
        //                                             blanc,
        //                                             FontWeight.w500,
        //                                             FontStyle.normal),
        //                                       ),
        //                                     ),
        //                                   ),
        //                                   paddingHorizontalGlobal(4),
        //                                   Text(
        //                                     'Issa Kane',
        //                                     style: fontFammilyDii(
        //                                         context,
        //                                         14,
        //                                         noir,
        //                                         FontWeight.w500,
        //                                         FontStyle.normal),
        //                                   ),
        //                                 ],
        //                               )),
        //                               Expanded(
        //                                   child: Row(
        //                                 children: [
        //                                   Text(
        //                                     '	12.07.2018',
        //                                     style: fontFammilyDii(
        //                                         context,
        //                                         14,
        //                                         noir,
        //                                         FontWeight.w500,
        //                                         FontStyle.normal),
        //                                   ),
        //                                 ],
        //                               )),
        //                               Expanded(
        //                                   child: Row(
        //                                 children: [
        //                                   Row(
        //                                     children: [
        //                                       Center(
        //                                           child: Text(
        //                                         (index % 2) == 0
        //                                             ? 'Politique'
        //                                             : 'Economique',
        //                                         style: fontFammilyDii(
        //                                             context,
        //                                             14,
        //                                             noir,
        //                                             FontWeight.w500,
        //                                             FontStyle.normal),
        //                                       )),
        //                                     ],
        //                                   ),
        //                                 ],
        //                               )),
        //                               Expanded(
        //                                   child: Row(
        //                                 children: [
        //                                   Expanded(
        //                                     child: Text(
        //                                       (index % 2) == 0
        //                                           ? 'Winding Way West, RI 3261, US'
        //                                           : 'Jarvis Street Portville, NY 2596, US',
        //                                       overflow: TextOverflow.clip,
        //                                       style: fontFammilyDii(
        //                                           context,
        //                                           14,
        //                                           noir,
        //                                           FontWeight.w500,
        //                                           FontStyle.normal),
        //                                     ),
        //                                   ),
        //                                 ],
        //                               )),
        //                               Expanded(
        //                                   child: Row(
        //                                 children: [
        //                                   Icon(
        //                                     CupertinoIcons.circle,
        //                                     size: 8,
        //                                     color: (index % 2) == 0
        //                                         ? vertSport
        //                                         : bleuMarine,
        //                                   ),
        //                                   paddingHorizontalGlobal(4),
        //                                   Text(
        //                                     (index % 2) == 0
        //                                         ? 'En ligne'
        //                                         : 'Pending',
        //                                     style: fontFammilyDii(
        //                                         context,
        //                                         14,
        //                                         noir,
        //                                         FontWeight.w500,
        //                                         FontStyle.normal),
        //                                   ),
        //                                 ],
        //                               )),
        //                               Expanded(
        //                                   child: Row(
        //                                 children: [
        //                                   paddingHorizontalGlobal(6),
        //                                   Text(
        //                                     '...',
        //                                     style: fontFammilyDii(
        //                                         context,
        //                                         14,
        //                                         noir,
        //                                         FontWeight.w500,
        //                                         FontStyle.normal),
        //                                   ),
        //                                 ],
        //                               )),
        //                               paddingHorizontalGlobal(8),
        //                             ],
        //                           ),
        //                         )),
        //               ),
        //             ),
        //             paddingHorizontalGlobal(8)
        //           ],
        //         )),
        //         paddingVerticalGlobal(8)
        //       ],
        //     ),
        //   ),
        // ),

        // paddingVerticalGlobal(8),
        // SizedBox(
        //   height: 500,
        //   width: size.width,
        //   child: Card(
        //     elevation: 4,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //     color: blanc,
        //   ),
        // ),
        paddingVerticalGlobal(),
      ],
    );
  }
}
