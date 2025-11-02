import 'package:dashbord/models/concurant-model.dart';
import 'package:dashbord/services/auth-service.dart';
import 'package:dashbord/utils/coolors-by-dii.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

class AuthBloc with ChangeNotifier {
  AuthService authService = AuthService();

  TextEditingController email = TextEditingController();

  TextEditingController password = TextEditingController();

  bool showPassword = true;

  setShowPassword() {
    showPassword = !showPassword;
    notifyListeners();
  }

  bool chargement = false;

  String? resultRegister;

  login(BuildContext context) async {
    Map<String, String> body = {"email": email.text, "password": password.text};

    chargement = true;
    notifyListeners();

    resultRegister = await authService.auth(body);

    chargement = false;
    notifyListeners();

    if (resultRegister != null) {
      email.text = "";
      // resultRegister = null;
      password.text = "";
      notifyListeners();

      Fluttertoast.showToast(
          msg: "Connexion réussi.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: vert,
          textColor: Colors.white,
          fontSize: 12.0);
      // ignore: use_build_context_synchronously
      context.go('/admin');
    } else {
      Fluttertoast.showToast(
          msg: "Probleme de connexion identifiant incorrect",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: rouge,
          textColor: Colors.white,
          fontSize: 12.0);
    }
  }
}
