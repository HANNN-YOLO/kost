/// ============================================
/// RANK ORDER CENTROID (ROC) - Metode Pembobotan
/// ============================================
///
/// ROC menghitung bobot kriteria berdasarkan RANKING/URUTAN
/// yang diberikan oleh pengambil keputusan.
///
/// RUMUS:
/// W_k = (1/n) * Σ(1/i) untuk i dari k sampai n
///
/// Dimana:
/// - W_k = bobot untuk kriteria dengan ranking ke-k
/// - n   = jumlah total kriteria
/// - k   = posisi ranking (1 = paling penting)
///
/// KEUNGGULAN:
/// - Pengguna hanya perlu MENGURUTKAN, tidak perlu kasih angka bobot
/// - Hasil bobot otomatis ter-normalisasi (total = 1)
/// - Lebih mudah dan intuitif bagi pengguna awam

class RankOrderCentroid {
  /// Menghitung bobot ROC untuk setiap kriteria berdasarkan ranking
  ///
  /// [rankings] = List ranking dari setiap kriteria (1 = paling penting)
  ///
  /// Return: Map<int, double> dimana key=ranking, value=bobot ROC
  static Map<int, double> hitungBobot(List<int> rankings) {
    final int n = rankings.length;

    if (n == 0) {
      print("[ROC DEBUG] ❌ Error: List ranking kosong!");
      return {};
    }

    print("\n" + "=" * 50);
    print("🔢 RANK ORDER CENTROID - PERHITUNGAN BOBOT");
    print("=" * 50);
    print("📊 Jumlah kriteria (n): $n");
    print("-" * 50);

    Map<int, double> hasilBobot = {};

    for (int k = 1; k <= n; k++) {
      // Hitung sigma: Σ(1/i) untuk i = k sampai n
      double sigma = 0.0;
      String rumusDetail = "";

      for (int i = k; i <= n; i++) {
        sigma += 1 / i;
        rumusDetail += "1/$i";
        if (i < n) rumusDetail += " + ";
      }

      // Hitung bobot: W_k = (1/n) * sigma
      double bobot = (1 / n) * sigma;
      hasilBobot[k] = bobot;

      print("\n🎯 Ranking $k:");
      print("   Rumus: W_$k = (1/$n) × ($rumusDetail)");
      print("   Sigma: Σ = ${sigma.toStringAsFixed(4)}");
      print(
          "   Bobot: W_$k = (1/$n) × ${sigma.toStringAsFixed(4)} = ${bobot.toStringAsFixed(4)}");
    }

    // Verifikasi total bobot = 1
    double totalBobot = hasilBobot.values.fold(0.0, (sum, b) => sum + b);
    print("\n" + "-" * 50);
    print("✅ TOTAL BOBOT: ${totalBobot.toStringAsFixed(4)} (harus ≈ 1.0)");
    print("=" * 50 + "\n");

    return hasilBobot;
  }

  /// Menghitung bobot dan mengembalikan list bobot sesuai urutan ranking
  ///
  /// [jumlahKriteria] = total kriteria yang ada
  ///
  /// Return: List<double> bobot terurut dari ranking 1 sampai n
  static List<double> hitungBobotList(int jumlahKriteria) {
    if (jumlahKriteria <= 0) {
      print("[ROC DEBUG] ❌ Error: Jumlah kriteria harus > 0");
      return [];
    }

    List<int> rankings = List.generate(jumlahKriteria, (i) => i + 1);
    Map<int, double> bobotMap = hitungBobot(rankings);

    // Konversi ke list terurut
    return rankings.map((r) => bobotMap[r] ?? 0.0).toList();
  }

  /// Mengaplikasikan bobot ROC ke data kriteria
  ///
  /// [dataKriteria] = List Map kriteria dengan field 'ranking'
  ///
  /// Return: List Map kriteria dengan field 'bobot' yang sudah diisi ROC
  static List<Map<String, dynamic>> aplikasikanBobot(
    List<Map<String, dynamic>> dataKriteria,
  ) {
    final int n = dataKriteria.length;

    if (n == 0) {
      print("[ROC DEBUG] ❌ Error: Data kriteria kosong!");
      return [];
    }

    print("\n" + "=" * 50);
    print("📋 APLIKASI BOBOT ROC KE DATA KRITERIA");
    print("=" * 50);

    // Hitung bobot ROC
    Map<int, double> bobotROC = hitungBobot(
      List.generate(n, (i) => i + 1),
    );

    // Urutkan data berdasarkan ranking
    dataKriteria.sort((a, b) {
      int rankA = a['ranking'] ?? 999;
      int rankB = b['ranking'] ?? 999;
      return rankA.compareTo(rankB);
    });

    // Aplikasikan bobot ke setiap kriteria
    List<Map<String, dynamic>> hasilAkhir = [];

    for (int i = 0; i < dataKriteria.length; i++) {
      var kriteria = Map<String, dynamic>.from(dataKriteria[i]);
      int ranking = kriteria['ranking'] ?? (i + 1);
      double bobot = bobotROC[ranking] ?? 0.0;

      // Konversi ke integer (skala 0-100) untuk penyimpanan database
      // Atau bisa tetap decimal tergantung kebutuhan
      kriteria['bobot'] = (bobot * 100).round();
      kriteria['bobot_decimal'] = bobot;

      print(
          "📌 ${kriteria['kategori']} (Ranking $ranking) → Bobot: ${(bobot * 100).toStringAsFixed(2)}%");

      hasilAkhir.add(kriteria);
    }

    print("=" * 50 + "\n");
    return hasilAkhir;
  }

  /// Konversi bobot desimal ke persentase
  static int bobotKePersentase(double bobot) {
    return (bobot * 100).round();
  }

  /// Konversi persentase ke bobot desimal
  static double persentaseKeBobot(int persentase) {
    return persentase / 100.0;
  }
}
