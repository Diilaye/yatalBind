import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/config/app_config.dart';
import 'core/routes/app_pages.dart';
import 'core/errors/error_handler.dart';
import 'bloc/fade_in_animation_controller.dart';
import 'utils/colors.dart' as app_colors;

void main() async {
  // Initialisation Flutter
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  // Configuration de l'écran de démarrage natif
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // Configuration pour le web
  if (kIsWeb) {
    setUrlStrategy(PathUrlStrategy());
  }
  
  // Orientation portrait uniquement
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }
  
  // Configuration globale des erreurs
  if (kDebugMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      ErrorHandler.handleError(details.exception, details.stack);
    };
  }
  
  // Initialisation des contrôleurs
  _initializeControllers();
  
  // Lancement de l'application
  runApp(const YaatalMbindeApp());
  
  // Suppression de l'écran de démarrage natif
  FlutterNativeSplash.remove();
}

/// Initialise les contrôleurs globaux
void _initializeControllers() {
  Get.put(FadeInAnimationController(), permanent: true);
}

/// Application principale Yaatal Mbinde
class YaatalMbindeApp extends StatelessWidget {
  const YaatalMbindeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // Configuration de base
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      
      // Configuration de navigation
      initialRoute: AppPages.initialRoute,
      getPages: AppPages.pages,
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const NotFoundPage(),
      ),
      
      // Configuration du thème
      theme: _buildTheme(),
      
      // Configuration pour le web - supprimé car non supporté dans cette version
      
      // Configuration des erreurs
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child ?? const SizedBox(),
        );
      },
    );
  }

  /// Construit le thème de l'application
  ThemeData _buildTheme() {
    return ThemeData(
      // Police de base
      textTheme: GoogleFonts.poppinsTextTheme(),
      
      // Couleurs principales
      primarySwatch: Colors.blue,
      primaryColor: app_colors.yDarkColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: app_colors.yAccentColor,
        primary: app_colors.yDarkColor,
        secondary: app_colors.yAccentColor,
        surface: app_colors.yWhiteColor,
      ),
      
      // Configuration des composants
      appBarTheme: AppBarTheme(
        backgroundColor: app_colors.yDarkColor,
        foregroundColor: app_colors.yWhiteColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: app_colors.yWhiteColor,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: app_colors.yAccentColor,
          foregroundColor: app_colors.yWhiteColor,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Configuration des cartes
      cardTheme: const CardThemeData(
        elevation: 4,
        margin: EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
      ),
      
      // Configuration responsive
      visualDensity: VisualDensity.adaptivePlatformDensity,
      
      // Configuration pour le web
      splashFactory: kIsWeb ? NoSplash.splashFactory : InkSplash.splashFactory,
    );
  }
}