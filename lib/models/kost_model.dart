class KostModel {
  int? id_kost, id_fasilitas, notlp_kost, harga_kost, panjang, lebar, id_auth;
  String? nama_kost,
      alamat_kost,
      pemilik_kost,
      jenis_kost,
      keamanan,
      batas_jam_malam,
      jenis_pembayaran_air,
      jenis_listrik,
      gambar_kost;
  double? garis_lintang, garis_bujur;
  DateTime? createdAt, updatedAt;

  KostModel({
    this.id_kost,
    this.id_fasilitas,
    this.id_auth,
    this.nama_kost,
    this.pemilik_kost,
    this.alamat_kost,
    this.notlp_kost,
    this.harga_kost,
    this.batas_jam_malam,
    this.jenis_listrik,
    this.jenis_pembayaran_air,
    this.keamanan,
    this.jenis_kost,
    this.panjang,
    this.lebar,
    this.gambar_kost,
    this.garis_lintang,
    this.garis_bujur,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id_fasilitas': id_fasilitas,
      'id_auth': id_auth,
      'nama_kost': nama_kost,
      'pemilik_kost': pemilik_kost,
      'alamat_kost': alamat_kost,
      'notlp_kost': notlp_kost,
      'harga_kost': harga_kost,
      'batas_jam_malam': batas_jam_malam,
      'jenis_listrik': jenis_listrik,
      'jenis_pembayaran_air': jenis_pembayaran_air,
      'keamanan': keamanan,
      'jenis_kost': jenis_kost,
      'panjang': panjang,
      'lebar': lebar,
      'gambar_kost': gambar_kost,
      'garis_lintang': garis_lintang,
      'garis_bujur': garis_bujur,
    };

    if (id_kost != null) {
      data['id_kost'] = id_kost;
    }

    if (createdAt != null) {
      data['createdAt'] = createdAt;
    }

    if (updatedAt != null) {
      data['updatedAt'] = updatedAt!.toIso8601String();
    }
    return data;
  }

  factory KostModel.fromJson(Map<String, dynamic> json) {
    return KostModel(
      id_kost: json['id_kost'],
      id_fasilitas: json['id_fasilitas'],
      id_auth: json['id_auth'],
      nama_kost: json['nama_kost'],
      pemilik_kost: json['pemilik_kost'],
      alamat_kost: json['alamat_kost'],
      notlp_kost: json['notlp_kost'],
      harga_kost: json['harga_kost'],
      batas_jam_malam: json['batas_jam_malam'],
      jenis_listrik: json['jenis_listrik'],
      jenis_pembayaran_air: json['jenis_pembayaran_air'],
      keamanan: json['keamanan'],
      jenis_kost: json['jenis_kost'],
      panjang: json['panjang'],
      lebar: json['lebar'],
      gambar_kost: json['gambar_kost'],
      garis_lintang: json['garis_lintang'],
      garis_bujur: json['garis_bujur'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
