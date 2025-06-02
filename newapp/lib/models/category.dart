import '/utils/images_string.dart';

class Category {
  final String titre;
  final String image;
  final String? url;

  Category({required this.titre, required this.image, this.url});
}

final List<Category> categories = [
  Category(
      titre: "CONCOURS YAATAL 2023",
      image: category5,
      url: "https://www.youtube.com/watch?v=QyMGnGwMg-A&t=1s"),
  Category(
      titre: "CONCOURS YAATAL 2022",
      image: category4,
      url: "https://www.youtube.com/watch?v=abOcn6uB5N8&t=870s"),
  Category(
      titre: "CONCOURS YAATAL 2020 RECALE",
      image: category3,
      url: "https://www.youtube.com/watch?v=uswd30UbujM&t=2377s"),
  Category(
      titre: "CONCCOURS YAATAL 2020",
      image: category2,
      url: "https://www.youtube.com/watch?v=VuNamSqfVSU&t=118s"),
  Category(
      titre: "CONCOURS YAATAL 2019",
      image: category1,
      url: "https://www.youtube.com/watch?v=scRwpbkVOUc"),
];
