/// ============================================
/// SIMPLE ADDITIVE WEIGHTING (SAW) - Metode Perangkingan
/// ============================================
///
/// SAW adalah metode penjumlahan terbobot untuk menentukan
/// alternatif terbaik berdasarkan kriteria yang telah dinormalisasi.
///
/// LANGKAH-LANGKAH SAW:
/// 1. Membuat Matriks Keputusan (X)
/// 2. Normalisasi Matriks (R)
///    - Benefit: r_ij = x_ij / max(x_j)
///    - Cost:    r_ij = min(x_j) / x_ij
/// 3. Menghitung Nilai Preferensi (V)
///    - V_i = Σ(w_j * r_ij)
/// 4. Perangkingan berdasarkan nilai V (tertinggi = terbaik)

import 'dart:convert';
import 'dart:math' as math;
import '../models/kost_model.dart';
import '../models/fasilitas_model.dart';
import '../models/kriteria_models.dart';
import '../models/subkriteria_models.dart';

const String _kategoriMetaDelimiter = '||__META__||';

class _RangeOps {
  final bool minInclusive;
  final bool maxInclusive;

  const _RangeOps({required this.minInclusive, required this.maxInclusive});
}

/// Model untuk menyimpan hasil SAW
class HasilSAW {
  final List<DataAlternatif> dataAlternatif;
  final List<List<double>> matriksKeputusan;
  final List<List<double>> matriksNormalisasi;
  final List<List<double>> matriksTerbobot;
  final List<HasilPreferensi> hasilPreferensi;
  final List<HasilRanking> hasilRanking;
  final List<KostTerskipSAW> kostTerskip;
  final List<String> namaKriteria;
  final List<double> bobotKriteria;
  final List<String> atributKriteria;

  HasilSAW({
    required this.dataAlternatif,
    required this.matriksKeputusan,
    required this.matriksNormalisasi,
    required this.matriksTerbobot,
    required this.hasilPreferensi,
    required this.hasilRanking,
    this.kostTerskip = const [],
    required this.namaKriteria,
    required this.bobotKriteria,
    required this.atributKriteria,
  });
}

/// Kost yang tidak diproses dalam SAW karena ada kriteria yang tidak cocok
/// dengan subkriteria (nilai konversi = 0).
class KostTerskipSAW {
  final int idKost;
  final String namaKost;
  final List<String> alasan;

  KostTerskipSAW({
    required this.idKost,
    required this.namaKost,
    required this.alasan,
  });
}

class _DataAlternatifBuildResult {
  final List<DataAlternatif> alternatif;
  final List<KostTerskipSAW> terskip;

  _DataAlternatifBuildResult({
    required this.alternatif,
    required this.terskip,
  });
}

/// Model untuk data alternatif (kost)
class DataAlternatif {
  final String kode; // A1, A2, A3, ...
  final int idKost;
  final String namaKost;
  final Map<String, dynamic> nilaiKriteria; // {nama_kriteria: nilai_konversi}
  final Map<String, dynamic>
      nilaiMentah; // {nama_kriteria: nilai_asli} untuk tampilan

  DataAlternatif({
    required this.kode,
    required this.idKost,
    required this.namaKost,
    required this.nilaiKriteria,
    required this.nilaiMentah,
  });
}

/// Model untuk hasil preferensi
class HasilPreferensi {
  final String kode;
  final String namaKost;
  final List<double> nilaiPerKriteria; // w_j * r_ij per kriteria
  final double totalPreferensi;

  HasilPreferensi({
    required this.kode,
    required this.namaKost,
    required this.nilaiPerKriteria,
    required this.totalPreferensi,
  });
}

/// Model untuk hasil ranking
class HasilRanking {
  final int peringkat;
  final String kode;
  final int idKost;
  final String namaKost;
  final double skor;

  HasilRanking({
    required this.peringkat,
    required this.kode,
    required this.idKost,
    required this.namaKost,
    required this.skor,
  });
}

class SimpleAdditiveWeighting {
  /// ============================================
  /// RUMUS HAVERSINE - Menghitung Jarak 2 Titik Koordinat
  /// ============================================
  /// Rumus: a = sin²(Δlat/2) + cos(lat1) × cos(lat2) × sin²(Δlng/2)
  ///        c = 2 × atan2(√a, √(1-a))
  ///        d = R × c (dimana R = 6371 km)

  static double _deg2rad(double deg) => deg * (math.pi / 180.0);

  /// Menghitung jarak antara 2 titik koordinat dalam kilometer
  static double hitungJarakKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double R = 6371.0; // Radius bumi dalam kilometer

    final double dLat = _deg2rad(lat2 - lat1);
    final double dLng = _deg2rad(lng2 - lng1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double jarak = R * c;

    print(
        "📍 Jarak: ($lat1, $lng1) → ($lat2, $lng2) = ${jarak.toStringAsFixed(2)} km");
    return jarak;
  }

  /// Menjalankan perhitungan SAW lengkap
  ///
  /// [listKost] = Daftar kost sebagai alternatif
  /// [listFasilitas] = Daftar fasilitas kost
  /// [listKriteria] = Daftar kriteria dengan bobot dan atribut
  /// [listSubkriteria] = Daftar subkriteria untuk konversi nilai
  /// [userLat] = Latitude lokasi user (opsional untuk kriteria jarak)
  /// [userLng] = Longitude lokasi user (opsional untuk kriteria jarak)
  ///
  /// Return: HasilSAW berisi semua data perhitungan
  static HasilSAW? hitungSAW({
    required List<KostModel> listKost,
    required List<FasilitasModel> listFasilitas,
    required List<KriteriaModels> listKriteria,
    required List<SubkriteriaModels> listSubkriteria,
    double? userLat,
    double? userLng,
    Map<int, double>?
        jarakKostMap, // Map id_kost -> jarak dalam km (dari road distance)
  }) {
    print("\n" + "=" * 70);
    print("🚀 MEMULAI PERHITUNGAN SIMPLE ADDITIVE WEIGHTING (SAW)");
    print("=" * 70);

    // Tampilkan ringkasan rumus SAW
    print(
        "\n╔════════════════════════════════════════════════════════════════════╗");
    print(
        "║         RINGKASAN RUMUS SAW (Simple Additive Weighting)            ║");
    print(
        "╠════════════════════════════════════════════════════════════════════╣");
    print(
        "║                                                                    ║");
    print(
        "║  LANGKAH 1: Membuat Matriks Keputusan (X)                          ║");
    print(
        "║             Xᵢⱼ = nilai alternatif i pada kriteria j               ║");
    print(
        "║                                                                    ║");
    print(
        "║  LANGKAH 2: Normalisasi Matriks (R)                                ║");
    print(
        "║             • Benefit: rᵢⱼ = xᵢⱼ / max(xⱼ)                         ║");
    print(
        "║             • Cost:    rᵢⱼ = min(xⱼ) / xᵢⱼ                         ║");
    print(
        "║                                                                    ║");
    print(
        "║  LANGKAH 3: Matriks Terbobot (Y)                                   ║");
    print(
        "║             yᵢⱼ = wⱼ × rᵢⱼ                                         ║");
    print(
        "║                                                                    ║");
    print(
        "║  LANGKAH 4: Nilai Preferensi (V)                                   ║");
    print(
        "║             Vᵢ = Σⱼ₌₁ⁿ (wⱼ × rᵢⱼ)                                  ║");
    print(
        "║                                                                    ║");
    print(
        "║  LANGKAH 5: Perangkingan                                           ║");
    print(
        "║             Alternatif terbaik = Vᵢ maksimum                       ║");
    print(
        "║                                                                    ║");
    print(
        "╚════════════════════════════════════════════════════════════════════╝\n");

    if (listKost.isEmpty) {
      print("❌ Error: Tidak ada data kost!");
      return null;
    }

    if (listKriteria.isEmpty) {
      print("❌ Error: Tidak ada data kriteria!");
      return null;
    }

    // Cek apakah ada kriteria jarak dan lokasi user tersedia
    bool adaKriteriaJarak = listKriteria.any((k) {
      final kat = k.kategori?.toLowerCase() ?? '';
      return kat.contains('jarak');
    });

    if (adaKriteriaJarak && (userLat == null || userLng == null)) {
      print("⚠️ Warning: Ada kriteria jarak tapi lokasi user tidak tersedia!");
      print("   Jarak akan dihitung sebagai 0 km");
    }

    if (userLat != null && userLng != null) {
      print("📍 Lokasi User: ($userLat, $userLng)");
    }

    // SORTING: Urutkan kriteria berdasarkan ranking dari database
    // Ranking sudah diurutkan dari service, tapi pastikan urutannya benar
    final sortedKriteria = List<KriteriaModels>.from(listKriteria);
    sortedKriteria
        .sort((a, b) => (a.ranking ?? 999).compareTo(b.ranking ?? 999));

    print("\n📊 KRITERIA TERURUT BERDASARKAN RANKING:");
    print("-" * 50);
    for (int i = 0; i < sortedKriteria.length; i++) {
      final k = sortedKriteria[i];
      print(
          "C${i + 1} = ${k.kategori} (${k.atribut}) - Ranking: ${k.ranking} - Bobot: ${k.bobot_decimal?.toStringAsFixed(4)}");
    }

    // STEP 1: Buat Data Alternatif
    print("\n📋 STEP 1: Membuat Data Alternatif");
    print("-" * 50);
    final build = _buatDataAlternatif(
      listKost,
      listFasilitas,
      sortedKriteria, // Gunakan kriteria yang sudah diurutkan
      listSubkriteria,
      userLat,
      userLng,
      jarakKostMap, // Tambahkan parameter jarak dari road distance
    );

    final dataAlternatif = build.alternatif;
    final kostTerskip = build.terskip;

    // Ambil nama kriteria dan BOBOT DECIMAL dari database
    final namaKriteria = sortedKriteria.map((k) => k.kategori ?? '').toList();
    // PENTING: Gunakan bobot_decimal dari database, bukan hasil perhitungan ROC
    final bobotKriteria =
        sortedKriteria.map((k) => k.bobot_decimal ?? 0.0).toList();
    final atributKriteria = sortedKriteria.map((k) => k.atribut ?? '').toList();

    print("📊 Jumlah Alternatif: ${dataAlternatif.length}");
    if (kostTerskip.isNotEmpty) {
      print(
          "⚠️ Ada ${kostTerskip.length} kost yang tidak diproses karena tidak cocok dengan subkriteria.");
      for (final k in kostTerskip) {
        print("   - ${k.namaKost} (id=${k.idKost}): ${k.alasan.join(' | ')}");
      }
    }

    if (dataAlternatif.isEmpty) {
      // Tidak bisa lanjut membuat matriks, tapi tetap kembalikan info kostTerskip
      return HasilSAW(
        dataAlternatif: const [],
        matriksKeputusan: const [],
        matriksNormalisasi: const [],
        matriksTerbobot: const [],
        hasilPreferensi: const [],
        hasilRanking: const [],
        kostTerskip: kostTerskip,
        namaKriteria: namaKriteria,
        bobotKriteria: bobotKriteria,
        atributKriteria: atributKriteria,
      );
    }
    print("📊 Jumlah Kriteria: ${namaKriteria.length}");
    print("📊 Kriteria: $namaKriteria");
    print("📊 Bobot: $bobotKriteria");
    print("📊 Atribut: $atributKriteria");

    // STEP 2: Buat Matriks Keputusan
    print("\n📋 STEP 2: Membuat Matriks Keputusan");
    print("-" * 50);
    final matriksKeputusan =
        _buatMatriksKeputusan(dataAlternatif, namaKriteria);

    _printMatriks(
        "Matriks Keputusan", matriksKeputusan, dataAlternatif, namaKriteria);

    // STEP 3: Normalisasi Matriks
    print("\n📋 STEP 3: Normalisasi Matriks");
    print("-" * 50);
    final matriksNormalisasi = _normalisasiMatriks(
      matriksKeputusan,
      atributKriteria,
      namaKriteria,
    );

    _printMatriks("Matriks Normalisasi", matriksNormalisasi, dataAlternatif,
        namaKriteria);

    // STEP 4: Hitung Matriks Terbobot (R × W)
    print("\n📋 STEP 4: Menghitung Matriks Terbobot (R × W)");
    print("-" * 50);
    final matriksTerbobot = _hitungMatriksTerbobot(
      matriksNormalisasi,
      bobotKriteria,
      namaKriteria,
    );

    _printMatriks(
        "Matriks Terbobot", matriksTerbobot, dataAlternatif, namaKriteria);

    // STEP 5: Hitung Nilai Preferensi
    print("\n📋 STEP 5: Menghitung Nilai Preferensi");
    print("-" * 50);
    final hasilPreferensi = _hitungNilaiPreferensi(
      dataAlternatif,
      matriksTerbobot,
      namaKriteria,
    );

    for (var hasil in hasilPreferensi) {
      print(
          "${hasil.kode} (${hasil.namaKost}): V = ${hasil.totalPreferensi.toStringAsFixed(4)}");
    }

    // STEP 6: Perangkingan
    print("\n📋 STEP 6: Perangkingan");
    print("-" * 50);
    final hasilRanking = _buatPerangkingan(hasilPreferensi, dataAlternatif);

    print("\n🏆 HASIL PERANGKINGAN:");
    for (var ranking in hasilRanking) {
      print(
          "Peringkat #${ranking.peringkat}: ${ranking.namaKost} (${ranking.kode}) - Skor: ${ranking.skor.toStringAsFixed(4)}");
    }

    print("\n" + "=" * 60);
    print("✅ PERHITUNGAN SAW SELESAI!");
    print("=" * 60 + "\n");

    return HasilSAW(
      dataAlternatif: dataAlternatif,
      matriksKeputusan: matriksKeputusan,
      matriksNormalisasi: matriksNormalisasi,
      matriksTerbobot: matriksTerbobot,
      hasilPreferensi: hasilPreferensi,
      hasilRanking: hasilRanking,
      kostTerskip: kostTerskip,
      namaKriteria: namaKriteria,
      bobotKriteria: bobotKriteria,
      atributKriteria: atributKriteria,
    );
  }

  /// STEP 1: Membuat data alternatif dengan konversi nilai
  /// ============================================
  /// ALUR DATA:
  /// 1. Ambil data kost (sudah terurut berdasarkan id_kost dari service)
  /// 2. Untuk setiap kost, buat kode alternatif A1, A2, A3, dst
  /// 3. Untuk setiap kriteria (sudah terurut by ranking):
  ///    - Ambil nilai asli dari kost/fasilitas
  ///    - Konversi ke bobot subkriteria
  /// 4. Simpan dalam DataAlternatif
  /// ============================================
  static _DataAlternatifBuildResult _buatDataAlternatif(
    List<KostModel> listKost,
    List<FasilitasModel> listFasilitas,
    List<KriteriaModels> listKriteria,
    List<SubkriteriaModels> listSubkriteria,
    double? userLat,
    double? userLng,
    Map<int, double>?
        jarakKostMap, // Map id_kost -> jarak dalam km (dari road distance)
  ) {
    List<DataAlternatif> hasil = [];
    List<KostTerskipSAW> terskip = [];

    // SORTING: Urutkan kost berdasarkan id_kost dari terkecil ke terbesar
    final sortedKost = List<KostModel>.from(listKost);
    sortedKost.sort((a, b) => (a.id_kost ?? 0).compareTo(b.id_kost ?? 0));

    print("\n📋 MEMBUAT DATA ALTERNATIF:");
    print("   Total Kost: ${sortedKost.length}");
    print("   Total Fasilitas: ${listFasilitas.length}");
    print("   Total Kriteria: ${listKriteria.length}");
    print("   Total Subkriteria: ${listSubkriteria.length}");
    print("   📌 Kost diurutkan berdasarkan id_kost (ASC)");
    print("-" * 60);

    // Debug: tampilkan semua fasilitas yang tersedia
    print("\n📦 DAFTAR FASILITAS TERSEDIA:");
    for (var f in listFasilitas) {
      print("   id_fasilitas=${f.id_fasilitas}, id_auth=${f.id_auth}");
    }

    for (int i = 0; i < sortedKost.length; i++) {
      final kost = sortedKost[i];
      final kode = "A${hasil.length + 1}";

      print(
          "\n🏠 $kode: ${kost.nama_kost} (id_kost=${kost.id_kost}, id_fasilitas=${kost.id_fasilitas})");

      // Cari fasilitas yang sesuai berdasarkan id_fasilitas dari kost
      FasilitasModel fasilitas;
      try {
        fasilitas = listFasilitas.firstWhere(
          (f) => f.id_fasilitas == kost.id_fasilitas,
        );
        print(
            "   ✅ Fasilitas ditemukan: id_fasilitas=${fasilitas.id_fasilitas}");
      } catch (e) {
        print(
            "   ⚠️ Fasilitas TIDAK ditemukan untuk id_fasilitas=${kost.id_fasilitas}");
        fasilitas = FasilitasModel();
      }

      // Buat map nilai kriteria (konversi) dan nilai mentah
      Map<String, dynamic> nilaiKriteria = {};
      Map<String, dynamic> nilaiMentah = {};
      final List<String> alasanTerskip = [];

      for (var kriteria in listKriteria) {
        final kategori = kriteria.kategori?.toLowerCase() ?? '';
        final idKriteria = kriteria.id_kriteria ?? 0;
        dynamic nilaiAsli;
        double nilaiNumerik;

        final namaKritAsli = kriteria.kategori ?? 'Kriteria';
        final subCount =
            listSubkriteria.where((s) => s.id_kriteria == idKriteria).length;

        // Cek apakah kriteria adalah jarak
        if (kategori.contains('jarak')) {
          print("      🎯 KRITERIA JARAK DETECTED! kategori='$kategori'");

          // Prioritas 1: Gunakan jarakKostMap (road distance) jika tersedia
          if (jarakKostMap != null && jarakKostMap.containsKey(kost.id_kost)) {
            nilaiAsli = jarakKostMap[kost.id_kost]!;
            print(
                "      📍 Menggunakan ROAD DISTANCE dari jarakKostMap: ${nilaiAsli.toStringAsFixed(2)} km");

            // Konversi jarak ke nilai subkriteria berdasarkan range
            nilaiNumerik = _konversiJarakKeSubkriteria(
              nilaiAsli,
              idKriteria,
              listSubkriteria,
            );
          }
          // Prioritas 2: Hitung jarak menggunakan Haversine sebagai fallback
          else if (userLat != null &&
              userLng != null &&
              kost.garis_lintang != null &&
              kost.garis_bujur != null) {
            print(
                "      📍 Menggunakan HAVERSINE: user=($userLat, $userLng), kost=(${kost.garis_lintang}, ${kost.garis_bujur})");
            nilaiAsli = hitungJarakKm(
              userLat,
              userLng,
              kost.garis_lintang!,
              kost.garis_bujur!,
            );

            // Konversi jarak ke nilai subkriteria berdasarkan range
            nilaiNumerik = _konversiJarakKeSubkriteria(
              nilaiAsli,
              idKriteria,
              listSubkriteria,
            );
          } else {
            print(
                "      ⚠️ Tidak ada data jarak! jarakKostMap=${jarakKostMap != null}, userLat=$userLat, userLng=$userLng");
            nilaiAsli = null;
            nilaiNumerik = 0.0;
            alasanTerskip.add(
              '$namaKritAsli: lokasi/koordinat tidak lengkap untuk menghitung jarak.',
            );
          }
        } else {
          nilaiAsli = _ambilNilaiKriteria(kost, fasilitas, kategori);

          // Konversi ke nilai numerik menggunakan subkriteria
          nilaiNumerik = _konversiKeNumerik(
            nilaiAsli,
            idKriteria,
            listSubkriteria,
            kategori,
          );
        }

        nilaiKriteria[kriteria.kategori ?? ''] = nilaiNumerik;

        // Jika nilaiNumerik 0, berarti tidak ada subkriteria yang cocok / belum ada subkriteria
        if (nilaiNumerik <= 0) {
          if (subCount == 0) {
            alasanTerskip
                .add('$namaKritAsli: belum ada subkriteria untuk menilai.');
          } else if (kategori.contains('jarak') && nilaiAsli is num) {
            alasanTerskip.add(
              '$namaKritAsli: nilai "${(nilaiAsli as num).toDouble().toStringAsFixed(2)} km" tidak cocok dengan subkriteria.',
            );
          } else if (!kategori.contains('jarak')) {
            final nilaiDisplay =
                (nilaiAsli == null || nilaiAsli.toString().isEmpty)
                    ? '-'
                    : nilaiAsli.toString();
            alasanTerskip.add(
                '$namaKritAsli: nilai "$nilaiDisplay" tidak cocok dengan subkriteria.');
          }
        }

        // Simpan nilai mentah untuk tampilan
        // Format khusus untuk beberapa kriteria
        if (kategori.contains('biaya') || kategori.contains('harga')) {
          // Tampilkan harga yang SUDAH DIKONVERSI ke per-BULAN
          // Jika periode = Tahun, harga dibagi 12
          // Jika periode = Bulan, gunakan harga langsung
          final hargaAsliDb = kost.harga_kost ?? 0;
          final periodeDb = (kost.per ?? 'bulan').toLowerCase();
          int hargaPerBulan;
          if (periodeDb.contains('tahun')) {
            hargaPerBulan = (hargaAsliDb / 12).round();
          } else {
            hargaPerBulan = hargaAsliDb;
          }
          nilaiMentah[kriteria.kategori ?? ''] =
              'Rp ${_formatCurrency(hargaPerBulan)}';
        } else if (kategori.contains('jarak')) {
          if (nilaiAsli is num) {
            nilaiMentah[kriteria.kategori ?? ''] =
                '${(nilaiAsli as num).toDouble().toStringAsFixed(2)} km';
          } else {
            nilaiMentah[kriteria.kategori ?? ''] = '-';
          }
        } else if (kategori.contains('luas')) {
          nilaiMentah[kriteria.kategori ?? ''] =
              '${kost.panjang ?? 0}x${kost.lebar ?? 0} m²';
        } else if (kategori.contains('fasilitas')) {
          // VERSI BARU: Ambil daftar fasilitas dari field kost.fasilitas (text)
          nilaiMentah[kriteria.kategori ?? ''] =
              _getListFasilitasFromKost(kost);
        } else {
          nilaiMentah[kriteria.kategori ?? ''] = nilaiAsli?.toString() ?? '-';
        }

        print(
            "   C${kriteria.ranking}: ${kriteria.kategori} = $nilaiAsli → Bobot: $nilaiNumerik");
      }

      // Jika ada kriteria yang tidak cocok, kost tidak diproses dalam SAW.
      if (alasanTerskip.isNotEmpty) {
        terskip.add(
          KostTerskipSAW(
            idKost: kost.id_kost ?? 0,
            namaKost: kost.nama_kost ?? 'Tidak diketahui',
            alasan: alasanTerskip,
          ),
        );
        print(
            '   ⛔ Kost dilewati dari SAW karena: ${alasanTerskip.join(' | ')}');
        continue;
      }

      hasil.add(
        DataAlternatif(
          kode: kode,
          idKost: kost.id_kost ?? 0,
          namaKost: kost.nama_kost ?? 'Tidak diketahui',
          nilaiKriteria: nilaiKriteria,
          nilaiMentah: nilaiMentah,
        ),
      );
    }

    return _DataAlternatifBuildResult(
      alternatif: hasil,
      terskip: terskip,
    );
  }

  /// Mengambil nilai kriteria dari model kost/fasilitas
  /// ============================================
  /// MAPPING KRITERIA DATABASE KE DATA KOST:
  /// - Biaya → harga_kost (Cost)
  /// - Fasilitas → jumlah fasilitas true (Benefit)
  /// - Luas Kamar → panjang × lebar (Benefit)
  /// - Jarak → dihitung dengan Haversine (Benefit)
  /// - Keamanan → keamanan (Benefit)
  /// - Batas Jam Malam → batas_jam_malam (Cost)
  /// - Jenis Kost → jenis_kost (Benefit)
  /// - Jenis Listrik → jenis_listrik (Benefit)
  /// - Jenis Pembayaran Air → jenis_pembayaran_air (Benefit)
  /// ============================================
  static dynamic _ambilNilaiKriteria(
    KostModel kost,
    FasilitasModel fasilitas,
    String kategori,
  ) {
    // Mapping kategori kriteria ke field model
    // PENTING: kategori sudah dalam lowercase dari pemanggil

    // ========== C1: BIAYA (Cost) ==========
    // PENTING: Normalisasi harga ke per-BULAN untuk konsistensi perhitungan SAW
    // Jika field "per" = "Tahun", maka harga dibagi 12
    // Jika field "per" = "Bulan" atau kosong, gunakan harga langsung
    if (kategori.contains('biaya') ||
        kategori.contains('harga') ||
        kategori == 'harga_kost') {
      final hargaAsli = kost.harga_kost ?? 0;
      final periodePembayaran = (kost.per ?? 'Bulan').toLowerCase();

      int hargaPerBulan;
      if (periodePembayaran.contains('tahun')) {
        // Jika harga per tahun, konversi ke per bulan
        hargaPerBulan = (hargaAsli / 12).round();
        print(
            "    📌 Biaya: Rp $hargaAsli/$periodePembayaran → Rp $hargaPerBulan/bulan (dibagi 12)");
      } else {
        // Jika harga per bulan, gunakan langsung
        hargaPerBulan = hargaAsli;
        print("    📌 Biaya: Rp $hargaAsli/$periodePembayaran");
      }
      return hargaPerBulan;
    }

    // ========== C2: FASILITAS (Benefit) ==========
    // VERSI BARU: Menggunakan field 'fasilitas' di tabel kost (text list)
    // Menghitung jumlah item dalam list fasilitas
    if (kategori.contains('fasilitas')) {
      final fasilitasText = kost.fasilitas;

      // Jika fasilitas null, tandai sebagai tidak terpublish
      if (fasilitasText == null || fasilitasText.trim().isEmpty) {
        print(
            "    📌 Fasilitas: TIDAK TERPUBLISH (field fasilitas kosong/null)");
        return 0; // Return 0 untuk menandakan tidak ada fasilitas
      }

      // Parse string fasilitas (comma-separated list)
      final List<String> fasilitasList = fasilitasText
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final int jumlahFasilitas = fasilitasList.length;

      print(
          "    📌 Fasilitas (dari field kost.fasilitas): $jumlahFasilitas item");
      print("       Detail: ${fasilitasList.join(', ')}");
      return jumlahFasilitas;
    }

    // ========== VERSI LAMA (DEPRECATED): Menggunakan id_fasilitas ==========
    // Hitung jumlah fasilitas yang tersedia (true) dari tabel fasilitas
    // if (kategori.contains('fasilitas')) {
    //   int jumlahFasilitas = 0;
    //   List<String> fasilitasTersedia = [];
    //
    //   if (fasilitas.tempat_tidur) {
    //     jumlahFasilitas++;
    //     fasilitasTersedia.add('tempat_tidur');
    //   }
    //   if (fasilitas.kamar_mandi_dalam) {
    //     jumlahFasilitas++;
    //     fasilitasTersedia.add('kamar_mandi_dalam');
    //   }
    //   if (fasilitas.meja) {
    //     jumlahFasilitas++;
    //     fasilitasTersedia.add('meja');
    //   }
    //   if (fasilitas.tempat_parkir) {
    //     jumlahFasilitas++;
    //     fasilitasTersedia.add('tempat_parkir');
    //   }
    //   if (fasilitas.lemari) {
    //     jumlahFasilitas++;
    //     fasilitasTersedia.add('lemari');
    //   }
    //   if (fasilitas.ac) {
    //     jumlahFasilitas++;
    //     fasilitasTersedia.add('ac');
    //   }
    //   if (fasilitas.tv) {
    //     jumlahFasilitas++;
    //     fasilitasTersedia.add('tv');
    //   }
    //   if (fasilitas.kipas) {
    //     jumlahFasilitas++;
    //     fasilitasTersedia.add('kipas');
    //   }
    //   if (fasilitas.dapur_dalam) {
    //     jumlahFasilitas++;
    //     fasilitasTersedia.add('dapur_dalam');
    //   }
    //   if (fasilitas.wifi) {
    //     jumlahFasilitas++;
    //     fasilitasTersedia.add('wifi');
    //   }
    //
    //   print(
    //       "    📌 Fasilitas (id=${fasilitas.id_fasilitas}): $jumlahFasilitas dari 10");
    //   print("       Detail: ${fasilitasTersedia.join(', ')}");
    //   return jumlahFasilitas;
    // }

    // ========== C3: LUAS KAMAR (Benefit) ==========
    if (kategori.contains('luas')) {
      final luas = (kost.panjang ?? 0) * (kost.lebar ?? 0);
      print("    📌 Luas Kamar: ${kost.panjang} × ${kost.lebar} = $luas m²");
      return luas;
    }

    // ========== C4: JARAK - ditangani terpisah dengan Haversine ==========

    // ========== C5: KEAMANAN (Benefit) ==========
    if (kategori.contains('keamanan')) {
      final keamanan = kost.keamanan ?? '';
      print("    📌 Keamanan: $keamanan");
      return keamanan;
    }

    // ========== C6: BATAS JAM MALAM (Cost) ==========
    if (kategori.contains('batas') || kategori.contains('jam malam')) {
      final batasJam = kost.batas_jam_malam ?? '';
      print("    📌 Batas Jam Malam: $batasJam");
      return batasJam;
    }

    // ========== C7: JENIS KOST (Benefit) ==========
    if (kategori.contains('jenis kost') || kategori == 'jenis_kost') {
      final jenisKost = kost.jenis_kost ?? '';
      print("    📌 Jenis Kost: $jenisKost");
      return jenisKost;
    }

    // ========== C8: JENIS LISTRIK (Benefit) ==========
    if (kategori.contains('listrik')) {
      final jenisListrik = kost.jenis_listrik ?? '';
      print("    📌 Jenis Listrik: $jenisListrik");
      return jenisListrik;
    }

    // ========== C9: JENIS PEMBAYARAN AIR (Benefit) ==========
    if (kategori.contains('air') || kategori.contains('pembayaran')) {
      final jenisAir = kost.jenis_pembayaran_air ?? '';
      print("    📌 Jenis Pembayaran Air: $jenisAir");
      return jenisAir;
    }

    print("⚠️ Kategori tidak dikenal: $kategori");
    return 0;
  }

  /// ============================================
  /// KONVERSI NILAI KE BOBOT SUBKRITERIA
  /// ============================================
  /// Fungsi utama untuk mengkonversi nilai mentah ke bobot subkriteria
  /// Menggunakan data subkriteria langsung dari database
  /// ============================================
  static double _konversiKeNumerik(
    dynamic nilai,
    int idKriteria,
    List<SubkriteriaModels> listSubkriteria,
    String kategori,
  ) {
    // Cari subkriteria untuk kriteria ini
    final subkriteria =
        listSubkriteria.where((s) => s.id_kriteria == idKriteria).toList();

    print(
        "    🔍 Konversi: $kategori, nilai=$nilai, subkriteria=${subkriteria.length}");

    if (subkriteria.isEmpty) {
      print("    ⚠️ Tidak ada subkriteria untuk id_kriteria=$idKriteria");
      return 0.0;
    }

    // Jika nilai adalah numerik (Biaya, Fasilitas, Luas Kamar, Jarak)
    if (nilai is num) {
      final nilaiNum = nilai.toDouble();
      final hasil = _cocokkanRangeNumerik(nilaiNum, subkriteria);
      print("    ✅ Hasil konversi numerik: $nilaiNum → bobot $hasil");
      return hasil;
    }

    // Jika nilai adalah String (Keamanan, Batas Jam, Jenis Kost, Listrik, Air)
    if (nilai is String) {
      final hasil = _cocokkanString(nilai, subkriteria);
      print("    ✅ Hasil konversi string: $nilai → bobot $hasil");
      return hasil;
    }

    return 0.0;
  }

  /// Cocokkan nilai numerik dengan range subkriteria dari database
  /// Format subkriteria: "<= 700000 - 900000", ">= 900000 - 1300000", "> 2000000", "< 500m", dll
  static double _cocokkanRangeNumerik(
      double nilai, List<SubkriteriaModels> subkriteria) {
    for (var sub in subkriteria) {
      final kat = sub.kategori ?? '';
      final bobot = (sub.bobot ?? 1).toDouble();

      // Prioritas: gunakan kolom numeric (nilai_min/nilai_max) jika tersedia
      if (sub.nilai_min != null || sub.nilai_max != null) {
        // Prioritas 1: Baca operator dari kolom database
        bool minInclusive = true;
        bool maxInclusive = true;

        if (sub.min_operator != null || sub.max_operator != null) {
          // Data baru dengan kolom operator terpisah
          if (sub.min_operator != null) {
            minInclusive =
                (sub.min_operator == '>=' || sub.min_operator == '≥');
          }
          if (sub.max_operator != null) {
            maxInclusive =
                (sub.max_operator == '<=' || sub.max_operator == '≤');
          }
        } else {
          // Prioritas 2: Fallback decode dari kategori (backward compatibility)
          final ops = _decodeRangeOpsFromKategori(sub.kategori);
          minInclusive = ops.minInclusive;
          maxInclusive = ops.maxInclusive;
        }

        final cocok = _nilaiCocokDenganMinMax(
          nilai,
          sub.nilai_min,
          sub.nilai_max,
          minInclusive: minInclusive,
          maxInclusive: maxInclusive,
        );
        if (cocok) {
          print(
              "      📌 Match (min/max): '${sub.kategori}' [min=${sub.nilai_min}, max=${sub.nilai_max}, minOp=${sub.min_operator}, maxOp=${sub.max_operator}] → bobot $bobot");
          return bobot;
        }
        continue;
      }

      // Hapus satuan dan karakter non-numerik untuk parsing
      // Contoh: ">= 6m - 9m" → ">= 6 - 9"
      final katClean = kat
          .toLowerCase()
          .replaceAll('m²', '')
          .replaceAll('m', '')
          .replaceAll('km', '000') // konversi km ke meter
          .replaceAll(' ', '')
          .replaceAll('.', '');

      // Cek apakah nilai cocok dengan range
      if (_nilaiCocokDenganRange(nilai, katClean)) {
        print("      📌 Match: $kat → bobot $bobot");
        return bobot;
      }
    }

    print("      ⚠️ Tidak ada range yang cocok untuk nilai $nilai");
    return 0.0;
  }

  /// Cek apakah nilai cocok dengan batas min/max numeric.
  /// - min & max terisi: min <= nilai <= max
  /// - hanya max: nilai <= max
  /// - hanya min: nilai >= min
  static _RangeOps _decodeRangeOpsFromKategori(String? rawKategori) {
    if (rawKategori == null) {
      return const _RangeOps(minInclusive: true, maxInclusive: true);
    }

    // 1. Coba decode format baru: "nama||>|<="
    const newDelimiter = '||';
    final newIdx = rawKategori.indexOf(newDelimiter);
    if (newIdx >= 0) {
      final afterDelim = rawKategori.substring(newIdx + newDelimiter.length);
      // Format: {minOp}|{maxOp} dimana op adalah >, ≥, <, ≤, atau spasi
      if (afterDelim.length >= 3 && afterDelim[1] == '|') {
        final minOp = afterDelim[0];
        final maxOp = afterDelim[2];

        bool minInclusive = true;
        bool maxInclusive = true;

        // Min operator: '>' strict, '≥' inclusive
        if (minOp == '>') {
          minInclusive = false;
        } else if (minOp == '≥') {
          minInclusive = true;
        }

        // Max operator: '<' strict, '≤' inclusive
        if (maxOp == '<') {
          maxInclusive = false;
        } else if (maxOp == '≤') {
          maxInclusive = true;
        }

        return _RangeOps(
            minInclusive: minInclusive, maxInclusive: maxInclusive);
      }
    }

    // 2. Backward-compat: data lama dengan META JSON
    final idx = rawKategori.indexOf(_kategoriMetaDelimiter);
    if (idx >= 0) {
      final metaStr =
          rawKategori.substring(idx + _kategoriMetaDelimiter.length);
      try {
        final meta = json.decode(metaStr);
        if (meta is Map) {
          final minInc = meta['minInclusive'];
          final maxInc = meta['maxInclusive'];
          return _RangeOps(
            minInclusive: (minInc is bool) ? minInc : true,
            maxInclusive: (maxInc is bool) ? maxInc : true,
          );
        }
      } catch (_) {
        // ignore
      }
    }

    // 3. Fallback: infer dari operator di label (untuk data yang tidak ada encoding)
    final s = rawKategori.trim();
    bool minInclusive = true;
    bool maxInclusive = true;

    if (RegExp(r'(^|\s)>\s*\d').hasMatch(s) &&
        !RegExp(r'(^|\s)>=\s*\d').hasMatch(s) &&
        !RegExp(r'(^|\s)≥\s*\d').hasMatch(s)) {
      minInclusive = false;
    }
    if (RegExp(r'(^|\s)<\s*\d').hasMatch(s) &&
        !RegExp(r'(^|\s)<=\s*\d').hasMatch(s) &&
        !RegExp(r'(^|\s)≤\s*\d').hasMatch(s)) {
      maxInclusive = false;
    }

    return _RangeOps(minInclusive: minInclusive, maxInclusive: maxInclusive);
  }

  static bool _nilaiCocokDenganMinMax(
    double nilai,
    num? min,
    num? max, {
    bool minInclusive = true,
    bool maxInclusive = true,
  }) {
    final minVal = min?.toDouble();
    final maxVal = max?.toDouble();
    if (minVal != null && maxVal != null) {
      final lowerOk = minInclusive ? (nilai >= minVal) : (nilai > minVal);
      final upperOk = maxInclusive ? (nilai <= maxVal) : (nilai < maxVal);
      return lowerOk && upperOk;
    }
    if (maxVal != null) {
      return maxInclusive ? (nilai <= maxVal) : (nilai < maxVal);
    }
    if (minVal != null) {
      return minInclusive ? (nilai >= minVal) : (nilai > minVal);
    }
    return false;
  }

  /// Cek apakah nilai cocok dengan range string
  /// Mendukung format: "<= X", ">= X", "< X", "> X", ">= X - Y", "<= X - Y"
  static bool _nilaiCocokDenganRange(double nilai, String range) {
    print("        🔍 Parsing range: '$range' untuk nilai $nilai");

    // Format: "<= X" saja (kurang dari atau sama dengan, tanpa range)
    // Contoh: "<= 2" → nilai <= 2
    final regexLeOnly = RegExp(r'^<=(\d+)$');
    final matchLeOnly = regexLeOnly.firstMatch(range);
    if (matchLeOnly != null) {
      final batas = double.tryParse(matchLeOnly.group(1) ?? '0') ?? 0;
      final cocok = nilai <= batas;
      print("        ✓ Format <= X: batas=$batas, cocok=$cocok");
      return cocok;
    }

    // Format: ">= X" saja (lebih dari atau sama dengan, tanpa range)
    // Contoh: ">= 9" → nilai >= 9
    final regexGeOnly = RegExp(r'^>=(\d+)$');
    final matchGeOnly = regexGeOnly.firstMatch(range);
    if (matchGeOnly != null) {
      final batas = double.tryParse(matchGeOnly.group(1) ?? '0') ?? 0;
      final cocok = nilai >= batas;
      print("        ✓ Format >= X: batas=$batas, cocok=$cocok");
      return cocok;
    }

    // Format: "<= X - Y" (range dengan batas atas)
    final regexRangeLe = RegExp(r'^<=(\d+)-(\d+)$');
    final matchRangeLe = regexRangeLe.firstMatch(range);
    if (matchRangeLe != null) {
      final min = double.tryParse(matchRangeLe.group(1) ?? '0') ?? 0;
      final max = double.tryParse(matchRangeLe.group(2) ?? '0') ?? 0;
      final cocok = nilai >= min && nilai <= max;
      print("        ✓ Format <= X-Y: min=$min, max=$max, cocok=$cocok");
      return cocok;
    }

    // Format: ">= X - Y" (range dengan batas bawah)
    // Contoh: ">= 2-3" → nilai >= 2 DAN nilai <= 3
    final regexRangeGe = RegExp(r'^>=(\d+)-(\d+)$');
    final matchRangeGe = regexRangeGe.firstMatch(range);
    if (matchRangeGe != null) {
      final min = double.tryParse(matchRangeGe.group(1) ?? '0') ?? 0;
      final max = double.tryParse(matchRangeGe.group(2) ?? '0') ?? 0;
      final cocok = nilai >= min && nilai <= max;
      print("        ✓ Format >= X-Y: min=$min, max=$max, cocok=$cocok");
      return cocok;
    }

    // Format: "> X" (lebih dari, tanpa range)
    final regexGt = RegExp(r'^>(\d+)$');
    final matchGt = regexGt.firstMatch(range);
    if (matchGt != null) {
      final batas = double.tryParse(matchGt.group(1) ?? '0') ?? 0;
      final cocok = nilai > batas;
      print("        ✓ Format > X: batas=$batas, cocok=$cocok");
      return cocok;
    }

    // Format: "< X" (kurang dari, tanpa range)
    final regexLt = RegExp(r'^<(\d+)$');
    final matchLt = regexLt.firstMatch(range);
    if (matchLt != null) {
      final batas = double.tryParse(matchLt.group(1) ?? '0') ?? 0;
      final cocok = nilai < batas;
      print("        ✓ Format < X: batas=$batas, cocok=$cocok");
      return cocok;
    }

    print("        ⚠️ Format tidak dikenali: '$range'");
    return false;
  }

  /// Cocokkan nilai string dengan kategori subkriteria dari database
  /// Untuk: Keamanan, Batas Jam Malam, Jenis Kost, Jenis Listrik, Jenis Pembayaran Air
  ///
  /// PERBAIKAN: Prioritaskan exact match sebelum partial match
  /// Agar "Penjaga" tidak salah cocok dengan "Penjaga sama CCTV"
  static double _cocokkanString(
      String nilai, List<SubkriteriaModels> subkriteria) {
    String nilaiLower = nilai.toLowerCase().trim();

    // Normalisasi khusus untuk Jenis Kost:
    // Dropdown punya "Khusus Putra" & "Khusus Putri" sementara subkriteria hanya "Khusus".
    // Kedua nilai ini dipetakan ke "khusus" agar bobotnya sama.
    if (nilaiLower == 'khusus putra' || nilaiLower == 'khusus putri') {
      nilaiLower = 'khusus';
    }

    // PRIORITAS 1: Cari EXACT MATCH terlebih dahulu untuk semua subkriteria
    for (var sub in subkriteria) {
      final katLower = (sub.kategori ?? '').toLowerCase().trim();
      final bobot = (sub.bobot ?? 1).toDouble();

      if (katLower == nilaiLower) {
        print("      📌 Exact match: $nilai = ${sub.kategori} → bobot $bobot");
        return bobot;
      }
    }

    // PRIORITAS 2: Jika tidak ada exact match, cari partial match
    // Urutkan subkriteria berdasarkan panjang kategori (lebih pendek = lebih spesifik)
    // Contoh: "Penjaga" (7 huruf) harus dicek sebelum "Penjaga sama CCTV" (17 huruf)
    final sortedSub = List<SubkriteriaModels>.from(subkriteria);
    sortedSub.sort((a, b) {
      final lenA = (a.kategori ?? '').length;
      final lenB = (b.kategori ?? '').length;
      return lenA.compareTo(lenB); // Urutkan dari yang terpendek
    });

    for (var sub in sortedSub) {
      final katLower = (sub.kategori ?? '').toLowerCase().trim();
      final bobot = (sub.bobot ?? 1).toDouble();

      // Partial match: nilai MENGANDUNG kategori subkriteria
      // Contoh: nilai "Penjaga" mengandung subkriteria "Penjaga" → cocok
      // Tapi "Penjaga" TIDAK mengandung "Penjaga sama CCTV" → tidak cocok
      if (nilaiLower.contains(katLower)) {
        print(
            "      📌 Partial match (nilai contains sub): $nilai mengandung '${sub.kategori}' → bobot $bobot");
        return bobot;
      }
    }

    // PRIORITAS 3: Cek sebaliknya - kategori subkriteria mengandung nilai
    // Ini untuk kasus nilai di kost lebih pendek dari subkriteria
    // Contoh: nilai "CCTV" bisa cocok dengan subkriteria "Penjaga sama CCTV"
    for (var sub in sortedSub) {
      final katLower = (sub.kategori ?? '').toLowerCase().trim();
      final bobot = (sub.bobot ?? 1).toDouble();

      if (katLower.contains(nilaiLower)) {
        print(
            "      📌 Partial match (sub contains nilai): '${sub.kategori}' mengandung $nilai → bobot $bobot");
        return bobot;
      }
    }

    print("      ⚠️ Tidak ada string yang cocok untuk: $nilai");
    return 0.0;
  }

  /// Konversi jarak (km) ke nilai subkriteria berdasarkan range dari DATABASE
  /// Data subkriteria Jarak (id=61): > 3km=1, >= 2km-3km=2, >= 1km-2km=3, >= 500m-1km=4, < 500m=5
  static double _konversiJarakKeSubkriteria(
    double jarakKm,
    int idKriteria,
    List<SubkriteriaModels> listSubkriteria,
  ) {
    print("  📏 Konversi jarak: ${jarakKm.toStringAsFixed(2)} km");

    // Cari subkriteria untuk kriteria jarak ini
    final subkriteriaJarak =
        listSubkriteria.where((s) => s.id_kriteria == idKriteria).toList();

    // PENTING: Urutkan berdasarkan bobot ASC agar range yang lebih spesifik dicek duluan
    subkriteriaJarak.sort((a, b) => (a.bobot ?? 0).compareTo(b.bobot ?? 0));

    print("     Subkriteria jarak ditemukan: ${subkriteriaJarak.length}");
    for (var s in subkriteriaJarak) {
      print("       - ${s.kategori} (bobot: ${s.bobot})");
    }

    if (subkriteriaJarak.isEmpty) {
      print("     ⚠️ Tidak ada subkriteria jarak!");
      return 0.0;
    }

    for (var sub in subkriteriaJarak) {
      final kat = sub.kategori ?? '';
      final bobot = (sub.bobot ?? 1).toDouble();

      // Prioritas: gunakan kolom numeric (nilai_min/nilai_max) jika tersedia
      if (sub.nilai_min != null || sub.nilai_max != null) {
        // Prioritas 1: Baca operator dari kolom database
        bool minInclusive = true;
        bool maxInclusive = true;

        if (sub.min_operator != null || sub.max_operator != null) {
          // Data baru dengan kolom operator terpisah
          if (sub.min_operator != null) {
            minInclusive =
                (sub.min_operator == '>=' || sub.min_operator == '≥');
          }
          if (sub.max_operator != null) {
            maxInclusive =
                (sub.max_operator == '<=' || sub.max_operator == '≤');
          }
        } else {
          // Prioritas 2: Fallback decode dari kategori (backward compatibility)
          final ops = _decodeRangeOpsFromKategori(sub.kategori);
          minInclusive = ops.minInclusive;
          maxInclusive = ops.maxInclusive;
        }

        if (_nilaiCocokDenganMinMax(
          jarakKm,
          sub.nilai_min,
          sub.nilai_max,
          minInclusive: minInclusive,
          maxInclusive: maxInclusive,
        )) {
          print(
              "     ✅ Match (min/max): '${sub.kategori}' [min=${sub.nilai_min}, max=${sub.nilai_max}, minOp=${sub.min_operator}, maxOp=${sub.max_operator}] → bobot $bobot");
          return bobot;
        }
        continue;
      }

      // Cek apakah jarak cocok dengan range subkriteria
      if (_jarakCocokDenganRange(jarakKm, kat)) {
        print("     ✅ Match: $kat → bobot $bobot");
        return bobot;
      }
    }

    print("     ⚠️ Tidak ada range yang cocok untuk jarak $jarakKm km");
    return 0.0;
  }

  /// Cek apakah jarak cocok dengan range subkriteria - FLEKSIBEL
  /// Mendukung format apapun dari database: m, km, atau angka biasa
  /// Haversine menghitung dalam KM, jadi semua nilai dikonversi ke KM
  static bool _jarakCocokDenganRange(double jarakKm, String range) {
    final r = range.toLowerCase().replaceAll(' ', '');
    print(
        "        🔍 Parsing: '$r' untuk jarak ${jarakKm.toStringAsFixed(2)} km");

    /// Helper: Konversi nilai + satuan ke KM
    /// Mendukung: "500m" → 0.5km, "3km" → 3km, "3" → 3km (default km)
    double parseToKm(String? valueStr, String? unit) {
      if (valueStr == null) return 0;
      double val = double.tryParse(valueStr) ?? 0;

      // Jika satuan adalah meter, konversi ke km
      if (unit != null && unit.toLowerCase() == 'm') {
        return val / 1000;
      }
      // Default: anggap km
      return val;
    }

    /// Helper: Extract angka dan satuan dari string seperti "500m", "3km", "3"
    Map<String, dynamic> extractValue(String s) {
      // Coba match angka dengan satuan
      final match = RegExp(r'(\d+\.?\d*)(m|km)?').firstMatch(s);
      if (match != null) {
        return {
          'value': match.group(1),
          'unit': match.group(2) ?? 'km', // default km jika tidak ada satuan
        };
      }
      return {'value': '0', 'unit': 'km'};
    }

    // ========== FORMAT RANGE: ">= X - Y" atau ">= Xm - Ykm" ==========
    if (r.contains('-')) {
      // Regex fleksibel untuk range dengan atau tanpa satuan
      final match = RegExp(r'>=?\s*(\d+\.?\d*)(m|km)?\s*-\s*(\d+\.?\d*)(m|km)?')
          .firstMatch(r);
      if (match != null) {
        double minKm = parseToKm(match.group(1), match.group(2));
        double maxKm = parseToKm(match.group(3), match.group(4));
        final cocok = jarakKm >= minKm && jarakKm <= maxKm;
        print(
            "        ✓ Range: ${minKm.toStringAsFixed(2)}km - ${maxKm.toStringAsFixed(2)}km → cocok=$cocok");
        return cocok;
      }
    }

    // ========== FORMAT: "< X" atau "< Xm" atau "< Xkm" ==========
    if (r.startsWith('<') && !r.contains('-') && !r.contains('=')) {
      final match = RegExp(r'<\s*(\d+\.?\d*)(m|km)?').firstMatch(r);
      if (match != null) {
        double batasKm = parseToKm(match.group(1), match.group(2));
        final cocok = jarakKm < batasKm;
        print(
            "        ✓ Format < : batas=${batasKm.toStringAsFixed(2)}km → cocok=$cocok");
        return cocok;
      }
    }

    // ========== FORMAT: "> X" atau "> Xm" atau "> Xkm" ==========
    if (r.startsWith('>') && !r.contains('-') && !r.contains('=')) {
      final match = RegExp(r'>\s*(\d+\.?\d*)(m|km)?').firstMatch(r);
      if (match != null) {
        double batasKm = parseToKm(match.group(1), match.group(2));
        final cocok = jarakKm > batasKm;
        print(
            "        ✓ Format > : batas=${batasKm.toStringAsFixed(2)}km → cocok=$cocok");
        return cocok;
      }
    }

    // ========== FORMAT: ">= X" (tanpa range) ==========
    if (r.startsWith('>=') && !r.contains('-')) {
      final match = RegExp(r'>=\s*(\d+\.?\d*)(m|km)?').firstMatch(r);
      if (match != null) {
        double batasKm = parseToKm(match.group(1), match.group(2));
        final cocok = jarakKm >= batasKm;
        print(
            "        ✓ Format >= : batas=${batasKm.toStringAsFixed(2)}km → cocok=$cocok");
        return cocok;
      }
    }

    // ========== FORMAT: "<= X" (tanpa range) ==========
    if (r.startsWith('<=') && !r.contains('-')) {
      final match = RegExp(r'<=\s*(\d+\.?\d*)(m|km)?').firstMatch(r);
      if (match != null) {
        double batasKm = parseToKm(match.group(1), match.group(2));
        final cocok = jarakKm <= batasKm;
        print(
            "        ✓ Format <= : batas=${batasKm.toStringAsFixed(2)}km → cocok=$cocok");
        return cocok;
      }
    }

    print("        ⚠️ Format tidak dikenali: $r");
    return false;
  }

  /// STEP 2: Membuat Matriks Keputusan
  static List<List<double>> _buatMatriksKeputusan(
    List<DataAlternatif> dataAlternatif,
    List<String> namaKriteria,
  ) {
    List<List<double>> matriks = [];

    print("\n🔍 DEBUG MATRIKS KEPUTUSAN:");
    for (var alternatif in dataAlternatif) {
      List<double> baris = [];
      print(
          "   ${alternatif.kode} - Keys tersedia: ${alternatif.nilaiKriteria.keys.toList()}");
      for (var kriteria in namaKriteria) {
        final nilai = alternatif.nilaiKriteria[kriteria];
        final nilaiDouble = (nilai is num) ? nilai.toDouble() : 0.0;
        if (nilai == null) {
          print("      ⚠️ Key '$kriteria' TIDAK DITEMUKAN!");
        }
        baris.add(nilaiDouble);
      }
      matriks.add(baris);
    }

    return matriks;
  }

  /// STEP 3: Normalisasi Matriks
  /// - Benefit: r_ij = x_ij / max(x_j)
  /// - Cost:    r_ij = min(x_j) / x_ij
  static List<List<double>> _normalisasiMatriks(
    List<List<double>> matriks,
    List<String> atributKriteria,
    List<String> namaKriteria,
  ) {
    if (matriks.isEmpty) return [];

    final int jumlahAlternatif = matriks.length;
    final int jumlahKriteria = matriks[0].length;

    // Inisialisasi matriks normalisasi
    List<List<double>> matriksNormal = List.generate(
      jumlahAlternatif,
      (_) => List.filled(jumlahKriteria, 0.0),
    );

    // Tampilkan rumus SAW untuk normalisasi
    print(
        "\n╔════════════════════════════════════════════════════════════════╗");
    print(
        "║           RUMUS NORMALISASI SAW (Simple Additive Weighting)     ║");
    print("╠════════════════════════════════════════════════════════════════╣");
    print("║  • Benefit (semakin tinggi semakin baik):                      ║");
    print("║    rᵢⱼ = xᵢⱼ / max(xⱼ)                                         ║");
    print("║                                                                ║");
    print("║  • Cost (semakin rendah semakin baik):                         ║");
    print("║    rᵢⱼ = min(xⱼ) / xᵢⱼ                                         ║");
    print("║                                                                ║");
    print("║  Keterangan:                                                   ║");
    print("║    rᵢⱼ = nilai normalisasi alternatif i pada kriteria j        ║");
    print("║    xᵢⱼ = nilai alternatif i pada kriteria j                    ║");
    print("║    max(xⱼ) = nilai maksimum pada kriteria j                    ║");
    print("║    min(xⱼ) = nilai minimum pada kriteria j                     ║");
    print(
        "╚════════════════════════════════════════════════════════════════╝\n");

    // Hitung max dan min per kolom (kriteria)
    for (int j = 0; j < jumlahKriteria; j++) {
      // Ambil semua nilai di kolom j
      List<double> kolom = [];
      for (int i = 0; i < jumlahAlternatif; i++) {
        kolom.add(matriks[i][j]);
      }

      // Abaikan nilai 0 (menandakan tidak ada subkriteria cocok) saat mencari min/max,
      // agar tidak merusak normalisasi semua alternatif.
      final nonZero = kolom.where((v) => v > 0).toList();
      final double maxKolom =
          nonZero.isNotEmpty ? nonZero.reduce((a, b) => a > b ? a : b) : 0.0;
      final double minKolom =
          nonZero.isNotEmpty ? nonZero.reduce((a, b) => a < b ? a : b) : 0.0;

      String atribut =
          j < atributKriteria.length ? atributKriteria[j] : 'Benefit';
      String namaKrit = j < namaKriteria.length ? namaKriteria[j] : 'C${j + 1}';

      print(
          "┌────────────────────────────────────────────────────────────────┐");
      print("│ C${j + 1} ($namaKrit) - Atribut: $atribut");
      print("│ max(x${j + 1}) = $maxKolom, min(x${j + 1}) = $minKolom");
      print(
          "├────────────────────────────────────────────────────────────────┤");

      // Normalisasi
      for (int i = 0; i < jumlahAlternatif; i++) {
        double nilai = matriks[i][j];

        if (atribut.toLowerCase() == 'cost') {
          // Cost: r_ij = min(x_j) / x_ij
          if (nilai <= 0 || minKolom <= 0) {
            matriksNormal[i][j] = 0.0;
          } else {
            matriksNormal[i][j] = minKolom / nilai;
          }
          print(
              "│  r${i + 1}${j + 1} = min(x${j + 1}) / x${i + 1}${j + 1} = $minKolom / $nilai = ${matriksNormal[i][j].toStringAsFixed(4)}");
        } else {
          // Benefit: r_ij = x_ij / max(x_j)
          if (nilai <= 0 || maxKolom <= 0) {
            matriksNormal[i][j] = 0.0;
          } else {
            matriksNormal[i][j] = nilai / maxKolom;
          }
          print(
              "│  r${i + 1}${j + 1} = x${i + 1}${j + 1} / max(x${j + 1}) = $nilai / $maxKolom = ${matriksNormal[i][j].toStringAsFixed(4)}");
        }
      }
      print(
          "└────────────────────────────────────────────────────────────────┘\n");
    }

    return matriksNormal;
  }

  /// STEP 4: Hitung Matriks Terbobot (R × W)
  static List<List<double>> _hitungMatriksTerbobot(
    List<List<double>> matriksNormal,
    List<double> bobot,
    List<String> namaKriteria,
  ) {
    if (matriksNormal.isEmpty) return [];

    final int jumlahAlternatif = matriksNormal.length;
    final int jumlahKriteria = matriksNormal[0].length;

    // Tampilkan rumus SAW untuk matriks terbobot
    print(
        "\n╔════════════════════════════════════════════════════════════════╗");
    print(
        "║           RUMUS MATRIKS TERBOBOT (Weighted Normalized Matrix)   ║");
    print("╠════════════════════════════════════════════════════════════════╣");
    print("║  yᵢⱼ = wⱼ × rᵢⱼ                                                ║");
    print("║                                                                ║");
    print("║  Keterangan:                                                   ║");
    print("║    yᵢⱼ = nilai terbobot alternatif i pada kriteria j           ║");
    print("║    wⱼ  = bobot kriteria j (dari ROC)                           ║");
    print("║    rᵢⱼ = nilai normalisasi alternatif i pada kriteria j        ║");
    print(
        "╚════════════════════════════════════════════════════════════════╝\n");

    // Tampilkan bobot
    print("┌────────────────────────────────────────────────────────────────┐");
    print("│ BOBOT KRITERIA (W):                                            │");
    for (int j = 0; j < bobot.length; j++) {
      String namaKrit = j < namaKriteria.length ? namaKriteria[j] : 'C${j + 1}';
      print("│  w${j + 1} ($namaKrit) = ${bobot[j].toStringAsFixed(4)}");
    }
    print(
        "└────────────────────────────────────────────────────────────────┘\n");

    List<List<double>> matriksTerbobot = List.generate(
      jumlahAlternatif,
      (_) => List.filled(jumlahKriteria, 0.0),
    );

    for (int i = 0; i < jumlahAlternatif; i++) {
      print(
          "┌────────────────────────────────────────────────────────────────┐");
      print("│ A${i + 1}:");
      for (int j = 0; j < jumlahKriteria; j++) {
        double w = j < bobot.length ? bobot[j] : 0.0;
        matriksTerbobot[i][j] = matriksNormal[i][j] * w;
        String namaKrit =
            j < namaKriteria.length ? namaKriteria[j] : 'C${j + 1}';
        print(
            "│  y${i + 1}${j + 1} = w${j + 1} × r${i + 1}${j + 1} = ${w.toStringAsFixed(4)} × ${matriksNormal[i][j].toStringAsFixed(4)} = ${matriksTerbobot[i][j].toStringAsFixed(4)} ($namaKrit)");
      }
      print(
          "└────────────────────────────────────────────────────────────────┘");
    }

    return matriksTerbobot;
  }

  /// STEP 5: Hitung Nilai Preferensi (V)
  static List<HasilPreferensi> _hitungNilaiPreferensi(
    List<DataAlternatif> dataAlternatif,
    List<List<double>> matriksTerbobot,
    List<String> namaKriteria,
  ) {
    List<HasilPreferensi> hasil = [];

    // Tampilkan rumus SAW untuk nilai preferensi
    print(
        "\n╔════════════════════════════════════════════════════════════════╗");
    print("║           RUMUS NILAI PREFERENSI (Preference Value)            ║");
    print("╠════════════════════════════════════════════════════════════════╣");
    print("║  Vᵢ = Σⱼ₌₁ⁿ (wⱼ × rᵢⱼ) = Σⱼ₌₁ⁿ yᵢⱼ                             ║");
    print("║                                                                ║");
    print("║  Atau secara lengkap:                                          ║");
    print("║  Vᵢ = y₁ + y₂ + y₃ + ... + yₙ                                  ║");
    print("║                                                                ║");
    print("║  Keterangan:                                                   ║");
    print("║    Vᵢ  = nilai preferensi alternatif i                         ║");
    print("║    yᵢⱼ = nilai terbobot alternatif i pada kriteria j           ║");
    print("║    n   = jumlah kriteria                                       ║");
    print(
        "╚════════════════════════════════════════════════════════════════╝\n");

    for (int i = 0; i < dataAlternatif.length; i++) {
      final alternatif = dataAlternatif[i];
      final nilaiPerKriteria = matriksTerbobot[i];

      // V_i = Σ(w_j * r_ij)
      double total = nilaiPerKriteria.fold(0.0, (sum, val) => sum + val);

      // Buat string formula detail
      List<String> komponenRumus = [];
      for (int j = 0; j < nilaiPerKriteria.length; j++) {
        komponenRumus.add("y${i + 1}${j + 1}");
      }

      List<String> nilaiKomponen = [];
      for (int j = 0; j < nilaiPerKriteria.length; j++) {
        nilaiKomponen.add(nilaiPerKriteria[j].toStringAsFixed(4));
      }

      print(
          "┌────────────────────────────────────────────────────────────────┐");
      print("│ V${i + 1} (${alternatif.namaKost}):");
      print("│  V${i + 1} = ${komponenRumus.join(' + ')}");
      print("│  V${i + 1} = ${nilaiKomponen.join(' + ')}");
      print("│  V${i + 1} = ${total.toStringAsFixed(4)}");
      print(
          "└────────────────────────────────────────────────────────────────┘");

      hasil.add(HasilPreferensi(
        kode: alternatif.kode,
        namaKost: alternatif.namaKost,
        nilaiPerKriteria: nilaiPerKriteria,
        totalPreferensi: total,
      ));
    }

    return hasil;
  }

  /// STEP 6: Buat Perangkingan
  static List<HasilRanking> _buatPerangkingan(
    List<HasilPreferensi> hasilPreferensi,
    List<DataAlternatif> dataAlternatif,
  ) {
    // Tampilkan rumus SAW untuk perangkingan
    print(
        "\n╔════════════════════════════════════════════════════════════════╗");
    print("║           RUMUS PERANGKINGAN (Ranking)                         ║");
    print("╠════════════════════════════════════════════════════════════════╣");
    print("║  Peringkat ditentukan berdasarkan nilai Vᵢ tertinggi           ║");
    print("║                                                                ║");
    print("║  Alternatif terbaik adalah yang memiliki nilai Vᵢ MAKSIMUM    ║");
    print("║                                                                ║");
    print("║  Urutan: V_max > V_next > ... > V_min                          ║");
    print(
        "╚════════════════════════════════════════════════════════════════╝\n");

    // Gabungkan data preferensi dengan data alternatif
    List<Map<String, dynamic>> combined = [];
    for (int i = 0; i < hasilPreferensi.length; i++) {
      combined.add({
        'preferensi': hasilPreferensi[i],
        'alternatif': dataAlternatif[i],
      });
    }

    // Urutkan berdasarkan total preferensi (descending)
    combined.sort((a, b) {
      final prefA = a['preferensi'] as HasilPreferensi;
      final prefB = b['preferensi'] as HasilPreferensi;
      return prefB.totalPreferensi.compareTo(prefA.totalPreferensi);
    });

    print("┌────────────────────────────────────────────────────────────────┐");
    print("│                     HASIL PERANGKINGAN                         │");
    print("├────────────────────────────────────────────────────────────────┤");
    print("│ Rank │ Kode │ Nama Kost                      │ Nilai V         │");
    print("├────────────────────────────────────────────────────────────────┤");

    // Buat hasil ranking
    List<HasilRanking> hasil = [];
    for (int i = 0; i < combined.length; i++) {
      final pref = combined[i]['preferensi'] as HasilPreferensi;
      final alt = combined[i]['alternatif'] as DataAlternatif;

      String namaDisplay = pref.namaKost.length > 30
          ? '${pref.namaKost.substring(0, 27)}...'
          : pref.namaKost;
      print(
          "│  ${(i + 1).toString().padLeft(2)}  │ ${pref.kode.padRight(4)} │ ${namaDisplay.padRight(30)} │ ${pref.totalPreferensi.toStringAsFixed(4).padLeft(15)} │");

      hasil.add(HasilRanking(
        peringkat: i + 1,
        kode: pref.kode,
        idKost: alt.idKost,
        namaKost: pref.namaKost,
        skor: pref.totalPreferensi,
      ));
    }
    print("└────────────────────────────────────────────────────────────────┘");

    return hasil;
  }

  /// Helper: Print matriks untuk debugging
  static void _printMatriks(
    String judul,
    List<List<double>> matriks,
    List<DataAlternatif> alternatif,
    List<String> kriteria,
  ) {
    print("\n📊 $judul:");

    // Header
    String header = "      ";
    for (int j = 0; j < kriteria.length; j++) {
      header += "C${j + 1}".padLeft(10);
    }
    print(header);

    // Data
    for (int i = 0; i < matriks.length; i++) {
      String baris = "${alternatif[i].kode}".padRight(6);
      for (int j = 0; j < matriks[i].length; j++) {
        baris += matriks[i][j].toStringAsFixed(4).padLeft(10);
      }
      print(baris);
    }
  }

  /// Helper: Format currency untuk tampilan
  static String _formatCurrency(int value) {
    final str = value.toString();
    final rev = str.split('').reversed.toList();
    final parts = <String>[];
    for (int i = 0; i < rev.length; i += 3) {
      parts.add(rev.sublist(i, (i + 3).clamp(0, rev.length)).join());
    }
    return parts.join('.').split('').reversed.join();
  }

  /// Helper: Get list fasilitas dari field kost.fasilitas (VERSI BARU)
  /// Field fasilitas di tabel kost bertipe text yang menyimpan comma-separated list
  static String _getListFasilitasFromKost(KostModel kost) {
    final fasilitasText = kost.fasilitas;

    // Jika field fasilitas null atau kosong, tandai sebagai tidak terpublish
    if (fasilitasText == null || fasilitasText.trim().isEmpty) {
      return 'Tidak Terpublish';
    }

    // Parse dan format list fasilitas
    final List<String> fasilitasList = fasilitasText
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (fasilitasList.isEmpty) return 'Tidak Terpublish';
    return fasilitasList.join(', ');
  }

  /// Helper: Get list fasilitas yang tersedia (VERSI LAMA - DEPRECATED)
  /// Menggunakan FasilitasModel dari tabel fasilitas via id_fasilitas
  // static String _getListFasilitas(FasilitasModel fasilitas) {
  //   List<String> list = [];
  //   if (fasilitas.tempat_tidur) list.add('Tempat Tidur');
  //   if (fasilitas.kamar_mandi_dalam) list.add('KM Dalam');
  //   if (fasilitas.meja) list.add('Meja');
  //   if (fasilitas.tempat_parkir) list.add('Parkir');
  //   if (fasilitas.lemari) list.add('Lemari');
  //   if (fasilitas.ac) list.add('AC');
  //   if (fasilitas.tv) list.add('TV');
  //   if (fasilitas.kipas) list.add('Kipas');
  //   if (fasilitas.dapur_dalam) list.add('Dapur');
  //   if (fasilitas.wifi) list.add('WiFi');
  //
  //   if (list.isEmpty) return '-';
  //   return list.join(', ');
  // }
}
