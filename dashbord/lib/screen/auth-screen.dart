import 'package:dashbord/bloc/auth-bloc.dart';
import 'package:dashbord/utils/coolors-by-dii.dart';
import 'package:dashbord/utils/font-familly-dii.dart';
import 'package:dashbord/utils/padding-global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final connectionBloc = Provider.of<AuthBloc>(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: .0,
        elevation: .0,
      ),
      body: Container(
        height: size.height,
        width: size.width,
        color: bgAdmin,
        child: ListView(
          children: [
            Container(
              height: 60,
              width: size.width,
              color: blanc,
              child: Row(
                children: [
                  paddingHorizontalGlobal(size.width * .1),
                  SizedBox(
                    width: 200,
                    child: Image.asset(
                      "assets/images/LOGO_YAATAL.png",
                      // color: vert,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            paddingVerticalGlobal(24),
            Center(
              child: Container(
                height: 450,
                width: 300,
                decoration: BoxDecoration(
                    color: blanc,
                    border: Border(
                        top: BorderSide(color: noir.withOpacity(.5), width: 2)),
                    boxShadow: [
                      BoxShadow(color: noir.withOpacity(.3), blurRadius: 10)
                    ]),
                child: Column(
                  children: [
                    paddingVerticalGlobal(32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Connectez-vous',
                          style: fontFammilyDii(context, 16, vert,
                              FontWeight.bold, FontStyle.normal),
                        )
                      ],
                    ),
                    paddingVerticalGlobal(15),
                    Container(
                      height: 1,
                      color: noir.withOpacity(.2),
                    ),
                    paddingVerticalGlobal(24),
                    Row(
                      children: [
                        paddingHorizontalGlobal(8),
                        Text(
                          'Email',
                          style: fontFammilyDii(context, 14, noir,
                              FontWeight.bold, FontStyle.normal),
                        ),
                        paddingHorizontalGlobal(8),
                      ],
                    ),
                    paddingVerticalGlobal(4),
                    Center(
                      child: SizedBox(
                        height: 45,
                        width: size.width,
                        child: Row(
                          children: [
                            paddingHorizontalGlobal(8),
                            Expanded(
                              child: TextField(
                                controller: connectionBloc.email,
                                decoration: const InputDecoration(
                                  hintText: "Email",
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            paddingHorizontalGlobal(8),
                          ],
                        ),
                      ),
                    ),
                    paddingVerticalGlobal(24),
                    Row(
                      children: [
                        paddingHorizontalGlobal(8),
                        Text(
                          'Mot de passe',
                          style: fontFammilyDii(context, 14, noir,
                              FontWeight.bold, FontStyle.normal),
                        ),
                        paddingHorizontalGlobal(8),
                        Text(
                          "(6 caractères minimum)",
                          style: fontFammilyDii(context, 8, noir,
                              FontWeight.w300, FontStyle.normal),
                        )
                      ],
                    ),
                    paddingVerticalGlobal(4),
                    Center(
                      child: SizedBox(
                        height: 45,
                        width: size.width,
                        child: Row(
                          children: [
                            paddingHorizontalGlobal(8),
                            Expanded(
                              child: TextField(
                                obscureText: connectionBloc.showPassword,
                                controller: connectionBloc.password,
                                decoration: const InputDecoration(
                                  hintText: "Mot de passe",
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            paddingHorizontalGlobal(8),
                          ],
                        ),
                      ),
                    ),
                    paddingVerticalGlobal(),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Row(
                        children: [
                          paddingHorizontalGlobal(8),
                          GestureDetector(
                            onTap: () => connectionBloc.setShowPassword(),
                            child: Icon(
                              connectionBloc.showPassword
                                  ? Icons.square_outlined
                                  : Icons.check_box,
                              color: noir,
                              size: 20,
                            ),
                          ),
                          paddingHorizontalGlobal(4),
                          Expanded(
                            child: Text(
                              'Afficher le mot de passe',
                              style: fontFammilyDii(context, 14, noir,
                                  FontWeight.w400, FontStyle.normal),
                            ),
                          ),
                          paddingHorizontalGlobal(8),
                        ],
                      ),
                    ),
                    paddingVerticalGlobal(32),
                    Row(
                      children: [
                        paddingHorizontalGlobal(8),
                        Expanded(
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () async {
                                await connectionBloc.login(context);
                              },
                              child: Container(
                                height: 45,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: vert),
                                child: Center(
                                  child: connectionBloc.chargement
                                      ? CircularProgressIndicator(
                                          color: vert,
                                          backgroundColor: blanc,
                                        )
                                      : Text(
                                          "Se connecter",
                                          style: fontFammilyDii(
                                              context,
                                              12,
                                              blanc,
                                              FontWeight.w400,
                                              FontStyle.normal),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        paddingHorizontalGlobal(8),
                      ],
                    ),
                    paddingVerticalGlobal(24),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //         child: Container(
                    //       height: 1,
                    //       color: noir.withOpacity(.3),
                    //     )),
                    //     paddingHorizontalGlobal(0),
                    //     Text(
                    //       'OU',
                    //       style: fontFammilyDii(context, 16, bleuMarine,
                    //           FontWeight.w400, FontStyle.normal),
                    //     ),
                    //     paddingHorizontalGlobal(0),
                    //     Expanded(
                    //         child: Container(
                    //       height: 1,
                    //       color: noir.withOpacity(.3),
                    //     )),
                    //   ],
                    // ),
                    // // paddingVerticalGlobal(),
                    // // Row(
                    // //   children: [
                    // //     paddingHorizontalGlobal(8),
                    // //     Expanded(
                    // //         child: Container(
                    // //       height: 40,
                    // //       decoration: BoxDecoration(color: blanc, boxShadow: [
                    // //         BoxShadow(
                    // //             blurRadius: .5,
                    // //             color: bleuMarine.withOpacity(.5))
                    // //       ]),
                    // //       child: Row(
                    // //         children: [
                    // //           paddingHorizontalGlobal(),
                    // //           CachedNetworkImage(
                    // //             height: 24,
                    // //             width: 24,
                    // //             imageUrl: "assets/images/google.png",
                    // //           ),
                    // //           paddingHorizontalGlobal(8),
                    // //           Text(
                    // //             "S'inscrire avec Google",
                    // //             style: fontFammilyDii(
                    // //                 context,
                    // //                 10,
                    // //                 noir.withOpacity(.4),
                    // //                 FontWeight.w600,
                    // //                 FontStyle.normal),
                    // //           )
                    // //         ],
                    // //       ),
                    // //     )),
                    // //     paddingHorizontalGlobal(8),
                    // //   ],
                    // // ),
                    // // paddingVerticalGlobal(),
                    // // Row(
                    // //   children: [
                    // //     paddingHorizontalGlobal(8),
                    // //     Expanded(
                    // //         child: Container(
                    // //       height: 40,
                    // //       decoration: BoxDecoration(color: blanc, boxShadow: [
                    // //         BoxShadow(
                    // //             blurRadius: .5,
                    // //             color: bleuMarine.withOpacity(.5))
                    // //       ]),
                    // //       child: Row(
                    // //         children: [
                    // //           paddingHorizontalGlobal(),
                    // //           CachedNetworkImage(
                    // //             height: 24,
                    // //             width: 24,
                    // //             imageUrl: "assets/images/apple.png",
                    // //           ),
                    // //           paddingHorizontalGlobal(8),
                    // //           Text(
                    // //             "S'inscrire avec Apple",
                    // //             style: fontFammilyDii(
                    // //                 context,
                    // //                 10,
                    // //                 noir.withOpacity(.4),
                    // //                 FontWeight.w600,
                    // //                 FontStyle.normal),
                    // //           )
                    // //         ],
                    // //       ),
                    // //     )),
                    // //     paddingHorizontalGlobal(8),
                    // //   ],
                    // // ),
                    // paddingVerticalGlobal(),
                    // Expanded(
                    //     child: Container(
                    //   color: gris,
                    //   child: Column(
                    //     children: [
                    //       paddingVerticalGlobal(),
                    //       Center(
                    //         child: Text(
                    //           "Vous êtes déjà inscrit ?",
                    //           style: fontFammilyDii(
                    //               context,
                    //               12,
                    //               noir.withOpacity(.6),
                    //               FontWeight.bold,
                    //               FontStyle.normal),
                    //         ),
                    //       ),
                    //       paddingVerticalGlobal(),
                    //       Center(
                    //         child: MouseRegion(
                    //           cursor: SystemMouseCursors.click,
                    //           child: GestureDetector(
                    //             // onTap: () => context.go('/login'),
                    //             child: Container(
                    //               height: 45,
                    //               width: 250,
                    //               color: blanc,
                    //               child: Center(
                    //                 child: Text(
                    //                   "Se connecter",
                    //                   style: fontFammilyDii(context, 14, noir,
                    //                       FontWeight.bold, FontStyle.normal),
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ))
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
