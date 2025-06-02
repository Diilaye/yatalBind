import '/models/concours_list.dart';
import '/screen/Concours/pdfviewer_screen.dart';
import 'package:flutter/material.dart';

class ConcoursInfoWidget extends StatelessWidget {
  const ConcoursInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: concourslist.length,
        itemBuilder: (context, index) {
          final concours = concourslist[index];
          return GestureDetector(
            onTap: () {
              if (concours.type == 'pdf') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PDFViewerWidget(filePath: concours.url)),
                );
              } else {}
            },
            child: Column(
              children: [
                Container(
                  height: 155,
                  width: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                        image: AssetImage(concourslist[index].image),
                        fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(concourslist[index].titre,
                    style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(
          width: 20,
        ),
      ),
    );
  }
}
