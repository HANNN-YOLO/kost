# Analisis Implementasi Metode SAW (Simple Additive Weighting)

Dokumen ini menjelaskan alur kode yang menerapkan metode **SAW** pada aplikasi ini, mulai dari **Screen → Provider → Service → Algoritma → kembali ke Provider → Screen**, sampai tampil di halaman **Recommendation SAW**.

Tanggal penulisan: 21 Feb 2026.

---

## 1) Gambaran Singkat

Metode SAW digunakan untuk melakukan **perangkingan kost** berdasarkan sejumlah **kriteria** (misalnya biaya, fasilitas, luas kamar, jarak, keamanan, dan lain-lain). Implementasi di proyek ini memakai pola:

- **Screen**: mengumpulkan input user (mis. tujuan), menghitung jarak jalan via OSRM, memicu provider untuk menjalankan SAW, dan menampilkan hasil.
- **Provider (`KostProvider`)**: memegang state (loading/error/hasil), mengambil data kriteria & subkriteria dari service, lalu memanggil algoritma SAW.
- **Service**: mengambil data dari Supabase REST (kost, kriteria, subkriteria).
- **Algoritma (`SimpleAdditiveWeighting`)**: melakukan perhitungan SAW lengkap dan mengembalikan objek `HasilSAW`.

---

## 2) Lokasi File Utama

- Halaman rekomendasi awal (menghitung jarak OSRM & navigasi ke SAW):
  - [lib/screens/main/penyewa/recommendation.dart](lib/screens/main/penyewa/recommendation.dart)
- Halaman hasil rekomendasi SAW:
  - [lib/screens/main/penyewa/recommendation_saw.dart](lib/screens/main/penyewa/recommendation_saw.dart)
- Halaman detail proses/tabel perhitungan SAW:
  - [lib/screens/main/penyewa/process_saw.dart](lib/screens/main/penyewa/process_saw.dart)
- Provider utama (state + pemicu perhitungan):
  - [lib/providers/kost_provider.dart](lib/providers/kost_provider.dart)
- Algoritma SAW:
  - [lib/algoritma/simple_additive_weighting.dart](lib/algoritma/simple_additive_weighting.dart)
- Service data:
  - [lib/services/kost_service.dart](lib/services/kost_service.dart)
  - [lib/services/kriteria_services.dart](lib/services/kriteria_services.dart)
  - [lib/services/subkriteria_services.dart](lib/services/subkriteria_services.dart)
- Algoritma pembobotan ROC (dipakai untuk membangkitkan bobot kriteria, lalu disimpan ke DB):
  - [lib/algoritma/rank_order_centroid.dart](lib/algoritma/rank_order_centroid.dart)

---

## 3) Diagram Alur Data (End-to-End)

```mermaid
flowchart LR
  A[Screen recommendation.dart
User pilih tujuan] --> B[Hitung jarak OSRM
(table/route)]
  B --> C[Build jarakMap id_kost->km
& kostData]
  C --> D[KostProvider.setJarakKostMap]
  D --> E[Navigate ke RecommendationSawPage
(recommendation_saw.dart)]

  E --> F[KostProvider.hitungSAW
(set userLat/Lng)]
  F --> G[KostProvider.fetchKriteria
(KriteriaServices)]
  F --> H[KostProvider.fetchSubkriteria
(SubkriteriaServices)]
  F --> I[SimpleAdditiveWeighting.hitungSAW]
  I --> J[HasilSAW disimpan
ke KostProvider]
  J --> K[Consumer<KostProvider>
Render loading/error/hasil]
  K --> L[Ranking list + filter
& jarak dari kostData]

  E --> M[ProcessSawPage
(process_saw.dart)]
  M --> F
```

---

## 4) Tahap 1 — Screen: Hitung jarak OSRM & masuk ke halaman SAW

### 4.1 Peran halaman Recommendation (sebelum SAW)

Pada [bagian ini](lib/screens/main/penyewa/recommendation.dart#L1100-L1305), screen melakukan:

1. Mengambil semua data kost dari provider (`kostpenyewa` kalau ada, jika tidak gunakan `kost`).
2. Mengumpulkan daftar destinasi (koordinat kost) untuk dihitung jaraknya.
3. Menghitung jarak **tujuan → kost** secara batching via OSRM table, lalu fallback ke OSRM route jika ada yang belum dapat jarak.
4. Menyusun:
   - `dataKost`: list map ringkas (id, nama, harga, `distanceKm`, dll) untuk dipakai UI SAW.
   - `jarakMap`: map `id_kost -> distanceKm`.
5. Menyimpan `jarakMap` ke provider agar algoritma SAW memakai jarak jalan (bukan haversine).
6. Navigasi ke `RecommendationSawPage`.

Bagian krusial:

- Menyimpan jarak ke provider: [setJarakKostMap](lib/screens/main/penyewa/recommendation.dart#L1238-L1246)
- Navigasi ke SAW page: [push RecommendationSawPage](lib/screens/main/penyewa/recommendation.dart#L1249-L1260)

**Catatan desain penting**: jarak yang dipakai SAW di proyek ini adalah **jarak jalan (road distance)** dari OSRM, bukan jarak garis lurus.

---

## 5) Tahap 2 — Screen: Halaman hasil SAW (RecommendationSawPage)

### 5.1 Auto-run SAW saat halaman dibuka

Di [RecommendationSawPage.initState](lib/screens/main/penyewa/recommendation_saw.dart#L470-L488):

- mengambil instance provider sekali (`context.read<KostProvider>()`)
- menjalankan `provider.hitungSAW(userLat, userLng)` pada `addPostFrameCallback`

`userLat/userLng` yang dikirim adalah koordinat tujuan (destination) dari halaman sebelumnya.

### 5.2 Render state dari provider

Pada [body Consumer<KostProvider>](lib/screens/main/penyewa/recommendation_saw.dart#L535-L676), UI mengikuti state provider:

- `isLoadingSAW = true` → tampil loading
- `errorSAW != null` → tampil error + tombol “Coba Lagi” (memanggil `hitungSAW` lagi)
- `hasilSAW == null` → tampil “Belum ada hasil rekomendasi”
- `hasilSAW != null` → tampil daftar ranking

### 5.3 Jarak di card hasil: diambil dari `kostData`

Walaupun algoritma SAW mengambil jarak dari `jarakKostMap` (yang disimpan di provider), halaman UI juga menampilkan jarak di card ranking dengan mengambilnya dari argumen `kostData` (hasil OSRM dari halaman sebelumnya).

- Helper pembaca jarak: [\_getDistanceKmFromArgs](lib/screens/main/penyewa/recommendation_saw.dart#L295-L313)
- Dipakai saat build ranking card: [pemakaian distanceKm](lib/screens/main/penyewa/recommendation_saw.dart#L1111-L1148)

---

## 6) Tahap 3 — Provider: `KostProvider.hitungSAW()` sebagai “orchestrator”

### 6.1 State yang disimpan di provider

Provider menyimpan state SAW berikut:

- `hasilSAW`: hasil perhitungan lengkap
- `isLoadingSAW`: flag loading
- `errorSAW`: pesan error bila gagal
- `userLat/userLng`: lokasi tujuan/user untuk kriteria jarak
- `jarakKostMap`: map jarak OSRM id_kost → km

Lihat: [state SAW di provider](lib/providers/kost_provider.dart#L1360-L1417)

### 6.2 Set jarak hasil OSRM

Dari halaman recommendation, jarak disimpan ke provider lewat:

- [setJarakKostMap](lib/providers/kost_provider.dart#L1395-L1403)

### 6.3 Eksekusi perhitungan

Di [hitungSAW](lib/providers/kost_provider.dart#L1466-L1554), provider melakukan:

1. (Opsional) menyimpan lokasi user/tujuan via `setUserLocation(lat,lng)`.
2. Set loading state (`_isLoadingSAW = true`), clear error.
3. Memanggil `fetchKriteria()` dan `fetchSubkriteria()`.
4. Validasi data (misal `kostpenyewa` tidak kosong, `listKriteria` ada).
5. Memanggil algoritma:
   - `SimpleAdditiveWeighting.hitungSAW(...)`
   - parameter penting: `jarakKostMap: _jarakKostMap`

6. Menyimpan hasil ke `_hasilSAW` dan `notifyListeners()`.

**Kembali ke Screen**: karena screen memakai `Consumer<KostProvider>`, maka UI otomatis re-render saat `notifyListeners()` terpanggil.

---

## 7) Tahap 4 — Service: sumber data yang dipakai SAW

### 7.1 Service Kriteria (urutan + bobot)

Provider mengambil kriteria dari service:

- Endpoint: `kriteria?order=ranking.asc`
- Tujuan: memastikan urutan `C1..Cn` konsisten sesuai ranking

Lihat: [KriteriaServices.readdata](lib/services/kriteria_services.dart#L33-L104)

**Catatan bobot**: algoritma SAW memakai `bobot_decimal` dari database (bukan menghitung ulang ROC di runtime).

### 7.1.1 Algoritma ROC (Rank Order Centroid) — Perhitungan bobot

ROC dipakai untuk **mengubah urutan prioritas (ranking) menjadi bobot** yang totalnya ter-normalisasi (jumlah bobot ≈ 1). Implementasinya ada di:

- [lib/algoritma/rank_order_centroid.dart](lib/algoritma/rank_order_centroid.dart)

#### Rumus ROC

Untuk $n$ kriteria dan posisi ranking $k$ (1 = paling penting):

$$
W_k = \frac{1}{n} \sum_{i=k}^{n} \frac{1}{i}
$$

#### Implementasi di kode

Di algoritma, perhitungan dilakukan oleh fungsi `RankOrderCentroid.hitungBobot()`:

1. Ambil $n = jumlah\_kriteria$.
2. Untuk setiap ranking $k = 1..n$:
   - Hitung $\sigma = \sum_{i=k}^{n} (1/i)$
   - Hitung bobot $W_k = (1/n) \times \sigma$
3. Simpan hasil ke `Map<int,double>`: key = ranking, value = bobot.
4. Verifikasi total bobot (seharusnya mendekati 1).

Fungsi `RankOrderCentroid.aplikasikanBobot()` lalu:

- Mengurutkan list kriteria berdasarkan field `ranking`.
- Mengambil bobot sesuai ranking dari hasil `hitungBobot()`.
- Mengisi 2 field:
  - `bobot` (integer persentase, dibulatkan dari `bobot_decimal * 100`)
  - `bobot_decimal` (double 0..1)

#### ROC dipanggil dari mana?

ROC tidak dipanggil oleh SAW secara langsung. ROC dipakai saat **admin menyimpan/merubah urutan kriteria**, agar bobot tersimpan di database. Pemanggil utamanya ada di provider kriteria:

- `KriteriaProvider.savemassal()` → hitung ROC lalu create ke DB
- `KriteriaProvider.updatedmassal()` → hitung ROC lalu update/create ke DB
- `KriteriaProvider._recalculateROC()` → hitung ulang ROC saat ada kriteria dihapus

Sesudah bobot tersimpan, SAW mengambil bobot dari field `bobot_decimal` tabel `kriteria`.

### 7.2 Service Subkriteria (konversi nilai)

- Endpoint: `sub_kriteria?order=id_kriteria.asc,bobot.desc`
- Tujuan: konversi nilai mentah (string/range) menjadi skor numerik (bobot)

Lihat: [SubkriteriaServices.readdata](lib/services/subkriteria_services.dart#L7-L38)

### 7.3 Service Kost (alternatif)

Untuk penyewa, provider memanggil service:

- [KostService.readdatapenyewa](lib/services/kost_service.dart#L354-L378)
- Provider mengisi `_kostpenyewa`: [readdatapenyewa di provider](lib/providers/kost_provider.dart#L1016-L1048)

Untuk admin, ada jalur `KostService.readdata` yang sudah `order=id_kost.asc` agar kode alternatif A1, A2, ... stabil.

---

## 8) Tahap 5 — Algoritma: `SimpleAdditiveWeighting.hitungSAW()`

### 8.1 Kontrak input-output

Input utama:

- `listKost`: daftar kost (alternatif)
- `listKriteria`: daftar kriteria (punya `ranking`, `atribut`, `bobot_decimal`)
- `listSubkriteria`: daftar subkriteria (untuk konversi)
- `userLat/userLng`: dipakai jika ada kriteria jarak
- `jarakKostMap`: hasil jarak OSRM (id_kost → km)

Output:

- objek [HasilSAW](lib/algoritma/simple_additive_weighting.dart#L33-L58) berisi:
  - `dataAlternatif`
  - matriks keputusan, normalisasi, terbobot
  - `hasilPreferensi`
  - `hasilRanking`
  - `kostTerskip` (yang tidak diproses karena tidak cocok subkriteria / data jarak tidak ada)

### 8.2 Step SAW yang diimplementasikan

SAW diimplementasikan sesuai rumus standar:

1. Matriks keputusan $X = [x_{ij}]$
2. Normalisasi $R = [r_{ij}]$
   - Benefit: $r_{ij} = \frac{x_{ij}}{\max(x_j)}$
   - Cost: $r_{ij} = \frac{\min(x_j)}{x_{ij}}$
3. Matriks terbobot $Y = w \cdot R$
4. Nilai preferensi $V_i = \sum_j (w_j \cdot r_{ij})$
5. Ranking berdasarkan $V_i$ terbesar

Lihat implementasi flow utama pada: [hitungSAW](lib/algoritma/simple_additive_weighting.dart#L187-L414)

### 8.3 Sorting kriteria berdasarkan ranking

Algoritma mengurutkan kriteria berdasarkan `ranking` agar urutan C1..Cn konsisten:

- [sorting kriteria](lib/algoritma/simple_additive_weighting.dart#L277-L288)

### 8.4 Pembentukan data alternatif + konversi subkriteria

Pada step 1, setiap kost dibentuk menjadi `DataAlternatif` dan setiap nilai kriteria dikonversi.

- Builder: [\_buatDataAlternatif](lib/algoritma/simple_additive_weighting.dart#L433-L599)
- Jika ada kriteria jarak:
  - prioritas memakai `jarakKostMap[id_kost]`
  - jika tidak ada jarak, alternatif bisa diberi nilai 0 dan masuk daftar `kostTerskip`
  - lihat: [blok jarak OSRM](lib/algoritma/simple_additive_weighting.dart#L483-L510)

### 8.5 Mapping kategori kriteria ke field kost

Nilai mentah diambil melalui helper:

- [\_ambilNilaiKriteria](lib/algoritma/simple_additive_weighting.dart#L629-L756)

Mapping yang terlihat di fungsi tersebut (ringkas):

- **Biaya/Harga** → `kost.harga_kost` (dinormalisasi ke _per bulan_ jika `kost.per` tahunan)
- **Fasilitas** → jumlah item dalam string `kost.fasilitas` (comma-separated)
- **Luas** → `kost.panjang * kost.lebar`
- **Keamanan** → `kost.keamanan`
- **Batas jam malam** → `kost.batas_jam_malam`
- **Jenis kost** → `kost.penghuni`/`kost.jenis_kost` (tergantung definisi kategori di DB)
- **Listrik/Air** → `kost.jenis_listrik`, `kost.jenis_pembayaran_air`
- **Jarak** → dari OSRM (`jarakKostMap`)

---

## 9) Kembali ke Screen: bagaimana hasil tampil di UI

Setelah algoritma selesai:

- Provider menyimpan `hasilSAW` dan mematikan `isLoadingSAW`, lalu `notifyListeners()`.
- Halaman [RecommendationSawPage](lib/screens/main/penyewa/recommendation_saw.dart) menangkap perubahan state via `Consumer<KostProvider>`.
- Ranking ditampilkan berdasarkan `hasilSAW.hasilRanking`.
- Halaman [ProcessSawPage](lib/screens/main/penyewa/process_saw.dart) menampilkan tabel lengkap (matriks keputusan, normalisasi, terbobot, preferensi, ranking) dari objek `HasilSAW`.

---

## 10) Catatan Penting & Edge Case

1. **Jika `jarakKostMap` kosong** (atau tidak ada entry untuk kost tertentu), algoritma akan memberi nilai jarak 0 untuk kost tersebut dan bisa memasukkan ke `kostTerskip` (tergantung aturan konversi jarak).
2. **Jika semua kost “tidak cocok subkriteria”**, `HasilSAW` tetap dikembalikan tetapi `hasilRanking` bisa kosong dan `kostTerskip` berisi alasan.
3. **Bobot kriteria** diambil dari `bobot_decimal` di tabel `kriteria`.
   - ROC tersedia di [rank_order_centroid.dart](lib/algoritma/rank_order_centroid.dart) untuk membantu membangkitkan bobot dari ranking, tetapi pada runtime SAW menggunakan bobot dari DB.
4. **Fasilitas** sudah dipindahkan ke `kost.fasilitas` (string). Algoritma sudah punya jalur “versi baru” untuk menghitung jumlah fasilitas dari string.

---

## 11) Cara Debug Cepat (opsional)

- Jalankan app dalam mode debug.
- Buka halaman rekomendasi → pilih tujuan → masuk ke SAW.
- Perhatikan log:
  - Screen: log OSRM (jarak) + pengisian `jarakMap`
  - Provider: log fetch kriteria/subkriteria + ringkasan input SAW
  - Algoritma: log step 1..6 (matriks & ranking)

---

Jika Anda mau, saya bisa tambahkan juga bagian “contoh data kecil (2–3 kost)” untuk menunjukkan perhitungan SAW secara manual agar cocok dengan output di `ProcessSawPage`.
