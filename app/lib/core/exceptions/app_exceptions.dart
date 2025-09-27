// Exceptions de base pour l'application

abstract class AppException implements Exception {
  final String message;
  final dynamic details;
  
  const AppException({
    required this.message,
    this.details,
  });
  
  @override
  String toString() => 'AppException: $message';
}

class ServerException extends AppException {
  final int? statusCode;
  
  const ServerException({
    required String message,
    this.statusCode,
    dynamic details,
  }) : super(message: message, details: details);
  
  @override
  String toString() => 'ServerException: $message (Code: $statusCode)';
}

class NetworkException extends AppException {
  const NetworkException({
    required String message,
    dynamic details,
  }) : super(message: message, details: details);
  
  @override
  String toString() => 'NetworkException: $message';
}

class CacheException extends AppException {
  const CacheException({
    required String message,
    dynamic details,
  }) : super(message: message, details: details);
  
  @override
  String toString() => 'CacheException: $message';
}

class ValidationException extends AppException {
  const ValidationException({
    required String message,
    dynamic details,
  }) : super(message: message, details: details);
  
  @override
  String toString() => 'ValidationException: $message';
}

class UnknownException extends AppException {
  const UnknownException({
    required String message,
    dynamic details,
  }) : super(message: message, details: details);
  
  @override
  String toString() => 'UnknownException: $message';
}