import 'package:app/utils/images_string.dart';

class ConcoursList {
  final String titre;
  final String image;

  ConcoursList({
    required this.titre,
    required this.image,
  });
}
final List<ConcoursList> concourslist = [
  ConcoursList(titre: "Liste des candidats", image: concours1),
  ConcoursList(titre: "Sciences de la caligraphie", image: concours2),
  ConcoursList(titre: "Mini Livret", image: concours3),
  ConcoursList(titre: "Tournée Régionale", image: concours4),
];
