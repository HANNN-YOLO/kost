import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import '../custom/satu_tombol.dart';
import '../main/shared/formatCurrency.dart';
import '../../models/kost_model.dart';

class DetailKost extends StatelessWidget {
  static const arah = "detail-kost";

  static const Color warnaUtama = Color(0xFF1E3A8A);
  static const Color warnaLatar = Color(0xFFF5F7FB);

  const DetailKost({super.key});

  double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  List<String> _tokens(String? s) {
    if (s == null) return const [];
    final trimmed = s.trim();
    if (trimmed.isEmpty || trimmed == '-') return const [];
    return trimmed
        .split(RegExp(r'[|,;]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final argsRaw = ModalRoute.of(context)?.settings.arguments;
    final Map args = argsRaw is Map ? argsRaw : const {};

    final dynamic kostRaw = args['data_kost'];
    KostModel? terima;
    if (kostRaw is KostModel) {
      terima = kostRaw;
    } else if (kostRaw is Map<String, dynamic>) {
      terima = KostModel.fromJson(kostRaw);
    } else if (kostRaw is Map) {
      terima = KostModel.fromJson(kostRaw.cast<String, dynamic>());
    }

    if (terima == null) {
      return Scaffold(
        backgroundColor: warnaLatar,
        appBar: AppBar(
          backgroundColor: warnaLatar,
          elevation: 0,
          title: const Text('Detail Kost'),
        ),
        body: const Center(
          child: Text('Data kost tidak ditemukan.'),
        ),
      );
    }

    final KostModel kost = terima;

    final double? destinationLat = _asDouble(args['destinationLat']);
    final double? destinationLng = _asDouble(args['destinationLng']);
    final double? distanceKm = _asDouble(args['distanceKm']);

    final fasilitasUnique = _tokens(kost.fasilitas).toSet().toList();
    fasilitasUnique.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return Scaffold(
      backgroundColor: warnaLatar,
      body: SafeArea(
        child: Column(
          children: [
            _DetailHeader(
              imageUrl: kost.gambar_kost,
              price: kost.harga_kost ?? 0,
              per: (kost.per ?? '').toString(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (kost.nama_kost ?? '-').toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 18, color: Colors.black54),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            kost.alamat_kost ?? "-",
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatChip(
                          icon: Icons.sell_outlined,
                          label: 'Harga',
                          value: formatCurrency(kost.harga_kost ?? 0),
                        ),
                        _StatChip(
                          icon: Icons.king_bed_outlined,
                          label: 'Ukuran',
                          value: "${kost.panjang} x ${kost.lebar}",
                        ),
                        _StatChip(
                          icon: Icons.home_work_outlined,
                          label: 'Jenis',
                          value: kost.jenis_kost.toString(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Informasi Umum',
                      children: [
                        _InfoTile(
                          icon: Icons.person_outline,
                          label: 'Hubungi',
                          value: () {
                            final nama = (kost.pemilik_kost ?? '').toString();
                            if (nama.trim().isNotEmpty) return nama;
                            return '-';
                          }(),
                        ),
                        _InfoTile(
                          icon: Icons.phone_outlined,
                          label: 'Kontak',
                          value: (kost.notlp_kost == null ||
                                  (kost.notlp_kost ?? '').trim().isEmpty ||
                                  (kost.notlp_kost ?? '').trim() == '0')
                              ? '-'
                              : (kost.notlp_kost ?? '').trim(),
                        ),
                        _InfoTile(
                          icon: Icons.king_bed_outlined,
                          label: 'Ukuran Kamar',
                          value: "${kost.panjang} x ${kost.lebar}",
                        ),
                        _InfoTile(
                          icon: Icons.home_work_outlined,
                          label: 'Jenis Kost',
                          value: kost.jenis_kost.toString(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Fasilitas & Utilitas',
                      children: [
                        _InfoTile(
                          icon: Icons.flash_on_outlined,
                          label: 'Jenis Listrik',
                          value: kost.jenis_listrik.toString(),
                        ),
                        _InfoTile(
                          icon: Icons.water_drop_outlined,
                          label: 'Pembayaran Air',
                          value: kost.jenis_pembayaran_air.toString(),
                        ),
                        _InfoTile(
                          icon: Icons.security_outlined,
                          label: 'Keamanan',
                          value: kost.keamanan.toString(),
                        ),
                        const SizedBox(height: 8),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Fasilitas',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        fasilitasUnique.isEmpty
                            ? const Text(
                                '- Tidak ada data fasilitas',
                                style: TextStyle(color: Colors.black54),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final f in fasilitasUnique)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE9EEF9),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        f,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1F1F1F),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Lokasi Kost',
                      children: [
                        _MapWidget(
                          latitude: kost.garis_lintang ?? -5.147665,
                          longitude: kost.garis_bujur ?? 119.432731,
                          destinationLat: destinationLat,
                          destinationLng: destinationLng,
                        ),
                        if (distanceKm != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Jarak dari tempat ke kost: '
                            '${distanceKm.toStringAsFixed(2)} km',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.06 * 255).round()),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SatuTombol(
            warna: warnaUtama,
            fungsi: () {
              Navigator.of(context).pop();
            },
            label: "Kembali",
          ),
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final String? imageUrl;
  final int price;
  final String per;

  const _DetailHeader(
      {required this.imageUrl, required this.price, required this.per});

  @override
  Widget build(BuildContext context) {
    final perLabel = per.trim().isEmpty ? 'bulan' : per;
    final url = (imageUrl ?? '').trim();
    final bool hasImage = url.isNotEmpty;
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: hasImage
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFE5ECFF),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                        size: 34,
                      ),
                    ),
                  ),
                )
              : Container(
                  color: const Color(0xFFE5ECFF),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey,
                      size: 34,
                    ),
                  ),
                ),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.9 * 255).round()),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.08 * 255).round()),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sell_outlined,
                    size: 18, color: Color(0xFF1E3A8A)),
                const SizedBox(width: 6),
                Text(
                  "${formatCurrency(price)} / $perLabel",
                  style: const TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFDDE6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1E3A8A)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE5ECFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF1E3A8A)),
          const SizedBox(width: 6),
          Text(
            "$label: $value",
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double? destinationLat;
  final double? destinationLng;

  const _MapWidget({
    required this.latitude,
    required this.longitude,
    this.destinationLat,
    this.destinationLng,
  });

  @override
  State<_MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<_MapWidget> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..loadFlutterAsset('assets/map/map.html')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // Set marker pada koordinat kost setelah map selesai dimuat
            _setMarkerOnMap();
            // Set mode readonly agar klik di peta tidak memindahkan marker kost
            _controller?.runJavaScript("setMode('readonly');");
          },
        ),
      );
  }

  void _setMarkerOnMap() async {
    if (_controller != null) {
      // Delay lebih singkat untuk performa lebih baik
      await Future.delayed(const Duration(milliseconds: 300));
      final hasDestination =
          widget.destinationLat != null && widget.destinationLng != null;

      if (hasDestination) {
        // Set marker kost dan tujuan lalu fit ke keduanya
        await _controller!.runJavaScript(
          'window.setMarker(${widget.latitude}, ${widget.longitude});',
        );
        await _controller!.runJavaScript(
          'window.setDestinationLocation(${widget.destinationLat}, ${widget.destinationLng});',
        );
        await _controller!.runJavaScript('window.fitToKostAndDestination();');
        await _controller!.runJavaScript(
          'window.drawRouteBetweenPoints(${widget.destinationLat}, ${widget.destinationLng}, '
          '${widget.latitude}, ${widget.longitude});',
        );
      } else {
        // View & marker hanya pada kost seperti sebelumnya
        await _controller!.runJavaScript(
          'window.setView(${widget.latitude}, ${widget.longitude}, 16);',
        );
        await _controller!.runJavaScript(
          'window.setMarker(${widget.latitude}, ${widget.longitude});',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (_controller != null)
              WebViewWidget(
                controller: _controller!,
                gestureRecognizers: {
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
              ),
            if (_controller == null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
