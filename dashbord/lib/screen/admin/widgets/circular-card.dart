import 'package:dashbord/utils/coolors-by-dii.dart';
import 'package:dashbord/utils/font-familly-dii.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class CircularChart extends StatelessWidget {
  final double percentage;
  final String label;
  final Color color;

  CircularChart(
      {required this.percentage, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      // size: Size(200, 200),
      painter: CircularChartPainter(percentage: percentage, color),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${percentage.toInt()}%',
              style: fontFammilyDii(
                  context, 10, noir, FontWeight.bold, FontStyle.normal),
            ),
            Text(
              label,
              style: fontFammilyDii(context, 7, noir.withOpacity(.6),
                  FontWeight.bold, FontStyle.normal),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularChartNoLabel extends StatelessWidget {
  final double percentage;
  final String label;
  final Color color;
  final double taille;

  CircularChartNoLabel(
      {required this.percentage,
      required this.label,
      required this.color,
      this.taille = 300});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(taille, taille),
      painter: CircularChartPainter(percentage: percentage, color),
      child: Center(
          child: Container(
        color: rouge,
        height: 250,
        width: 250,
        child: Center(
          child: CustomPaint(
              painter: CircularChartPainter(percentage: percentage - 30, jaune),
              child: Center(
                child: Container(
                  height: 200,
                  width: 200,
                  color: jaune,
                  child: Center(
                    child: CustomPaint(
                      painter: CircularChartPainter(
                          percentage: percentage - 60, noir),
                      child: SizedBox(),
                    ),
                  ),
                ),
              )),
        ),
      )),
    );
  }
}

class CircularChartPainter extends CustomPainter {
  final double percentage;
  final Color color;

  CircularChartPainter(this.color, {required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    // Dessiner le cercle de fond
    canvas.drawCircle(center, radius, backgroundPaint);

    // Dessiner l'arc
    final double arcAngle = 2 * pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      arcAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CircularChartPainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}
