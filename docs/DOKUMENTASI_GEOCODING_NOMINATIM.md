# Dokumentasi Fitur Geocoding (Alamat → Koordinat) dengan Nominatim + Leaflet (Gratis)

Tanggal: 2026-02-22

## 1. Tujuan Fitur

Fitur ini dibuat untuk memenuhi kebutuhan: **ketika user mengisi alamat lengkap, sistem bisa menentukan titik koordinat secara otomatis** (tanpa Google Maps billing), lalu menampilkan titik tersebut di peta.

Solusi yang digunakan:

- **Tampilan peta**: LeafletJS di file HTML asset, ditampilkan lewat **WebView Flutter**.
- **Geocoding (alamat → lat/lng)**: **Nominatim** (OpenStreetMap).

Catatan penting:

- Leaflet hanya untuk menampilkan peta/marker. Leaflet **tidak** punya kemampuan “alamat → koordinat”. Itu tugas geocoding (Nominatim).

## 2. Lokasi Implementasi di Project

Komponen utama yang terlibat:

1. Service geocoding (shared)

- `lib/services/nominatim_geocoding_service.dart`

2. Form input kost + map (admin)

- `lib/screens/main/admin/form_house.dart`

3. Form input kost + map (pemilik)

- `lib/screens/main/pemilik/form_house_pemilik.dart`

4. Map engine (Leaflet)

- `assets/map/map.html`

## 3. Alur Kerja (Flow) Fitur

### 3.1. Interaksi User

1. User mengisi field **Alamat**.
2. User menekan ikon **Search** di sisi kanan field Alamat (atau tekan tombol search/enter pada keyboard).
3. Aplikasi mengirim request ke Nominatim untuk mencari kandidat lokasi.
4. Jika kandidat lebih dari 1:
   - Aplikasi menampilkan **bottom sheet** untuk memilih alamat yang benar.
5. Setelah user memilih:
   - Field **Koordinat** otomatis terisi format `lat, lng`.
   - Marker peta berpindah ke lokasi tersebut.

### 3.2. Mekanisme Teknis

- Flutter memanggil service:
  - `NominatimGeocodingService.instance.searchAddress(query, ...)`
- Service mengakses endpoint:
  - `https://nominatim.openstreetmap.org/search`
- Setelah dapat `lat` dan `lng`, form:
  - mengisi controller koordinat
  - memanggil JavaScript di WebView (Leaflet) untuk menggeser marker

## 4. Detail Service Nominatim

File: `lib/services/nominatim_geocoding_service.dart`

Yang dilakukan service ini:

- Mengirim HTTP GET ke Nominatim `/search`
- Mengambil field penting:
  - `lat`
  - `lon`
  - `display_name`
- Mengembalikan list kandidat `NominatimPlace` (lat, lng, displayName)

Proteksi pemakaian public Nominatim:

- **Throttle** minimal 1 detik antar request (menghindari spam)
- **Cache in-memory** untuk query yang sama (mengurangi request berulang)
- **Timeout** request (12 detik)
- **Header User-Agent** untuk identitas aplikasi

Parameter request penting:

- `format=json`
- `limit=5`
- `countrycodes=id` (membatasi ke Indonesia)
- `accept-language=id`
- `addressdetails=1`

## 5. Integrasi di Form (Admin dan Pemilik)

### 5.1. Tombol Search pada Field Alamat

- Pada field **Alamat**, ada suffix icon:
  - ikon search (normal)
  - loading spinner ketika request berjalan

Trigger geocoding terjadi pada:

- menekan tombol search (ikon)
- `onSubmitted` (keyboard action search)

### 5.2. Pemilihan Hasil (Jika Kandidat > 1)

- Ketika Nominatim mengembalikan beberapa hasil, sistem menampilkan bottom sheet.
- User memilih salah satu.

### 5.3. Sinkronisasi dengan Map yang Belum Siap

Kadang map WebView belum selesai load saat hasil geocoding sudah didapat.
Untuk itu:

- form menyimpan `_pendingMarkerLat/_pendingMarkerLng`
- saat `onPageFinished`, marker akan di-apply ke map.

## 6. Dokumentasi Input “Alamat Lengkap” (Agar Akurasi Tinggi)

Geocoding Nominatim bersifat _text search_ sehingga kualitas hasil sangat tergantung pada kelengkapan alamat.

### 6.1. Format Alamat yang Disarankan (Indonesia)

Tulis alamat dengan urutan dari spesifik → umum, dipisahkan koma:

**Template:**

- `Nama jalan + nomor (jika ada), Kelurahan/Desa, Kecamatan, Kota/Kabupaten, Provinsi, Kode Pos, Indonesia`

**Jika ada penanda lokal:**

- Tambahkan `RT/RW` dan/atau nama kompleks/gedung/landmark.

**Khusus alamat di dalam kompleks/perumahan (ada RT/RW):**

- `Blok/Cluster + No Rumah, RT xx/RW yy, Nama Kompleks/Perumahan, Kelurahan/Desa, Kecamatan, Kota/Kabupaten, Provinsi, Kode Pos, Indonesia`

Catatan:

- Jika alamat di dalam kompleks tidak punya nama jalan yang jelas, **blok/cluster + nomor rumah** biasanya lebih membantu.
- Format RT/RW yang umum: `RT 001/RW 002` (pakai 3 digit juga boleh, yang penting konsisten).
- Kalau ada patokan yang terkenal (misalnya “dekat gerbang utama/pos satpam/masjid kompleks”), boleh ditambahkan di depan.

### 6.2. Contoh Alamat Lengkap (Baik)

1. Dengan jalan dan nomor:

- `Jl. Sudirman No. 12, Kelurahan ABC, Kecamatan XYZ, Kota Jayapura, Papua, 99111, Indonesia`

2. Dengan landmark/gedung:

- `Dekat Kampus UNDIPA, Jl. Raya Abepura, Kecamatan Abepura, Kota Jayapura, Papua, Indonesia`

3. Jika tanpa nomor rumah:

- `Jl. Diponegoro, Kelurahan Mangunharjo, Kecamatan Mayangan, Kota Probolinggo, Jawa Timur, Indonesia`

4. Jika berada di dalam kompleks/perumahan dan ada RT/RW:

- `Blok B No. 12, RT 003/RW 001, Perumahan Griya Harmoni, Kelurahan Abepura, Kecamatan Abepura, Kota Jayapura, Papua, 99351, Indonesia`

### 6.3. Tips Penulisan Agar Tidak Melenceng

- Gunakan **nama kota/kabupaten dan provinsi** (wajib bila nama jalan umum).
- Hindari singkatan yang terlalu pendek/ambigu.
  - contoh: lebih baik tulis `Kecamatan`/`Kabupaten`/`Kota` secara jelas.
- Tambahkan **kode pos** jika tahu.
- Jika ada beberapa “Jl. Merdeka” di kota berbeda, selalu tulis kota/provinsi.
- Untuk kos: tambahkan nama area/kampus/landmark populer.

### 6.4. Jika Hasil Tidak Tepat

Jika lokasi yang muncul tidak sesuai:

1. Perbaiki alamat (tambah kota, kecamatan, provinsi, atau landmark).
2. Coba lagi, lalu pilih kandidat yang benar di bottom sheet.
3. Jika tetap salah, user masih bisa:
   - memilih titik lewat mode “Lokasi Tujuan” (double tap di peta)
   - atau mengisi koordinat manual

### 6.5. Contoh Alamat Kompleks yang Sering Gagal (dan Solusinya)

Kadang alamat sudah lengkap, tetapi **tetap tidak ditemukan** oleh Nominatim. Penyebab umumnya:

- Detail blok/nomor rumah/RT/RW **belum ada** atau **belum rapi** di data OpenStreetMap untuk area tersebut.
- Nama kompleks ditulis dengan singkatan yang tidak umum di OSM (misal `BTN`).

Contoh input yang bisa saja gagal:

- `BTN PONDOK ASRI II BLOK F2/14, RT 001/RW 009, Bakung, Biringkanaya, Makassar, Sulawesi Selatan, 90242, Indonesia`

Jika gagal, coba variasi berikut (mulai dari yang paling mudah dicari):

1. Ganti singkatan `BTN` menjadi kata yang lebih umum:

- `Perumahan Pondok Asri II, Bakung, Kecamatan Biringkanaya, Kota Makassar, Sulawesi Selatan, Indonesia`

2. Tambahkan blok/nomor rumah tetapi tetap pakai kata “Perumahan/Komplek”:

- `Blok F2 No. 14, Perumahan Pondok Asri II, Bakung, Kecamatan Biringkanaya, Kota Makassar, Sulawesi Selatan, Indonesia`

3. Jika masih gagal, cari dulu level yang lebih umum (kompleks/kelurahan), lalu set titik manual di peta:

- `Bakung, Kecamatan Biringkanaya, Kota Makassar, Sulawesi Selatan, Indonesia`

Catatan praktik saat testing:

- Jangan mengetes request berkali-kali terlalu cepat (ada throttle minimal 1 detik).
- Jika hasilnya “mendekati”, pilih hasil tersebut lalu koreksi titik dengan double tap di peta.

## 7. Troubleshooting

- **Alamat tidak ditemukan**
  - Biasanya karena alamat terlalu pendek atau kurang kota/provinsi.
- **Hasil banyak dan membingungkan**
  - Tambahkan detail (kecamatan/kelurahan/kode pos/landmark).
- **Request terasa lambat**
  - Ada throttle 1 detik (normal), dan Nominatim public bisa berubah performanya.
- **Map belum langsung pindah**
  - Jika WebView belum selesai load, marker akan di-apply setelah `onPageFinished`.

## 8. Catatan Etika & Batasan Public Nominatim

Nominatim public instance digunakan bersama komunitas.
Aplikasi sudah menambahkan throttle + User-Agent, namun untuk skala besar produksi biasanya disarankan:

- memakai provider geocoding lain, atau
- self-host Nominatim.

---

## Ringkas (untuk laporan)

- Leaflet = tampilkan peta/marker (via WebView)
- Nominatim = geocoding alamat → koordinat (gratis)
- UI: field Alamat punya tombol Search → hasil (pilih jika banyak) → isi koordinat + update marker
