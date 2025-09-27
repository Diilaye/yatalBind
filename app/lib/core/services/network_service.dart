import 'dart:convert';
import 'package:http/http.dart' as http;
import '../exceptions/app_exceptions.dart';

class NetworkService {
  static const Duration _timeout = Duration(seconds: 30);
  
  Future<Map<String, dynamic>> get(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(_timeout);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ServerException(
          message: 'Erreur serveur: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw NetworkException(
        message: 'Erreur de réseau: $e',
        details: e.toString(),
      );
    }
  }
  
  Future<Map<String, dynamic>> post(String url, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      ).timeout(_timeout);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw ServerException(
          message: 'Erreur serveur: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw NetworkException(
        message: 'Erreur de réseau: $e',
        details: e.toString(),
      );
    }
  }
}