import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../custom/satu_tombol.dart';
import '../../models/fasilitas_model.dart';
import '../main/shared/formatCurrency.dart';
import '../../providers/kost_provider.dart';

class DetailKost extends StatelessWidget {
  static const arah = "detail-kost";

  static const Color warnaUtama = Color(0xFF1E3A8A);
  static const Color warnaLatar = Color(0xFFF5F7FB);

  @override
  Widget build(BuildContext context) {
    final argsRaw = ModalRoute.of(context)?.settings.arguments;
    final gunakan =
        argsRaw is Map<String, dynamic> ? argsRaw : <String, dynamic>{};

    final terima = gunakan['data_kost'];
    // final pakai = gunakan['data_fasilitas'];
    // final terima = ModalRoute.of(context)!.settings.arguments as int;
    // final pakai = Provider.of<KostProvider>(context)
    //     .kost
    //     .firstWhereOrNull((element) => element.id_kost == terima);

    // optional: koordinat tujuan & jarak dari halaman rekomendasi SAW
    final dynamic rawDestLat = gunakan['destinationLat'];
    final dynamic rawDestLng = gunakan['destinationLng'];
    final dynamic rawDistanceKm = gunakan['distanceKm'];

    double? destinationLat;
    double? destinationLng;
    double? distanceKm;

    if (rawDestLat is num) destinationLat = rawDestLat.toDouble();
    if (rawDestLng is num) destinationLng = rawDestLng.toDouble();
    if (rawDistanceKm is num) distanceKm = rawDistanceKm.toDouble();
    Positioned(
      left: 12,
      top: 12,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1E3A8A),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: warnaLatar,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DetailHeader(
              imageUrl: terima!.gambar_kost,
              price: terima!.harga_kost ?? 0,
              per: terima.per ?? "",
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    terima!.nama_kost ?? "-",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          terima!.alamat_kost ?? "-",
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
                        value: terima!.harga_kost.toString(),
                      ),
                      _StatChip(
                          icon: Icons.king_bed_outlined,
                          label: 'Ukuran',
                          value: "${terima!.panjang} x ${terima!.lebar}"),
                      _StatChip(
                        icon: Icons.home_work_outlined,
                        label: 'Jenis',
                        value: terima!.jenis_kost.toString(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Informasi Umum',
                    children: [
                      _InfoTile(
                        icon: Icons.person_outline,
                        label: 'Pemilik',
                        value: terima!.pemilik_kost.toString(),
                      ),
                      _InfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Kontak',
                        value: terima!.notlp_kost.toString(),
                      ),
                      _InfoTile(
                          icon: Icons.king_bed_outlined,
                          label: 'Ukuran Kamar',
                          value: "${terima!.panjang} x ${terima!.lebar}"),
                      _InfoTile(
                        icon: Icons.home_work_outlined,
                        label: 'Jenis Kost',
                        value: terima!.jenis_kost.toString(),
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
                        value: terima!.jenis_listrik.toString(),
                      ),
                      _InfoTile(
                        icon: Icons.water_drop_outlined,
                        label: 'Pembayaran Air',
                        value: terima!.jenis_pembayaran_air.toString(),
                      ),
                      _InfoTile(
                        icon: Icons.security_outlined,
                        label: 'Keamanan',
                        value: terima!.keamanan.toString(),
                      ),
                      // _FacilityList(fasilitas: terima),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Lokasi Kost',
                    children: [
                      _MapWidget(
                        latitude: terima.garis_lintang ?? -5.147665,
                        longitude: terima.garis_bujur ?? 119.432731,
                        // destinationLat: destinationLat,
                        // destinationLng: destinationLng,
                      ),
                      // if (distanceKm != null) ...[
                      //   const SizedBox(height: 8),
                      //   Text(
                      //     'Jarak kost ke tujuan Anda: '
                      //     '${distanceKm!.toStringAsFixed(2)} km',
                      //     style: const TextStyle(
                      //       fontSize: 13,
                      //       fontWeight: FontWeight.w600,
                      //       color: Colors.black54,
                      //     ),
                      //   ),
                      // ],
                    ],
                  ),
                ],
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
                color: Colors.black.withOpacity(0.06),
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
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            imageUrl ?? '',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFFE5ECFF),
              child: const Center(
                child: Icon(Icons.image_not_supported_outlined,
                    color: Colors.grey, size: 34),
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
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
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
                  "${formatCurrency(price)} / $per",
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
            color: Colors.black.withOpacity(0.05),
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

class _FacilityChips extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? raw1;
  // final String? raw2;

  const _FacilityChips({
    required this.label,
    required this.icon,
    required this.raw1,
    // required this.raw2,
  });

  List<String> _tokens(String? s) {
    if (s == null) return [];
    final trimmed = s.trim();
    if (trimmed.isEmpty || trimmed == '-') return [];
    return trimmed
        .split(RegExp(r'[|,;]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _tokens(raw1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
            const Text(
              'Fasilitas',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const Text(
            '-',
            style: TextStyle(fontWeight: FontWeight.w700),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (e) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: const Color(0xFF1E3A8A).withOpacity(0.25)),
                    ),
                    child: Text(
                      e,
                      style: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
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
          'window.drawRouteBetweenPoints(${widget.latitude}, ${widget.longitude}, '
          '${widget.destinationLat}, ${widget.destinationLng});',
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

class _FacilityList extends StatelessWidget {
  final FasilitasModel fasilitas;

  const _FacilityList({required this.fasilitas});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> fasilitasList = [
      {
        'icon': Icons.bed_outlined,
        'label': 'Tempat Tidur',
        'available': fasilitas.tempat_tidur
      },
      {
        'icon': Icons.bathroom_outlined,
        'label': 'Kamar Mandi Dalam',
        'available': fasilitas.kamar_mandi_dalam
      },
      {
        'icon': Icons.table_restaurant_outlined,
        'label': 'Meja',
        'available': fasilitas.meja
      },
      {
        'icon': Icons.local_parking_outlined,
        'label': 'Tempat Parkir',
        'available': fasilitas.tempat_parkir
      },
      {
        'icon': Icons.checkroom_outlined,
        'label': 'Lemari',
        'available': fasilitas.lemari
      },
      {
        'icon': Icons.ac_unit_outlined,
        'label': 'AC',
        'available': fasilitas.ac
      },
      {'icon': Icons.tv_outlined, 'label': 'TV', 'available': fasilitas.tv},
      {
        'icon': Icons.air_outlined,
        'label': 'Kipas',
        'available': fasilitas.kipas
      },
      {
        'icon': Icons.kitchen_outlined,
        'label': 'Dapur Dalam',
        'available': fasilitas.dapur_dalam
      },
      {
        'icon': Icons.wifi_outlined,
        'label': 'WiFi',
        'available': fasilitas.wifi
      },
    ];

    // Filter hanya fasilitas yang tersedia
    final availableFacilities =
        fasilitasList.where((item) => item['available'] == true).toList();

    // Jika tidak ada fasilitas yang tersedia, return empty widget
    if (availableFacilities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableFacilities
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: item['available'] == true
                    ? const Color(0xFFE5ECFF)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: item['available'] == true
                      ? const Color(0xFF1E3A8A).withOpacity(0.3)
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item['icon'],
                    size: 16,
                    color: item['available'] == true
                        ? const Color(0xFF1E3A8A)
                        : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item['label'],
                    style: TextStyle(
                      color: item['available'] == true
                          ? const Color(0xFF1E3A8A)
                          : Colors.grey.shade600,
                      fontWeight: item['available'] == true
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  if (item['available'] == true) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Color(0xFF1E3A8A),
                    ),
                  ],
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
