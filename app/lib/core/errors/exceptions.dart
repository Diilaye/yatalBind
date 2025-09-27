/// Classe de base pour toutes les exceptions personnalisées
abstract class AppException implements Exception {
  final String message;
  final int? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message';
}

/// Exceptions réseau
class NetworkException extends AppException {
  const NetworkException(String message, {int? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Exceptions d'API
class ApiException extends AppException {
  const ApiException(String message, {int? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Exceptions de validation
class ValidationException extends AppException {
  const ValidationException(String message, {dynamic details})
      : super(message, details: details);
}

/// Exceptions de cache
class CacheException extends AppException {
  const CacheException(String message, {dynamic details})
      : super(message, details: details);
}

/// Exceptions YouTube
class YouTubeException extends AppException {
  const YouTubeException(String message, {dynamic details})
      : super(message, details: details);
}

/// Exceptions PDF
class PdfException extends AppException {
  const PdfException(String message, {dynamic details})
      : super(message, details: details);
}