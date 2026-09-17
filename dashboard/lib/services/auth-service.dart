import 'package:dashboard/models/concurant-model.dart';
import 'package:dashboard/utils/phone_normalizer.dart';
import 'package:dashboard/utils/requette-by-dii.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthData
// ─────────────────────────────────────────────────────────────────────────────

class AuthData {
  final String token;
  final String role;
  final String? userId;
  final String? userName;
  final String? email;

  AuthData({
    required this.token,
    required this.role,
    this.userId,
    this.userName,
    this.email,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
        token: json['token'] ?? '',
        role: json['service'] ?? json['role'] ?? 'user',
        userId: json['userId']?.toString(),
        userName: json['name'] ?? json['userName'],
        email: json['email'],
      );

  Map<String, dynamic> toJson() => {
        'token': token,
        'role': role,
        'userId': userId,
        'userName': userName,
        'email': email,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// ServiceResult
// ─────────────────────────────────────────────────────────────────────────────

class ServiceResult<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;

  ServiceResult({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
  });

  factory ServiceResult.success({String? message, T? data, int? statusCode}) =>
      ServiceResult(
          success: true, message: message, data: data, statusCode: statusCode);

  factory ServiceResult.error({String? message, int? statusCode}) =>
      ServiceResult(success: false, message: message, statusCode: statusCode);
}

// ─────────────────────────────────────────────────────────────────────────────
// SmsResult — Modèle de réponse de /api/v1/sms/send-bulk
// ─────────────────────────────────────────────────────────────────────────────

class SmsFailedDetail {
  final String phone;
  final String error;
  final int? code;

  SmsFailedDetail({required this.phone, required this.error, this.code});

  factory SmsFailedDetail.fromJson(Map<String, dynamic> json) =>
      SmsFailedDetail(
        phone: json['phone'] as String? ?? '',
        error: json['error'] as String? ?? 'Erreur inconnue',
        code: json['code'] as int?,
      );

  @override
  String toString() =>
      'SmsFailedDetail(phone: $phone, error: $error, code: $code)';
}

class SmsResult {
  final List<String> sent;
  final List<String> failed;
  final List<SmsFailedDetail> failedDetails; // ← détails causes d'échec
  final int total;
  final String status; // "OK" | "PARTIAL" | "ERROR"

  SmsResult({
    required this.sent,
    required this.failed,
    required this.failedDetails,
    required this.total,
    required this.status,
  });

  factory SmsResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    final rawDetails = data['failedDetails'] as List<dynamic>? ?? [];
    final details = rawDetails
        .map((e) => SmsFailedDetail.fromJson(e as Map<String, dynamic>))
        .toList();

    return SmsResult(
      sent: List<String>.from(data['sent'] ?? []),
      failed: List<String>.from(data['failed'] ?? []),
      failedDetails: details,
      total: (data['total'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'UNKNOWN',
    );
  }

  bool get isFullSuccess => failed.isEmpty && sent.isNotEmpty;
  bool get isPartial => failed.isNotEmpty && sent.isNotEmpty;
  bool get isFullFailure => sent.isEmpty;

  int get sentCount => sent.length;
  int get failedCount => failed.length;

  /// Résumé lisible pour affichage dans l'UI
  String get summary {
    if (isFullSuccess) return '$sentCount SMS envoyé(s) avec succès';
    if (isPartial) return '$sentCount/$total envoyés — $failedCount échec(s)';
    return 'Tous les SMS ont échoué ($failedCount)';
  }

  @override
  String toString() =>
      'SmsResult(sent: $sentCount, failed: $failedCount, total: $total, status: $status)';
}

// ─────────────────────────────────────────────────────────────────────────────
// PhoneNormalizer — Normalisation des numéros sénégalais
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// AuthService
// ─────────────────────────────────────────────────────────────────────────────

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _api = ApiService();

  static const String _keyToken = 'token';
  static const String _keyRole = 'role';
  static const String _keyUserId = 'userId';
  static const String _keyUserName = 'userName';
  static const String _keyEmail = 'email';
  static const String _keyIsLoggedIn = 'isLoggedIn';

  AuthData? _cachedAuthData;

  // ─────────────────────────────────────────────────────────────────────────
  // CACHE
  // ─────────────────────────────────────────────────────────────────────────

  Future<AuthData?> getCachedAuthData() async {
    if (_cachedAuthData != null) return _cachedAuthData;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    if (token == null || token.isEmpty) return null;
    _cachedAuthData = AuthData(
      token: token,
      role: prefs.getString(_keyRole) ?? 'user',
      userId: prefs.getString(_keyUserId),
      userName: prefs.getString(_keyUserName),
      email: prefs.getString(_keyEmail),
    );
    return _cachedAuthData;
  }

  Future<void> _saveAuthData(AuthData authData) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_keyToken, authData.token),
      prefs.setString(_keyRole, authData.role),
      prefs.setBool(_keyIsLoggedIn, true),
      if (authData.userId != null)
        prefs.setString(_keyUserId, authData.userId!),
      if (authData.userName != null)
        prefs.setString(_keyUserName, authData.userName!),
      if (authData.email != null) prefs.setString(_keyEmail, authData.email!),
    ]);
    _cachedAuthData = authData;
    await _api.setToken(authData.token);
    if (kDebugMode) print('[AuthService] ✅ Auth sauvegardée');
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_keyToken),
      prefs.remove(_keyRole),
      prefs.remove(_keyUserId),
      prefs.remove(_keyUserName),
      prefs.remove(_keyEmail),
      prefs.setBool(_keyIsLoggedIn, false),
    ]);
    _cachedAuthData = null;
    await _api.clearToken();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AUTHENTIFICATION — POST /api/v1/users/auth
  // ─────────────────────────────────────────────────────────────────────────

  Future<ServiceResult<AuthData>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        url: '/users/auth',
        body: {'email': email, 'password': password},
        includeAuth: false,
      );
      if (response.success) {
        final data = response.data?['data'];
        if (data == null)
          return ServiceResult.error(message: 'Données invalides');
        final authData = AuthData.fromJson(data);
        await _saveAuthData(authData);
        return ServiceResult.success(
            message: 'Connexion réussie', data: authData);
      }
      return ServiceResult.error(
        message: response.data?['message'] ??
            response.message ??
            'Identifiant incorrect',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ServiceResult.error(message: 'Erreur réseau : $e');
    }
  }

  @Deprecated('Utilisez login() à la place')
  Future<String?> auth(Map<String, dynamic> body) async {
    final r = await login(
        email: body['email'] ?? '', password: body['password'] ?? '');
    return r.success ? r.message : null;
  }

  Future<ServiceResult<void>> logout() async {
    await _clearAuthData();
    return ServiceResult.success(message: 'Déconnexion réussie');
  }

  Future<bool> isLoggedIn() async =>
      (await getCachedAuthData())?.token.isNotEmpty ?? false;
  Future<String?> getUserRole() async => (await getCachedAuthData())?.role;
  Future<bool> hasRole(String role) async =>
      (await getUserRole())?.toLowerCase() == role.toLowerCase();
  Future<bool> isAdmin() async => hasRole('admin');

  // ─────────────────────────────────────────────────────────────────────────
  // UTILISATEURS
  // ─────────────────────────────────────────────────────────────────────────

  Future<ServiceResult<void>> addUser({
    required String name,
    required String email,
    required String password,
    String? role,
    String? phone,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final response = await _api.post(
        url: '/users/store',
        body: {
          'name': name,
          'email': email,
          'password': password,
          if (role != null) 'role': role,
          if (phone != null) 'phone': phone,
          ...?additionalData,
        },
      );
      return response.success
          ? ServiceResult.success(message: 'Utilisateur ajouté')
          : ServiceResult.error(message: response.message ?? 'Échec ajout');
    } catch (e) {
      return ServiceResult.error(message: 'Erreur : $e');
    }
  }

  @Deprecated('Utilisez addUser() à la place')
  Future<String?> add(Map<String, dynamic> body) async {
    final r = await addUser(
      name: body['name'] ?? '',
      email: body['email'] ?? '',
      password: body['password'] ?? '',
      additionalData: body,
    );
    return r.success ? r.message : null;
  }

  Future<ServiceResult<void>> updateUser({
    required String userId,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? password,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final body = <String, dynamic>{
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (role != null) 'role': role,
        if (phone != null) 'phone': phone,
        if (password != null) 'password': password,
        ...?additionalData,
      };
      if (body.isEmpty)
        return ServiceResult.error(message: 'Rien à mettre à jour');
      final response = await _api.put(url: '/users/$userId', body: body);
      return response.success
          ? ServiceResult.success(message: 'Mis à jour')
          : ServiceResult.error(message: response.message ?? 'Échec');
    } catch (e) {
      return ServiceResult.error(message: 'Erreur : $e');
    }
  }

  @Deprecated('Utilisez updateUser() à la place')
  Future<String?> updateAdmin(Map<String, dynamic> body, String id) async {
    final r = await updateUser(userId: id, additionalData: body);
    return r.success ? r.message : null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CONCURANTS — GET /api/v1/users/allConcurant
  // ─────────────────────────────────────────────────────────────────────────

  Future<ServiceResult<List<ConcurantModel>>> getConcurants() async {
    try {
      final response = await _api.get(url: '/users/concurants');
      if (response.success) {
        final data = response.data?['data'];
        if (data == null) return ServiceResult.success(data: []);
        final concurants = ConcurantModel.fromList(data: data);
        if (kDebugMode)
          print('[AuthService] ✅ ${concurants.length} concurant(s)');
        return ServiceResult.success(data: concurants);
      }
      return ServiceResult.error(
          message: response.message ?? 'Erreur récupération');
    } catch (e) {
      return ServiceResult.error(message: 'Erreur réseau : $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ENVOI SMS — POST /api/v1/sms/send-bulk (mode: "list")
  //
  // Flux complet :
  //   1. Normaliser les numéros (supprimer +221/221, valider format sénégalais)
  //   2. POST /sms/send-bulk avec mode: "list"
  //   3. Parser SmsResult (sent, failed, failedDetails)
  //   4. Retourner ServiceResult<SmsResult>
  // ─────────────────────────────────────────────────────────────────────────────

  Future<ServiceResult<SmsResult>> sendDepouillementMessage({
    required List<String> phoneNumbers,
    required String subject,
    required String message,
  }) async {
    try {
      // ── 1. Validation préliminaire ──────────────────────────────────
      if (phoneNumbers.isEmpty) {
        return ServiceResult.error(message: 'Aucun numéro fourni');
      }
      if (subject.trim().isEmpty) {
        return ServiceResult.error(message: 'Le sujet est requis');
      }
      if (message.trim().isEmpty) {
        return ServiceResult.error(message: 'Le message est requis');
      }

      // ── 2. Normalisation ────────────────────────────────────────────
      final cleanedPhones = PhoneNormalizer.normalizeList(phoneNumbers);

      if (cleanedPhones.isEmpty) {
        return ServiceResult.error(
          message: 'Aucun numéro valide. '
              'Format attendu : 77/78/75/76/70 + 7 chiffres (ex: 773412312)',
        );
      }

      if (kDebugMode) {
        final filtered = phoneNumbers.length - cleanedPhones.length;
        print('[AuthService] 📤 send-bulk à ${cleanedPhones.length} numéro(s)');
        if (filtered > 0) {
          print('[AuthService] ⚠️ $filtered numéro(s) ignoré(s)');
        }
        print('[AuthService]    Sujet : $subject');
      }

      // ── 3. Appel API — route send-bulk en mode list ─────────────────
      final response = await _api.post(
        url: '/sms/send-bulk',
        body: {
          'mode': 'list', // ← mode liste explicite
          'telephones': cleanedPhones, // ← numéros normalisés
          'subTitle': subject.trim(),
          'desc': message.trim(),
        },
      );

      if (kDebugMode) {
        print(
            '[AuthService] 📨 Réponse ${response.statusCode}: ${response.data}');
      }

      // ── 4. Parser la réponse ────────────────────────────────────────
      final responseData = response.data as Map<String, dynamic>? ?? {};

      // Succès total ou partiel (200)
      if (response.success) {
        final smsResult = SmsResult.fromJson(responseData);
        return ServiceResult.success(
          message: responseData['message'] ?? smsResult.summary,
          data: smsResult,
          statusCode: response.statusCode,
        );
      }

      // Succès partiel possible (le serveur répond 200 même en PARTIAL)
      // Si le status Node est PARTIAL, response.success est true — géré ci-dessus

      // Gestion des erreurs de validation (422)
      if (response.statusCode == 422) {
        final errors = responseData['errors'] as List<dynamic>?;
        final errMsg = errors?.join('\n') ?? 'Données invalides (422)';
        if (kDebugMode) print('[AuthService] ❌ 422: $errMsg');
        return ServiceResult.error(message: errMsg, statusCode: 422);
      }

      // Erreur serveur (502, 500...)
      return ServiceResult.error(
        message:
            responseData['message'] ?? response.message ?? 'Échec envoi SMS',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (kDebugMode) print('[AuthService] ❌ sendDepouillementMessage: $e');
      return ServiceResult.error(message: 'Erreur réseau : $e');
    }
  }

  @Deprecated('Utilisez sendDepouillementMessage() à la place')
  Future<String?> sendMessageDepouillement(
    List<String> tel,
    String subTitle,
    String desc,
  ) async {
    final r = await sendDepouillementMessage(
      phoneNumbers: tel,
      subject: subTitle,
      message: desc,
    );
    return r.success ? r.message : null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UTILITAIRES
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> validateToken() async {
    try {
      return (await _api.get(url: '/users/validate-token')).success;
    } catch (_) {
      return false;
    }
  }

  Future<ServiceResult<Map<String, dynamic>>> getProfile() async {
    try {
      final r = await _api.get(url: '/users/profile');
      return r.success
          ? ServiceResult.success(data: r.data?['data'] ?? r.data)
          : ServiceResult.error(message: r.message ?? 'Erreur profil');
    } catch (e) {
      return ServiceResult.error(message: 'Erreur : $e');
    }
  }

  Future<ServiceResult<AuthData>> refreshToken() async {
    try {
      final r = await _api.post(url: '/users/refresh-token', body: {});
      if (r.success) {
        final data = r.data?['data'];
        if (data == null)
          return ServiceResult.error(message: 'Données invalides');
        final auth = AuthData.fromJson(data);
        await _saveAuthData(auth);
        return ServiceResult.success(data: auth);
      }
      return ServiceResult.error(message: r.message ?? 'Échec refresh');
    } catch (e) {
      return ServiceResult.error(message: 'Erreur : $e');
    }
  }
}
