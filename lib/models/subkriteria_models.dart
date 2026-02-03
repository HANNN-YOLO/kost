class SubkriteriaModels {
  int? id_subkriteria, id_kriteria, id_auth, bobot;
  String? kategori;
  num? nilai_min, nilai_max;
  DateTime? createdAt, updatedAt;

  SubkriteriaModels({
    this.id_subkriteria,
    required this.id_kriteria,
    required this.id_auth,
    this.kategori,
    this.bobot,
    this.nilai_min,
    this.nilai_max,
    this.createdAt,
    this.updatedAt,
  });

  static num? _toNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    return num.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id_kriteria': id_kriteria,
      'id_auth': id_auth,
      'kategori': kategori,
      'bobot': bobot,
    };

    if (nilai_min != null) {
      data['nilai_min'] = nilai_min;
    }
    if (nilai_max != null) {
      data['nilai_max'] = nilai_max;
    }

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
      nilai_min: _toNum(json['nilai_min']),
      nilai_max: _toNum(json['nilai_max']),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
