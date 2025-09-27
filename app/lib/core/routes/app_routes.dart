/// Noms des routes de l'application
class AppRoutes {
  // Route principale
  static const String splash = '/';
  static const String home = '/home';
  static const String navbar = '/navbar';
  
  // Routes des concours
  static const String concours = '/concours';
  static const String concoursParticipate = '/concours/participate';
  static const String concoursPdf = '/concours/pdf';
  
  // Routes des événements
  static const String events = '/events';
  static const String eventVideo = '/events/video';
  static const String videoPlayer = '/video-player';
  
  // Routes de contact et galerie
  static const String contact = '/contact';
  static const String gallery = '/gallery';
  
  // Routes d'authentification  
  static const String auth = '/auth';
  
  // Routes utilitaires
  static const String settings = '/settings';
  static const String about = '/about';
  static const String profile = '/profile';
  static const String help = '/help';
  
  // Route d'erreur
  static const String notFound = '/404';
}