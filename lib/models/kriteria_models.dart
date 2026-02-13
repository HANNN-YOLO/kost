class KriteriaModels {
  int? id_kriteria, bobot, ranking;
  double? bobot_decimal;
  String? kategori, atribut;
  DateTime? createdAt, updatedAt;

  KriteriaModels({
    this.id_kriteria,
    required this.kategori,
    required this.atribut,
    required this.bobot,
    this.ranking,
    this.bobot_decimal,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'kategori': kategori,
      'atribut': atribut,
      // 'bobot': bobot,
      'bobot_decimal': bobot_decimal,
    };

    // Tambah ranking jika ada
    if (ranking != null) {
      data['ranking'] = ranking;
    }

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
      kategori: json['kategori'],
      atribut: json['atribut'],
      bobot: json['bobot'],
      ranking: json['ranking'],
      bobot_decimal: json['bobot_decimal'] != null
          ? (json['bobot_decimal'] as num).toDouble()
          : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
