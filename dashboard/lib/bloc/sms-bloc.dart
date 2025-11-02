import 'package:dashbord/models/concurant-model.dart';
import 'package:dashbord/services/auth-service.dart';
import 'package:dashbord/utils/upload-file.dart';
import 'package:flutter/material.dart';

class SmsBloc with ChangeNotifier {
  AuthService authService = AuthService();

  List<String> tel = [];

  TextEditingController email = TextEditingController();
  TextEditingController subtitle = TextEditingController();
  TextEditingController desc = TextEditingController();

  String rechercheT = "";

  setRecherche(String v) {
    rechercheT = v;
    notifyListeners();
  }

  getTelFile() async {
    List? v = await getFile();
    tel = v!.map((e) => e.toString()).toList();
    print(tel);
    notifyListeners();
  }

  List<ConcurantModel>? concurantsListe = [];
  List<ConcurantModel> concurantsListeSelect = [];

  getAllconcurant() async {
    concurantsListe = await authService.getConcurants();
    notifyListeners();
  }

  selectConcurantOne(ConcurantModel c) {
    if (concurantsListeSelect.where((e) => e.id! == c.id!).isNotEmpty) {
      concurantsListeSelect.removeWhere((e) => e.id! == c.id!);
    } else {
      concurantsListeSelect.add(c);
    }
    notifyListeners();
  }

  selectConcurant() {
    if (concurantsListeSelect.length + 1 == concurantsListe!.length) {
      concurantsListeSelect = [];
      notifyListeners();
    } else {
      for (var element in concurantsListe!) {
        if (element.telephone != null) {
          if (element.telephone!.contains(rechercheT)) {
            concurantsListeSelect.add(element);
            notifyListeners();
          }
        }
      }
    }

    notifyListeners();
  }

  sendSms() async {
    String? result = await authService.sendMessageDepouillement(
        concurantsListeSelect.map((e) => e.telephone!).toList(),
        subtitle.text,
        desc.text);
    notifyListeners();
  }

  SmsBloc() {
    getAllconcurant();
  }
}
