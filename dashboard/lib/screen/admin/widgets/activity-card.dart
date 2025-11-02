import 'dart:math';

import 'package:dashbord/utils/coolors-by-dii.dart';
import 'package:dashbord/utils/font-familly-dii.dart';
import 'package:dashbord/utils/padding-global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActivyEmission extends StatelessWidget {
  final String title;
  final List<Color> colors;
  final List<double> pourcentages;
  final List<String> labels;

  // final int total;
  // final double percentage;
  // final String label;
  // final String desc;
  // final double increase;
  // final Color color;

  ActivyEmission({
    required this.title,
    required this.colors,
    required this.pourcentages,
    required this.labels,
    // required this.total,
    // required this.percentage,
    // required this.label,
    // required this.desc,
    // required this.increase,
    // required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: fontFammilyDii(
                      context, 14, noir, FontWeight.bold, FontStyle.normal),
                ),
              ],
            ),
            Expanded(
              child: MultiCircleActivity(
                pourcentage: pourcentages,
                colors: colors,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.circle_fill,
                            size: 12,
                            color: colors[0],
                          ),
                          paddingHorizontalGlobal(4),
                          Text(
                            labels[0],
                            style: fontFammilyDii(context, 14, noir,
                                FontWeight.w400, FontStyle.normal),
                          ),
                        ],
                      ),
                      paddingVerticalGlobal(6),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: gris,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: pourcentages[0].ceil(),
                                      child: Container(
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: colors[0],
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      )),
                                  Expanded(
                                      flex: 100 - pourcentages[0].ceil(),
                                      child: SizedBox()),
                                ],
                              ),
                            ),
                          ),
                          paddingHorizontalGlobal(6),
                          Text("${pourcentages[0]}%",
                              style: fontFammilyDii(context, 14, noir,
                                  FontWeight.w400, FontStyle.normal))
                        ],
                      ),
                      paddingVerticalGlobal(8),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.circle_fill,
                            size: 12,
                            color: colors[1],
                          ),
                          paddingHorizontalGlobal(4),
                          Text(
                            labels[1],
                            style: fontFammilyDii(context, 14, noir,
                                FontWeight.w400, FontStyle.normal),
                          ),
                        ],
                      ),
                      paddingVerticalGlobal(6),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: gris,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: pourcentages[0].ceil(),
                                      child: Container(
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: colors[1],
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      )),
                                  Expanded(
                                      flex: 100 - pourcentages[1].ceil(),
                                      child: SizedBox()),
                                ],
                              ),
                            ),
                          ),
                          paddingHorizontalGlobal(6),
                          Text("${pourcentages[1]}%",
                              style: fontFammilyDii(context, 14, noir,
                                  FontWeight.w400, FontStyle.normal))
                        ],
                      ),
                      paddingVerticalGlobal(8),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.circle_fill,
                            size: 12,
                            color: colors[2],
                          ),
                          paddingHorizontalGlobal(4),
                          Text(
                            labels[2],
                            style: fontFammilyDii(context, 14, noir,
                                FontWeight.w400, FontStyle.normal),
                          ),
                        ],
                      ),
                      paddingVerticalGlobal(6),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: gris,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: pourcentages[0].ceil(),
                                      child: Container(
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: colors[2],
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      )),
                                  Expanded(
                                      flex: 100 - pourcentages[2].ceil(),
                                      child: SizedBox()),
                                ],
                              ),
                            ),
                          ),
                          paddingHorizontalGlobal(6),
                          Text("${pourcentages[2]}%",
                              style: fontFammilyDii(context, 14, noir,
                                  FontWeight.w400, FontStyle.normal))
                        ],
                      ),
                      paddingVerticalGlobal(8),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConcentricCircles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        child: CustomPaint(
          painter: CirclesPainter(),
        ),
      ),
    );
  }
}

class CirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 2;

    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      Offset(centerX, centerY),
      80,
      paint,
    );

    canvas.drawCircle(
      Offset(centerX, centerY),
      60,
      paint,
    );

    canvas.drawCircle(
      Offset(centerX, centerY),
      40,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class MultiCircleActivity extends StatelessWidget {
  final List<double> pourcentage;
  final List<Color> colors;

  const MultiCircleActivity({
    required this.pourcentage,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 200,
        child: CustomPaint(
          painter:
              MultiCirclesPainter(pourcentages: pourcentage, colors: colors),
        ),
      ),
    );
  }
}

class MultiCirclesPainter extends CustomPainter {
  final List<double> pourcentages;
  final List<Color> colors;

  MultiCirclesPainter({
    required this.pourcentages,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double radiusOuter = 80;
    double radiusMiddle = 60;
    double radiusInner = 40;

    // Calculate angles based on percentages
    double outerAngle = 2 * pi * (pourcentages[0] / 100);
    double middleAngle = 2 * pi * (pourcentages[1] / 100);
    double innerAngle = 2 * pi * (pourcentages[2] / 100);

    // Gray paint for the background
    Paint grayPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    // Draw outer circle
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radiusOuter),
      -pi / 2,
      2 * pi,
      false,
      grayPaint,
    );

    // Blue paint for outer circle
    Paint outerCirclePaint = Paint()
      ..color = colors[0]
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radiusOuter),
      -pi / 2,
      outerAngle,
      false,
      outerCirclePaint,
    );

    // Draw middle circle
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radiusMiddle),
      -pi / 2,
      2 * pi,
      false,
      grayPaint,
    );

    // Green paint for middle circle
    Paint middleCirclePaint = Paint()
      ..color = colors[1]
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radiusMiddle),
      -pi / 2,
      middleAngle,
      false,
      middleCirclePaint,
    );

    // Draw inner circle
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radiusInner),
      -pi / 2,
      2 * pi,
      false,
      grayPaint,
    );

    // Red paint for inner circle
    Paint innerCirclePaint = Paint()
      ..color = colors[2]
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radiusInner),
      -pi / 2,
      innerAngle,
      false,
      innerCirclePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
