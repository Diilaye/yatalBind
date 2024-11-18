import 'package:app/utils/images_string.dart';

class ConcoursList {
  final String titre;
  final String image;
  final String url;
  final String type;

  ConcoursList({
    required this.titre,
    required this.image,
    required this.url,
    required this.type
  });
}
final List<ConcoursList> concourslist = [
  ConcoursList(titre: "Liste des candidats", image: concours1, type: 'pdf', url: ''),
  ConcoursList(titre: "Sciences de la caligraphie", image: concours2, type: 'youtube', url:''),
  ConcoursList(titre: "Mini Livret", image: concours3, type: 'pdf',url:'assets/pdf/mini_livret_2022.pdf'),
  ConcoursList(titre: "Tournée Régionale", image: concours4, type: 'youtube',url:''),
];
