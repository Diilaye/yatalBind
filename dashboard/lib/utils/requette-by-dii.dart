import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

/// Configuration de l'environnement API
class ApiConfig {
  static const String _prodBaseUrl = "https://api.yaatalmbindumalxuran.sn";
  static const String _devBaseUrl  = "https://api.yaatalmbindumalxuran.sn";

  static String get baseUrl {
    if (kIsWeb) return _prodBaseUrl;
    return kDebugMode ? _devBaseUrl : _prodBaseUrl;
  }

  static String get apiVersion  => "/api/v1";
  static String get fullBaseUrl => "$baseUrl$apiVersion";
  static String get assetBaseUrl => baseUrl;

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout    = Duration(seconds: 30);

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

/// Exception personnalisée
class ApiException implements Exception {
  final String  message;
  final int?    statusCode;
  final dynamic error;

  ApiException({required this.message, this.statusCode, this.error});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Réponse standardisée
class ApiResponse<T> {
  final T?      data;
  final int     statusCode;
  final String? message;
  final bool    success;

  ApiResponse({
    this.data,
    required this.statusCode,
    this.message,
    required this.success,
  });

  factory ApiResponse.success(T data, int statusCode, [String? message]) {
    return ApiResponse(
      data      : data,
      statusCode: statusCode,
      message   : message,
      success   : true,
    );
  }

  factory ApiResponse.error(int statusCode, String message) {
    return ApiResponse(
      statusCode: statusCode,
      message   : message,
      success   : false,
    );
  }
}

/// Service API principal
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    ApiConfig.printConfig();
  }

  String? _cachedToken;

  // ── Token ──────────────────────────────────────────────────────────────────

  Future<String> _getToken() async {
    if (_cachedToken != null) return _cachedToken!;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString("token") ?? '';
    return _cachedToken!;
  }

  /// ✅ NOUVEAU — Expose le token pour les uploads multipart
  Future<String> getToken() async => await _getToken();

  Future<void> setToken(String token) async {
    _cachedToken = token;
    final prefs  = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  Future<void> clearToken() async {
    _cachedToken = null;
    final prefs  = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  // ── Headers ────────────────────────────────────────────────────────────────

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept'      : 'application/json',
    };
    if (includeAuth) {
      final token = await _getToken();
      if (token.isNotEmpty) {
        headers['Authorization'] = "Bearer $token";
      }
    }
    return headers;
  }

  // ── URL Builder ────────────────────────────────────────────────────────────

  String _buildUrl(String endpoint) {
    if (endpoint.startsWith('/')) endpoint = endpoint.substring(1);
    return "${ApiConfig.fullBaseUrl}/$endpoint";
  }

  // ── Logs ───────────────────────────────────────────────────────────────────

  void _logRequest(String method, String url, {dynamic body}) {
    if (kDebugMode) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🌐 API Request: $method');
      print('🔗 URL: $url');
      if (body != null) print('📦 Body: ${json.encode(body)}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  void _logResponse(int statusCode, dynamic body) {
    if (kDebugMode) {
      print('✅ Response Status: $statusCode');
      print('📥 Response Body: $body');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    }
  }

  // ── Erreurs ────────────────────────────────────────────────────────────────

  ApiResponse<dynamic> _handleError(dynamic error, [int? statusCode]) {
    String message;
    if (error is SocketException) {
      message = "Erreur de connexion. Vérifiez votre connexion internet.";
    } else if (error is http.ClientException) {
      message = "Impossible de contacter le serveur.";
    } else if (error is FormatException) {
      message = "Erreur de format de données.";
    } else {
      message = error.toString();
    }
    if (kDebugMode) {
      print('❌ API Error: $message');
      print('❌ Status Code: $statusCode');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    }
    return ApiResponse.error(statusCode ?? 500, message);
  }

  // ── Parser ─────────────────────────────────────────────────────────────────

  Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      final decoded = json.decode(response.body);
      return {"body": decoded, "status": response.statusCode};
    } catch (e) {
      throw FormatException("Erreur de parsing JSON: ${response.body}");
    }
  }

  bool _isSuccessStatusCode(int statusCode) =>
      statusCode >= 200 && statusCode < 300;

  // ══════════════════════════════════════════════════════════════════════════
  // MÉTHODES HTTP
  // ══════════════════════════════════════════════════════════════════════════

  /// GET
  Future<ApiResponse<dynamic>> get({
    required String url,
    bool includeAuth = true,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final fullUrl = _buildUrl(url);
      final uri     = Uri.parse(fullUrl).replace(queryParameters: queryParameters);
      final headers = await _getHeaders(includeAuth: includeAuth);

      _logRequest('GET', uri.toString());

      final response = await http
          .get(uri, headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      _logResponse(response.statusCode, response.body);
      final parsed = _parseResponse(response);

      if (_isSuccessStatusCode(response.statusCode)) {
        return ApiResponse.success(parsed["body"], parsed["status"]);
      }
      final msg = parsed["body"]["message"] ??
          parsed["body"]["error"] ?? "Une erreur est survenue";
      return ApiResponse.error(parsed["status"], msg);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// POST
  Future<ApiResponse<dynamic>> post({
    required String url,
    required Map<String, dynamic> body,
    bool includeAuth = true,
  }) async {
    try {
      final fullUrl = _buildUrl(url);
      final uri     = Uri.parse(fullUrl);
      final headers = await _getHeaders(includeAuth: includeAuth);

      _logRequest('POST', uri.toString(), body: body);

      final response = await http
          .post(uri, body: json.encode(body), headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      _logResponse(response.statusCode, response.body);
      final parsed = _parseResponse(response);

      if (_isSuccessStatusCode(response.statusCode)) {
        return ApiResponse.success(parsed["body"], parsed["status"]);
      }
      final msg = parsed["body"]["message"] ??
          parsed["body"]["error"] ?? "Une erreur est survenue";
      return ApiResponse.error(parsed["status"], msg);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// PUT
  Future<ApiResponse<dynamic>> put({
    required String url,
    required Map<String, dynamic> body,
    bool includeAuth = true,
  }) async {
    try {
      final fullUrl = _buildUrl(url);
      final uri     = Uri.parse(fullUrl);
      final headers = await _getHeaders(includeAuth: includeAuth);

      _logRequest('PUT', uri.toString(), body: body);

      final response = await http
          .put(uri, body: json.encode(body), headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      _logResponse(response.statusCode, response.body);
      final parsed = _parseResponse(response);

      if (_isSuccessStatusCode(response.statusCode)) {
        return ApiResponse.success(parsed["body"], parsed["status"]);
      }
      final msg = parsed["body"]["message"] ??
          parsed["body"]["error"] ?? "Une erreur est survenue";
      return ApiResponse.error(parsed["status"], msg);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// ✅ NOUVEAU — PATCH
  Future<ApiResponse<dynamic>> patch({
    required String url,
    required Map<String, dynamic> body,
    bool includeAuth = true,
  }) async {
    try {
      final fullUrl = _buildUrl(url);
      final uri     = Uri.parse(fullUrl);
      final headers = await _getHeaders(includeAuth: includeAuth);

      _logRequest('PATCH', uri.toString(), body: body);

      final response = await http
          .patch(uri, body: json.encode(body), headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      _logResponse(response.statusCode, response.body);
      final parsed = _parseResponse(response);

      if (_isSuccessStatusCode(response.statusCode)) {
        return ApiResponse.success(parsed["body"], parsed["status"]);
      }
      final msg = parsed["body"]["message"] ??
          parsed["body"]["error"] ?? "Une erreur est survenue";
      return ApiResponse.error(parsed["status"], msg);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// DELETE
  Future<ApiResponse<dynamic>> delete({
    required String url,
    bool includeAuth = true,
  }) async {
    try {
      final fullUrl = _buildUrl(url);
      final uri     = Uri.parse(fullUrl);
      final headers = await _getHeaders(includeAuth: includeAuth);

      _logRequest('DELETE', uri.toString());

      final response = await http
          .delete(uri, headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      _logResponse(response.statusCode, response.body);
      final parsed = _parseResponse(response);

      if (_isSuccessStatusCode(response.statusCode)) {
        return ApiResponse.success(parsed["body"], parsed["status"]);
      }
      final msg = parsed["body"]["message"] ??
          parsed["body"]["error"] ?? "Une erreur est survenue";
      return ApiResponse.error(parsed["status"], msg);
    } catch (e) {
      return _handleError(e);
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FONCTIONS LEGACY (Compatibilité — ne pas modifier)
// ══════════════════════════════════════════════════════════════════════════════

final _api = ApiService();

@Deprecated('Utilisez ApiService().get() à la place')
Future<Map<String, dynamic>> getResponse({required String url}) async {
  final response = await _api.get(url: url);
  return {"body": response.data ?? {}, "status": response.statusCode};
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
  return {"body": response.data ?? {}, "status": response.statusCode};
}

@Deprecated('Utilisez ApiService().post() à la place')
Future<Map<String, dynamic>> postResponse({
  required String url,
  required Map<String, dynamic> body,
}) async {
  final response = await _api.post(url: url, body: body);
  return {"body": response.data ?? {}, "status": response.statusCode};
}

@Deprecated('Utilisez ApiConfig.fullBaseUrl à la place')
String get BASE_URL => ApiConfig.fullBaseUrl;

@Deprecated('Utilisez ApiConfig.assetBaseUrl à la place')
String get BASE_URL_ASSET => ApiConfig.assetBaseUrl;