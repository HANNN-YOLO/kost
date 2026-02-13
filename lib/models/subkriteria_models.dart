class SubkriteriaModels {
  int? id_subkriteria, id_kriteria, bobot;
  String? kategori;
  num? nilai_min, nilai_max;
  String? min_operator, max_operator;
  DateTime? createdAt, updatedAt;

  SubkriteriaModels({
    this.id_subkriteria,
    required this.id_kriteria,
    this.kategori,
    this.bobot,
    this.nilai_min,
    this.nilai_max,
    this.min_operator,
    this.max_operator,
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
      'kategori': kategori,
      'bobot': bobot,
    };

    if (nilai_min != null) {
      data['nilai_min'] = nilai_min;
    }
    if (nilai_max != null) {
      data['nilai_max'] = nilai_max;
    }

    if (min_operator != null) {
      data['min_operator'] = min_operator;
    }
    if (max_operator != null) {
      data['max_operator'] = max_operator;
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
      kategori: json['kategori'],
      bobot: json['bobot'],
      nilai_min: _toNum(json['nilai_min']),
      nilai_max: _toNum(json['nilai_max']),
      min_operator: json['min_operator'],
      max_operator: json['max_operator'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
