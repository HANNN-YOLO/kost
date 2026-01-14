class SubkriteriaModels {
  int? id_subkriteria, id_kriteria, id_auth, bobot;
  String? kategori;
  DateTime? createdAt, updatedAt;

  SubkriteriaModels({
    this.id_subkriteria,
    required this.id_kriteria,
    required this.id_auth,
    this.kategori,
    this.bobot,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id_kriteria': id_kriteria,
      'id_autuh': id_auth,
      'kategori': kategori,
      'bobot': bobot,
    };

    if (id_subkriteria != null) {
      data['id_subkriteria'] = id_subkriteria;
    }

    if (createdAt != null) {
      data['createdAt'] = createdAt;
    }

    if (updatedAt != null) {
      data['updatedAt'] = updatedAt!.toIso8601String();
    }
    return data;
  }

  factory SubkriteriaModels.fromJson(Map<String, dynamic> json) {
    return SubkriteriaModels(
      id_subkriteria: json['id_subkriteria'],
      id_kriteria: json['id_kriteria'],
      id_auth: json['id_auth'],
      kategori: json['kategori'],
      bobot: json['bobot'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
