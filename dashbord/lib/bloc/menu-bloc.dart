import 'package:flutter/material.dart';

class MenuAdminBloc with ChangeNotifier {
  int menu = 0;
  setMenu(int i) {
    menu = i;
    notifyListeners();
  }

  int sousMenu = 0;
  setSousMenu(int i) {
    sousMenu = i;
    notifyListeners();
  }

  int addArticle = 0;

  setAddArticle(int i) {
    addArticle = i;
    notifyListeners();
  }

  int addEmission = 0;

  setEmission(int i) {
    print("setEmission");
    print(i);
    addEmission = i;
    notifyListeners();
  }

  int addPresseEcrite = 0;

  setPresseEcrite(int i) {
    addPresseEcrite = i;
    notifyListeners();
  }

  int addFlashNews = 0;

  setFlashNews(int i) {
    addFlashNews = i;
    notifyListeners();
  }

  int addCategorie = 0;

  setCategorie(int i) {
    addCategorie = i;
    notifyListeners();
  }

  int addUser = 0;

  setAddUser(int i) {
    addUser = i;
    notifyListeners();
  }

  int addSouCategorie = 0;

  setSousCategorie(int i) {
    addSouCategorie = i;
    notifyListeners();
  }

  int addTag = 0;

  setTag(int i) {
    addTag = i;
    notifyListeners();
  }

  int keyWord = 0;

  setKeyWord(int i) {
    keyWord = i;
    notifyListeners();
  }
}
