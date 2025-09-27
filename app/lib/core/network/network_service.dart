import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../errors/exceptions.dart';

/// Service réseau avec gestion d'erreurs robuste
class NetworkService {
  static NetworkService? _instance;
  static NetworkService get instance => _instance ??= NetworkService._();
  
  NetworkService._();

  final http.Client _client = http.Client();
  
  /// Headers par défaut
  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': '${AppConfig.appName}/${AppConfig.appVersion}',
  };

  /// Effectue une requête GET
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final response = await _client
          .get(uri, headers: {..._defaultHeaders, ...?headers})
          .timeout(Duration(seconds: AppConfig.networkTimeout));

      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException('Pas de connexion internet');
    } on HttpException {
      throw const NetworkException('Erreur de connexion réseau');
    } catch (e) {
      throw NetworkException('Erreur réseau: $e');
    }
  }

  /// Effectue une requête POST
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client
          .post(
            uri,
            headers: {..._defaultHeaders, ...?headers},
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(Duration(seconds: AppConfig.networkTimeout));

      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException('Pas de connexion internet');
    } on HttpException {
      throw const NetworkException('Erreur de connexion réseau');
    } catch (e) {
      throw NetworkException('Erreur réseau: $e');
    }
  }

  /// Construit l'URI avec les paramètres de requête
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: {
        ...uri.queryParameters,
        ...queryParams.map((key, value) => MapEntry(key, value.toString())),
      });
    }
    return uri;
  }

  /// Traite la réponse HTTP
  Map<String, dynamic> _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 202:
        try {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          throw const ApiException('Format de réponse invalide');
        }
      case 400:
        throw const ApiException('Requête invalide', code: 400);
      case 401:
        throw const ApiException('Non autorisé', code: 401);
      case 403:
        throw const ApiException('Accès interdit', code: 403);
      case 404:
        throw const ApiException('Ressource non trouvée', code: 404);
      case 500:
        throw const ApiException('Erreur serveur', code: 500);
      default:
        throw ApiException(
          'Erreur HTTP: ${response.statusCode}',
          code: response.statusCode,
        );
    }
  }

  /// Nettoie les ressources
  void dispose() {
    _client.close();
  }
}