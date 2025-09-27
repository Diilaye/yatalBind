import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Gestionnaire d'erreurs global pour l'application
class ErrorHandler {
  static void handleError(dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      print('🔴 Erreur capturée: $error');
      print('📍 Stack trace: $stackTrace');
    }
    
    // Log vers un service externe en production
    // TODO: Intégrer Crashlytics ou Sentry
  }

  /// Convertit une exception en Failure
  static Failure mapExceptionToFailure(dynamic exception) {
    if (exception is NetworkException) {
      return NetworkFailure(exception.message, code: exception.code);
    } else if (exception is ApiException) {
      return ServerFailure(exception.message, code: exception.code);
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.message);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message);
    } else if (exception is YouTubeException) {
      return YouTubeFailure(exception.message);
    } else if (exception is PdfException) {
      return PdfFailure(exception.message);
    } else {
      return GeneralFailure('Une erreur inattendue s\'est produite');
    }
  }

  /// Affiche une snackbar d'erreur
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  /// Affiche un dialog d'erreur
  static void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}