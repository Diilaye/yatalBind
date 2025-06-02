import '/models/concours_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConcoursWidget extends StatelessWidget {
  const ConcoursWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: concourslist.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Container(
                height: 155,
                width: 165,
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
          );
        },
        separatorBuilder: (context, index) => const SizedBox(
          width: 20,
        ),
      ),
    );
  }
}
