// lib/bloc/candidats_bloc.dart

import 'package:flutter/foundation.dart';
import 'package:dashboard/models/concurant-model.dart';
import 'package:dashboard/services/auth-service.dart';

const int _kPageSize = 25;

class CandidatsBloc with ChangeNotifier {
  final AuthService _authService = AuthService();

  // ── Données ───────────────────────────────────────────────────────────────
  List<ConcurantModel> _allCandidats = [];
  List<ConcurantModel> get allCandidats => _allCandidats;

  // ── Pagination ────────────────────────────────────────────────────────────
  int _currentPage = 1;
  int get currentPage => _currentPage;

  int get totalPages => (_filtered.length / _kPageSize).ceil().clamp(1, 99999);
  int get totalCount => _allCandidats.length;
  int get filteredCount => _filtered.length;

  List<ConcurantModel> get paginated {
    final start = (_currentPage - 1) * _kPageSize;
    final end = (start + _kPageSize).clamp(0, _filtered.length);
    if (start >= _filtered.length) return [];
    return _filtered.sublist(start, end);
  }

  // ── Recherche ─────────────────────────────────────────────────────────────
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<ConcurantModel> get _filtered {
    if (_searchQuery.trim().isEmpty) return _allCandidats;
    final q = _searchQuery.toLowerCase().trim();
    return _allCandidats.where((c) {
      return (c.prenom?.toLowerCase().contains(q) ?? false) ||
          (c.nom?.toLowerCase().contains(q) ?? false) ||
          (c.telephone?.contains(q) ?? false) ||
          (c.daara?.toLowerCase().contains(q) ?? false) ||
          (c.id?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  // ── Filtre fichier ────────────────────────────────────────────────────────
  bool _showOnlyWithFiles = false;
  bool get showOnlyWithFiles => _showOnlyWithFiles;

  void toggleFileFilter() {
    _showOnlyWithFiles = !_showOnlyWithFiles;
    _currentPage = 1;
    notifyListeners();
  }

  // ── État UI ───────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Aperçu fichier
  ConcurantModel? _previewCandidat;
  ConcurantModel? get previewCandidat => _previewCandidat;

  // Sélection SMS
  final Set<String> _selectedIds = {};
  Set<String> get selectedIds => Set.unmodifiable(_selectedIds);

  bool isSelected(ConcurantModel c) => _selectedIds.contains(c.id);

  void toggleSelection(ConcurantModel c) {
    if (c.id == null) return;
    if (_selectedIds.contains(c.id)) {
      _selectedIds.remove(c.id);
    } else {
      _selectedIds.add(c.id!);
    }
    notifyListeners();
  }

  void selectAll() {
    for (final c in _filtered) {
      if (c.id != null && c.telephone != null) _selectedIds.add(c.id!);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  List<ConcurantModel> get selectedCandidats =>
      _allCandidats.where((c) => _selectedIds.contains(c.id)).toList();

  List<String> get selectedPhones => selectedCandidats
      .where((c) => c.telephone != null)
      .map((c) => c.telephone!)
      .toList();

  int get selectedCount => _selectedIds.length;

  // ── Init ──────────────────────────────────────────────────────────────────
  CandidatsBloc() {
    fetchCandidats();
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────
  Future<void> fetchCandidats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.getConcurants();
      if (result.success && result.data != null) {
        _allCandidats = result.data!;
        _currentPage = 1;
      } else {
        _errorMessage = result.message ?? 'Erreur de chargement.';
        _allCandidats = [];
      }
    } catch (e) {
      _errorMessage = 'Erreur réseau : $e';
      _allCandidats = [];
      debugPrint('[CandidatsBloc] fetchCandidats error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => fetchCandidats();

  // ── Recherche ─────────────────────────────────────────────────────────────
  void setSearch(String query) {
    _searchQuery = query;
    _currentPage = 1;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _currentPage = 1;
    notifyListeners();
  }

  // ── Pagination ────────────────────────────────────────────────────────────
  void goToPage(int page) {
    if (page < 1 || page > totalPages) return;
    _currentPage = page;
    notifyListeners();
  }

  void nextPage() => goToPage(_currentPage + 1);
  void previousPage() => goToPage(_currentPage - 1);

  bool get canGoNext => _currentPage < totalPages;
  bool get canGoPrev => _currentPage > 1;

  String get rangeLabel {
    if (_filtered.isEmpty) return '0 résultat';
    final start = (_currentPage - 1) * _kPageSize + 1;
    final end = (start + _kPageSize - 1).clamp(1, _filtered.length);
    return '$start–$end sur ${_filtered.length}';
  }

  // ── Aperçu fichier ────────────────────────────────────────────────────────
  void openPreview(ConcurantModel candidat) {
    _previewCandidat = candidat;
    notifyListeners();
  }

  void closePreview() {
    _previewCandidat = null;
    notifyListeners();
  }

  // ── Stats ─────────────────────────────────────────────────────────────────
  int get countMasculin =>
      _allCandidats.where((c) => c.sexe == 'masculin').length;
  int get countFeminin =>
      _allCandidats.where((c) => c.sexe == 'feminin').length;
  int get countAvecFichier =>
      _allCandidats.where((c) => c.fichierUrl != null).length;
  int get countCloudinary =>
      _allCandidats.where((c) => c.isFichierCloudinary).length;

  @override
  void dispose() => super.dispose();
}
