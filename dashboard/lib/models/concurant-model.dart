// lib/models/concurant-model.dart

// ─── Sous-modèle : fichier justificatif ───────────────────────────────────────

class FichierJustificatif {
  final String? url;
  final String? nomFichier;
  final String? typeFichier;
  final int? tailleFichier;

  const FichierJustificatif({
    this.url,
    this.nomFichier,
    this.typeFichier,
    this.tailleFichier,
  });

  factory FichierJustificatif.fromJson(Map<String, dynamic> json) {
    return FichierJustificatif(
      url: json['url'] as String?,
      nomFichier: json['nomFichier'] as String?,
      typeFichier: json['typeFichier'] as String?,
      tailleFichier: json['tailleFichier'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'nomFichier': nomFichier,
        'typeFichier': typeFichier,
        'tailleFichier': tailleFichier,
      };

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Vrai si l'URL pointe vers Cloudinary
  bool get isCloudinary =>
      url != null && url!.startsWith('https://res.cloudinary.com');

  /// Vrai si le fichier est une image affichable
  bool get isImage =>
      typeFichier != null &&
      ['jpg', 'jpeg', 'png', 'webp'].contains(typeFichier!.toLowerCase());

  /// Vrai si le fichier est un PDF
  bool get isPdf => typeFichier != null && typeFichier!.toLowerCase() == 'pdf';

  /// Taille formatée : "1.2 Mo" ou "340 Ko"
  String get sizeLabel {
    if (tailleFichier == null) return '';
    if (tailleFichier! >= 1024 * 1024) {
      return '${(tailleFichier! / 1024 / 1024).toStringAsFixed(1)} Mo';
    }
    return '${(tailleFichier! / 1024).toStringAsFixed(0)} Ko';
  }
}

// ─── Sous-modèle : métadonnées Cloudinary ─────────────────────────────────────

class CloudinaryMeta {
  final String? publicId;
  final String? secureUrl;
  final String source; // 'cloudinary' | 'local'

  const CloudinaryMeta({
    this.publicId,
    this.secureUrl,
    this.source = 'local',
  });

  factory CloudinaryMeta.fromJson(Map<String, dynamic> json) {
    return CloudinaryMeta(
      publicId: json['publicId'] as String?,
      secureUrl: json['secureUrl'] as String?,
      source: json['source'] as String? ?? 'local',
    );
  }

  Map<String, dynamic> toJson() => {
        'publicId': publicId,
        'secureUrl': secureUrl,
        'source': source,
      };
}

// ─── Modèle principal ─────────────────────────────────────────────────────────

class ConcurantModel {
  // ── Champs originaux (inchangés) ──────────────────────────────────────────
  String? daara;
  String? addresse;
  String? sexe;
  String? nom;
  String? prenom;
  String? telephone;
  String? id;

  // ── Champs ajoutés ────────────────────────────────────────────────────────
  String? professeur;
  int? age;
  DateTime? dateNaissance;
  String? niveauEtudes;
  String? sourceInscription;
  FichierJustificatif? fichierJustificatif;
  CloudinaryMeta? cloudinary;
  DateTime? createdAt;
  DateTime? updatedAt;

  ConcurantModel({
    // Originaux
    this.daara,
    this.addresse,
    this.sexe,
    this.nom,
    this.prenom,
    this.telephone,
    this.id,
    // Nouveaux
    this.professeur,
    this.age,
    this.dateNaissance,
    this.niveauEtudes,
    this.sourceInscription,
    this.fichierJustificatif,
    this.cloudinary,
    this.createdAt,
    this.updatedAt,
  });

  // ─── fromJson ──────────────────────────────────────────────────────────────

  ConcurantModel.fromJson(Map<String, dynamic> json) {
    // ── Originaux — structure préservée ──────────────────────────────────────
    daara = json['daara'] as String?;
    addresse = json['addresse'] as String? // champ original
        ??
        json['adresse'] as String?; // alias renvoyé par l'API
    sexe = json['sexe'] as String?;
    nom = json['nom'] as String?;
    prenom = json['prenom'] as String?;
    telephone = json['telephone'] as String?;
    id = json['id'] as String? // toJSON transform Mongoose
        ??
        json['_id'] as String?; // fallback MongoDB brut

    // ── Nouveaux ─────────────────────────────────────────────────────────────
    professeur = json['professeur'] as String?;
    age = json['age'] as int?;
    niveauEtudes = json['niveauEtudes'] as String?;
    sourceInscription = json['sourceInscription'] as String?;

    dateNaissance = json['dateNaissance'] != null
        ? DateTime.tryParse(json['dateNaissance'].toString())
        : null;

    createdAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'].toString())
        : null;

    updatedAt = json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'].toString())
        : null;

    fichierJustificatif = json['fichierJustificatif'] != null
        ? FichierJustificatif.fromJson(
            json['fichierJustificatif'] as Map<String, dynamic>)
        : null;

    cloudinary = json['cloudinary'] != null
        ? CloudinaryMeta.fromJson(json['cloudinary'] as Map<String, dynamic>)
        : null;
  }

  // ─── toJson ────────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    // Originaux — toujours inclus (comportement original conservé)
    data['daara'] = daara;
    data['addresse'] = addresse;
    data['sexe'] = sexe;
    data['nom'] = nom;
    data['prenom'] = prenom;
    data['telephone'] = telephone;
    data['id'] = id;

    // Nouveaux — omis si null pour alléger les payloads
    if (professeur != null) data['professeur'] = professeur;
    if (age != null) data['age'] = age;
    if (niveauEtudes != null) data['niveauEtudes'] = niveauEtudes;
    if (sourceInscription != null)
      data['sourceInscription'] = sourceInscription;

    if (dateNaissance != null)
      data['dateNaissance'] = dateNaissance!.toIso8601String();
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String();

    if (fichierJustificatif != null)
      data['fichierJustificatif'] = fichierJustificatif!.toJson();
    if (cloudinary != null) data['cloudinary'] = cloudinary!.toJson();

    return data;
  }

  // ─── fromList — inchangé ───────────────────────────────────────────────────

  static List<ConcurantModel> fromList({required dynamic data}) {
    final List<ConcurantModel> liste = [];
    for (final element in data) {
      liste.add(ConcurantModel.fromJson(element));
    }
    return liste;
  }

  // ─── Getters utilitaires ───────────────────────────────────────────────────

  /// Nom complet en majuscules — ex : "AMADOU DIALLO"
  String get fullName => '${prenom ?? ''} ${nom ?? ''}'.trim().toUpperCase();

  /// Initiales pour avatar — ex : "AD"
  String get initials {
    final p = (prenom ?? '').isNotEmpty ? prenom![0].toUpperCase() : '';
    final n = (nom ?? '').isNotEmpty ? nom![0].toUpperCase() : '';
    return '$p$n';
  }

  // ── URL brute stockée en base (peut être relative ou absolue) ────────────────

  /// URL brute du fichier : priorité Cloudinary secureUrl → fichierJustificatif.url
  /// Peut être un chemin relatif (/justificatifs/xxx.pdf) ou une URL complète.
  String? get fichierUrlRaw =>
      cloudinary?.secureUrl ?? fichierJustificatif?.url;

  /// Vrai si le fichier est hébergé sur Cloudinary
  bool get isFichierCloudinary =>
      cloudinary?.source == 'cloudinary' && cloudinary?.secureUrl != null;

  // ── Getters URL résolus ───────────────────────────────────────────────────

  /// URL absolue du fichier, prête à l'emploi.
  ///
  /// Cas 1 — URL Cloudinary complète  → retournée telle quelle
  ///   "https://res.cloudinary.com/.../upload/fichier.pdf"
  ///
  /// Cas 2 — Chemin relatif en base   → préfixé avec ApiConfig.assetBaseUrl
  ///   "/justificatifs/fichier.pdf"
  ///   → "https://api.yaatalmbindumalxuran.sn/justificatifs/fichier.pdf"
  String? get fichierUrl {
    final raw = fichierUrlRaw;
    if (raw == null || raw.trim().isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;

    // Chemin relatif : reconstruire l'URL absolue
    const base = 'https://api.yaatalmbindumalxuran.sn';
    final path = raw.startsWith('/') ? raw : '/$raw';
    return '$base$path';
  }

  /// URL de téléchargement forcé.
  ///
  /// • Cloudinary  → injecte fl_attachment pour forcer le téléchargement
  ///   ".../upload/fl_attachment/fichier.pdf"
  /// • Serveur local → ajoute ?download=1 (nécessite header côté API)
  String? get fichierDownloadUrl {
    final url = fichierUrl;
    if (url == null) return null;

    if (url.contains('cloudinary.com') && url.contains('/upload/')) {
      return url.replaceFirst('/upload/', '/upload/fl_attachment/');
    }

    // Serveur local
    return url.contains('?') ? '$url&download=1' : '$url?download=1';
  }
}
