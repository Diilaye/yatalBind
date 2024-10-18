import 'package:app/utils/images_string.dart';

class Category {
  final String titre;
  final String image;

  Category({
    required this.titre,
    required this.image,
  });
}
  final List<Category> categories = [
    Category(titre: "YARU AK YARE", image: category1),
    Category(titre: "EMISSION BOOLE", image: category5),
    Category(titre: "THIOSSANAL MBINDE", image: category2),
    Category(titre: "NDIANGOUM BINDE", image: category3),
    Category(titre: "CONCOURS YAATAL", image: category4),
  ];
