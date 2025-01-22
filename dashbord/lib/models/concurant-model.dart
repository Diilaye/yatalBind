class ConcurantModel {
  String? daara;
  String? addresse;
  String? sexe;
  String? nom;
  String? prenom;
  String? telephone;
  String? id;

  ConcurantModel(
      {this.daara,
      this.addresse,
      this.sexe,
      this.nom,
      this.prenom,
      this.telephone,
      this.id});

  ConcurantModel.fromJson(Map<String, dynamic> json) {
    daara = json['daara'];
    addresse = json['addresse'];
    sexe = json['sexe'];
    nom = json['nom'];
    prenom = json['prenom'];
    telephone = json['telephone'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['daara'] = this.daara;
    data['addresse'] = this.addresse;
    data['sexe'] = this.sexe;
    data['nom'] = this.nom;
    data['prenom'] = this.prenom;
    data['telephone'] = this.telephone;
    data['id'] = this.id;
    return data;
  }

  static List<ConcurantModel> fromList({required data}) {
    List<ConcurantModel> liste = [];
    for (var element in data) {
      liste.add(ConcurantModel.fromJson(element));
    }
    return liste;
  }
}
