import 'package:app/models/concours_list.dart';
import 'package:flutter/material.dart';

class ConcoursInfoWidget extends StatelessWidget {
   ConcoursInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: concourslist.length,
        itemBuilder: (context, index){
          return Column(
            children: [
              Container(
                height: 155,
                width: 165,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(image: AssetImage(concourslist[index].image),
                      fit: BoxFit.cover
                  ),
                ),
              ),
              SizedBox(height: 5,),
              Text(
                  concourslist[index].titre,
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold
                  )
              ),
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
