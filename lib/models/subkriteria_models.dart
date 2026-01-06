class SubkriteriaModels {
  int? id_subkriteria,
      id_kriteria,
      id_auth,
      bobot1,
      bobot2,
      bobot3,
      bobot4,
      bobot5;
  String? kategori1, kategori2, kategori3, kategori4, kategori5;
  DateTime? createdAt, updatedAt;

  SubkriteriaModels({
    this.id_subkriteria,
    required this.id_kriteria,
    required this.id_auth,
    this.kategori1,
    this.bobot1,
    this.kategori2,
    this.bobot2,
    this.kategori3,
    this.bobot3,
    this.kategori4,
    this.bobot4,
    this.kategori5,
    this.bobot5,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id_kriteria': id_kriteria,
      'id_autuh': id_auth,
    };

    if (id_subkriteria != null) {
      data['id_subkriteria'] = id_subkriteria;
    }

    if (kategori1 != null) {
      data['kategori1'] = kategori1;
    }

    if (bobot1 != null) {
      data['bobot1'] = bobot1;
    }

    if (kategori2 != null) {
      data['kategori2'] = kategori2;
    }

    if (bobot2 != null) {
      data['bobot2'] = bobot2;
    }

    if (kategori3 != null) {
      data['kategori3'] = kategori3;
    }

    if (bobot3 != null) {
      data['bobot3'] = bobot3;
    }

    if (kategori4 != null) {
      data['kategori4'] = kategori4;
    }

    if (bobot4 != null) {
      data['bobot4'] = bobot4;
    }

    if (kategori5 != null) {
      data['kategori5'] = kategori5;
    }

    if (bobot5 != null) {
      data['bobot5'] = bobot5;
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
      kategori1: json['kategori1'],
      bobot1: json['bobot1'],
      kategori2: json['kategori2'],
      bobot2: json['bobot2'],
      kategori3: json['kategori3'],
      bobot3: json['bobot3'],
      kategori4: json['kategori4'],
      bobot4: json['bobot4'],
      kategori5: json['kategori5'],
      bobot5: json['bobot5'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
