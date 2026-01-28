class TujuanModels {
  int? id_tujuan;
  String? namatujuan;
  double? garislintang, garisbujur;
  DateTime? createdAt, updatedAt;

  TujuanModels({
    this.id_tujuan,
    required this.namatujuan,
    required this.garislintang,
    required this.garisbujur,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'namatujuan': namatujuan,
      'garislintang': garislintang,
      'garisbujur': garisbujur,
    };

    if (id_tujuan != null) {
      data['id_tujuan'] = id_tujuan;
    }

    if (createdAt != null) {
      data['createdAt'] = createdAt;
    }

    if (updatedAt != null) {
      data['updatedAt'] = updatedAt!.toIso8601String();
    }
    return data;
  }

  factory TujuanModels.fromJson(Map<String, dynamic> json) {
    return TujuanModels(
      id_tujuan: json['id_tujuan'],
      namatujuan: json['namatujuan'],
      garislintang: json['garislintang'],
      garisbujur: json['garisbujur'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
