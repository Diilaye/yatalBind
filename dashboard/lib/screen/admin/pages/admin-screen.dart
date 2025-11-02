import 'package:dashbord/bloc/menu-bloc.dart';
import 'package:dashbord/screen/admin/pages/over-view-admin.dart';
import 'package:dashbord/screen/admin/pages/sms-screen.dart';
import 'package:dashbord/utils/coolors-by-dii.dart';
import 'package:dashbord/utils/dialog-request.dart';
import 'package:dashbord/utils/font-familly-dii.dart';
import 'package:dashbord/utils/padding-global.dart';
import 'package:dashbord/utils/responsive-ui.dart';
import 'package:dashbord/widgets/menu-item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class AdministrateurAscreen extends StatelessWidget {
  const AdministrateurAscreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final menuAdminBloc = Provider.of<MenuAdminBloc>(context);

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: .0,
          elevation: .0,
        ),
        body: SizedBox(
          height: size.height,
          width: size.width,
          child: deviceName(size) == ScreenType.Desktop
              ? SizedBox(
                  height: size.height - 60,
                  width: size.width,
                  child: Row(
                    children: [
                      // ignore: unrelated_type_equality_checks
                      Expanded(
                          child: Container(
                        decoration: BoxDecoration(color: blanc, boxShadow: [
                          BoxShadow(
                              offset: const Offset(0, 0),
                              blurRadius: 10,
                              color: noir.withOpacity(.2))
                        ]),
                        child: Column(
                          children: [
                            SizedBox(
                              height: size.height * .05,
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => context.go('/'),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: size.width * .025,
                                    ),
                                    Text(
                                      'Dashbord',
                                      style: fontFammilyDii(context, 14, vert,
                                          FontWeight.bold, FontStyle.normal),
                                    ),
                                    Text(
                                      'Yaatalmbind',
                                      style: fontFammilyDii(context, 14, noir,
                                          FontWeight.bold, FontStyle.normal),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: size.height * .05,
                            ),
                            ItemMenu(
                              titre: 'Dashbord',
                              icons: CupertinoIcons.circle_fill,
                              haveIcon: false,
                              isActive: menuAdminBloc.menu == 0,
                              ontap: () => menuAdminBloc.setMenu(0),
                            ),
                            SizedBox(
                              height: size.height * .02,
                            ),
                            ItemMenu(
                              titre: 'Candidats',
                              icons: CupertinoIcons.circle_fill,
                              haveIcon: false,
                              isActive: menuAdminBloc.menu == 1,
                              ontap: () => menuAdminBloc.setMenu(1),
                            ),
                            SizedBox(
                              height: size.height * .02,
                            ),
                            ItemMenu(
                              titre: 'Images',
                              icons: CupertinoIcons.circle_fill,
                              haveIcon: false,
                              isActive: menuAdminBloc.menu == 2,
                              ontap: () => menuAdminBloc.setMenu(2),
                            ),
                            SizedBox(
                              height: size.height * .02,
                            ),
                            ItemMenu(
                              titre: 'Evenements',
                              icons: CupertinoIcons.circle_fill,
                              haveIcon: false,
                              isActive: menuAdminBloc.menu == 3,
                              ontap: () => menuAdminBloc.setMenu(3),
                            ),
                            SizedBox(
                              height: size.height * .02,
                            ),
                            ItemMenu(
                              titre: 'Articles',
                              icons: CupertinoIcons.circle_fill,
                              haveIcon: false,
                              isActive: menuAdminBloc.menu == 4,
                              ontap: () => menuAdminBloc.setMenu(4),
                            ),
                            const Spacer(),
                            ItemMenu(
                              titre: 'Help & Support',
                              icons: CupertinoIcons.headphones,
                              isActive: menuAdminBloc.menu == 6,
                              ontap: () => menuAdminBloc.setMenu(6),
                            ),
                            SizedBox(
                              height: size.height * .01,
                            ),
                            ItemMenu(
                              titre: 'Paramètres',
                              icons: CupertinoIcons.settings,
                              isActive: menuAdminBloc.menu == 7,
                              ontap: () => menuAdminBloc.setMenu(7),
                            ),
                            SizedBox(
                              height: size.height * .01,
                            ),
                            GestureDetector(
                              onTap: () => dialogRequest(
                                      context: context,
                                      title: "Voullez-vous vous déconectez ?")
                                  .then((value) {
                                if (value) {
                                  SharedPreferences.getInstance().then((prefs) {
                                    prefs.clear();
                                    context.go("/");
                                  });
                                }
                              }),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: size.width * .03,
                                      ),
                                      const Icon(
                                        Icons.logout_rounded,
                                        size: 13,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        'Déconnection',
                                        style: TextStyle(
                                            fontSize: 14, color: noir),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                ],
                              ),
                            ),
                            paddingVerticalGlobal(32)
                          ],
                        ),
                      )),
                      Expanded(
                          flex: 4,
                          child: menuAdminBloc.menu == 0
                              ? const OverViewAdmin()
                              : menuAdminBloc.menu == 1
                                  ? const SmsmScreen()
                                  : const SizedBox()),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    Positioned(
                        top: 60,
                        child: SizedBox(
                            height: size.height - 60,
                            width: size.width,
                            child: menuAdminBloc.menu == 0
                                ? Container()
                                : Container())),
                    // if (homeUtilisateurBloc.showMenuMobile == 1)
                    //   const Positioned(
                    //       top: 60, child: MenuMobileAdministratreur()),
                    // const Positioned(child: TopBarMenu())
                  ],
                ),
        ));
  }
}
