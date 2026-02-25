import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class NominatimPlace {
  final double lat;
  final double lng;
  final String displayName;
  final String? addresstype;
  final String? category;
  final String? type;
  final double? importance;
  final Map<String, String>? address;
  final int? placeId;

  /// [south, north, west, east]
  final List<double>? boundingBox;

  const NominatimPlace({
    required this.lat,
    required this.lng,
    required this.displayName,
    this.addresstype,
    this.category,
    this.type,
    this.importance,
    this.address,
    this.placeId,
    this.boundingBox,
  });

  String? get houseNumber {
    final raw = address?['house_number']?.trim();
    return (raw == null || raw.isEmpty) ? null : raw;
  }

  bool get hasHouseNumber => houseNumber != null;

  static NominatimPlace? tryFromJson(Map<String, dynamic> json) {
    final latStr = json['lat']?.toString();
    final lonStr = json['lon']?.toString();
    if (latStr == null || lonStr == null) return null;

    final lat = double.tryParse(latStr);
    final lng = double.tryParse(lonStr);
    if (lat == null || lng == null) return null;

    final displayName = (json['display_name'] ?? '').toString().trim();

    final addresstype = json['addresstype']?.toString().trim();
    final category = json['class']?.toString().trim();
    final type = json['type']?.toString().trim();
    final importanceRaw = json['importance'];
    final importance = importanceRaw is num
        ? importanceRaw.toDouble()
        : double.tryParse(importanceRaw?.toString() ?? '');

    Map<String, String>? address;
    final addressRaw = json['address'];
    if (addressRaw is Map) {
      final tmp = <String, String>{};
      for (final entry in addressRaw.entries) {
        final key = entry.key?.toString();
        final value = entry.value?.toString();
        if (key == null || value == null) continue;
        final trimmed = value.trim();
        if (trimmed.isEmpty) continue;
        tmp[key] = trimmed;
      }
      if (tmp.isNotEmpty) address = tmp;
    }

    final placeIdRaw = json['place_id'];
    final placeId = placeIdRaw is int
        ? placeIdRaw
        : int.tryParse(placeIdRaw?.toString() ?? '');

    List<double>? boundingBox;
    final bboxRaw = json['boundingbox'];
    if (bboxRaw is List && bboxRaw.length == 4) {
      final parsed = bboxRaw
          .map((e) => double.tryParse(e.toString()))
          .whereType<double>()
          .toList();
      if (parsed.length == 4) {
        boundingBox = parsed;
      }
    }

    return NominatimPlace(
      lat: lat,
      lng: lng,
      displayName: displayName.isEmpty ? '$lat, $lng' : displayName,
      addresstype: (addresstype?.isEmpty ?? true) ? null : addresstype,
      category: (category?.isEmpty ?? true) ? null : category,
      type: (type?.isEmpty ?? true) ? null : type,
      importance: importance,
      address: address,
      placeId: placeId,
      boundingBox: boundingBox,
    );
  }
}

/// Service geocoding berbasis OpenStreetMap (Nominatim).
///
/// Catatan pemakaian public instance:
/// - Jangan spam request (service ini memberi jarak minimal 1 detik antar request).
/// - Sertakan identitas aplikasi via header User-Agent.
class NominatimGeocodingService {
  NominatimGeocodingService._();

  static final NominatimGeocodingService instance =
      NominatimGeocodingService._();

  static const Duration minDelayBetweenRequests = Duration(seconds: 1);
  static const Duration requestTimeout = Duration(seconds: 12);

  static const String _host = 'nominatim.openstreetmap.org';
  static const String _pathSearch = '/search';
  static const String _pathReverse = '/reverse';

  final Map<String, List<NominatimPlace>> _cache =
      <String, List<NominatimPlace>>{};

  final Map<String, String> _reverseCache = <String, String>{};

  Future<void> _queue = Future<void>.value();
  DateTime? _lastRequestAt;

  static bool _queryLooksLikeHasHouseNumber(String query) {
    final q = query.toLowerCase();

    // Indikator eksplisit: "No 12", "Nomor 12", "#12"
    final explicitNo =
        RegExp(r'\b(?:no\.?|nomor|nmr|number|#)\s*\d+[a-z]?\b').hasMatch(q);
    if (explicitNo) return true;

    // Indikator umum di Indonesia: blok/cluster + nomor (contoh: "Blok B No 12", "F2/14")
    final blok = RegExp(
            r'\b(?:blok|block|cluster|klaster)\s*[a-z0-9]+(?:\s*\/\s*\d+)?\b')
        .hasMatch(q);
    if (blok) return true;

    // Jika ada angka 1-4 digit (bukan kode pos 5 digit) dan bukan konteks RT/RW/KM.
    final tokens = q.split(RegExp(r'\s+'));
    for (var i = 0; i < tokens.length; i++) {
      final t = tokens[i].replaceAll(RegExp(r'[^a-z0-9\/]'), '');
      if (t.isEmpty) continue;
      if (RegExp(r'^\d{5}$').hasMatch(t)) continue; // kode pos

      final numLike =
          RegExp(r'^(?:\d{1,4}[a-z]?|[a-z]\d{1,4}|\d{1,3}\/\d{1,3})$')
              .hasMatch(t);
      if (!numLike) continue;

      final prev =
          i > 0 ? tokens[i - 1].replaceAll(RegExp(r'[^a-z0-9]'), '') : '';
      if (prev == 'rt' || prev == 'rw' || prev == 'km') continue;

      return true;
    }

    return false;
  }

  static int _specificityScore(NominatimPlace place) {
    var score = 0;

    if (place.hasHouseNumber) score += 100;

    final addresstype = place.addresstype?.toLowerCase();
    final type = place.type?.toLowerCase();
    final category = place.category?.toLowerCase();

    bool isOneOf(String? v, List<String> candidates) =>
        v != null && candidates.contains(v);

    if (isOneOf(addresstype, const ['house', 'building'])) score += 70;
    if (isOneOf(type, const ['house', 'building'])) score += 60;
    if (isOneOf(addresstype, const ['residential'])) score += 40;
    if (isOneOf(type, const ['residential'])) score += 30;
    if (isOneOf(category, const ['building'])) score += 20;

    return score;
  }

  static String _collapseSpaces(String input) {
    return input
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\s+,\s+'), ', ')
        .replaceAll(RegExp(r',\s*,+'), ', ')
        .trim();
  }

  static String? _stringFromAddressField(Map address, String key) {
    final value = address[key];
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  static String? _buildSearchFriendlyAddressFromReverse(Map decoded) {
    final addressRaw = decoded['address'];
    if (addressRaw is! Map) return null;

    String? cleanPoi(String? value) {
      if (value == null) return null;
      final t = _collapseSpaces(value);
      if (t.isEmpty) return null;
      final low = t.toLowerCase();
      // Hindari nilai POI yang generik/boolean yang kadang muncul di field address.
      if (low == 'yes' || low == 'building' || low == 'house') return null;
      return t;
    }

    // Nama tempat/POI kadang tersedia di root response (reverse) atau sebagai
    // address field seperti amenity/shop/tourism. Ini berguna agar hasil reverse
    // lebih mudah dicari ulang via /search.
    final rootName = cleanPoi(
      (decoded['name'] ?? decoded['localname'])?.toString().trim(),
    );
    final poiFromAddress = _stringFromAddressField(addressRaw, 'amenity') ??
        _stringFromAddressField(addressRaw, 'shop') ??
        _stringFromAddressField(addressRaw, 'tourism') ??
        _stringFromAddressField(addressRaw, 'leisure') ??
        _stringFromAddressField(addressRaw, 'building');

    final poiName = rootName ?? cleanPoi(poiFromAddress);

    // Nominatim reverse biasanya menyediakan struktur seperti:
    // road, house_number, suburb, neighbourhood, village/hamlet, city/town,
    // county/municipality, state, postcode, country.
    final houseNumber = _stringFromAddressField(addressRaw, 'house_number');

    String? road = _stringFromAddressField(addressRaw, 'road') ??
        _stringFromAddressField(addressRaw, 'pedestrian') ??
        _stringFromAddressField(addressRaw, 'cycleway') ??
        _stringFromAddressField(addressRaw, 'footway');

    // Jika reverse memberi nama POI (mis. "Camba Jawaya"), kadang ditaruh di
    // neighbourhood/hamlet/suburb. Kita tetap masukkan sebagai bagian awal.
    final neighbourhood = _stringFromAddressField(addressRaw, 'neighbourhood');
    final suburb = _stringFromAddressField(addressRaw, 'suburb');
    final village = _stringFromAddressField(addressRaw, 'village') ??
        _stringFromAddressField(addressRaw, 'hamlet');
    final city = _stringFromAddressField(addressRaw, 'city') ??
        _stringFromAddressField(addressRaw, 'town') ??
        _stringFromAddressField(addressRaw, 'municipality');
    final county = _stringFromAddressField(addressRaw, 'county');
    final state = _stringFromAddressField(addressRaw, 'state');
    final postcode = _stringFromAddressField(addressRaw, 'postcode');
    final country = _stringFromAddressField(addressRaw, 'country');

    final parts = <String>[];

    if (road != null) {
      if (houseNumber != null) {
        parts.add(_collapseSpaces('$road No $houseNumber'));
      } else {
        parts.add(road);
      }
      // Tambahkan nama tempat/POI setelah alamat jalan (agar alamat utama tetap benar).
      if (poiName != null) parts.add(poiName);
    } else {
      // Jika tidak ada nama jalan, pakai POI sebagai bagian utama.
      if (poiName != null) parts.add(poiName);
    }

    // Masukkan detail area (hindari duplikat).
    for (final p in [neighbourhood, suburb, village]) {
      if (p == null) continue;
      parts.add(p);
    }

    // Kota/kabupaten
    if (city != null) {
      parts.add(city);
    } else if (county != null) {
      parts.add(county);
    }

    // Provinsi
    if (state != null) parts.add(state);

    if (postcode != null) parts.add(postcode);

    // Jangan ikutkan "region" (contoh: Sulawesi) karena sering redundan.
    // Pastikan selalu akhiri dengan Indonesia jika tersedia.
    final normalizedCountry = (country ?? 'Indonesia').trim();
    if (normalizedCountry.isNotEmpty) parts.add(normalizedCountry);

    // Deduplicate (case-insensitive) sambil mempertahankan urutan.
    final seen = <String>{};
    final deduped = <String>[];
    for (final part in parts) {
      final cleaned = _collapseSpaces(part);
      if (cleaned.isEmpty) continue;
      final key = cleaned.toLowerCase();
      if (seen.add(key)) deduped.add(cleaned);
    }

    final result = deduped.join(', ').trim();
    if (result.isEmpty) return null;

    return result;
  }

  static String _expandCommonAbbreviationsId(String input) {
    var q = input;

    // Umum dipakai di alamat Indonesia.
    q = q.replaceAll(RegExp(r'\bko\.?\b', caseSensitive: false), 'Kompleks');
    q = q.replaceAll(RegExp(r'\bkomp\.?\b', caseSensitive: false), 'Komplek');
    q = q.replaceAll(RegExp(r'\bkec\.?\b', caseSensitive: false), 'Kecamatan');
    q = q.replaceAll(RegExp(r'\bkel\.?\b', caseSensitive: false), 'Kelurahan');
    q = q.replaceAll(RegExp(r'\bds\.?\b', caseSensitive: false), 'Desa');
    q = q.replaceAll(RegExp(r'\bjl\.?\b', caseSensitive: false), 'Jalan');
    q = q.replaceAll(RegExp(r'\bjln\.?\b', caseSensitive: false), 'Jalan');
    q = q.replaceAll(RegExp(r'\bno\.?\b', caseSensitive: false), 'No');

    // Bersihkan format RT/RW yang sering pakai titik.
    q = q.replaceAll(RegExp(r'\bRT\.?\s*', caseSensitive: false), 'RT ');
    q = q.replaceAll(RegExp(r'\bRW\.?\s*', caseSensitive: false), 'RW ');
    return _collapseSpaces(q);
  }

  static String _removeRtRwSegment(String input) {
    var q = input;

    // Hapus pola gabungan RT xxx/RW yyy.
    q = q.replaceAll(
      RegExp(
        r'(?:,\s*)?\bRT\s*\d{1,3}\s*\/\s*RW\s*\d{1,3}\b(?:\s*,)?',
        caseSensitive: false,
      ),
      ', ',
    );

    // Hapus jika dipisah.
    q = q.replaceAll(
      RegExp(r'(?:,\s*)?\bRT\s*\d{1,3}\b(?:\s*,)?', caseSensitive: false),
      ', ',
    );
    q = q.replaceAll(
      RegExp(r'(?:,\s*)?\bRW\s*\d{1,3}\b(?:\s*,)?', caseSensitive: false),
      ', ',
    );

    return _collapseSpaces(q);
  }

  static String _removePostalCode(String input) {
    final q = input.replaceAll(RegExp(r'\b\d{5}\b'), '');
    return _collapseSpaces(q);
  }

  static bool _looksLikeComplexAddress(String input) {
    final q = input.toLowerCase();
    return q.contains('kompleks') ||
        q.contains('komplek') ||
        q.contains('perumahan') ||
        q.contains('cluster') ||
        q.contains('klaster') ||
        q.contains('blok') ||
        q.contains('block');
  }

  static String _rewriteBlockHouseNumber(String input) {
    // Contoh target:
    // - "No.B1/11" => "Blok B1 No 11"
    // - "No B1/11" => "Blok B1 No 11"
    // - "B1/11" (jika konteks komplek) => "Blok B1 No 11"
    var q = input;
    final contextOk = _looksLikeComplexAddress(q);

    q = q.replaceAllMapped(
      RegExp(
        r'\bNo\s*\.?\s*([A-Za-z]\d+)\s*\/\s*(\d{1,4})\b',
        caseSensitive: false,
      ),
      (m) => 'Blok ${m[1]!.toUpperCase()} No ${m[2]}',
    );

    if (contextOk) {
      q = q.replaceAllMapped(
        RegExp(r'\b([A-Za-z]\d+)\s*\/\s*(\d{1,4})\b'),
        (m) => 'Blok ${m[1]!.toUpperCase()} No ${m[2]}',
      );
    }

    return _collapseSpaces(q);
  }

  static String _ensureIndonesiaSuffix(String input) {
    final q = input.trim();
    if (q.isEmpty) return q;
    if (q.toLowerCase().contains('indonesia')) return q;
    return _collapseSpaces('$q, Indonesia');
  }

  // Hapus nama-nama pulau/region level yang sering muncul di display_name
  // Nominatim tapi tidak dikenali dengan baik oleh endpoint /search.
  // Contoh: "Sulawesi Selatan, Sulawesi, Indonesia" -> "Sulawesi Selatan, Indonesia"
  static String _removeIslandRegionTokens(String input) {
    // Nama-nama pulau besar / region administratif Indonesia yang sering
    // muncul sebagai token standalone antara provinsi dan 'Indonesia'.
    const islandTokens = [
      'Sulawesi',
      'Jawa',
      'Kalimantan',
      'Sumatera',
      'Papua',
      'Maluku',
      'Nusa Tenggara',
      'Tanimbar',
    ];

    var q = input;
    for (final token in islandTokens) {
      // Hapus token hanya jika berdiri sendiri di antara koma.
      // Contoh: ", Sulawesi," atau ", Sulawesi" di akhir (sebelum Indonesia).
      q = q.replaceAll(
        RegExp(
          r'(?:,\s*)' + RegExp.escape(token) + r'(?=\s*,|\s*$)',
          caseSensitive: false,
        ),
        '',
      );
    }
    return _collapseSpaces(q);
  }

  /// Bersihkan query dari token region OSM (Sulawesi, Jawa, dll) dan spasi
  /// berlebih sebelum dikirim ke Nominatim /search. Berguna untuk autocomplete.
  static String cleanForSearch(String query) {
    String trimEdgeCommas(String s) {
      // Hapus koma/spasi berlebih di awal/akhir (contoh: "..., 90135," -> "..., 90135")
      return s.replaceAll(RegExp(r'^[,\s]+|[,\s]+$'), '').trim();
    }

    var q = _collapseSpaces(query);
    q = trimEdgeCommas(q);
    q = _removeIslandRegionTokens(q);
    q = _removePostalCode(q);
    q = trimEdgeCommas(q);
    return _collapseSpaces(q);
  }

  static String _normalizeForMatch(String input) {
    final q = cleanForSearch(input).toLowerCase();
    return q
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static Set<String> _tokenizeForMatch(String input) {
    const stopwords = {
      'jalan',
      'jl',
      'jln',
      'no',
      'nomor',
      'rt',
      'rw',
      'kecamatan',
      'kec',
      'kelurahan',
      'kel',
      'desa',
      'dusun',
      'kota',
      'kabupaten',
      'provinsi',
      'indonesia',
      'blok',
      'kompleks',
      'komplek',
      'perumahan',
      'cluster',
      'klaster',
    };

    final normalized = _normalizeForMatch(input);
    final parts = normalized.split(' ');
    final out = <String>{};
    for (final p in parts) {
      final t = p.trim();
      if (t.length < 2) continue;
      if (stopwords.contains(t)) continue;
      out.add(t);
    }
    return out;
  }

  static int _keywordMatchScore(String query, NominatimPlace place) {
    final qNorm = _normalizeForMatch(query);
    if (qNorm.isEmpty) return 0;

    final pNorm = _normalizeForMatch(place.displayName);
    final qTokens = _tokenizeForMatch(qNorm);
    final pTokens = _tokenizeForMatch(pNorm);

    final intersection = qTokens.intersection(pTokens).length;
    var score = intersection * 10;

    if (pNorm.contains(qNorm)) score += 35;
    if (qNorm.contains(pNorm) && pNorm.length >= 8) score += 10;

    if (_queryLooksLikeHasHouseNumber(qNorm) && place.hasHouseNumber) {
      score += 50;
    }

    // Boost kandidat dengan importance lebih besar.
    final imp = place.importance ?? 0.0;
    score += (imp * 10).round();

    return score;
  }

  static String? _buildCoreAutocompleteQuery(String input) {
    final cleaned = cleanForSearch(input);
    final segs = cleaned
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .where((s) => s.toLowerCase() != 'indonesia')
        .toList();

    // Target: "nama tempat" + (opsional kelurahan) + "kota"
    // Kota biasanya berada satu posisi sebelum provinsi.
    if (segs.length < 4) return null;

    final name = segs[0];
    final second = segs.length >= 2 ? segs[1] : null;
    final city = segs[segs.length - 2];

    final parts = <String>[name];
    if (second != null && second.toLowerCase() != city.toLowerCase()) {
      parts.add(second);
    }
    if (city.toLowerCase() != name.toLowerCase()) parts.add(city);

    final core = _collapseSpaces(parts.join(', '));
    if (core.length < 3) return null;
    return _ensureIndonesiaSuffix(core);
  }

  static bool _looksLikeAdministrativeSegment(String segment) {
    final s = _normalizeForMatch(segment);
    if (s.isEmpty) return false;
    // Token administratif yang sering dipakai user.
    return s.contains('kelurahan') ||
        RegExp(r'\bkel\b').hasMatch(s) ||
        s.contains('kecamatan') ||
        RegExp(r'\bkec\b').hasMatch(s) ||
        s.contains('desa') ||
        s.contains('dusun') ||
        s.contains('kabupaten') ||
        RegExp(r'\bkab\b').hasMatch(s) ||
        s.contains('kota') ||
        s.contains('provinsi') ||
        RegExp(r'\bprov\b').hasMatch(s);
  }

  static bool _looksLikeRoadSegment(String segment) {
    final s = _normalizeForMatch(segment);
    if (s.isEmpty) return false;
    return s.contains('jalan') ||
        RegExp(r'\bjl\b').hasMatch(s) ||
        RegExp(r'\bjln\b').hasMatch(s) ||
        s.contains('lorong') ||
        RegExp(r'\blr\b').hasMatch(s) ||
        s.contains('gang') ||
        RegExp(r'\bgg\b').hasMatch(s);
  }

  static final RegExp _adminPrefixRegex = RegExp(
    r'^(?:kelurahan|kel|kecamatan|kec|kota|kabupaten|kab|provinsi|prov|desa|dusun)\b\s*',
    caseSensitive: false,
  );

  static final RegExp _adminWordRegex = RegExp(
    r'\b(?:kelurahan|kel|kecamatan|kec|kota|kabupaten|kab|provinsi|prov|desa|dusun)\b',
    caseSensitive: false,
  );

  static bool _containsAdministrativeWords(String input) {
    return _adminWordRegex.hasMatch(input);
  }

  static String _stripLeadingAdministrativePrefix(String segment) {
    var s = segment.trim();
    if (s.isEmpty) return s;
    // Hapus prefix seperti: "kelurahan ", "kecamatan ", "kota " dll.
    s = s.replaceFirst(_adminPrefixRegex, '');
    // Bersihkan ':' atau '-' yang sering dipakai setelah label.
    s = s.replaceFirst(RegExp(r'^[\s:;-]+'), '');
    return _collapseSpaces(s);
  }

  static String _stripAdministrativeWordsFromQuery(String cleanedQuery) {
    // Bersihkan setiap segmen koma agar query lebih "natural" untuk Nominatim.
    final segs = cleanedQuery
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .where((s) => s.toLowerCase() != 'indonesia')
        .map(_stripLeadingAdministrativePrefix)
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    if (segs.isEmpty) return cleanedQuery;
    return _collapseSpaces(segs.join(', '));
  }

  /// Beberapa user mengetik komponen alamat terbalik (mis. "Kelurahan X, Jalan Y").
  /// Nominatim kadang sensitif terhadap urutan segmen (terutama jika pakai koma),
  /// jadi kita buat varian query yang lebih "bag-of-words" dengan menaruh segmen
  /// yang tampak seperti jalan di depan dan segmen administratif di belakang.
  static String? _buildReorderedCommaQueryVariant(String cleanedQuery) {
    final segs = cleanedQuery
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .where((s) => s.toLowerCase() != 'indonesia')
        .toList(growable: false);
    if (segs.length < 2) return null;

    final strippedSegs = segs
        .map(_stripLeadingAdministrativePrefix)
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    if (strippedSegs.length < 2) return null;

    final roads = <String>[];
    final admins = <String>[];
    final others = <String>[];

    for (var i = 0; i < segs.length; i++) {
      final seg = segs[i];
      final stripped = i < strippedSegs.length ? strippedSegs[i] : seg;
      if (_looksLikeRoadSegment(seg)) {
        roads.add(stripped);
      } else if (_looksLikeAdministrativeSegment(seg)) {
        admins.add(stripped);
      } else {
        others.add(stripped);
      }
    }

    // Jika kita gagal mendeteksi apa pun, fallback: reverse 2 segmen pertama.
    if (roads.isEmpty && admins.isEmpty) {
      final swapped = <String>[
        strippedSegs[1],
        strippedSegs[0],
        ...strippedSegs.skip(2)
      ];
      return _ensureIndonesiaSuffix(_collapseSpaces(swapped.join(', ')));
    }

    final reordered = <String>[...roads, ...others, ...admins];
    final candidate = _collapseSpaces(reordered.join(', '));
    final original = _collapseSpaces(strippedSegs.join(', '));
    if (candidate.isEmpty) return null;
    if (candidate.toLowerCase() == original.toLowerCase()) return null;
    return _ensureIndonesiaSuffix(candidate);
  }

  static List<String> _buildSmartQueryVariants(String query) {
    final base = _collapseSpaces(query);
    final expanded = _expandCommonAbbreviationsId(base);
    final rewritten = _rewriteBlockHouseNumber(expanded);

    // Pembersihan bertahap
    final noIsland = _removeIslandRegionTokens(rewritten);
    final noRtRw = _removeRtRwSegment(noIsland);
    final noPostal = _removePostalCode(noRtRw);

    // Segmentasi: pisahkan per koma, buang "Indonesia" dari list agar bisa
    // kita kontrol penambahan suffix-nya secara eksplisit.
    final allSegs = noPostal
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final segs = allSegs.where((s) => s.toLowerCase() != 'indonesia').toList();

    // Helper: build query dari list segment + suffix Indonesia
    String withIndo(List<String> parts) =>
        _ensureIndonesiaSuffix(parts.join(', '));

    final out = <String>[];

    // Jika user mengetik label administratif (kelurahan/kecamatan/kota...),
    // buat varian yang menghapus label tsb agar query lebih cocok ke Nominatim.
    final strippedNoPostal = _stripAdministrativeWordsFromQuery(noPostal);
    if (strippedNoPostal.isNotEmpty &&
        strippedNoPostal.toLowerCase() != noPostal.toLowerCase()) {
      out.add(_ensureIndonesiaSuffix(strippedNoPostal));
      out.add(
        _ensureIndonesiaSuffix(
          _collapseSpaces(strippedNoPostal.replaceAll(',', ' ')),
        ),
      );
    }

    // Tambahan: varian query yang mencoba membalik/menata ulang segmen (urutan kata)
    // agar input user yang "terbalik" masih menghasilkan kandidat dari Nominatim.
    final reordered = _buildReorderedCommaQueryVariant(noPostal);
    if (reordered != null) out.add(reordered);

    final reorderedStripped =
        _buildReorderedCommaQueryVariant(strippedNoPostal);
    if (reorderedStripped != null) out.add(reorderedStripped);

    if (segs.length >= 5) {
      // Query panjang (tipikal hasil reverse-geocoding):
      // segs: [NamaTempat, Kelurahan, Kecamatan, Kota, Provinsi, ...]
      // Strategi: coba berbagai kombinasi seperti keyword search —
      // selalu pertahankan token paling spesifik (depan), variasikan sisanya.

      final name = segs[0]; // mis. Camba Jawaya
      final kel = segs[1]; // mis. Tello Baru
      final kec = segs[2]; // mis. Panakkukang
      final kota = segs[3]; // mis. Makassar
      final prov = segs[4]; // mis. Sulawesi Selatan

      // v1 — lengkap tanpa pulau/kode pos (paling rinci)
      out.add(withIndo([name, kel, kec, kota, prov]));
      // v2 — skip kecamatan (satu level lebih fleksibel)
      out.add(withIndo([name, kel, kota, prov]));
      // v3 — skip kecamatan & provinsi (paling sering match di Nominatim)
      out.add(withIndo([name, kel, kota]));
      // v4 — hanya nama + kota (paling singkat, jangkauan paling lebar)
      out.add(withIndo([name, kota]));
      // v5 — nama + kecamatan + kota (kombinasi alternatif)
      out.add(withIndo([name, kec, kota]));
    } else if (segs.length == 4) {
      // [Nama, Kel, Kota, Provinsi]
      out.add(withIndo(segs));
      out.add(withIndo([segs[0], segs[1], segs[2]]));
      out.add(withIndo([segs[0], segs[2]]));
    } else if (segs.length == 3) {
      // [Nama, Kel/Kec, Kota]
      out.add(withIndo(segs));
      out.add(withIndo([segs[0], segs[2]]));
    } else {
      // Query pendek — pakai as-is
      out.add(_ensureIndonesiaSuffix(noPostal));
      if (noPostal != noRtRw) out.add(_ensureIndonesiaSuffix(noRtRw));
    }

    // Deduplicate while keeping order
    final seen = <String>{};
    final result = <String>[];
    for (final v in out) {
      final t = v.trim();
      if (t.isEmpty) continue;
      if (seen.add(t.toLowerCase())) result.add(t);
    }
    return result.take(6).toList(growable: false);
  }

  /// Autocomplete fleksibel: mencoba 1-2 query yang paling "masuk akal" dan
  /// mengurutkan hasil berdasarkan kecocokan kata (mirip pencarian produk).
  ///
  /// Ini dibuat terpisah dari [searchAddressSmart] supaya UX autocomplete tetap cepat
  /// (tidak terlalu banyak request dan terhambat throttle 1 detik).
  Future<List<NominatimPlace>> searchAddressAutocomplete(
    String query, {
    int limit = 7,
    String countryCodes = 'id',
    String acceptLanguage = 'id',
    String userAgent = 'KostSAW-Skripsi/1.0 (contact: unknown)',
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const <NominatimPlace>[];

    final primary = cleanForSearch(trimmed);
    final core = _buildCoreAutocompleteQuery(primary);

    final strippedPrimary = _stripAdministrativeWordsFromQuery(primary);
    final reordered = _buildReorderedCommaQueryVariant(primary);
    final reorderedStripped = _buildReorderedCommaQueryVariant(strippedPrimary);

    // Keyword query: ganti koma jadi spasi agar lebih seperti keyword search.
    final keyword = _ensureIndonesiaSuffix(
      _collapseSpaces(primary.replaceAll(',', ' ')),
    );
    final strippedKeyword = _ensureIndonesiaSuffix(
      _collapseSpaces(strippedPrimary.replaceAll(',', ' ')),
    );

    final candidates = <String>[];

    // Jika input mengandung label administratif, prioritaskan varian yang sudah
    // di-strip agar Nominatim tidak "nyangkut" ke kata kelurahan/kecamatan/kota.
    final hasAdminWords = _containsAdministrativeWords(primary);
    if (hasAdminWords) {
      if (strippedKeyword.isNotEmpty) candidates.add(strippedKeyword);
      if (strippedPrimary.length >= 3) candidates.add(strippedPrimary);
      if (reorderedStripped != null) candidates.add(reorderedStripped);
      if (keyword.isNotEmpty) candidates.add(keyword);
      if (primary.length >= 3) candidates.add(primary);
    } else {
      candidates.add(primary.length >= 3 ? primary : trimmed);
      if (reordered != null) candidates.add(reordered);
      if (core != null) candidates.add(core);
      if (keyword.isNotEmpty) candidates.add(keyword);
      if (strippedKeyword.isNotEmpty) candidates.add(strippedKeyword);
      if (strippedPrimary.length >= 3) candidates.add(strippedPrimary);
    }

    // Deduplicate query order
    final seenQ = <String>{};
    final queries = <String>[];
    for (final c in candidates) {
      final t = _collapseSpaces(c);
      if (t.length < 3) continue;
      if (seenQ.add(t.toLowerCase())) queries.add(t);
    }

    // Pakai maksimal 2 request untuk menjaga respons autocomplete.
    final maxRequests = queries.length > 2 ? 2 : queries.length;
    final perQueryLimit = (limit * 3).clamp(10, 18);

    final seenKeys = <String>{};
    final merged = <NominatimPlace>[];

    for (var i = 0; i < maxRequests; i++) {
      final results = await searchAddress(
        queries[i],
        limit: perQueryLimit,
        countryCodes: countryCodes,
        acceptLanguage: acceptLanguage,
        userAgent: userAgent,
      );

      for (final r in results) {
        final key = r.placeId != null
            ? 'id:${r.placeId}'
            : '${r.lat.toStringAsFixed(5)},${r.lng.toStringAsFixed(5)}';
        if (seenKeys.add(key)) merged.add(r);
      }
    }

    if (merged.isEmpty) return const <NominatimPlace>[];

    // Rank hasil berdasarkan kecocokan keyword terhadap query asli user.
    merged.sort((a, b) {
      final sa = _keywordMatchScore(trimmed, a);
      final sb = _keywordMatchScore(trimmed, b);
      final byScore = sb.compareTo(sa);
      if (byScore != 0) return byScore;

      final ai = a.importance ?? 0.0;
      final bi = b.importance ?? 0.0;
      final byImportance = bi.compareTo(ai);
      if (byImportance != 0) return byImportance;

      return a.displayName.length.compareTo(b.displayName.length);
    });

    return merged.take(limit).toList(growable: false);
  }

  /// Search alamat -> kandidat lokasi. Default dibatasi ke Indonesia.
  Future<List<NominatimPlace>> searchAddress(
    String query, {
    int limit = 5,
    String countryCodes = 'id',
    String acceptLanguage = 'id',
    String userAgent = 'KostSAW-Skripsi/1.0 (contact: unknown)',
  }) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return const <NominatimPlace>[];

    final looksSpecific = _queryLooksLikeHasHouseNumber(normalized);

    final cacheKey =
        '${normalized.toLowerCase()}|$limit|$countryCodes|$acceptLanguage|smart:1';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    // Serialize & throttle semua request agar tidak melebihi rate limit.
    final completer = Completer<List<NominatimPlace>>();
    _queue = _queue.then((_) async {
      try {
        final now = DateTime.now();
        final last = _lastRequestAt;
        if (last != null) {
          final elapsed = now.difference(last);
          if (elapsed < minDelayBetweenRequests) {
            await Future<void>.delayed(minDelayBetweenRequests - elapsed);
          }
        }

        _lastRequestAt = DateTime.now();

        // Jika query mengandung nomor rumah/blok, overfetch sedikit lalu kita urutkan
        // agar kandidat paling spesifik masuk ke top-N (tanpa mengubah UX jumlah hasil).
        final effectiveLimit =
            looksSpecific ? (limit < 10 ? 12 : limit) : limit;

        final uri = Uri.https(_host, _pathSearch, <String, String>{
          'q': normalized,
          'format': 'jsonv2',
          'limit': effectiveLimit.toString(),
          'addressdetails': '1',
          'countrycodes': countryCodes,
          'accept-language': acceptLanguage,
          'dedupe': '1',
        });

        final resp = await http.get(
          uri,
          headers: <String, String>{
            // Nominatim meminta identitas aplikasi.
            'User-Agent': userAgent,
            'Accept': 'application/json',
          },
        ).timeout(requestTimeout);

        if (resp.statusCode < 200 || resp.statusCode >= 300) {
          completer.complete(const <NominatimPlace>[]);
          return;
        }

        final decoded = jsonDecode(resp.body);
        if (decoded is! List) {
          completer.complete(const <NominatimPlace>[]);
          return;
        }

        final results = <NominatimPlace>[];
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final place = NominatimPlace.tryFromJson(item);
            if (place != null) results.add(place);
          } else if (item is Map) {
            final place =
                NominatimPlace.tryFromJson(item.cast<String, dynamic>());
            if (place != null) results.add(place);
          }
        }

        if (looksSpecific && results.length > 1) {
          final scored = <({NominatimPlace place, int index, int score})>[];
          for (var i = 0; i < results.length; i++) {
            final place = results[i];
            scored
                .add((place: place, index: i, score: _specificityScore(place)));
          }

          scored.sort((a, b) {
            // score desc
            final byScore = b.score.compareTo(a.score);
            if (byScore != 0) return byScore;

            // importance desc
            final ai = a.place.importance ?? 0.0;
            final bi = b.place.importance ?? 0.0;
            final byImportance = bi.compareTo(ai);
            if (byImportance != 0) return byImportance;

            // stable by original index
            return a.index.compareTo(b.index);
          });

          final ordered = scored.map((e) => e.place).toList();
          results
            ..clear()
            ..addAll(ordered);
        }

        final finalResults =
            results.length > limit ? results.sublist(0, limit) : results;

        _cache[cacheKey] = finalResults;
        completer.complete(finalResults);
      } catch (_) {
        completer.complete(const <NominatimPlace>[]);
      }
    });

    return completer.future;
  }

  /// Versi "smart" untuk geocoding yang lebih tahan terhadap format alamat Indonesia
  /// (mis. blok/nomor rumah + RT/RW + singkatan). Cocok dipakai saat user menekan
  /// tombol Search/Submit maupun untuk autocomplete tiap ketikan.
  ///
  /// Berbeda dari [searchAddress], fungsi ini:
  /// 1. Membuat beberapa variant query (hapus pulau, skip kecamatan, singkat, dll)
  /// 2. Mencoba semua variant dan **menggabungkan** hasilnya (deduplikasi per placeId)
  /// Sehingga bersifat lebih fleksibel seperti keyword search:
  /// jika ada kata yang cocok di variant manapun, hasilnya akan muncul.
  Future<List<NominatimPlace>> searchAddressSmart(
    String query, {
    int limit = 5,
    String countryCodes = 'id',
    String acceptLanguage = 'id',
    String userAgent = 'KostSAW-Skripsi/1.0 (contact: unknown)',
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const <NominatimPlace>[];

    final variants = _buildSmartQueryVariants(trimmed);

    // Key deduplikasi: gunakan placeId jika tersedia, fallback ke "lat,lng".
    final seenKeys = <String>{};
    final merged = <NominatimPlace>[];

    for (var i = 0; i < variants.length; i++) {
      final results = await searchAddress(
        variants[i],
        limit: limit,
        countryCodes: countryCodes,
        acceptLanguage: acceptLanguage,
        userAgent: userAgent,
      );

      for (final r in results) {
        final key = r.placeId != null
            ? 'id:${r.placeId}'
            : '${r.lat.toStringAsFixed(5)},${r.lng.toStringAsFixed(5)}';
        if (seenKeys.add(key)) {
          merged.add(r);
        }
      }

      // Berhenti awal hanya jika sudah cukup hasil DAN sudah mencoba
      // minimal 2 variant (agar hasilnya benar-benar beragam).
      if (merged.length >= limit && i >= 1) break;
    }

    return merged.take(limit).toList(growable: false);
  }

  /// Reverse geocoding: koordinat -> alamat (display_name).
  ///
  /// Catatan: tingkat detail sangat tergantung data OpenStreetMap.
  Future<String?> reverseGeocode(
    double lat,
    double lng, {
    String acceptLanguage = 'id',
    String userAgent = 'KostSAW-Skripsi/1.0 (contact: unknown)',
    int zoom = 18,
  }) async {
    // cache key dengan pembulatan 6 desimal agar stabil
    final key =
        '${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}|$acceptLanguage|z:$zoom';
    final cached = _reverseCache[key];
    if (cached != null) return cached;

    final completer = Completer<String?>();
    _queue = _queue.then((_) async {
      try {
        final now = DateTime.now();
        final last = _lastRequestAt;
        if (last != null) {
          final elapsed = now.difference(last);
          if (elapsed < minDelayBetweenRequests) {
            await Future<void>.delayed(minDelayBetweenRequests - elapsed);
          }
        }

        _lastRequestAt = DateTime.now();

        final uri = Uri.https(_host, _pathReverse, <String, String>{
          'lat': lat.toString(),
          'lon': lng.toString(),
          'format': 'jsonv2',
          'addressdetails': '1',
          'accept-language': acceptLanguage,
          'zoom': zoom.toString(),
        });

        final resp = await http.get(
          uri,
          headers: <String, String>{
            'User-Agent': userAgent,
            'Accept': 'application/json',
          },
        ).timeout(requestTimeout);

        if (resp.statusCode < 200 || resp.statusCode >= 300) {
          completer.complete(null);
          return;
        }

        final decoded = jsonDecode(resp.body);
        if (decoded is! Map) {
          completer.complete(null);
          return;
        }

        final friendly = _buildSearchFriendlyAddressFromReverse(decoded);
        if (friendly != null) {
          _reverseCache[key] = friendly;
          completer.complete(friendly);
          return;
        }

        // Fallback: display_name dengan region token dihapus agar bisa dicari ulang.
        final displayName = (decoded['display_name'] ?? '').toString().trim();
        if (displayName.isEmpty) {
          completer.complete(null);
          return;
        }

        final cleaned = _collapseSpaces(_removeIslandRegionTokens(displayName));
        _reverseCache[key] = cleaned;
        completer.complete(cleaned);
      } catch (_) {
        completer.complete(null);
      }
    });

    return completer.future;
  }
}
