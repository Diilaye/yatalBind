import 'package:app/utils/images_string.dart';

class CategoryModel{
  final String titre;
  final String image;

  CategoryModel({
    required this.titre,
    required this.image,
  });

  final List<CategoryModel> categories = [
    CategoryModel(titre: "YARU AK YARE", image: category1),
    CategoryModel(titre: "EMISSION BOOLE", image: category5),
    CategoryModel(titre: "THIOSSANAL MBINDE", image: category2),
    CategoryModel(titre: "NDIANGOUM BINDE", image: category3),
    CategoryModel(titre: "CONCOURS YAATAL", image: category4),
  ];
}