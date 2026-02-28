# DOKUMENTASI LENGKAP IMPLEMENTASI METODE SAW (Simple Additive Weighting)

**File:** `lib/algoritma/simple_additive_weighting.dart`

**Tanggal Dokumentasi:** 28 Februari 2026

---

## DAFTAR ISI

1. [Pendahuluan](#1-pendahuluan)
2. [Dasar Teori Metode SAW](#2-dasar-teori-metode-saw)
3. [Struktur File dan Class](#3-struktur-file-dan-class)
4. [Analisis Setiap Fungsi](#4-analisis-setiap-fungsi)
5. [Implementasi Rumus SAW dalam Kode](#5-implementasi-rumus-saw-dalam-kode)
6. [Alur Kerja SAW End-to-End](#6-alur-kerja-saw-end-to-end)
7. [Kesimpulan](#7-kesimpulan)

---

## 1. PENDAHULUAN

### 1.1 Tentang Metode SAW

**Simple Additive Weighting (SAW)** adalah metode pengambilan keputusan multikriteria yang digunakan untuk menentukan alternatif terbaik berdasarkan penjumlahan terbobot dari nilai-nilai kriteria yang telah dinormalisasi.

Dalam aplikasi ini, SAW digunakan untuk **merekomendasikan kost terbaik** kepada pengguna berdasarkan kriteria-kriteria seperti:

- Biaya sewa (Cost)
- Jumlah fasilitas (Benefit)
- Luas kamar (Benefit)
- Jarak dari lokasi tujuan (Benefit)
- Keamanan (Benefit)
- Batas jam malam (Cost)
- Jenis kost (Benefit)
- Jenis listrik (Benefit)
- Jenis pembayaran air (Benefit)

### 1.2 Referensi Rumus

Berdasarkan referensi (Tarigan et al., 2022), rumus-rumus SAW yang digunakan adalah:

**Rumus (2) - Normalisasi Benefit:**
$$r_{ij} = \frac{x_{ij}}{\max(x_j)}$$
_Digunakan jika J adalah atribut keuntungan (Benefit)_

**Rumus (3) - Normalisasi Cost:**
$$r_{ij} = \frac{\min(x_j)}{x_{ij}}$$
_Digunakan jika J adalah atribut biaya (Cost)_

**Rumus (4) - Nilai Preferensi:**
$$V_i = \sum_{j=1}^{n} w_j \times r_{ij}$$

**Keterangan:**

- $r_{ij}$ = nilai normalisasi dari alternatif ke-i terhadap kriteria ke-j
- $x_{ij}$ = nilai asli dari alternatif ke-i terhadap kriteria ke-j
- $\max(x_j)$ = nilai maksimum pada kriteria ke-j
- $\min(x_j)$ = nilai minimum pada kriteria ke-j
- $V_i$ = nilai preferensi untuk setiap alternatif (rangking)
- $w_j$ = bobot untuk setiap kriteria

---

## 2. DASAR TEORI METODE SAW

### 2.1 Langkah-Langkah SAW

Metode SAW memiliki 6 langkah utama:

| Langkah | Nama                    | Deskripsi                                                 |
| ------- | ----------------------- | --------------------------------------------------------- |
| 1       | Membuat Data Alternatif | Mengumpulkan nilai setiap alternatif untuk semua kriteria |
| 2       | Matriks Keputusan (X)   | Menyusun nilai-nilai dalam bentuk matriks                 |
| 3       | Normalisasi Matriks (R) | Menormalisasi nilai dengan rumus Benefit/Cost             |
| 4       | Matriks Terbobot (Y)    | Mengalikan nilai normalisasi dengan bobot kriteria        |
| 5       | Nilai Preferensi (V)    | Menjumlahkan seluruh nilai terbobot per alternatif        |
| 6       | Perangkingan            | Mengurutkan alternatif berdasarkan nilai V tertinggi      |

### 2.2 Jenis Atribut Kriteria

| Jenis       | Rumus                         | Keterangan                                                       |
| ----------- | ----------------------------- | ---------------------------------------------------------------- |
| **Benefit** | $r_{ij} = x_{ij} / \max(x_j)$ | Semakin tinggi semakin baik (fasilitas, luas, keamanan, jarak\*) |
| **Cost**    | $r_{ij} = \min(x_j) / x_{ij}$ | Semakin rendah semakin baik (biaya, batas jam malam)             |

> **Catatan Khusus untuk Kriteria Jarak:**
>
> Dalam aplikasi ini, **Jarak ditetapkan sebagai BENEFIT** karena nilai jarak sudah dikonversi ke bobot subkriteria sebelum masuk ke matriks keputusan. Konversi ini membalik logika:
>
> - Jarak dekat (< 500m) → bobot tinggi (5)
> - Jarak jauh (> 3km) → bobot rendah (1)
>
> Jadi setelah konversi, nilai yang lebih tinggi berarti jarak yang lebih dekat (lebih baik), sehingga menggunakan rumus Benefit.

---

## 3. STRUKTUR FILE DAN CLASS

### 3.1 Import yang Digunakan

```dart
import 'dart:convert';        // Untuk parsing JSON metadata
import 'dart:math' as math;   // Untuk perhitungan matematika (Haversine)
import '../models/kost_model.dart';
import '../models/fasilitas_model.dart';
import '../models/kriteria_models.dart';
import '../models/subkriteria_models.dart';
```

### 3.2 Class Model Data

| Class             | Fungsi                                 | Field Utama                                                                          |
| ----------------- | -------------------------------------- | ------------------------------------------------------------------------------------ |
| `HasilSAW`        | Menyimpan seluruh hasil perhitungan    | matriksKeputusan, matriksNormalisasi, matriksTerbobot, hasilPreferensi, hasilRanking |
| `KostTerskipSAW`  | Menyimpan kost yang tidak diproses     | idKost, namaKost, alasan                                                             |
| `DataAlternatif`  | Menyimpan data setiap alternatif       | kode (A1, A2, ...), idKost, namaKost, nilaiKriteria, nilaiMentah                     |
| `HasilPreferensi` | Menyimpan hasil perhitungan preferensi | kode, namaKost, nilaiPerKriteria, totalPreferensi                                    |
| `HasilRanking`    | Menyimpan hasil perangkingan           | peringkat, kode, idKost, namaKost, skor                                              |
| `_RangeOps`       | Helper untuk operator range            | minInclusive, maxInclusive                                                           |

---

## 4. ANALISIS SETIAP FUNGSI

### 4.1 Fungsi Utama: `hitungSAW()`

**Lokasi:** Baris 187-414

**Signature:**

```dart
static HasilSAW? hitungSAW({
  required List<KostModel> listKost,
  required List<FasilitasModel> listFasilitas,
  required List<KriteriaModels> listKriteria,
  required List<SubkriteriaModels> listSubkriteria,
  double? userLat,
  double? userLng,
  Map<int, double>? jarakKostMap,
})
```

**Deskripsi:**
Fungsi utama yang menjalankan seluruh tahapan perhitungan SAW.

**Parameter Input:**
| Parameter | Tipe | Keterangan |
|-----------|------|------------|
| `listKost` | `List<KostModel>` | Daftar kost sebagai alternatif (A1, A2, dst) |
| `listFasilitas` | `List<FasilitasModel>` | Data fasilitas masing-masing kost |
| `listKriteria` | `List<KriteriaModels>` | Daftar kriteria dengan bobot dan atribut |
| `listSubkriteria` | `List<SubkriteriaModels>` | Daftar subkriteria untuk konversi nilai |
| `userLat` | `double?` | Latitude lokasi pengguna (untuk kriteria jarak) |
| `userLng` | `double?` | Longitude lokasi pengguna |
| `jarakKostMap` | `Map<int, double>?` | Peta id_kost → jarak dalam km dari OSRM |

**Alur Eksekusi:**

```
MULAI
  │
  ├─ Validasi: listKost kosong? → return null
  ├─ Validasi: listKriteria kosong? → return null
  │
  ├─ Cek kriteria jarak tersedia
  ├─ Urutkan kriteria berdasarkan ranking (ASC)
  │
  ├─ STEP 1: _buatDataAlternatif()
  ├─ STEP 2: _buatMatriksKeputusan()
  ├─ STEP 3: _normalisasiMatriks()
  ├─ STEP 4: _hitungMatriksTerbobot()
  ├─ STEP 5: _hitungNilaiPreferensi()
  ├─ STEP 6: _buatPerangkingan()
  │
  └─ Return HasilSAW
SELESAI
```

**Kode Kritis - Sorting Kriteria (Baris 277-288):**

```dart
// SORTING: Urutkan kriteria berdasarkan ranking dari database
final sortedKriteria = List<KriteriaModels>.from(listKriteria);
sortedKriteria.sort((a, b) => (a.ranking ?? 999).compareTo(b.ranking ?? 999));
```

_Penjelasan:_ Kriteria diurutkan dari ranking terkecil (paling penting) ke terbesar. Nilai default 999 digunakan jika ranking tidak ada.

---

### 4.2 Fungsi `_buatDataAlternatif()` - STEP 1

**Lokasi:** Baris 423-614

**Signature:**

```dart
static _DataAlternatifBuildResult _buatDataAlternatif(
  List<KostModel> listKost,
  List<FasilitasModel> listFasilitas,
  List<KriteriaModels> listKriteria,
  List<SubkriteriaModels> listSubkriteria,
  double? userLat,
  double? userLng,
  Map<int, double>? jarakKostMap,
)
```

**Deskripsi:**
Mengkonversi data kost mentah menjadi format `DataAlternatif` dengan nilai numerik yang sudah terkonversi dari subkriteria.

**Alur Proses:**

```
Untuk setiap kost:
  │
  ├─ Buat kode alternatif (A1, A2, A3, ...)
  ├─ Cari fasilitas yang sesuai (by id_fasilitas)
  │
  ├─ Untuk setiap kriteria:
  │   ├─ Jika kriteria JARAK:
  │   │   └─ Ambil jarak dari jarakKostMap (OSRM road distance)
  │   │
  │   ├─ Jika kriteria LAIN:
  │   │   └─ Ambil nilai dari _ambilNilaiKriteria()
  │   │
  │   └─ Konversi nilai ke bobot subkriteria:
  │       └─ _konversiKeNumerik() atau _konversiJarakKeSubkriteria()
  │
  ├─ Jika ada kriteria dengan nilai 0 (tidak cocok subkriteria):
  │   └─ Tambahkan ke daftar terskip
  │
  └─ Jika semua kriteria valid:
      └─ Tambahkan ke daftar hasil
```

**Kode Kritis - Sorting Kost (Baris 437-438):**

```dart
final sortedKost = List<KostModel>.from(listKost);
sortedKost.sort((a, b) => (a.id_kost ?? 0).compareTo(b.id_kost ?? 0));
```

_Penjelasan:_ Kost diurutkan berdasarkan id_kost untuk memastikan kode alternatif (A1, A2, ...) konsisten.

**Kode Kritis - Penanganan Jarak OSRM (Baris 483-510):**

```dart
if (kategori.contains('jarak')) {
  // Prioritas 1: Gunakan jarakKostMap (road distance) jika tersedia
  if (jarakKostMap != null && jarakKostMap.containsKey(kost.id_kost)) {
    nilaiAsli = jarakKostMap[kost.id_kost]!;
    // Konversi jarak ke nilai subkriteria berdasarkan range
    nilaiNumerik = _konversiJarakKeSubkriteria(
      nilaiAsli,
      idKriteria,
      listSubkriteria,
    );
  } else {
    nilaiAsli = null;
    nilaiNumerik = 0.0;
    alasanTerskip.add('$namaKritAsli: jarak jalan tidak tersedia.');
  }
}
```

_Penjelasan:_ Jarak menggunakan OSRM (jarak jalan) bukan Haversine (garis lurus). Jika jarak tidak tersedia, kost akan dilewati.

---

### 4.3 Fungsi `_ambilNilaiKriteria()` - Pengambilan Nilai Kriteria

**Lokasi:** Baris 629-798

**Signature:**

```dart
static dynamic _ambilNilaiKriteria(
  KostModel kost,
  FasilitasModel fasilitas,
  String kategori,
)
```

**Deskripsi:**
Mengambil nilai kriteria dari model kost/fasilitas berdasarkan kategori kriteria.

**Mapping Kategori ke Field Database:**

| Kategori        | Field Database              | Tipe Atribut | Keterangan                  |
| --------------- | --------------------------- | ------------ | --------------------------- |
| Biaya/Harga     | `kost.harga_kost`           | Cost         | Dinormalisasi ke per bulan  |
| Fasilitas       | `kost.fasilitas`            | Benefit      | Jumlah item dalam list      |
| Luas Kamar      | `kost.panjang × kost.lebar` | Benefit      | Dalam m²                    |
| Jarak           | `jarakKostMap`              | Benefit      | Dari OSRM (km)              |
| Keamanan        | `kost.keamanan`             | Benefit      | String (Penjaga, CCTV, dll) |
| Batas Jam Malam | `kost.batas_jam_malam`      | Cost         | String waktu                |
| Jenis Kost      | `kost.jenis_kost`           | Benefit      | Campur/Khusus               |
| Jenis Listrik   | `kost.jenis_listrik`        | Benefit      | Token/Abodemen              |
| Jenis Air       | `kost.jenis_pembayaran_air` | Benefit      | Bayar/Gratis                |

**Kode Kritis - Normalisasi Biaya ke Per Bulan (Baris 652-674):**

```dart
if (kategori.contains('biaya') || kategori.contains('harga')) {
  final hargaAsli = kost.harga_kost ?? 0;
  final periodePembayaran = (kost.per ?? 'Bulan').toLowerCase();

  int hargaPerBulan;
  if (periodePembayaran.contains('tahun')) {
    // Jika harga per tahun, konversi ke per bulan
    hargaPerBulan = (hargaAsli / 12).round();
  } else {
    hargaPerBulan = hargaAsli;
  }
  return hargaPerBulan;
}
```

_Penjelasan:_ Untuk konsistensi perhitungan, semua harga dinormalisasi ke per bulan. Jika harga asli per tahun, akan dibagi 12.

**Kode Kritis - Perhitungan Jumlah Fasilitas (Baris 680-700):**

```dart
if (kategori.contains('fasilitas')) {
  final fasilitasText = kost.fasilitas;

  if (fasilitasText == null || fasilitasText.trim().isEmpty) {
    return 0; // Tidak ada fasilitas
  }

  // Parse string fasilitas (comma-separated list)
  final List<String> fasilitasList = fasilitasText
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  return fasilitasList.length; // Jumlah fasilitas
}
```

_Penjelasan:_ Fasilitas disimpan sebagai string comma-separated. Fungsi ini menghitung jumlah item dalam daftar tersebut.

---

### 4.4 Fungsi `_konversiKeNumerik()` - Konversi ke Bobot Subkriteria

**Lokasi:** Baris 805-850

**Signature:**

```dart
static double _konversiKeNumerik(
  dynamic nilai,
  int idKriteria,
  List<SubkriteriaModels> listSubkriteria,
  String kategori,
)
```

**Deskripsi:**
Mengkonversi nilai mentah ke bobot numerik menggunakan subkriteria dari database.

**Alur Konversi:**

```
INPUT: nilai (bisa num atau String)
  │
  ├─ Cari subkriteria untuk id_kriteria ini
  │
  ├─ Jika nilai adalah NUMERIK (num):
  │   └─ Panggil _cocokkanRangeNumerik()
  │
  ├─ Jika nilai adalah STRING:
  │   └─ Panggil _cocokkanString()
  │
  └─ Return bobot (double)
```

**Contoh Konversi:**
| Nilai Asli | Subkriteria | Bobot |
|------------|-------------|-------|
| Rp 800.000 | ≤ 700.000 - 900.000 | 5 |
| "Penjaga" | Penjaga | 3 |
| 12 m² | ≥ 9m² - 12m² | 4 |
| 0.5 km | < 500m | 5 |
| 2.5 km | ≥ 2km - 3km | 2 |

**Catatan untuk Kriteria Jarak:**
Konversi jarak ke bobot subkriteria menghasilkan nilai yang **berbanding terbalik** dengan jarak asli:

- Jarak dekat → bobot tinggi (karena lebih disukai)
- Jarak jauh → bobot rendah

Ini menyebabkan Jarak diperlakukan sebagai **Benefit** dalam normalisasi SAW.

---

### 4.5 Fungsi `_cocokkanRangeNumerik()` - Pencocokan Range Numerik

**Lokasi:** Baris 856-920

**Deskripsi:**
Mencocokkan nilai numerik dengan range subkriteria yang tersimpan di database.

**Format Range yang Didukung:**

| Format     | Contoh                | Penjelasan        |
| ---------- | --------------------- | ----------------- |
| `<= X`     | `<= 700000`           | Nilai ≤ 700.000   |
| `>= X`     | `>= 2000000`          | Nilai ≥ 2.000.000 |
| `<= X - Y` | `<= 700000 - 900000`  | Min ≤ Nilai ≤ Max |
| `>= X - Y` | `>= 900000 - 1300000` | Min ≤ Nilai ≤ Max |
| `> X`      | `> 2000000`           | Nilai > 2.000.000 |
| `< X`      | `< 500000`            | Nilai < 500.000   |

**Kode Kritis - Pencocokan dengan nilai_min/nilai_max (Baris 870-905):**

```dart
// Prioritas: gunakan kolom numeric (nilai_min/nilai_max) jika tersedia
if (sub.nilai_min != null || sub.nilai_max != null) {
  bool minInclusive = true;
  bool maxInclusive = true;

  if (sub.min_operator != null || sub.max_operator != null) {
    // Data baru dengan kolom operator terpisah
    if (sub.min_operator != null) {
      minInclusive = (sub.min_operator == '>=' || sub.min_operator == '≥');
    }
    if (sub.max_operator != null) {
      maxInclusive = (sub.max_operator == '<=' || sub.max_operator == '≤');
    }
  }

  final cocok = _nilaiCocokDenganMinMax(
    nilai,
    sub.nilai_min,
    sub.nilai_max,
    minInclusive: minInclusive,
    maxInclusive: maxInclusive,
  );
  if (cocok) return bobot;
}
```

_Penjelasan:_ Fungsi ini mendukung dua format data subkriteria:

1. Format baru: menggunakan kolom `nilai_min`, `nilai_max`, `min_operator`, `max_operator`
2. Format lama: parsing langsung dari string `kategori`

---

### 4.6 Fungsi `_buatMatriksKeputusan()` - STEP 2

**Lokasi:** Baris 1318-1340

**Signature:**

```dart
static List<List<double>> _buatMatriksKeputusan(
  List<DataAlternatif> dataAlternatif,
  List<String> namaKriteria,
)
```

**Deskripsi:**
Membuat Matriks Keputusan (X) dari data alternatif. Setiap baris mewakili satu alternatif, setiap kolom mewakili satu kriteria.

**Contoh Output:**

```
Matriks Keputusan (X):
         C1       C2       C3       C4
A1      4.0      8.0      9.0      3.0
A2      5.0      6.0     12.0      4.0
A3      3.0      7.0      6.0      2.0
```

**Kode Lengkap:**

```dart
static List<List<double>> _buatMatriksKeputusan(
  List<DataAlternatif> dataAlternatif,
  List<String> namaKriteria,
) {
  List<List<double>> matriks = [];

  for (var alternatif in dataAlternatif) {
    List<double> baris = [];
    for (var kriteria in namaKriteria) {
      final nilai = alternatif.nilaiKriteria[kriteria];
      final nilaiDouble = (nilai is num) ? nilai.toDouble() : 0.0;
      baris.add(nilaiDouble);
    }
    matriks.add(baris);
  }

  return matriks;
}
```

---

### 4.7 Fungsi `_normalisasiMatriks()` - STEP 3 ⭐ IMPLEMENTASI RUMUS SAW

**Lokasi:** Baris 1346-1449

**Signature:**

```dart
static List<List<double>> _normalisasiMatriks(
  List<List<double>> matriks,
  List<String> atributKriteria,
  List<String> namaKriteria,
)
```

**Deskripsi:**
Menormalisasi matriks keputusan menggunakan rumus SAW. Ini adalah **implementasi langsung dari Rumus (2) dan Rumus (3)** dari referensi.

**IMPLEMENTASI RUMUS (2) - BENEFIT:**
$$r_{ij} = \frac{x_{ij}}{\max(x_j)}$$

**Kode Implementasi (Baris 1428-1433):**

```dart
// Benefit: r_ij = x_ij / max(x_j)
if (nilai <= 0 || maxKolom <= 0) {
  matriksNormal[i][j] = 0.0;
} else {
  matriksNormal[i][j] = _roundExcel(nilai / maxKolom);
}
```

**Penjelasan Baris per Baris:**
| Baris | Kode | Penjelasan |
|-------|------|------------|
| 1 | `if (nilai <= 0 || maxKolom <= 0)` | Cek jika nilai atau max adalah 0 atau negatif |
| 2 | `matriksNormal[i][j] = 0.0` | Jika tidak valid, set hasil normalisasi = 0 |
| 3 | `else` | Jika valid, lakukan normalisasi |
| 4 | `matriksNormal[i][j] = _roundExcel(nilai / maxKolom)` | **r_ij = x_ij / max(x_j)** - pembagian nilai dengan maksimum |

**IMPLEMENTASI RUMUS (3) - COST:**
$$r_{ij} = \frac{\min(x_j)}{x_{ij}}$$

**Kode Implementasi (Baris 1419-1424):**

```dart
// Cost: r_ij = min(x_j) / x_ij
if (nilai <= 0 || minKolom <= 0) {
  matriksNormal[i][j] = 0.0;
} else {
  matriksNormal[i][j] = _roundExcel(minKolom / nilai);
}
```

**Penjelasan Baris per Baris:**
| Baris | Kode | Penjelasan |
|-------|------|------------|
| 1 | `if (nilai <= 0 || minKolom <= 0)` | Cek jika nilai atau min adalah 0 atau negatif |
| 2 | `matriksNormal[i][j] = 0.0` | Jika tidak valid, set hasil normalisasi = 0 |
| 3 | `else` | Jika valid, lakukan normalisasi |
| 4 | `matriksNormal[i][j] = _roundExcel(minKolom / nilai)` | **r_ij = min(x_j) / x_ij** - pembagian minimum dengan nilai |

**Kode Lengkap dengan Komentar:**

```dart
// Hitung max dan min per kolom (kriteria)
for (int j = 0; j < jumlahKriteria; j++) {
  // Ambil semua nilai di kolom j
  List<double> kolom = [];
  for (int i = 0; i < jumlahAlternatif; i++) {
    kolom.add(matriks[i][j]);
  }

  // Abaikan nilai 0 saat mencari min/max
  final nonZero = kolom.where((v) => v > 0).toList();
  final double maxKolom = nonZero.isNotEmpty
      ? nonZero.reduce((a, b) => a > b ? a : b)
      : 0.0;  // max(x_j)
  final double minKolom = nonZero.isNotEmpty
      ? nonZero.reduce((a, b) => a < b ? a : b)
      : 0.0;  // min(x_j)

  String atribut = atributKriteria[j];  // 'Benefit' atau 'Cost'

  // Normalisasi
  for (int i = 0; i < jumlahAlternatif; i++) {
    double nilai = matriks[i][j];  // x_ij

    if (atribut.toLowerCase() == 'cost') {
      // RUMUS (3): r_ij = min(x_j) / x_ij
      matriksNormal[i][j] = _roundExcel(minKolom / nilai);
    } else {
      // RUMUS (2): r_ij = x_ij / max(x_j)
      matriksNormal[i][j] = _roundExcel(nilai / maxKolom);
    }
  }
}
```

**Contoh Perhitungan:**

_Data:_
| Alternatif | Biaya (Cost) | Fasilitas (Benefit) |
|------------|--------------|---------------------|
| A1 | 800.000 | 8 |
| A2 | 1.000.000 | 6 |
| A3 | 600.000 | 10 |

_Normalisasi Biaya (Cost):_

- min(Biaya) = 600.000
- r₁₁ = 600.000 / 800.000 = 0.75
- r₂₁ = 600.000 / 1.000.000 = 0.60
- r₃₁ = 600.000 / 600.000 = 1.00

_Normalisasi Fasilitas (Benefit):_

- max(Fasilitas) = 10
- r₁₂ = 8 / 10 = 0.80
- r₂₂ = 6 / 10 = 0.60
- r₃₂ = 10 / 10 = 1.00

_Normalisasi Jarak (Benefit - setelah konversi subkriteria):_

> **Catatan:** Nilai jarak sudah dikonversi ke bobot subkriteria sebelum masuk matriks.
> Contoh konversi: 0.5km → bobot 5, 1.5km → bobot 3, 4km → bobot 1

| Alternatif | Jarak Asli | Bobot Subkriteria |
| ---------- | ---------- | ----------------- |
| A1         | 0.8 km     | 4                 |
| A2         | 1.2 km     | 3                 |
| A3         | 0.3 km     | 5                 |

- max(Jarak_bobot) = 5
- r₁₃ = 4 / 5 = 0.80 (A1 cukup dekat)
- r₂₃ = 3 / 5 = 0.60 (A2 agak jauh)
- r₃₃ = 5 / 5 = 1.00 (A3 paling dekat - nilai tertinggi)

---

### 4.8 Fungsi `_hitungMatriksTerbobot()` - STEP 4

**Lokasi:** Baris 1455-1516

**Signature:**

```dart
static List<List<double>> _hitungMatriksTerbobot(
  List<List<double>> matriksNormal,
  List<double> bobot,
  List<String> namaKriteria,
)
```

**Deskripsi:**
Menghitung matriks terbobot dengan mengalikan setiap nilai normalisasi dengan bobot kriteria.

**Rumus:**
$$y_{ij} = w_j \times r_{ij}$$

**Kode Implementasi (Baris 1500-1503):**

```dart
for (int j = 0; j < jumlahKriteria; j++) {
  double w = bobot[j];  // w_j = bobot kriteria j
  // y_ij = w_j × r_ij
  matriksTerbobot[i][j] = _roundExcel(matriksNormal[i][j] * w);
}
```

**Penjelasan Baris per Baris:**
| Baris | Kode | Penjelasan |
|-------|------|------------|
| 1 | `for (int j = 0; j < jumlahKriteria; j++)` | Loop untuk setiap kriteria |
| 2 | `double w = bobot[j]` | Ambil bobot kriteria ke-j (w_j) |
| 3 | `matriksTerbobot[i][j] = _roundExcel(matriksNormal[i][j] * w)` | **y_ij = w_j × r_ij** - perkalian bobot dengan nilai normalisasi |

---

### 4.9 Fungsi `_hitungNilaiPreferensi()` - STEP 5 ⭐ IMPLEMENTASI RUMUS V

**Lokasi:** Baris 1522-1592

**Signature:**

```dart
static List<HasilPreferensi> _hitungNilaiPreferensi(
  List<DataAlternatif> dataAlternatif,
  List<List<double>> matriksTerbobot,
  List<String> namaKriteria,
)
```

**Deskripsi:**
Menghitung nilai preferensi untuk setiap alternatif. Ini adalah **implementasi langsung dari Rumus (4)** dari referensi.

**IMPLEMENTASI RUMUS (4):**
$$V_i = \sum_{j=1}^{n} w_j \times r_{ij}$$

**Kode Implementasi (Baris 1557-1559):**

```dart
// V_i = Σ(w_j * r_ij) = Σ(y_ij)
double total = nilaiPerKriteria.fold(0.0, (sum, val) => sum + val);
total = _roundExcel(total);
```

**Penjelasan Baris per Baris:**
| Baris | Kode | Penjelasan |
|-------|------|------------|
| 1 | `final nilaiPerKriteria = matriksTerbobot[i]` | Ambil baris matriks terbobot untuk alternatif ke-i (semua y_ij) |
| 2 | `double total = nilaiPerKriteria.fold(0.0, (sum, val) => sum + val)` | **Σ(y_ij)** - menjumlahkan semua nilai terbobot |
| 3 | `total = _roundExcel(total)` | Pembulatan untuk presisi seperti Excel |

**Kode Lengkap dengan Komentar:**

```dart
for (int i = 0; i < dataAlternatif.length; i++) {
  final alternatif = dataAlternatif[i];

  // Ambil semua nilai terbobot untuk alternatif i
  // nilaiPerKriteria = [y_i1, y_i2, y_i3, ..., y_in]
  final nilaiPerKriteria = matriksTerbobot[i];

  // RUMUS (4): V_i = Σ(j=1 sampai n) w_j × r_ij
  // Karena y_ij = w_j × r_ij, maka:
  // V_i = Σ(y_ij) = y_i1 + y_i2 + y_i3 + ... + y_in
  double total = nilaiPerKriteria.fold(0.0, (sum, val) => sum + val);
  total = _roundExcel(total);

  hasil.add(HasilPreferensi(
    kode: alternatif.kode,
    namaKost: alternatif.namaKost,
    nilaiPerKriteria: nilaiPerKriteria,
    totalPreferensi: total,  // V_i
  ));
}
```

**Contoh Perhitungan V:**

_Data Matriks Terbobot:_
| Alternatif | y₁ (Biaya) | y₂ (Fasilitas) | y₃ (Luas) | y₄ (Jarak) |
|------------|------------|----------------|-----------|------------|
| A1 | 0.3056 | 0.1200 | 0.0889 | 0.0750 |
| A2 | 0.2444 | 0.0900 | 0.1333 | 0.1000 |
| A3 | 0.4074 | 0.1500 | 0.0667 | 0.0500 |

_Perhitungan V:_

- V₁ = 0.3056 + 0.1200 + 0.0889 + 0.0750 = **0.5895**
- V₂ = 0.2444 + 0.0900 + 0.1333 + 0.1000 = **0.5677**
- V₃ = 0.4074 + 0.1500 + 0.0667 + 0.0500 = **0.6741**

---

### 4.10 Fungsi `_buatPerangkingan()` - STEP 6

**Lokasi:** Baris 1598-1673

**Signature:**

```dart
static List<HasilRanking> _buatPerangkingan(
  List<HasilPreferensi> hasilPreferensi,
  List<DataAlternatif> dataAlternatif,
)
```

**Deskripsi:**
Membuat perangkingan berdasarkan nilai preferensi tertinggi.

**Prinsip:**

> Alternatif terbaik adalah yang memiliki nilai V_i MAKSIMUM

**Kode Implementasi (Baris 1632-1638):**

```dart
// Urutkan berdasarkan total preferensi (descending)
combined.sort((a, b) {
  final prefA = a['preferensi'] as HasilPreferensi;
  final prefB = b['preferensi'] as HasilPreferensi;
  return prefB.totalPreferensi.compareTo(prefA.totalPreferensi);
});
```

**Penjelasan:**

- `compareTo` membandingkan dua nilai
- Urutan `prefB.compareTo(prefA)` = descending (terbesar ke terkecil)
- Alternatif dengan V tertinggi mendapat peringkat 1

**Contoh Hasil Perangkingan:**

| Peringkat | Alternatif | Nama Kost   | Nilai V |
| --------- | ---------- | ----------- | ------- |
| 1         | A3         | Kost Melati | 0.6741  |
| 2         | A1         | Kost Dahlia | 0.5895  |
| 3         | A2         | Kost Mawar  | 0.5677  |

---

### 4.11 Fungsi Helper: `_roundExcel()`

**Lokasi:** Baris 132-134

```dart
static double _roundExcel(double value) {
  return double.parse(value.toStringAsFixed(_excelLikePrecision));
}
```

**Deskripsi:**
Membulatkan nilai ke 4 desimal untuk konsistensi dengan perhitungan Excel.

**Konstanta:**

```dart
static const int _excelLikePrecision = 4;
```

---

### 4.12 Fungsi Helper: `hitungJarakKm()` (Haversine - DEPRECATED)

**Lokasi:** Baris 150-172

```dart
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

  return jarak;
}
```

**Rumus Haversine:**
$$a = \sin^2(\frac{\Delta lat}{2}) + \cos(lat_1) \times \cos(lat_2) \times \sin^2(\frac{\Delta lng}{2})$$
$$c = 2 \times \arctan2(\sqrt{a}, \sqrt{1-a})$$
$$d = R \times c$$

**Catatan:** Fungsi ini sudah tidak digunakan untuk rekomendasi. Jarak sekarang menggunakan OSRM (jarak jalan yang lebih akurat).

---

## 5. IMPLEMENTASI RUMUS SAW DALAM KODE

### 5.1 Ringkasan Implementasi

| Rumus          | Formula                        | Fungsi                     | Baris Kode |
| -------------- | ------------------------------ | -------------------------- | ---------- |
| (2) Benefit    | $r_{ij} = x_{ij} / \max(x_j)$  | `_normalisasiMatriks()`    | 1428-1433  |
| (3) Cost       | $r_{ij} = \min(x_j) / x_{ij}$  | `_normalisasiMatriks()`    | 1419-1424  |
| (4) Preferensi | $V_i = \sum w_j \times r_{ij}$ | `_hitungNilaiPreferensi()` | 1557-1559  |

### 5.2 Mapping Kode ke Simbol Matematika

| Simbol      | Variabel dalam Kode            | Penjelasan                           |
| ----------- | ------------------------------ | ------------------------------------ |
| $x_{ij}$    | `matriks[i][j]` atau `nilai`   | Nilai alternatif i pada kriteria j   |
| $\max(x_j)$ | `maxKolom`                     | Nilai maksimum pada kolom/kriteria j |
| $\min(x_j)$ | `minKolom`                     | Nilai minimum pada kolom/kriteria j  |
| $r_{ij}$    | `matriksNormal[i][j]`          | Nilai normalisasi                    |
| $w_j$       | `bobot[j]` atau `w`            | Bobot kriteria j                     |
| $y_{ij}$    | `matriksTerbobot[i][j]`        | Nilai terbobot                       |
| $V_i$       | `total` atau `totalPreferensi` | Nilai preferensi alternatif i        |
| $n$         | `jumlahKriteria`               | Jumlah kriteria                      |

---

## 6. ALUR KERJA SAW END-TO-END

```
┌─────────────────────────────────────────────────────────────────┐
│                     FLOW PERHITUNGAN SAW                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  [1] INPUT DATA                                                 │
│      │                                                          │
│      ├─ listKost (A1, A2, A3, ...)                              │
│      ├─ listKriteria (C1: Biaya, C2: Fasilitas, ...)            │
│      ├─ listSubkriteria (range konversi nilai)                  │
│      └─ jarakKostMap (jarak OSRM)                               │
│                                                                 │
│  [2] STEP 1: BUAT DATA ALTERNATIF                               │
│      │                                                          │
│      └─ Konversi nilai mentah → bobot subkriteria               │
│         Contoh: Rp 800.000 → bobot 5                            │
│                                                                 │
│  [3] STEP 2: MATRIKS KEPUTUSAN (X)                              │
│      │                                                          │
│      │      C1    C2    C3    C4                                │
│      │  A1  5.0   8.0   9.0   3.0                               │
│      │  A2  4.0   6.0  12.0   4.0                               │
│      │  A3  3.0  10.0   6.0   2.0                               │
│      │                                                          │
│  [4] STEP 3: NORMALISASI (R)                                    │
│      │                                                          │
│      │  BENEFIT: r = x / max(x)                                 │
│      │  COST:    r = min(x) / x                                 │
│      │                                                          │
│      │      C1    C2    C3    C4                                │
│      │  A1  0.60  0.80  0.75  0.67                              │
│      │  A2  0.75  0.60  1.00  0.50                              │
│      │  A3  1.00  1.00  0.50  1.00                              │
│      │                                                          │
│  [5] STEP 4: MATRIKS TERBOBOT (Y = W × R)                       │
│      │                                                          │
│      │  W = [0.4074, 0.1500, 0.1333, 0.1000]                    │
│      │                                                          │
│      │      C1     C2     C3     C4                             │
│      │  A1  0.244  0.120  0.100  0.067                          │
│      │  A2  0.306  0.090  0.133  0.050                          │
│      │  A3  0.407  0.150  0.067  0.100                          │
│      │                                                          │
│  [6] STEP 5: NILAI PREFERENSI (V = Σy)                          │
│      │                                                          │
│      │  V1 = 0.244 + 0.120 + 0.100 + 0.067 = 0.531              │
│      │  V2 = 0.306 + 0.090 + 0.133 + 0.050 = 0.579              │
│      │  V3 = 0.407 + 0.150 + 0.067 + 0.100 = 0.724              │
│      │                                                          │
│  [7] STEP 6: RANKING                                            │
│      │                                                          │
│      │  #1 - A3 (Kost Melati)  = 0.724  ← TERBAIK               │
│      │  #2 - A2 (Kost Mawar)   = 0.579                          │
│      │  #3 - A1 (Kost Dahlia)  = 0.531                          │
│      │                                                          │
│  [8] OUTPUT: HasilSAW                                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 7. KESIMPULAN

### 7.1 Kesesuaian dengan Teori

Implementasi dalam file `simple_additive_weighting.dart` **sesuai dengan rumus SAW standar** dari referensi (Tarigan et al., 2022):

| Aspek               | Referensi                      | Implementasi           | Status    |
| ------------------- | ------------------------------ | ---------------------- | --------- |
| Normalisasi Benefit | $r_{ij} = x_{ij} / \max(x_j)$  | `nilai / maxKolom`     | ✅ Sesuai |
| Normalisasi Cost    | $r_{ij} = \min(x_j) / x_{ij}$  | `minKolom / nilai`     | ✅ Sesuai |
| Nilai Preferensi    | $V_i = \sum w_j \times r_{ij}$ | `fold(0.0, sum + val)` | ✅ Sesuai |
| Perangkingan        | V tertinggi = terbaik          | `sort descending`      | ✅ Sesuai |

### 7.2 Fitur Tambahan Implementasi

1. **Konversi Subkriteria** - Nilai mentah dikonversi ke bobot menggunakan range dari database
2. **Penanganan Jarak OSRM** - Menggunakan jarak jalan, bukan garis lurus
3. **Presisi Excel** - Pembulatan 4 desimal untuk konsistensi
4. **Logging Detail** - Setiap langkah menampilkan rumus dan hasil perhitungan
5. **Penanganan Error** - Kost yang tidak valid dikelompokkan dalam `kostTerskip`

### 7.3 Daftar Fungsi Utama

| No  | Fungsi                     | Langkah SAW  | Rumus      |
| --- | -------------------------- | ------------ | ---------- |
| 1   | `hitungSAW()`              | Orchestrator | -          |
| 2   | `_buatDataAlternatif()`    | Step 1       | -          |
| 3   | `_buatMatriksKeputusan()`  | Step 2       | X = [x_ij] |
| 4   | `_normalisasiMatriks()`    | Step 3       | R = [r_ij] |
| 5   | `_hitungMatriksTerbobot()` | Step 4       | Y = W × R  |
| 6   | `_hitungNilaiPreferensi()` | Step 5       | V = Σy     |
| 7   | `_buatPerangkingan()`      | Step 6       | Ranking    |

---

**Dokumen ini dibuat untuk keperluan dokumentasi skripsi.**

_Referensi: Tarigan et al., 2022_
