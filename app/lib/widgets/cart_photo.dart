import 'package:app/bloc/youtube/player.dart';
import 'package:app/models/photos_list.dart';
import 'package:app/utils/colors.dart' as color;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
class CartPhoto extends StatelessWidget {
  const CartPhoto({super.key});


  @override
  Widget build(BuildContext context) {

    return GridView.extent(
      maxCrossAxisExtent: 200,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: EdgeInsets.all(8),
      childAspectRatio: 1/1.2,
      children: gridItems(),
    );
  }
  List<Widget> gridItems(){
    return photoslist.map<Widget>((photo)=> _GridItem(photo)).toList();
  }
}

class _GridItem extends StatelessWidget{
  _GridItem(this.photo);
  final PhotosList photo;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      child: InkWell(
        child: GridTile(
          footer: GridTileBar(
            backgroundColor: color.AppColor.yAccentColor,
            title: Text(photo.titre),
          ), 
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: AssetImage(
                  photo.image,
                ),
                fit: BoxFit.cover
              ),
            ),
          )

        ),
      ),
    );
  }
}
