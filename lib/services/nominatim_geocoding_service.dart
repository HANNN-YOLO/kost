import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class NominatimPlace {
  final double lat;
  final double lng;
  final String displayName;

  const NominatimPlace({
    required this.lat,
    required this.lng,
    required this.displayName,
  });

  static NominatimPlace? tryFromJson(Map<String, dynamic> json) {
    final latStr = json['lat']?.toString();
    final lonStr = json['lon']?.toString();
    if (latStr == null || lonStr == null) return null;

    final lat = double.tryParse(latStr);
    final lng = double.tryParse(lonStr);
    if (lat == null || lng == null) return null;

    final displayName = (json['display_name'] ?? '').toString().trim();
    return NominatimPlace(
      lat: lat,
      lng: lng,
      displayName: displayName.isEmpty ? '$lat, $lng' : displayName,
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

  final Map<String, List<NominatimPlace>> _cache =
      <String, List<NominatimPlace>>{};

  Future<void> _queue = Future<void>.value();
  DateTime? _lastRequestAt;

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

    final cacheKey =
        '${normalized.toLowerCase()}|$limit|$countryCodes|$acceptLanguage';
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

        final uri = Uri.https(_host, _pathSearch, <String, String>{
          'q': normalized,
          'format': 'json',
          'limit': limit.toString(),
          'addressdetails': '1',
          'countrycodes': countryCodes,
          'accept-language': acceptLanguage,
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

        _cache[cacheKey] = results;
        completer.complete(results);
      } catch (_) {
        completer.complete(const <NominatimPlace>[]);
      }
    });

    return completer.future;
  }
}
