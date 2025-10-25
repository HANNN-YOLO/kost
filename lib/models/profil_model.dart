class ProfilModel {
  int? id_profil, id_auth, kontak;
  String? foto, jkl;
  DateTime? tgllahir, createdAt, updatedAt;

  ProfilModel(
      {this.id_profil,
      this.id_auth,
      required this.foto,
      required this.tgllahir,
      required this.jkl,
      required this.kontak,
      this.createdAt,
      this.updatedAt});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'foto': foto,
      'tgllahir': tgllahir!.toIso8601String(),
      'jkl': jkl,
      'kontak': kontak
    };

    if (id_profil != null) {
      data['id_profil'] = id_profil;
    }

    if (id_auth != null) {
      data['id_auth'] = id_auth;
    }

    if (createdAt != null) {
      data['createdAt'] = createdAt;
    }

    if (updatedAt != null) {
      data['updatedAt'] = updatedAt!.toIso8601String();
    }

    return data;
  }

  factory ProfilModel.fromJson(Map<String, dynamic> json) {
    return ProfilModel(
      id_profil: json['id_profil'],
      id_auth: json['id_auth'],
      foto: json['foto'],
      tgllahir:
          json['tgllahir'] != null ? DateTime.parse(json['tgllahir']) : null,
      jkl: json['jkl'],
      kontak: json['kontak'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
