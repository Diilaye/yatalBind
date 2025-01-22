import 'package:dashbord/bloc/sms-bloc.dart';
import 'package:dashbord/utils/padding-global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<bool> dialogRequest(
    {required BuildContext context, required String title}) async {
  bool exitApp = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            content: Text(title),
            title: const Text('Yaatalmbind'),
            actions: [
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('Non')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Oui')),
            ],
          ));

  return exitApp;
}

Future<bool> dialogRequestMessage({required BuildContext context}) async {
  bool exitApp = await showDialog(
      context: context,
      builder: (context) {
        final smsBloc = Provider.of<SmsBloc>(context);

        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))),
          content: SizedBox(
            height: 300,
            child: Column(
              children: [
                SizedBox(
                  width: 500,
                  child: TextField(
                    cursorColor: Colors.black,
                    controller: smsBloc.subtitle,
                    decoration: const InputDecoration(
                        labelText: 'OBJECT SMS',
                        labelStyle: TextStyle(color: Colors.black),
                        focusColor: Colors.black,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black))),
                  ),
                ),
                paddingVerticalGlobal(8),
                SizedBox(
                  width: 500,
                  child: TextField(
                    maxLines: 4,
                    cursorColor: Colors.black,
                    controller: smsBloc.desc,
                    decoration: const InputDecoration(
                        labelText: 'MESSAGES ',
                        labelStyle: TextStyle(color: Colors.black),
                        focusColor: Colors.black,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black))),
                  ),
                ),
              ],
            ),
          ),
          title: const Text('Yaatalmbind'),
          actions: [
            TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(false);
                },
                child: Text('Annuler')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('Envoyer')),
          ],
        );
      });

  return exitApp;
}

Future<bool> dialogRequestInfo(
    {required BuildContext context,
    required String text1,
    required String text2,
    required String text3}) async {
  bool exitApp = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            content: SizedBox(
              height: 150,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      const ImageIcon(
                          AssetImage("assets/images/preparion.png")),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                          child: Text(
                        text1,
                        overflow: TextOverflow.ellipsis,
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      const ImageIcon(
                          AssetImage("assets/images/livraison.png")),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                          child: Text(
                        text2,
                        overflow: TextOverflow.ellipsis,
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      const ImageIcon(AssetImage("assets/images/livree.png")),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                          child: Text(
                        text3,
                        overflow: TextOverflow.ellipsis,
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            title: const Text('Swaped'),
            actions: [
              // TextButton(
              //     onPressed: () async {
              //       Navigator.of(context).pop(false);
              //     },
              //     child: Text('Non')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Fermer')),
            ],
          ));

  return exitApp;
}
