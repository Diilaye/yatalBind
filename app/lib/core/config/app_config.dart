/// Configuration générale de l'application
class AppConfig {
  // Informations de l'application
  static const String appName = 'Yaatal Mbinde';
  static const String appVersion = '1.0.0';
  
  // URLs et APIs
  static const String baseUrl = 'https://api.yaatalmbinde.sn';
  static const String youtubeApiKey = 'YOUR_YOUTUBE_API_KEY';
  
  // Limites et timeouts
  static const int networkTimeout = 30; // secondes
  static const int maxRetries = 3;
  
  // Configuration locale
  static const String defaultLanguage = 'fr';
  static const String defaultCountry = 'SN';
  
  // Configuration PDF
  static const int maxPdfPages = 100;
  
  // Configuration vidéo
  static const int maxVideoLength = 1800; // 30 minutes en secondes
}

/// Configuration pour l'environnement de développement
class DevConfig extends AppConfig {
  static const String baseUrl = 'https://dev-api.yaatalmbinde.sn';
  static const bool debugMode = true;
}

/// Configuration pour la production
class ProdConfig extends AppConfig {
  static const String baseUrl = 'https://api.yaatalmbinde.sn';
  static const bool debugMode = false;
}