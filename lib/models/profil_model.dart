class ProfilModel {
  int? id_profil, id_auth, kontak;
  String? foto;
  DateTime? updatedAt, createdAt;

  ProfilModel({
    this.id_profil,
    this.id_auth,
    this.foto,
    this.kontak,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (foto != null) {
      data['foto'] = foto;
    }

    if (id_profil != null) {
      data['id_profil'] = id_profil;
    }

    if (id_auth != null) {
      data['id_auth'] = id_auth;
    }

    if (kontak != null) {
      data['kontak'] = kontak;
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
      kontak: json['kontak'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
