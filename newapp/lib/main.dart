import 'package:yaatal_mbindum/bloc/controllers/language_controller.dart';
import 'package:yaatal_mbindum/bloc/controllers/home_controller.dart';
import 'package:yaatal_mbindum/bloc/controllers/gallery_controller.dart';
import 'package:yaatal_mbindum/bloc/translations/translations.dart';
import '/screen/nav_bar_screen.dart';
import '/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  setUrlStrategy(PathUrlStrategy());

  // Controllers existants
  Get.put(LanguageController());

  // ── Nouveaux controllers ──────────────────────────────
  Get.put(HomeController());
  Get.put(GalleryController());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LanguageController langController = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => GetMaterialApp(
          initialRoute: '/',
          debugShowCheckedModeBanner: false,
          locale: Locale(langController.currentLanguage.value),
          fallbackLocale: const Locale('fr'),
          translations: AppTranslations(),
          builder: (context, child) {
            return Directionality(
              textDirection: langController.isRTL.value
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: child!,
            );
          },
          theme: ThemeData(
            textTheme: GoogleFonts.mulishTextTheme(),
          ),
          getPages: [
            GetPage(name: '/NavBarScreen', page: () => NavBarScreen()),
            GetPage(name: '/', page: () => const SplashScreen()),
          ],
        ));
  }
}
