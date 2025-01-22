import 'package:flutter/material.dart';

Color rouge = const Color(0xffB30014);

Color blanc = const Color(0xffFFFFFF);

Color noir = const Color(0xff000000);

Color gris = const Color(0xffF0F0F0);

Color jaune = const Color(0xffFE9B003);
Color bleuMarine = const Color(0xff041A47);

Color vert = Color.fromARGB(255, 8, 77, 39);
Color bgFooter = Color(0xff2A303B);

Color bgNoir = const Color(0xff1F2024);
Color vertSport = const Color(0xff00A950);

Color bgAdmin = const Color(0xffF1F5F8);

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

Color hexToColor(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}
