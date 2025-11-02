import 'package:dashbord/screen/admin/widgets/circular-card.dart';
import 'package:dashbord/utils/coolors-by-dii.dart';
import 'package:dashbord/utils/font-familly-dii.dart';
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final int total;
  final double percentage;
  final String label;
  final String desc;
  final double increase;
  final Color color;

  StatCard({
    required this.title,
    required this.total,
    required this.percentage,
    required this.label,
    required this.desc,
    required this.increase,
    required this.color,
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: fontFammilyDii(
                        context, 14, noir, FontWeight.bold, FontStyle.normal),
                  ),
                  SizedBox(height: 8),
                  Text(
                    desc,
                    style: fontFammilyDii(context, 10, noir.withOpacity(.6),
                        FontWeight.w400, FontStyle.normal),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        total.toString(),
                        style: fontFammilyDii(context, 14, noir,
                            FontWeight.bold, FontStyle.normal),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: increase > 0
                              ? vertSport.withOpacity(0.2)
                              : rouge.withOpacity(.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            increase > 0
                                ? Icon(
                                    Icons.arrow_upward,
                                    color: vertSport,
                                    size: 12,
                                  )
                                : Icon(
                                    Icons.arrow_downward,
                                    color: rouge,
                                    size: 12,
                                  ),
                            SizedBox(width: 4),
                            Text(
                              '$increase%',
                              style: increase > 0
                                  ? fontFammilyDii(context, 8, vertSport,
                                      FontWeight.bold, FontStyle.normal)
                                  : fontFammilyDii(context, 8, rouge,
                                      FontWeight.bold, FontStyle.normal),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: CircularChart(
                percentage: percentage,
                label: label,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
