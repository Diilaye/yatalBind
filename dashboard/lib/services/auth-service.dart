import 'package:dashbord/models/concurant-model.dart';
import 'package:dashbord/utils/requette-by-dii.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<String?> add(Map<String, dynamic> body) async {
    return await postResponse(url: '/users', body: body).then((value) async {
      if (value['status'] == 201) {
        return "ajout réussi";
      } else {
        return null;
      }
    });
  }

  Future<String?> updateAdmin(Map<String, dynamic> body, String id) async {
    return await putResponse(url: '/users/$id', body: body).then((value) async {
      if (value['status'] == 200) {
        return "ajout réussi";
      } else {
        return null;
      }
    });
  }

  Future<String?> auth(Map<String, dynamic> body) async {
    return await postResponse(url: '/users/auth', body: body)
        .then((value) async {
      print(value['body']['data']);

      if (value['status'] == 200) {
        await SharedPreferences.getInstance().then((prefs) {
          prefs.setString('token', value['body']['data']['token']);
          prefs.setString('role', value['body']['data']['service']);
        });
        return "Connexion réussi";
      } else {
        return null;
      }
    });
  }

  Future<List<ConcurantModel>?> getConcurants() async {
    return getResponse(url: '/users/concurants').then((value) {
      if (value["status"] == 200) {
        return ConcurantModel.fromList(data: value['body']['data']);
      } else {
        return null;
      }
    });
  }

  Future<String?> sendMessageDepouillement(
      List<String> tel, String subTitle, String desc) async {
    return postResponse(
            url: '/users/sms',
            body: {"telephones": tel, "subTitle": subTitle, "desc": desc})
        .then((value) {
      if (value["status"] == 200) {
        return "envoie réussi";
      } else {
        return null;
      }
    });
  }
}
