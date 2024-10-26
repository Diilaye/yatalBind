import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      width: double.infinity,
      decoration: BoxDecoration(
        color: yWhiteColor,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child:  Row(
        children: [
          const Icon(
            Icons.search,
            color: Colors.black,
            size: 30,
          ),
          const SizedBox(width: 10,),
          const Flexible(
            flex: 4,
            child: TextField(
              decoration: InputDecoration(
                  hintText: "Rechercher...",
                  border: InputBorder.none
              ),
            ),
          ),
          Container(
            height: 25,
            width: 1.5,
            color: yAccentColor,
          ),
          IconButton(
              onPressed: (){},
              icon: const Icon(Icons.tune, color: yAccentColor,)
          ),
        ],
      ),
    );
  }
}
