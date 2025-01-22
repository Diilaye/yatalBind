import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle fontFammilyDii(
  context,
  size,
  color,
  weight,
  style,
) {
  return GoogleFonts.montserrat(
      textStyle: Theme.of(context).textTheme.displayLarge,
      letterSpacing: 0,
      fontSize: size,
      color: color,
      fontWeight: weight,
      fontStyle: style,
      height: 1.2);
}
