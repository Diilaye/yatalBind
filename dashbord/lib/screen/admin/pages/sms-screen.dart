import 'package:dashbord/bloc/sms-bloc.dart';
import 'package:dashbord/utils/coolors-by-dii.dart';
import 'package:dashbord/utils/dialog-request.dart';
import 'package:dashbord/utils/font-familly-dii.dart';
import 'package:dashbord/utils/padding-global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SmsmScreen extends StatelessWidget {
  const SmsmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final smsBloc = Provider.of<SmsBloc>(context);

    return ListView(
      children: [
        paddingVerticalGlobal(size.height * .05),
        Row(
          children: [
            paddingHorizontalGlobal(),
            Text(
              'candidats'.toUpperCase(),
              style: fontFammilyDii(
                  context, 20, noir, FontWeight.bold, FontStyle.normal),
            )
          ],
        ),
        paddingVerticalGlobal(size.height * .02),
        Row(
          children: [
            paddingHorizontalGlobal(),
            Icon(
              CupertinoIcons.home,
              color: noir.withOpacity(.6),
              size: 14,
            ),
            paddingHorizontalGlobal(6),
            Icon(
              CupertinoIcons.chevron_forward,
              color: noir.withOpacity(.6),
              size: 12,
            ),
            paddingHorizontalGlobal(6),
            Text(
              'CANDIDAT',
              style: fontFammilyDii(context, 14, noir.withOpacity(.6),
                  FontWeight.w300, FontStyle.normal),
            ),
            paddingHorizontalGlobal(6),
            Icon(
              CupertinoIcons.chevron_forward,
              color: noir.withOpacity(.6),
              size: 12,
            ),
            paddingHorizontalGlobal(6),
            Text(
              'Dashbord',
              style: fontFammilyDii(
                  context, 12, noir, FontWeight.w300, FontStyle.normal),
            ),
            const Spacer(),
            Center(
              child: SizedBox(
                height: 45,
                width: size.width * .3,
                child: Row(
                  children: [
                    paddingHorizontalGlobal(8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: "RECHERCHER UN CANDIDAT(E)",
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(),
                        ),
                        onChanged: (value) => smsBloc.setRecherche(value),
                      ),
                    ),
                    paddingHorizontalGlobal(8),
                  ],
                ),
              ),
            ),
            paddingHorizontalGlobal(32),
            CircleAvatar(
                backgroundColor: noir.withOpacity(.5),
                child: Center(
                    child: IconButton(
                  icon: const Icon(CupertinoIcons.envelope),
                  tooltip: "Envoyer Sms sur les selectionnées",
                  onPressed: () => dialogRequestMessage(
                    context: context,
                  ).then((value) {
                    if (value) {
                      smsBloc.sendSms();
                    }
                  }),
                ))),
            paddingHorizontalGlobal(),
            CircleAvatar(
                backgroundColor: noir.withOpacity(.5),
                child: Center(
                    child: IconButton(
                  icon: const Icon(CupertinoIcons.add),
                  onPressed: () => smsBloc.getTelFile(),
                ))),
            paddingHorizontalGlobal(),
          ],
        ),
        paddingVerticalGlobal(),
        Column(
          children: [
            paddingVerticalGlobal(),
            SizedBox(
              height: 650,
              width: size.width,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    paddingVerticalGlobal(8),
                    Row(
                      children: [
                        paddingHorizontalGlobal(8),
                        Expanded(
                            child: Row(children: [
                          Text(
                            'ID',
                            style: fontFammilyDii(context, 14, noir,
                                FontWeight.w500, FontStyle.normal),
                          )
                        ])),
                        Expanded(
                            child: Row(
                          children: [
                            Text(
                              'Candidat',
                              style: fontFammilyDii(context, 14, noir,
                                  FontWeight.w500, FontStyle.normal),
                            ),
                          ],
                        )),
                        Expanded(
                            child: Row(
                          children: [
                            Text(
                              'Télephone',
                              style: fontFammilyDii(context, 14, noir,
                                  FontWeight.w500, FontStyle.normal),
                            ),
                          ],
                        )),
                        Expanded(
                            child: Row(
                          children: [
                            Text(
                              'Sélectionnez tous',
                              style: fontFammilyDii(context, 14, noir,
                                  FontWeight.w500, FontStyle.normal),
                            ),
                            paddingHorizontalGlobal(6),
                            IconButton(
                                onPressed: () => smsBloc.selectConcurant(),
                                icon: Icon(
                                    smsBloc.concurantsListeSelect.length + 1 ==
                                            smsBloc.concurantsListe!.length
                                        ? CupertinoIcons.square_fill
                                        : CupertinoIcons.square))
                          ],
                        )),
                        paddingHorizontalGlobal(8),
                      ],
                    ),
                    paddingVerticalGlobal(8),
                    Expanded(
                        child: Row(
                      children: [
                        paddingHorizontalGlobal(8),
                        Expanded(
                          child: ListView(
                            children: smsBloc.concurantsListe!
                                .where((e) => e.telephone == null
                                    ? true
                                    : e.telephone!.contains(
                                        smsBloc.rechercheT.toLowerCase()))
                                .map((e) => Container(
                                      height: 50,
                                      color: blanc,
                                      child: Row(
                                        children: [
                                          paddingHorizontalGlobal(8),
                                          Expanded(
                                              child: Row(children: [
                                            Text(
                                              "#${e.id!.substring(0, 7)}",
                                              style: fontFammilyDii(
                                                  context,
                                                  12,
                                                  noir,
                                                  FontWeight.w500,
                                                  FontStyle.normal),
                                            )
                                          ])),
                                          Expanded(
                                              child: Row(children: [
                                            Text(
                                              "${e.prenom!} ${e.nom!}"
                                                  .toUpperCase(),
                                              style: fontFammilyDii(
                                                  context,
                                                  12,
                                                  noir,
                                                  FontWeight.w700,
                                                  FontStyle.normal),
                                            )
                                          ])),
                                          Expanded(
                                              child: Row(children: [
                                            Text(
                                              "${e.telephone == null ? "" : e.telephone}",
                                              style: fontFammilyDii(
                                                  context,
                                                  12,
                                                  noir,
                                                  FontWeight.w500,
                                                  FontStyle.normal),
                                            )
                                          ])),
                                          Expanded(
                                              child: Row(children: [
                                            IconButton(
                                                onPressed: () => smsBloc
                                                    .selectConcurantOne(e),
                                                icon: Icon(smsBloc
                                                        .concurantsListeSelect
                                                        .where((el) =>
                                                            el.id! == e.id!)
                                                        .isEmpty
                                                    ? CupertinoIcons.square
                                                    : CupertinoIcons
                                                        .square_fill))
                                          ])),
                                          paddingHorizontalGlobal(8),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        paddingHorizontalGlobal(8)
                      ],
                    )),
                    paddingVerticalGlobal(8)
                  ],
                ),
              ),
            ),
            paddingVerticalGlobal(),
            Row(
              children: [
                paddingHorizontalGlobal(8),
                Text(
                  "Affichage de 1 à 10 sur ${smsBloc.concurantsListe!.length} candidats",
                  style: fontFammilyDii(context, 14, noir.withOpacity(.7),
                      FontWeight.w700, FontStyle.normal),
                ),
                const Spacer(),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SizedBox(
                      height: 30,
                      width: 50,
                      child: Center(
                          child: Icon(
                        CupertinoIcons.chevron_left,
                        size: 14,
                        color: noir,
                      ))),
                ),
                paddingHorizontalGlobal(8),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SizedBox(
                      height: 30,
                      width: 50,
                      child: Center(
                          child: Icon(
                        CupertinoIcons.chevron_right,
                        size: 14,
                        color: noir,
                      ))),
                ),
                paddingHorizontalGlobal(),
              ],
            )
          ],
        ),
        paddingVerticalGlobal(size.height * .02),
      ],
    );
  }
}
