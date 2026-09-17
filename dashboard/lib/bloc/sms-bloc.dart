import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dashboard/models/concurant-model.dart';
import 'package:dashboard/services/auth-service.dart';
import 'package:dashboard/utils/upload-file.dart';

// ─── Statuts d'envoi ──────────────────────────────────────────────────────────

enum SmsStatus { idle, sending, success, error }

// ─── Bloc SMS ─────────────────────────────────────────────────────────────────

class SmsBloc with ChangeNotifier {
  // ── Services ──────────────────────────────────────────────────────────────
  final AuthService authService = AuthService();

  // ── Controllers formulaire ────────────────────────────────────────────────
  final TextEditingController subtitleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  // Alias court pour compatibilité
  TextEditingController get subtitle => subtitleController;
  TextEditingController get desc => descController;

  // ── Données ───────────────────────────────────────────────────────────────
  List<ConcurantModel> _allConcurants = [];
  final List<ConcurantModel> _selected = [];
  List<String> _phoneNumbersFromFile = [];

  List<ConcurantModel> get allConcurants => _allConcurants;
  List<ConcurantModel>? get concurantsList => _allConcurants;
  List<ConcurantModel>? get concurantsListe => _allConcurants;
  List<ConcurantModel> get selectedConcurants => List.unmodifiable(_selected);
  List<ConcurantModel> get concurantsListeSelect => _selected;
  List<String> get phoneNumbersFromFile =>
      List.unmodifiable(_phoneNumbersFromFile);
  List<String> get tel => _phoneNumbersFromFile;

  // ── Recherche ─────────────────────────────────────────────────────────────
  String _searchText = '';
  String get searchText => _searchText;
  String get rechercheT => _searchText;

  // ── Statut UI ─────────────────────────────────────────────────────────────
  SmsStatus _status = SmsStatus.idle;
  bool _isLoading = false;

  SmsStatus get status => _status;
  bool get isLoading => _isLoading;
  bool get isSending => _status == SmsStatus.sending;

  String? _errorMessage;
  String? _successMessage;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // ─────────────────────────────────────────────────────────────────────────
  // GETTERS CALCULÉS
  // ─────────────────────────────────────────────────────────────────────────

  String get subject => subtitleController.text;
  String get message => descController.text;

  int get messageLength => descController.text.length;
  int get smsCount => (descController.text.length / 160).ceil().clamp(1, 99);

  bool get canSend =>
      subtitleController.text.trim().isNotEmpty &&
      descController.text.trim().isNotEmpty;

  bool get isFormValid => canSend && totalRecipients > 0;

  List<String> get selectedPhoneNumbers => _selected
      .where((c) => c.telephone?.isNotEmpty == true)
      .map((c) => c.telephone!)
      .toList();

  List<String> get selectedPhones => selectedPhoneNumbers;

  /// Tous les numéros cumulés (sélection + fichier), dédupliqués
  List<String> get allPhoneNumbers =>
      <String>{...selectedPhoneNumbers, ..._phoneNumbersFromFile}.toList();

  int get totalRecipients => allPhoneNumbers.length;
  int get selectedCount => _selected.length;
  int get totalCount => _allConcurants.length;
  int get filePhoneCount => _phoneNumbersFromFile.length;

  List<ConcurantModel> get filteredConcurants {
    if (_searchText.trim().isEmpty) return _allConcurants;
    final q = _searchText.toLowerCase().trim();
    return _allConcurants.where((c) {
      return (c.nom?.toLowerCase().contains(q) ?? false) ||
          (c.prenom?.toLowerCase().contains(q) ?? false) ||
          (c.telephone?.contains(q) ?? false) ||
          (c.daara?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  bool get isAllFilteredSelected {
    final valid = filteredConcurants
        .where((c) => c.telephone?.isNotEmpty == true)
        .toList();
    if (valid.isEmpty) return false;
    return valid.every((c) => _selected.any((s) => s.id == c.id));
  }

  Map<String, dynamic> getStatistics() => {
        'totalConcurants': totalCount,
        'validConcurants':
            _allConcurants.where((c) => c.telephone?.isNotEmpty == true).length,
        'selectedConcurants': selectedCount,
        'phoneNumbersFromFile': filePhoneCount,
        'totalRecipients': totalRecipients,
        'filteredCount': filteredConcurants.length,
      };

  // ─────────────────────────────────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────────────────────────────────

  SmsBloc() {
    getAllConcurants();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CHARGEMENT
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> getAllConcurants() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await authService.getConcurants();
      if (result.success) {
        _allConcurants = result.data ?? [];
        if (kDebugMode)
          print('[SmsBloc] ${_allConcurants.length} concurant(s) chargé(s)');
      } else {
        _allConcurants = [];
        _errorMessage = result.message ?? 'Erreur de récupération';
      }
    } catch (e) {
      _allConcurants = [];
      _errorMessage = 'Erreur réseau : $e';
      debugPrint('[SmsBloc] getAllConcurants error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAllconcurant() => getAllConcurants();
  Future<void> refreshConcurants() => getAllConcurants();

  // ─────────────────────────────────────────────────────────────────────────
  // RECHERCHE
  // ─────────────────────────────────────────────────────────────────────────

  void setSearchText(String value) {
    _searchText = value;
    notifyListeners();
  }

  void setRecherche(String v) => setSearchText(v);

  void clearSearch() {
    _searchText = '';
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // IMPORT FICHIER CSV / TXT
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadPhoneNumbersFromFile() async {
    _errorMessage = null;
    notifyListeners();

    try {
      final List<dynamic>? fileData = await getFile();

      if (fileData != null && fileData.isNotEmpty) {
        _phoneNumbersFromFile = fileData
            .map((e) => e.toString().trim())
            .where((p) => p.isNotEmpty)
            .toList();
        _successMessage =
            '${_phoneNumbersFromFile.length} numéro(s) chargé(s) depuis le fichier';
        if (kDebugMode) print('[SmsBloc] Fichier: $_phoneNumbersFromFile');
      } else {
        _errorMessage = 'Aucun numéro trouvé dans le fichier';
      }
    } catch (e) {
      _errorMessage = 'Erreur chargement fichier : $e';
      debugPrint('[SmsBloc] loadPhoneNumbersFromFile error: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> getTelFile() => loadPhoneNumbersFromFile();

  void clearPhoneNumbersFromFile() {
    _phoneNumbersFromFile = [];
    _successMessage = 'Numéros du fichier effacés';
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SÉLECTION
  // ─────────────────────────────────────────────────────────────────────────

  void toggleConcurantSelection(ConcurantModel concurant) {
    final idx = _selected.indexWhere((c) => c.id == concurant.id);
    if (idx >= 0) {
      _selected.removeAt(idx);
    } else {
      if (concurant.telephone?.isNotEmpty == true) {
        _selected.add(concurant);
      } else {
        _errorMessage = 'Ce concurant n\'a pas de numéro de téléphone';
      }
    }
    notifyListeners();
  }

  void selectConcurantOne(ConcurantModel c) => toggleConcurantSelection(c);
  bool isConcurantSelected(ConcurantModel c) =>
      _selected.any((s) => s.id == c.id);

  /// Tout sélectionner dans la liste filtrée
  void selectAll() {
    for (final c in filteredConcurants) {
      if (c.telephone?.isNotEmpty == true &&
          !_selected.any((s) => s.id == c.id)) {
        _selected.add(c);
      }
    }
    _successMessage = '${_selected.length} concurant(s) sélectionné(s)';
    notifyListeners();
  }

  /// Tout sélectionner sans filtre
  void selectAllConcurants() {
    _selected
      ..clear()
      ..addAll(_allConcurants.where((c) => c.telephone?.isNotEmpty == true));
    _successMessage = '${_selected.length} concurant(s) sélectionné(s)';
    notifyListeners();
  }

  void toggleSelectAll() => isAllFilteredSelected ? deselectAll() : selectAll();

  void selectAllFiltered() => selectAll();
  void selectConcurant() => toggleSelectAll();

  void deselectAll() {
    _selected.clear();
    _successMessage = 'Sélection effacée';
    notifyListeners();
  }

  void clearSelection() => deselectAll();

  // ─────────────────────────────────────────────────────────────────────────
  // ENVOI SMS
  // ─────────────────────────────────────────────────────────────────────────

  /// Envoi complet avec validation
  Future<bool> sendSmsMessage() async {
    final err = validateSubject() ?? validateMessage() ?? validateRecipients();
    if (err != null) {
      _errorMessage = err;
      _status = SmsStatus.error;
      notifyListeners();
      return false;
    }

    _status = SmsStatus.sending;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final phones = allPhoneNumbers;

      if (kDebugMode) {
        print('[SmsBloc] Envoi à ${phones.length} destinataire(s)');
        print('[SmsBloc] Sujet: ${subtitleController.text}');
      }

      final result = await authService.sendDepouillementMessage(
        phoneNumbers: phones,
        subject: subtitleController.text.trim(),
        message: descController.text.trim(),
      );

      if (result.success) {
        _status = SmsStatus.success;
        _successMessage = result.message ??
            'SMS envoyé à ${phones.length} destinataire(s) avec succès';
        _resetForm();
        notifyListeners();
        return true;
      } else {
        _status = SmsStatus.error;
        _errorMessage = result.message ?? 'Échec de l\'envoi';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = SmsStatus.error;
      _errorMessage = 'Erreur réseau : $e';
      debugPrint('[SmsBloc] sendSmsMessage error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Alias utilisé par le panel : accepte une liste externe optionnelle
  Future<bool> send({List<String>? phones}) async {
    if (phones != null && phones.isNotEmpty) {
      for (final p in phones) {
        if (!allPhoneNumbers.contains(p)) {
          _phoneNumbersFromFile.add(p);
        }
      }
    }
    return sendSmsMessage();
  }

  /// Alias ancien code
  Future<String?> sendSms() async {
    final ok = await sendSmsMessage();
    return ok ? _successMessage : null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // VALIDATION
  // ─────────────────────────────────────────────────────────────────────────

  String? validateSubject() {
    final t = subtitleController.text.trim();
    if (t.isEmpty) return 'Le sujet est requis';
    if (t.length < 3) return 'Le sujet doit contenir au moins 3 caractères';
    return null;
  }

  String? validateMessage() {
    final t = descController.text.trim();
    if (t.isEmpty) return 'Le message est requis';
    if (t.length < 10) return 'Le message doit contenir au moins 10 caractères';
    return null;
  }

  String? validateRecipients() {
    if (totalRecipients == 0) {
      return 'Veuillez sélectionner au moins un destinataire';
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UTILITAIRES
  // ─────────────────────────────────────────────────────────────────────────

  void clearStatus() {
    _status = SmsStatus.idle;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearMessages() => clearStatus();

  void _resetForm() {
    subtitleController.clear();
    descController.clear();
    _selected.clear();
    _phoneNumbersFromFile.clear();
    _searchText = '';
  }

  void reset() {
    _resetForm();
    _status = SmsStatus.idle;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    subtitleController.dispose();
    descController.dispose();
    super.dispose();
  }
}
