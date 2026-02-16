class ProfilModel {
  int? id_profil, id_auth;
  String? kontak;
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
    // Handle kontak as both String and number (for backward compatibility)
    String? kontakValue;
    if (json['kontak'] != null) {
      if (json['kontak'] is String) {
        kontakValue = json['kontak'] as String;
      } else if (json['kontak'] is num) {
        // NOTE: Jika kolom database bertipe numeric, leading zero memang sudah hilang
        // sebelum sampai ke aplikasi. Di sisi aplikasi, kita pastikan tidak ada
        // konversi tambahan yang mengubah string (mis. toInt()).
        final num kontakNum = json['kontak'] as num;
        if (kontakNum.isFinite && kontakNum % 1 == 0) {
          kontakValue = kontakNum.toStringAsFixed(0);
        } else {
          kontakValue = kontakNum.toString();
        }
      }
    }

    return ProfilModel(
      id_profil: json['id_profil'],
      id_auth: json['id_auth'],
      foto: json['foto'],
      kontak: kontakValue,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
