# DOKUMENTASI LENGKAP IMPLEMENTASI METODE ROC (Rank Order Centroid)

**File:** `lib/algoritma/rank_order_centroid.dart`

**Tanggal Dokumentasi:** 28 Februari 2026

---

## DAFTAR ISI

1. [Pendahuluan](#1-pendahuluan)
2. [Dasar Teori Metode ROC](#2-dasar-teori-metode-roc)
3. [Struktur File dan Class](#3-struktur-file-dan-class)
4. [Analisis Setiap Fungsi](#4-analisis-setiap-fungsi)
5. [Implementasi Rumus ROC dalam Kode](#5-implementasi-rumus-roc-dalam-kode)
6. [Contoh Perhitungan Manual](#6-contoh-perhitungan-manual)
7. [Integrasi dengan SAW](#7-integrasi-dengan-saw)
8. [Kesimpulan](#8-kesimpulan)

---

## 1. PENDAHULUAN

### 1.1 Tentang Metode ROC

**Rank Order Centroid (ROC)** adalah metode pembobotan kriteria dalam sistem pendukung keputusan yang mengkonversi urutan prioritas (ranking) menjadi nilai bobot numerik yang ter-normalisasi.

Dalam aplikasi rekomendasi kost ini, ROC digunakan untuk **menghitung bobot kriteria** berdasarkan ranking yang diberikan oleh admin/pengambil keputusan.

### 1.2 Keunggulan Metode ROC

| No  | Keunggulan          | Penjelasan                                                           |
| --- | ------------------- | -------------------------------------------------------------------- |
| 1   | **Sederhana**       | Pengguna hanya perlu mengurutkan, tidak perlu memberikan angka bobot |
| 2   | **Ter-normalisasi** | Hasil bobot otomatis berjumlah ≈ 1.0 (100%)                          |
| 3   | **Intuitif**        | Mudah dipahami oleh pengguna awam                                    |
| 4   | **Konsisten**       | Ranking yang sama selalu menghasilkan bobot yang sama                |

### 1.3 Referensi Rumus

Berdasarkan referensi teori, rumus ROC adalah:

**Rumus (1) - Rank Order Centroid:**
$$W_k = \frac{1}{m} \sum_{i=k}^{m} \frac{1}{i}$$

**Keterangan:**

- $W_k$ = Bobot kriteria dengan ranking ke-k
- $m$ = Jumlah total kriteria
- $k$ = Posisi ranking (1 = paling penting)
- $i$ = Indeks iterasi (dari k sampai m)

---

## 2. DASAR TEORI METODE ROC

### 2.1 Konsep Dasar

ROC mengasumsikan bahwa kriteria dengan **ranking lebih kecil (lebih penting)** akan mendapat **bobot lebih besar**. Rumus ROC memastikan:

1. Bobot menurun seiring bertambahnya ranking
2. Total semua bobot = 1.0 (100%)
3. Perbedaan bobot antar ranking proporsional

### 2.2 Langkah-Langkah Perhitungan ROC

| Langkah | Deskripsi                                                          |
| ------- | ------------------------------------------------------------------ |
| 1       | Tentukan jumlah kriteria (m)                                       |
| 2       | Urutkan kriteria berdasarkan prioritas (ranking 1, 2, 3, ..., m)   |
| 3       | Untuk setiap ranking k, hitung sigma: $\sum_{i=k}^{m} \frac{1}{i}$ |
| 4       | Kalikan sigma dengan $\frac{1}{m}$ untuk mendapat bobot $W_k$      |
| 5       | Verifikasi total bobot ≈ 1.0                                       |

### 2.3 Distribusi Bobot ROC

Untuk 5 kriteria (m = 5), distribusi bobot ROC:

| Ranking   | Rumus                                                                    | Perhitungan  | Bobot      | Persentase |
| --------- | ------------------------------------------------------------------------ | ------------ | ---------- | ---------- |
| 1         | $\frac{1}{5}(1 + \frac{1}{2} + \frac{1}{3} + \frac{1}{4} + \frac{1}{5})$ | 0.2 × 2.2833 | 0.4567     | 45.67%     |
| 2         | $\frac{1}{5}(\frac{1}{2} + \frac{1}{3} + \frac{1}{4} + \frac{1}{5})$     | 0.2 × 1.2833 | 0.2567     | 25.67%     |
| 3         | $\frac{1}{5}(\frac{1}{3} + \frac{1}{4} + \frac{1}{5})$                   | 0.2 × 0.7833 | 0.1567     | 15.67%     |
| 4         | $\frac{1}{5}(\frac{1}{4} + \frac{1}{5})$                                 | 0.2 × 0.45   | 0.0900     | 9.00%      |
| 5         | $\frac{1}{5}(\frac{1}{5})$                                               | 0.2 × 0.2    | 0.0400     | 4.00%      |
| **Total** |                                                                          |              | **1.0000** | **100%**   |

---

## 3. STRUKTUR FILE DAN CLASS

### 3.1 Lokasi File

```
lib/
└── algoritma/
    └── rank_order_centroid.dart
```

### 3.2 Class `RankOrderCentroid`

```dart
class RankOrderCentroid {
  // Fungsi utama perhitungan bobot
  static Map<int, double> hitungBobot(List<int> rankings)

  // Wrapper untuk menghasilkan list bobot
  static List<double> hitungBobotList(int jumlahKriteria)

  // Aplikasi bobot ke data kriteria
  static List<Map<String, dynamic>> aplikasikanBobot(List<Map<String, dynamic>> dataKriteria)

  // Helper: konversi ke persentase
  static int bobotKePersentase(double bobot)

  // Helper: konversi dari persentase
  static double persentaseKeBobot(int persentase)
}
```

### 3.3 Daftar Fungsi

| No  | Fungsi                | Tipe   | Kegunaan                                      |
| --- | --------------------- | ------ | --------------------------------------------- |
| 1   | `hitungBobot()`       | Static | Menghitung bobot ROC untuk setiap ranking     |
| 2   | `hitungBobotList()`   | Static | Wrapper untuk menghasilkan list bobot terurut |
| 3   | `aplikasikanBobot()`  | Static | Mengaplikasikan bobot ke data kriteria        |
| 4   | `bobotKePersentase()` | Static | Konversi decimal ke integer persentase        |
| 5   | `persentaseKeBobot()` | Static | Konversi persentase ke decimal                |

---

## 4. ANALISIS SETIAP FUNGSI

### 4.1 Fungsi Utama: `hitungBobot()` ⭐ IMPLEMENTASI RUMUS ROC

**Lokasi:** Baris 27-70

**Signature:**

```dart
static Map<int, double> hitungBobot(List<int> rankings)
```

**Deskripsi:**
Fungsi utama yang mengimplementasikan rumus ROC untuk menghitung bobot setiap kriteria berdasarkan ranking.

**Parameter Input:**
| Parameter | Tipe | Keterangan |
|-----------|------|------------|
| `rankings` | `List<int>` | Daftar ranking kriteria (1 = paling penting) |

**Return:**
| Tipe | Keterangan |
|------|------------|
| `Map<int, double>` | Map dengan key = ranking, value = bobot ROC |

**Alur Eksekusi:**

```
MULAI
  │
  ├─ Ambil jumlah kriteria: n = rankings.length
  │
  ├─ Validasi: n == 0? → return {}
  │
  ├─ LOOP untuk setiap ranking k (1 sampai n):
  │   │
  │   ├─ Inisialisasi sigma = 0
  │   │
  │   ├─ LOOP untuk i = k sampai n:
  │   │   └─ sigma += 1/i          ← Σ(1/i)
  │   │
  │   ├─ Hitung bobot = (1/n) × sigma  ← W_k = (1/m) × Σ(1/i)
  │   │
  │   └─ Simpan: hasilBobot[k] = bobot
  │
  ├─ Verifikasi: totalBobot ≈ 1.0
  │
  └─ Return hasilBobot
SELESAI
```

---

#### 4.1.1 IMPLEMENTASI RUMUS ROC - ANALISIS BARIS PER BARIS

**RUMUS TEORI:**
$$W_k = \frac{1}{m} \sum_{i=k}^{m} \frac{1}{i}$$

**KODE LENGKAP DENGAN PENJELASAN:**

```dart
static Map<int, double> hitungBobot(List<int> rankings) {
  final int n = rankings.length;  // ← m dalam rumus (jumlah kriteria)

  if (n == 0) {
    print("[ROC DEBUG] ❌ Error: List ranking kosong!");
    return {};
  }

  Map<int, double> hasilBobot = {};

  for (int k = 1; k <= n; k++) {  // ← Loop untuk setiap ranking k
    // ================================================
    // LANGKAH 1: Hitung Sigma (Σ)
    // Rumus: Σ(1/i) untuk i = k sampai n
    // ================================================
    double sigma = 0.0;
    String rumusDetail = "";

    for (int i = k; i <= n; i++) {  // ← Loop dari k sampai m
      sigma += 1 / i;               // ← Σ(1/i) - penjumlahan 1/i
      rumusDetail += "1/$i";
      if (i < n) rumusDetail += " + ";
    }

    // ================================================
    // LANGKAH 2: Hitung Bobot (W_k)
    // Rumus: W_k = (1/n) × Σ
    // ================================================
    double bobot = (1 / n) * sigma;  // ← W_k = (1/m) × Σ(1/i)
    hasilBobot[k] = bobot;
  }

  // Verifikasi total bobot = 1
  double totalBobot = hasilBobot.values.fold(0.0, (sum, b) => sum + b);

  return hasilBobot;
}
```

---

#### 4.1.2 MAPPING KODE KE RUMUS MATEMATIKA

| Simbol Rumus                 | Variabel Kode | Baris  | Penjelasan                                                  |
| ---------------------------- | ------------- | ------ | ----------------------------------------------------------- |
| $m$                          | `n`           | 28     | `final int n = rankings.length` - Jumlah total kriteria     |
| $k$                          | `k`           | 42     | `for (int k = 1; k <= n; k++)` - Posisi ranking saat ini    |
| $i$                          | `i`           | 48     | `for (int i = k; i <= n; i++)` - Indeks iterasi penjumlahan |
| $\frac{1}{i}$                | `1 / i`       | 49     | Nilai yang dijumlahkan dalam sigma                          |
| $\sum_{i=k}^{m} \frac{1}{i}$ | `sigma`       | 44, 49 | Hasil penjumlahan dari i=k sampai i=n                       |
| $\frac{1}{m}$                | `1 / n`       | 55     | Faktor pengali (1 dibagi jumlah kriteria)                   |
| $W_k$                        | `bobot`       | 55     | `(1 / n) * sigma` - Hasil akhir bobot untuk ranking k       |

---

#### 4.1.3 ANALISIS BARIS KRITIS IMPLEMENTASI RUMUS

**BARIS 49 - Perhitungan Sigma (Σ):**

```dart
sigma += 1 / i;
```

| Komponen | Penjelasan                                            |
| -------- | ----------------------------------------------------- |
| `sigma`  | Variabel akumulator untuk menyimpan hasil penjumlahan |
| `+=`     | Operator penambahan kumulatif                         |
| `1 / i`  | Implementasi dari $\frac{1}{i}$ dalam rumus           |

**Contoh eksekusi untuk k=2, n=5:**

```
Iterasi i=2: sigma = 0 + 1/2 = 0.5
Iterasi i=3: sigma = 0.5 + 1/3 = 0.8333
Iterasi i=4: sigma = 0.8333 + 1/4 = 1.0833
Iterasi i=5: sigma = 1.0833 + 1/5 = 1.2833
```

---

**BARIS 55 - Perhitungan Bobot (W_k):**

```dart
double bobot = (1 / n) * sigma;
```

| Komponen  | Penjelasan                                     |
| --------- | ---------------------------------------------- |
| `(1 / n)` | Implementasi dari $\frac{1}{m}$ dalam rumus    |
| `*`       | Operator perkalian                             |
| `sigma`   | Hasil penjumlahan $\sum_{i=k}^{m} \frac{1}{i}$ |
| `bobot`   | Hasil akhir $W_k$                              |

**Contoh eksekusi untuk k=2, n=5:**

```
bobot = (1/5) × 1.2833
bobot = 0.2 × 1.2833
bobot = 0.2567
```

---

### 4.2 Fungsi `hitungBobotList()`

**Lokasi:** Baris 77-88

**Signature:**

```dart
static List<double> hitungBobotList(int jumlahKriteria)
```

**Deskripsi:**
Wrapper function yang memanggil `hitungBobot()` dan mengkonversi hasilnya menjadi `List<double>` yang terurut.

**Kode Lengkap:**

```dart
static List<double> hitungBobotList(int jumlahKriteria) {
  if (jumlahKriteria <= 0) {
    print("[ROC DEBUG] ❌ Error: Jumlah kriteria harus > 0");
    return [];
  }

  // Generate list ranking: [1, 2, 3, ..., n]
  List<int> rankings = List.generate(jumlahKriteria, (i) => i + 1);

  // Hitung bobot menggunakan fungsi utama
  Map<int, double> bobotMap = hitungBobot(rankings);

  // Konversi Map ke List terurut
  return rankings.map((r) => bobotMap[r] ?? 0.0).toList();
}
```

**Penjelasan Baris per Baris:**

| Baris | Kode                                               | Penjelasan                                |
| ----- | -------------------------------------------------- | ----------------------------------------- |
| 78-81 | `if (jumlahKriteria <= 0)`                         | Validasi input tidak boleh 0 atau negatif |
| 83    | `List.generate(jumlahKriteria, (i) => i + 1)`      | Membuat list [1, 2, 3, ..., n]            |
| 84    | `hitungBobot(rankings)`                            | Memanggil fungsi utama ROC                |
| 87    | `rankings.map((r) => bobotMap[r] ?? 0.0).toList()` | Konversi Map ke List terurut              |

**Contoh Output:**

```dart
hitungBobotList(5) → [0.4567, 0.2567, 0.1567, 0.0900, 0.0400]
```

---

### 4.3 Fungsi `aplikasikanBobot()`

**Lokasi:** Baris 95-139

**Signature:**

```dart
static List<Map<String, dynamic>> aplikasikanBobot(
  List<Map<String, dynamic>> dataKriteria,
)
```

**Deskripsi:**
Mengaplikasikan bobot ROC ke data kriteria yang sudah memiliki field `ranking`.

**Alur Proses:**

```
INPUT: List kriteria dengan field 'ranking'
  │
  ├─ Hitung bobot ROC untuk n kriteria
  │
  ├─ Urutkan kriteria berdasarkan ranking (ASC)
  │
  ├─ Untuk setiap kriteria:
  │   ├─ Ambil ranking
  │   ├─ Ambil bobot dari hasil ROC
  │   ├─ Set field 'bobot' = persentase (0-100)
  │   └─ Set field 'bobot_decimal' = decimal (0-1)
  │
  └─ Return list kriteria dengan bobot
OUTPUT: List kriteria dengan field 'bobot' dan 'bobot_decimal'
```

**Kode Kritis - Aplikasi Bobot (Baris 123-131):**

```dart
for (int i = 0; i < dataKriteria.length; i++) {
  var kriteria = Map<String, dynamic>.from(dataKriteria[i]);
  int ranking = kriteria['ranking'] ?? (i + 1);
  double bobot = bobotROC[ranking] ?? 0.0;

  // Konversi ke integer (skala 0-100) untuk database
  kriteria['bobot'] = (bobot * 100).round();
  kriteria['bobot_decimal'] = bobot;

  hasilAkhir.add(kriteria);
}
```

**Penjelasan:**

| Baris | Kode                             | Penjelasan                                |
| ----- | -------------------------------- | ----------------------------------------- |
| 125   | `kriteria['ranking'] ?? (i + 1)` | Ambil ranking, default i+1 jika tidak ada |
| 126   | `bobotROC[ranking] ?? 0.0`       | Ambil bobot dari Map hasil ROC            |
| 129   | `(bobot * 100).round()`          | Konversi ke persentase integer (0-100)    |
| 130   | `bobot`                          | Simpan juga versi decimal (0-1)           |

---

### 4.4 Fungsi Helper: `bobotKePersentase()` dan `persentaseKeBobot()`

**Lokasi:** Baris 142-149

```dart
/// Konversi bobot desimal ke persentase
static int bobotKePersentase(double bobot) {
  return (bobot * 100).round();
}

/// Konversi persentase ke bobot desimal
static double persentaseKeBobot(int persentase) {
  return persentase / 100.0;
}
```

**Contoh Penggunaan:**

```dart
bobotKePersentase(0.4567)  → 46  (dibulatkan)
persentaseKeBobot(46)      → 0.46
```

---

## 5. IMPLEMENTASI RUMUS ROC DALAM KODE

### 5.1 Ringkasan Implementasi

| Bagian Rumus                 | Kode                           | Baris | Fungsi          |
| ---------------------------- | ------------------------------ | ----- | --------------- |
| $m$ (jumlah kriteria)        | `n = rankings.length`          | 28    | `hitungBobot()` |
| $k$ (ranking)                | `for (int k = 1; k <= n; k++)` | 42    | `hitungBobot()` |
| $\sum_{i=k}^{m} \frac{1}{i}$ | `sigma += 1 / i`               | 49    | `hitungBobot()` |
| $\frac{1}{m}$                | `1 / n`                        | 55    | `hitungBobot()` |
| $W_k$                        | `bobot = (1 / n) * sigma`      | 55    | `hitungBobot()` |

### 5.2 Perbandingan Rumus Teori vs Implementasi

**Rumus Teori:**
$$W_k = \frac{1}{m} \sum_{i=k}^{m} \frac{1}{i}$$

**Implementasi Kode:**

```dart
for (int k = 1; k <= n; k++) {        // Untuk setiap ranking k
  double sigma = 0.0;
  for (int i = k; i <= n; i++) {      // Σ dari i=k sampai m
    sigma += 1 / i;                    // Σ(1/i)
  }
  double bobot = (1 / n) * sigma;      // W_k = (1/m) × Σ
  hasilBobot[k] = bobot;
}
```

| Aspek                    | Rumus Teori                       | Implementasi Kode              | Status    |
| ------------------------ | --------------------------------- | ------------------------------ | --------- |
| Variabel jumlah kriteria | $m$                               | `n`                            | ✅ Sesuai |
| Loop ranking             | $k = 1, 2, ..., m$                | `for (int k = 1; k <= n; k++)` | ✅ Sesuai |
| Loop sigma               | $i = k, k+1, ..., m$              | `for (int i = k; i <= n; i++)` | ✅ Sesuai |
| Penjumlahan              | $\sum \frac{1}{i}$                | `sigma += 1 / i`               | ✅ Sesuai |
| Perhitungan bobot        | $W_k = \frac{1}{m} \times \Sigma$ | `bobot = (1 / n) * sigma`      | ✅ Sesuai |

---

## 6. CONTOH PERHITUNGAN MANUAL

### 6.1 Kasus: 5 Kriteria

**Input:** m = 5 kriteria

**Kriteria:**
| Ranking (k) | Nama Kriteria |
|-------------|---------------|
| 1 | Biaya |
| 2 | Fasilitas |
| 3 | Luas Kamar |
| 4 | Jarak |
| 5 | Keamanan |

---

### 6.2 Perhitungan Langkah demi Langkah

#### **Ranking k = 1 (Biaya)**

**Langkah 1: Hitung Sigma**
$$\sum_{i=1}^{5} \frac{1}{i} = \frac{1}{1} + \frac{1}{2} + \frac{1}{3} + \frac{1}{4} + \frac{1}{5}$$
$$= 1 + 0.5 + 0.3333 + 0.25 + 0.2 = 2.2833$$

**Langkah 2: Hitung Bobot**
$$W_1 = \frac{1}{5} \times 2.2833 = 0.2 \times 2.2833 = 0.4567$$

---

#### **Ranking k = 2 (Fasilitas)**

**Langkah 1: Hitung Sigma**
$$\sum_{i=2}^{5} \frac{1}{i} = \frac{1}{2} + \frac{1}{3} + \frac{1}{4} + \frac{1}{5}$$
$$= 0.5 + 0.3333 + 0.25 + 0.2 = 1.2833$$

**Langkah 2: Hitung Bobot**
$$W_2 = \frac{1}{5} \times 1.2833 = 0.2 \times 1.2833 = 0.2567$$

---

#### **Ranking k = 3 (Luas Kamar)**

**Langkah 1: Hitung Sigma**
$$\sum_{i=3}^{5} \frac{1}{i} = \frac{1}{3} + \frac{1}{4} + \frac{1}{5}$$
$$= 0.3333 + 0.25 + 0.2 = 0.7833$$

**Langkah 2: Hitung Bobot**
$$W_3 = \frac{1}{5} \times 0.7833 = 0.2 \times 0.7833 = 0.1567$$

---

#### **Ranking k = 4 (Jarak)**

**Langkah 1: Hitung Sigma**
$$\sum_{i=4}^{5} \frac{1}{i} = \frac{1}{4} + \frac{1}{5}$$
$$= 0.25 + 0.2 = 0.45$$

**Langkah 2: Hitung Bobot**
$$W_4 = \frac{1}{5} \times 0.45 = 0.2 \times 0.45 = 0.0900$$

---

#### **Ranking k = 5 (Keamanan)**

**Langkah 1: Hitung Sigma**
$$\sum_{i=5}^{5} \frac{1}{i} = \frac{1}{5} = 0.2$$

**Langkah 2: Hitung Bobot**
$$W_5 = \frac{1}{5} \times 0.2 = 0.2 \times 0.2 = 0.0400$$

---

### 6.3 Hasil Akhir

| Ranking   | Kriteria   | Sigma (Σ) | Bobot (W)  | Persentase |
| --------- | ---------- | --------- | ---------- | ---------- |
| 1         | Biaya      | 2.2833    | 0.4567     | 45.67%     |
| 2         | Fasilitas  | 1.2833    | 0.2567     | 25.67%     |
| 3         | Luas Kamar | 0.7833    | 0.1567     | 15.67%     |
| 4         | Jarak      | 0.4500    | 0.0900     | 9.00%      |
| 5         | Keamanan   | 0.2000    | 0.0400     | 4.00%      |
| **Total** |            |           | **1.0000** | **100%**   |

### 6.4 Visualisasi Distribusi Bobot

```
Ranking 1 (Biaya)     : ████████████████████████████████████████████████ 45.67%
Ranking 2 (Fasilitas) : ██████████████████████████ 25.67%
Ranking 3 (Luas)      : ████████████████ 15.67%
Ranking 4 (Jarak)     : █████████ 9.00%
Ranking 5 (Keamanan)  : ████ 4.00%
```

---

## 7. INTEGRASI DENGAN SAW

### 7.1 Alur Penggunaan ROC dalam Sistem

```
┌─────────────────────────────────────────────────────────────────┐
│                     ALUR INTEGRASI ROC - SAW                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  [1] ADMIN: Menentukan Urutan Kriteria                          │
│      │                                                          │
│      └─ Input: Ranking kriteria (1, 2, 3, ...)                  │
│                                                                 │
│  [2] ROC: Menghitung Bobot                                      │
│      │                                                          │
│      ├─ hitungBobot() → Map<ranking, bobot>                     │
│      └─ aplikasikanBobot() → Update kriteria di database        │
│                                                                 │
│  [3] DATABASE: Menyimpan Bobot                                  │
│      │                                                          │
│      └─ Tabel kriteria: bobot_decimal disimpan                  │
│                                                                 │
│  [4] SAW: Mengambil Bobot dari Database                         │
│      │                                                          │
│      ├─ fetchKriteria() → Ambil bobot_decimal                   │
│      └─ hitungSAW() → Gunakan bobot untuk perhitungan           │
│                                                                 │
│  [5] OUTPUT: Hasil Rekomendasi                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 7.2 Di Mana ROC Dipanggil

ROC dipanggil oleh **KriteriaProvider** saat admin menyimpan atau mengubah urutan kriteria:

| Fungsi Provider     | Aksi                        | Kapan Dipanggil           |
| ------------------- | --------------------------- | ------------------------- |
| `savemassal()`      | Hitung ROC, simpan ke DB    | Saat create kriteria baru |
| `updatedmassal()`   | Hitung ulang ROC, update DB | Saat update urutan        |
| `_recalculateROC()` | Hitung ulang ROC            | Saat kriteria dihapus     |

### 7.3 Penggunaan Bobot di SAW

Di SAW, bobot dari ROC digunakan pada **STEP 4 (Matriks Terbobot)**:

```dart
// Di simple_additive_weighting.dart
final bobotKriteria = sortedKriteria.map((k) => k.bobot_decimal ?? 0.0).toList();

// Digunakan di _hitungMatriksTerbobot()
matriksTerbobot[i][j] = matriksNormal[i][j] * bobot[j];  // bobot dari ROC
```

---

## 8. KESIMPULAN

### 8.1 Kesesuaian dengan Teori

Implementasi dalam file `rank_order_centroid.dart` **sesuai dengan rumus ROC standar**:

| Aspek             | Rumus Teori                       | Implementasi Kode              | Status    |
| ----------------- | --------------------------------- | ------------------------------ | --------- |
| Jumlah kriteria   | $m$                               | `n = rankings.length`          | ✅ Sesuai |
| Iterasi ranking   | $k = 1..m$                        | `for (int k = 1; k <= n; k++)` | ✅ Sesuai |
| Penjumlahan sigma | $\sum_{i=k}^{m} \frac{1}{i}$      | `sigma += 1 / i`               | ✅ Sesuai |
| Perhitungan bobot | $W_k = \frac{1}{m} \times \Sigma$ | `bobot = (1 / n) * sigma`      | ✅ Sesuai |
| Total bobot       | $\sum W_k = 1$                    | Terverifikasi                  | ✅ Sesuai |

### 8.2 Daftar Fungsi Utama

| No  | Fungsi               | Rumus yang Diimplementasikan                   | Baris Kritis |
| --- | -------------------- | ---------------------------------------------- | ------------ |
| 1   | `hitungBobot()`      | $W_k = \frac{1}{m} \sum_{i=k}^{m} \frac{1}{i}$ | 49, 55       |
| 2   | `hitungBobotList()`  | Wrapper untuk `hitungBobot()`                  | 84           |
| 3   | `aplikasikanBobot()` | Aplikasi $W_k$ ke data kriteria                | 129-130      |

### 8.3 Keterkaitan dengan SAW

```
ROC (Pembobotan)          SAW (Perangkingan)
      │                         │
      ├─ W₁ = 0.4567    →       ├─ w₁ × r₁ⱼ
      ├─ W₂ = 0.2567    →       ├─ w₂ × r₂ⱼ
      ├─ W₃ = 0.1567    →       ├─ w₃ × r₃ⱼ
      ├─ W₄ = 0.0900    →       ├─ w₄ × r₄ⱼ
      └─ W₅ = 0.0400    →       └─ w₅ × r₅ⱼ
                                      │
                                      ↓
                                Vᵢ = Σ(wⱼ × rᵢⱼ)
```

---

**Dokumen ini dibuat untuk keperluan dokumentasi skripsi.**

_Referensi: Teori Rank Order Centroid (ROC) dalam Sistem Pendukung Keputusan_
