import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: UserRecommendationPage(),
  ));
}

class UserRecommendationPage extends StatefulWidget {
  const UserRecommendationPage({super.key});

  @override
  State<UserRecommendationPage> createState() => _UserRecommendationPageState();
}

class _UserRecommendationPageState extends State<UserRecommendationPage> {
  void _showFilterPopup() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox
            .shrink(); // Dibutuhkan, tapi kita ganti di transitionBuilder
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
            child: const Center(
              child: PopupFilter(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FC),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Rekomendasi Indekos',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const Icon(Icons.filter_alt_outlined, color: Colors.black),
              onPressed: _showFilterPopup,
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.sentiment_neutral,
                  size: 40,
                  color: Colors.black87,
                ),
                SizedBox(height: 16),
                Text(
                  "Upss Belum Ada Rekomendasi...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Untuk menampilkan hasil rekomendasi pastikan anda memasukkan kriteria kost pilihan anda di pojok kanan atas",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================
// POPUP FILTER
// ==========================
class PopupFilter extends StatefulWidget {
  const PopupFilter({super.key});

  @override
  State<PopupFilter> createState() => _PopupFilterState();
}

class _PopupFilterState extends State<PopupFilter> {
  final List<String> allKriteria = ["Lokasi", "Harga", "Fasilitas", "Keamanan"];
  final List<String> selectedKriteria = [];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Filter simple additive weighting",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // ==== Kriteria yang terpilih ====
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: selectedKriteria.isNotEmpty
                  ? Wrap(
                      key: const ValueKey(1),
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedKriteria.map((item) {
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedKriteria.remove(item);
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  : Container(
                      key: const ValueKey(2),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Belum ada kriteria dipilih",
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ),
            ),

            const SizedBox(height: 16),
            const Divider(thickness: 1, color: Color(0xFFE0E0E0)),
            const SizedBox(height: 12),

            const Text(
              "Kriteria",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // ==== Pilihan semua kriteria ====
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: allKriteria.map((item) {
                final bool isSelected = selectedKriteria.contains(item);
                return ChoiceChip(
                  label: Text(item),
                  selected: isSelected,
                  backgroundColor: const Color(0xFFF5F5F5),
                  selectedColor: const Color(0xFF2196F3).withOpacity(0.15),
                  labelStyle: TextStyle(
                    color:
                        isSelected ? const Color(0xFF2196F3) : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF2196F3)
                          : Colors.transparent,
                    ),
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        selectedKriteria.add(item);
                      } else {
                        selectedKriteria.remove(item);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  "Terapkan",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
