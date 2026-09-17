// lib/bloc/auth_bloc.dart
import 'package:dashboard/services/auth-service.dart';
import 'package:dashboard/utils/coolors-by-dii.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthBloc with ChangeNotifier {
  // ==================== SERVICES ====================
  final AuthService _authService = AuthService();

  // ==================== CONTROLLERS ====================
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  TextEditingController get email => emailController;
  TextEditingController get password => passwordController;

  // ==================== ÉTAT ====================
  bool _showPassword = false;
  bool get showPassword => _showPassword;

  bool _isLoading = false;
  bool get chargement => _isLoading;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  AuthData? _currentUser;
  AuthData? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  String? resultRegister;

  // ==================== VALIDATION ====================

  String? validateEmail() {
    final emailText = emailController.text.trim();
    if (emailText.isEmpty) return 'Veuillez entrer votre email';
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(emailText)) return 'Format d\'email invalide';
    return null;
  }

  String? validatePassword() {
    final passwordText = passwordController.text;
    if (passwordText.isEmpty) return 'Veuillez entrer votre mot de passe';
    if (passwordText.length < 6)
      return 'Le mot de passe doit contenir au moins 6 caractères';
    return null;
  }

  bool validateForm() {
    final emailError = validateEmail();
    if (emailError != null) {
      _errorMessage = emailError;
      notifyListeners();
      return false;
    }
    final passwordError = validatePassword();
    if (passwordError != null) {
      _errorMessage = passwordError;
      notifyListeners();
      return false;
    }
    _errorMessage = null;
    return true;
  }

  // ==================== MOT DE PASSE ====================
  void setShowPassword() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  void showPasswordVisibility() {
    _showPassword = true;
    notifyListeners();
  }

  void hidePasswordVisibility() {
    _showPassword = false;
    notifyListeners();
  }

  // ==================== AUTHENTIFICATION ====================

  /// [FIX #1] login() — context.go('/admin') remplacé par loginSuccess()
  Future<void> login(BuildContext context) async {
    if (!validateForm()) {
      _showToast(_errorMessage!, isError: true);
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    resultRegister = null;
    notifyListeners();

    try {
      if (kDebugMode)
        print('🔐 Tentative de connexion: ${emailController.text}');

      final result = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (result.success && result.data != null) {
        _successMessage = result.message ?? 'Connexion réussie';
        resultRegister = _successMessage;
        _errorMessage = null;

        _showToast(_successMessage ?? 'Connexion réussie.', isError: false);
        await Future.delayed(const Duration(milliseconds: 500));

        // [FIX] Plus de context.go('/admin') — le router redirige automatiquement
        // via refreshListenable dès que loginSuccess() appelle notifyListeners()
        loginSuccess(result.data!);
      } else {
        _errorMessage =
            result.message ?? 'Problème de connexion, identifiant incorrect';
        _successMessage = null;
        resultRegister = null;
        _currentUser = null;
        _isLoading = false;

        if (kDebugMode) print('❌ Échec de connexion: $_errorMessage');
        _showToast(_errorMessage!, isError: true);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
      _successMessage = null;
      resultRegister = null;
      _currentUser = null;
      _isLoading = false;

      if (kDebugMode) print('❌ Erreur lors de la connexion: $e');
      _showToast(_errorMessage!, isError: true);
      notifyListeners();
    }
    // Pas de finally : loginSuccess() gère _isLoading = false
  }

  /// [AJOUT] Appelée après login réussi — ou directement si besoin externe
  /// notifyListeners() → GoRouter.refreshListenable → redirect('/admin')
  void loginSuccess(AuthData user) {
    _currentUser = user;
    _isLoading = false;
    _errorMessage = null;
    emailController.clear();
    passwordController.clear();
    _showPassword = false;

    if (kDebugMode) {
      print('✅ Connexion réussie');
      print('👤 Utilisateur: ${_currentUser?.userName}');
      print('🔑 Rôle: ${_currentUser?.role}');
    }

    notifyListeners(); // ← GoRouter réévalue redirect → '/admin'
  }

  /// [FIX #2] logout() — context.go('/') remplacé par notifyListeners()
  Future<void> logout(BuildContext context) async {
    await logoutSilent();
    // Le router redirige vers '/' automatiquement via refreshListenable
  }

  /// [AJOUT] Déconnexion sans BuildContext — utilisable depuis sidebar, timer, etc.
  Future<void> logoutSilent() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) print('🔓 Déconnexion en cours...');
      final result = await _authService.logout();

      if (result.success) {
        if (kDebugMode) print('✅ Déconnexion réussie');
        _showToast('Déconnexion réussie', isError: false);
      } else {
        _errorMessage = result.message ?? 'Erreur lors de la déconnexion';
        _showToast(_errorMessage!, isError: true);
      }
    } catch (e) {
      if (kDebugMode) print('❌ Erreur lors de la déconnexion: $e');
      _showToast('Erreur lors de la déconnexion', isError: true);
    }

    _currentUser = null;
    emailController.clear();
    passwordController.clear();
    _errorMessage = null;
    _successMessage = null;
    resultRegister = null;
    _showPassword = false;
    _isLoading = false;

    notifyListeners(); // ← GoRouter réévalue redirect → '/'
  }

  // ==================== SESSION ====================

  Future<void> checkAuthStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _currentUser = await _authService.getCachedAuthData();
        if (kDebugMode && _currentUser != null) {
          print('✅ Session active détectée');
          print('👤 Utilisateur: ${_currentUser?.userName}');
        }
      } else {
        _currentUser = null;
        if (kDebugMode) print('ℹ️ Aucune session active');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Erreur checkAuthStatus: $e');
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<void> fetchUserProfile() async {
    if (_currentUser == null) return;
    try {
      final result = await _authService.getProfile();
      if (result.success && result.data != null) {
        final data = result.data!;
        _currentUser = AuthData(
          token: _currentUser?.token ?? '',
          role: data['role'] ?? _currentUser?.role ?? 'user',
          userId: data['id']?.toString() ?? _currentUser?.userId,
          userName: data['name'] ?? _currentUser?.userName,
          email: data['email'] ?? _currentUser?.email,
        );
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('❌ Erreur fetchUserProfile: $e');
    }
  }

  Future<bool> validateSession() async {
    try {
      return await _authService.validateToken();
    } catch (e) {
      return false;
    }
  }

  // ==================== RÔLES ====================
  bool hasRole(String role) =>
      _currentUser?.role.toLowerCase() == role.toLowerCase();
  bool get isAdmin => hasRole('admin');
  String? get userRole => _currentUser?.role;

  // ==================== UTILITAIRES ====================
  void _showToast(String message, {required bool isError}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 2,
      backgroundColor: isError ? rouge : vert,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  void resetForm() {
    emailController.clear();
    passwordController.clear();
    _showPassword = false;
    _errorMessage = null;
    _successMessage = null;
    resultRegister = null;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    resultRegister = null;
    notifyListeners();
  }

  void reset() {
    emailController.clear();
    passwordController.clear();
    _showPassword = false;
    _isLoading = false;
    _errorMessage = null;
    _successMessage = null;
    resultRegister = null;
    _currentUser = null;
    notifyListeners();
  }

  Map<String, dynamic>? getUserInfo() {
    if (_currentUser == null) return null;
    return {
      'userId': _currentUser!.userId,
      'userName': _currentUser!.userName,
      'email': _currentUser!.email,
      'role': _currentUser!.role,
      'isAdmin': isAdmin,
    };
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
