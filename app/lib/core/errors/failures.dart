/// Classes de base pour représenter les échecs
abstract class Failure {
  final String message;
  final int? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure: $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure && runtimeType == other.runtimeType && message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// Échecs réseau
class NetworkFailure extends Failure {
  const NetworkFailure(String message, {int? code}) : super(message, code: code);
}

/// Échecs de serveur
class ServerFailure extends Failure {
  const ServerFailure(String message, {int? code}) : super(message, code: code);
}

/// Échecs de validation
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

/// Échecs de cache
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

/// Échecs YouTube
class YouTubeFailure extends Failure {
  const YouTubeFailure(String message) : super(message);
}

/// Échecs PDF
class PdfFailure extends Failure {
  const PdfFailure(String message) : super(message);
}

/// Échecs génériques
class GeneralFailure extends Failure {
  const GeneralFailure(String message) : super(message);
}