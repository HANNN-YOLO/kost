class KriteriaModels {
  int? id_kriteria, id_auth, bobot;
  String? kategori, atribut;
  DateTime? createdAt, updatedAt;

  KriteriaModels({
    this.id_kriteria,
    this.id_auth,
    required this.kategori,
    required this.atribut,
    required this.bobot,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id_auth': id_auth,
      'kategori': kategori,
      'atribut': atribut,
      'bobot': bobot,
    };

    if (id_kriteria != null) {
      data['id_kriteria'] = id_kriteria;
    }

    if (createdAt != null) {
      data['createdAt'] = createdAt;
    }

    if (updatedAt != null) {
      data['updatedAt'] = updatedAt!.toIso8601String();
    }

    return data;
  }

  factory KriteriaModels.fromJjson(Map<String, dynamic> json) {
    return KriteriaModels(
      id_kriteria: json['id_kriteria'],
      id_auth: json['id_auth'],
      kategori: json['kategori'],
      atribut: json['atribut'],
      bobot: json['bobot'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
