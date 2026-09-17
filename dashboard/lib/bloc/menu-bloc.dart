import 'package:flutter/foundation.dart';

enum AdminPage {
  dashboard, // 0 — OverviewScreen
  candidats, // 1 — CandidatsScreen
  sms, // 2 — SmsPage  ← était inaccessible avant
  gallery, // 3
  homeConfig,
  evenements, // 4
  articles, // 5
  help, // 6
  settings, // 7
}

class MenuAdminBloc with ChangeNotifier {
  // ── Page courante ─────────────────────────────────────────────────────────
  AdminPage _currentPage = AdminPage.dashboard;
  AdminPage get currentPage => _currentPage;

  // Compatibilité avec l'ancien code qui lisait bloc.menu (int)
  int get menu => _currentPage.index;

  void navigate(AdminPage page) {
    if (_currentPage == page) return;
    _currentPage = page;
    notifyListeners();
  }

  // Ancien setMenu(int) — conservé pour ne rien casser
  void setMenu(int i) {
    if (i >= 0 && i < AdminPage.values.length) {
      navigate(AdminPage.values[i]);
    }
  }

  /// Raccourci depuis CandidatsScreen → bouton "Envoyer SMS"
  void goToSms() => navigate(AdminPage.sms);

  // ── Sous-menus (INCHANGÉS) ────────────────────────────────────────────────
  int sousMenu = 0;
  void setSousMenu(int i) {
    sousMenu = i;
    notifyListeners();
  }

  int addArticle = 0;
  void setAddArticle(int i) {
    addArticle = i;
    notifyListeners();
  }

  int addEmission = 0;
  void setEmission(int i) {
    addEmission = i;
    notifyListeners();
  }

  int addPresseEcrite = 0;
  void setPresseEcrite(int i) {
    addPresseEcrite = i;
    notifyListeners();
  }

  int addFlashNews = 0;
  void setFlashNews(int i) {
    addFlashNews = i;
    notifyListeners();
  }

  int addCategorie = 0;
  void setCategorie(int i) {
    addCategorie = i;
    notifyListeners();
  }

  int addUser = 0;
  void setAddUser(int i) {
    addUser = i;
    notifyListeners();
  }

  int addSouCategorie = 0;
  void setSousCategorie(int i) {
    addSouCategorie = i;
    notifyListeners();
  }

  int addTag = 0;
  void setTag(int i) {
    addTag = i;
    notifyListeners();
  }

  int keyWord = 0;
  void setKeyWord(int i) {
    keyWord = i;
    notifyListeners();
  }
}
