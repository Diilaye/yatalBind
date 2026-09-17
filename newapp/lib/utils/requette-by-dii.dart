import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

/// Configuration de l'environnement API
class ApiConfig {
  // URLs de base selon l'environnement
  static const String _prodBaseUrl = "https://api.yaatalmbindumalxuran.sn";
  static const String _devBaseUrl =
      "https://api.yaatalmbindumalxuran.sn"; // Pour développement local uniquement

  // Détection automatique de l'environnement
  static String get baseUrl {
    if (kIsWeb) return _prodBaseUrl;
    return kDebugMode ? _devBaseUrl : _prodBaseUrl;
  }

  static String get apiVersion => "/api/v1";
  static String get fullBaseUrl => "$baseUrl$apiVersion";
  static String get assetBaseUrl => baseUrl;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pour debug
  static void printConfig() {
    if (kDebugMode) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📡 API Configuration');
      print('   Mode Web: $kIsWeb');
      print('   Mode Debug: $kDebugMode');
      print('   Base URL: $baseUrl');
      print('   Full URL: $fullBaseUrl');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }
}

/// Exception personnalisée pour les erreurs API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic error;

  ApiException({
    required this.message,
    this.statusCode,
    this.error,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Classe de réponse standardisée
class ApiResponse<T> {
  final T? data;
  final int statusCode;
  final String? message;
  final bool success;

  ApiResponse({
    this.data,
    required this.statusCode,
    this.message,
    required this.success,
  });

  factory ApiResponse.success(T data, int statusCode, [String? message]) {
    return ApiResponse(
      data: data,
      statusCode: statusCode,
      message: message,
      success: true,
    );
  }

  factory ApiResponse.error(int statusCode, String message) {
    return ApiResponse(
      statusCode: statusCode,
      message: message,
      success: false,
    );
  }
}

/// Service API principal avec gestion complète des requêtes
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    // Afficher la config au démarrage
    ApiConfig.printConfig();
  }

  String? _cachedToken;

  /// Récupère le token d'authentification
  Future<String> _getToken() async {
    if (_cachedToken != null) return _cachedToken!;

    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString("token") ?? '';
    return _cachedToken!;
  }

  /// Sauvegarde le token
  Future<void> setToken(String token) async {
    _cachedToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  /// Supprime le token (déconnexion)
  Future<void> clearToken() async {
    _cachedToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  /// Headers par défaut
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _getToken();
      if (token.isNotEmpty) {
        headers['Authorization'] = "Bearer $token";
      }
    }

    return headers;
  }

  /// Construction de l'URL complète
  String _buildUrl(String endpoint) {
    // Supprimer le slash initial si présent
    if (endpoint.startsWith('/')) {
      endpoint = endpoint.substring(1);
    }
    return "${ApiConfig.fullBaseUrl}/$endpoint";
  }

  /// Log des requêtes (seulement en debug)
  void _logRequest(String method, String url, {dynamic body}) {
    if (kDebugMode) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🌐 API Request: $method');
      print('🔗 URL: $url');
      print('🏠 Base URL: ${ApiConfig.baseUrl}');
      if (body != null) {
        print('📦 Body: ${json.encode(body)}');
      }
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  /// Log des réponses (seulement en debug)
  void _logResponse(int statusCode, dynamic body) {
    if (kDebugMode) {
      print('✅ Response Status: $statusCode');
      print('📥 Response Body: $body');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    }
  }

  /// Gestion des erreurs HTTP
  ApiResponse<dynamic> _handleError(dynamic error, [int? statusCode]) {
    String message;

    if (error is SocketException) {
      message = "Erreur de connexion. Vérifiez votre connexion internet.";
    } else if (error is http.ClientException) {
      message = "Impossible de contacter le serveur.";
    } else if (error is FormatException) {
      // ✅ On indique clairement que c'est une réponse invalide du serveur
      message = "Réponse invalide du serveur. Vérifiez que l'API est démarrée.";
    } else {
      message = error.toString();
    }

    if (kDebugMode) {
      print('❌ API Error: $message');
      print('❌ Status Code: $statusCode');
      print('❌ Error Type: ${error.runtimeType}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    }

    // ✅ On préserve le statusCode reçu même en cas d'erreur
    return ApiResponse.error(statusCode ?? 502, message);
  }

  /// Parse la réponse HTTP
  /// Parse la réponse HTTP — robuste aux réponses non-JSON
  Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      final decoded = json.decode(response.body);
      return {
        "body": decoded,
        "status": response.statusCode,
      };
    } catch (e) {
      // Le serveur a renvoyé du texte brut (ex: "Bad Gateway", "502")
      // On encapsule proprement pour éviter le crash
      return {
        "body": {
          "message": response.body.isNotEmpty
              ? response.body
              : "Erreur serveur (${response.statusCode})",
          "error": "non_json_response",
        },
        "status": response.statusCode,
      };
    }
  }

  /// Vérifie si la réponse est un succès
  bool _isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  // ==================== MÉTHODES HTTP ====================

  /// GET Request
  Future<ApiResponse<dynamic>> get({
    required String url,
    bool includeAuth = true,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final fullUrl = _buildUrl(url);
      final uri = Uri.parse(fullUrl).replace(queryParameters: queryParameters);
      final headers = await _getHeaders(includeAuth: includeAuth);

      _logRequest('GET', uri.toString());

      final response = await http
          .get(uri, headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      _logResponse(response.statusCode, response.body);

      final parsedResponse = _parseResponse(response);

      if (_isSuccessStatusCode(response.statusCode)) {
        return ApiResponse.success(
          parsedResponse["body"],
          parsedResponse["status"],
        );
      } else {
        final errorMessage = parsedResponse["body"]["message"] ??
            parsedResponse["body"]["error"] ??
            "Une erreur est survenue";
        return ApiResponse.error(parsedResponse["status"], errorMessage);
      }
    } catch (e) {
      return _handleError(e);
    }
  }

  /// POST Request
  Future<ApiResponse<dynamic>> post({
    required String url,
    required Map<String, dynamic> body,
    bool includeAuth = true,
  }) async {
    try {
      final fullUrl = _buildUrl(url);
      final uri = Uri.parse(fullUrl);
      final headers = await _getHeaders(includeAuth: includeAuth);

      _logRequest('POST', uri.toString(), body: body);

      final response = await http
          .post(
            uri,
            body: json.encode(body),
            headers: headers,
          )
          .timeout(ApiConfig.connectionTimeout);

      _logResponse(response.statusCode, response.body);

      final parsedResponse = _parseResponse(response);

      if (_isSuccessStatusCode(response.statusCode)) {
        return ApiResponse.success(
          parsedResponse["body"],
          parsedResponse["status"],
        );
      } else {
        final errorMessage = parsedResponse["body"]["message"] ??
            parsedResponse["body"]["error"] ??
            "Une erreur est survenue";
        return ApiResponse.error(parsedResponse["status"], errorMessage);
      }
    } catch (e) {
      return _handleError(e);
    }
  }

  /// PUT Request
  Future<ApiResponse<dynamic>> put({
    required String url,
    required Map<String, dynamic> body,
    bool includeAuth = true,
  }) async {
    try {
      final fullUrl = _buildUrl(url);
      final uri = Uri.parse(fullUrl);
      final headers = await _getHeaders(includeAuth: includeAuth);

      _logRequest('PUT', uri.toString(), body: body);

      final response = await http
          .put(
            uri,
            body: json.encode(body),
            headers: headers,
          )
          .timeout(ApiConfig.connectionTimeout);

      _logResponse(response.statusCode, response.body);

      final parsedResponse = _parseResponse(response);

      if (_isSuccessStatusCode(response.statusCode)) {
        return ApiResponse.success(
          parsedResponse["body"],
          parsedResponse["status"],
        );
      } else {
        final errorMessage = parsedResponse["body"]["message"] ??
            parsedResponse["body"]["error"] ??
            "Une erreur est survenue";
        return ApiResponse.error(parsedResponse["status"], errorMessage);
      }
    } catch (e) {
      return _handleError(e);
    }
  }

  /// DELETE Request
  Future<ApiResponse<dynamic>> delete({
    required String url,
    bool includeAuth = true,
  }) async {
    try {
      final fullUrl = _buildUrl(url);
      final uri = Uri.parse(fullUrl);
      final headers = await _getHeaders(includeAuth: includeAuth);

      _logRequest('DELETE', uri.toString());

      final response = await http
          .delete(uri, headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      _logResponse(response.statusCode, response.body);

      final parsedResponse = _parseResponse(response);

      if (_isSuccessStatusCode(response.statusCode)) {
        return ApiResponse.success(
          parsedResponse["body"],
          parsedResponse["status"],
        );
      } else {
        final errorMessage = parsedResponse["body"]["message"] ??
            parsedResponse["body"]["error"] ??
            "Une erreur est survenue";
        return ApiResponse.error(parsedResponse["status"], errorMessage);
      }
    } catch (e) {
      return _handleError(e);
    }
  }
}

// ==================== FONCTIONS LEGACY (Compatibilité) ====================

final _api = ApiService();

@Deprecated('Utilisez ApiService().get() à la place')
Future<Map<String, dynamic>> getResponse({required String url}) async {
  final response = await _api.get(url: url);
  return {
    "body": response.data ?? {},
    "status": response.statusCode,
  };
}

@Deprecated('Utilisez ApiService().delete() à la place')
Future<dynamic> deleteResponse({required String url}) async {
  final response = await _api.delete(url: url);
  return response.data;
}

@Deprecated('Utilisez ApiService().put() à la place')
Future<Map<String, dynamic>> putResponse({
  required String url,
  required Map<String, dynamic> body,
}) async {
  final response = await _api.put(url: url, body: body);
  return {
    "body": response.data ?? {},
    "status": response.statusCode,
  };
}

@Deprecated('Utilisez ApiService().post() à la place')
Future<Map<String, dynamic>> postResponse({
  required String url,
  required Map<String, dynamic> body,
}) async {
  final response = await _api.post(url: url, body: body);
  return {
    "body": response.data ?? {},
    "status": response.statusCode,
  };
}

// ==================== CONSTANTES LEGACY ====================

@Deprecated('Utilisez ApiConfig.fullBaseUrl à la place')
String get BASE_URL => ApiConfig.fullBaseUrl;

@Deprecated('Utilisez ApiConfig.assetBaseUrl à la place')
String get BASE_URL_ASSET => ApiConfig.assetBaseUrl;
