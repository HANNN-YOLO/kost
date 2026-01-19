import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/profil_provider.dart';
import 'package:intl/intl.dart';

class DetailUser extends StatelessWidget {
  static const arah = "/detail-user-admin";
  const DetailUser({super.key});

  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;

    // 🎨 Warna dan gaya umum
    const warnaUtama = Color(0xFF1C3B98);
    const warnaLatar = Color(0xFFF5F7FB);
    const warnaTeksHitam = Colors.black87;
    const warnaAbu = Color(0xFF6B7280);

    final terima = ModalRoute.of(context)!.settings.arguments as int;
    final profilProvider = Provider.of<ProfilProvider>(context, listen: false);

    dynamic pakai;
    try {
      pakai = profilProvider.alluser
          .firstWhere((element) => element.id_auth == terima);
    } catch (_) {
      pakai = null;
    }

    dynamic isinya;
    try {
      isinya = profilProvider.listauth
          .firstWhere((element) => element.id_auth == terima);
    } catch (_) {
      isinya = null;
    }

    final String displayNama = isinya?.username ?? 'Tidak ada';
    final String displayEmail = isinya?.Email ?? 'Tidak ada';
    final String displayFoto = pakai?.foto ?? '';
    final bool hasProfil = pakai != null;

    return Scaffold(
      backgroundColor: warnaLatar,

      // 🔹 HEADER seperti halaman Daftar Kost / Daftar Pengguna
      appBar: AppBar(
        elevation: 0,
        backgroundColor: warnaUtama,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () {
            Navigator.pop(
              context,
            );
          },
        ),
        title: const Text(
          'Detail Pengguna',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: lebarLayar * 0.05),
        child: Column(
          children: [
            SizedBox(height: tinggiLayar * 0.04),

            // 🔹 Bagian Profil
            Column(
              children: [
                Container(
                  width: lebarLayar * 0.22,
                  height: lebarLayar * 0.22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFDDE6FF),
                    image: displayFoto.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(displayFoto),
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          )
                        : null,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: displayFoto.isEmpty
                      ? const Icon(
                          Icons.person,
                          color: Colors.white70,
                          size: 40,
                        )
                      : null,
                ),
                SizedBox(height: tinggiLayar * 0.015),
                Text(
                  displayNama,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: warnaTeksHitam,
                  ),
                ),
                Text(
                  displayEmail,
                  style: TextStyle(
                    fontSize: 14,
                    color: warnaAbu,
                  ),
                ),
              ],
            ),

            SizedBox(height: tinggiLayar * 0.04),

            // 🔹 Bagian Informasi Pengguna
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Informasi pengguna",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: warnaTeksHitam,
                      ),
                    ),
                    SizedBox(height: tinggiLayar * 0.015),

                    // 🔹 Kartu Informasi
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: tinggiLayar * 0.02,
                        horizontal: lebarLayar * 0.04,
                      ),
                      child: Column(
                        children: [
                          infoBar("Nama", displayNama),
                          infoBar("Email", displayEmail),
                          infoBar(
                            "Jenis Kelamin",
                            pakai?.jkl != null && "${pakai.jkl}".isNotEmpty
                                ? "${pakai.jkl}"
                                : "-",
                          ),
                          infoBar(
                            "No. handphone",
                            pakai == null
                                ? "Belum mengisi profil"
                                : (pakai.kontak == 0
                                    ? "Tidak di publish"
                                    : "${pakai.kontak}"),
                          ),
                          infoBar(
                            "Tanggal Lahir",
                            pakai?.tgllahir != null
                                ? DateFormat('dd-MM-yyyy')
                                    .format(pakai.tgllahir as DateTime)
                                : "-",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              left: lebarLayar * 0.05, right: lebarLayar * 0.05, bottom: 12),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: hasProfil
                  ? () {
                      _showEditBottomSheet(context, pakai);
                    }
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Pengguna belum mengisi profil, tidak ada data untuk diedit.',
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: warnaUtama,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
              label: const Text(
                'Edit Informasi Pengguna',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔸 Widget baris info (label & nilai)
  Widget infoBar(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.5,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditBottomSheet(BuildContext context, dynamic pakai) {
    final profilProvider = Provider.of<ProfilProvider>(context, listen: false);

    final TextEditingController noHpController = TextEditingController(
      text: pakai.kontak?.toString() ?? '',
    );
    final TextEditingController tglController = TextEditingController(
      text: pakai.tgllahir != null
          ? DateFormat('dd-MM-yyyy')
              .format(DateTime.parse(pakai.tgllahir.toString()))
          : '',
    );

    String selectedJkl = (pakai.jkl ?? '').toString().isNotEmpty
        ? pakai.jkl.toString()
        : 'Laki-Laki';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (ctx, setState) {
            final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 18,
                bottom: bottomInset + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Edit Informasi Pengguna',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Perbarui data profil seperti tanggal lahir, nomor handphone, dan jenis kelamin.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tanggal lahir
                  TextField(
                    controller: tglController,
                    readOnly: true,
                    onTap: () async {
                      final now = DateTime.now();
                      final initialDate = pakai.tgllahir ?? now;
                      final picked = await showDatePicker(
                        context: ctx,
                        firstDate: DateTime(1945),
                        lastDate: DateTime(9999),
                        initialDate: initialDate,
                      );
                      if (picked != null) {
                        tglController.text =
                            DateFormat('dd-MM-yyyy').format(picked);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Tanggal Lahir',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1C3B98),
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Jenis kelamin
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Jenis Kelamin',
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedJkl,
                        items: const [
                          DropdownMenuItem(
                            value: 'Laki-Laki',
                            child: Text('Laki-Laki'),
                          ),
                          DropdownMenuItem(
                            value: 'Perempuan',
                            child: Text('Perempuan'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() {
                            selectedJkl = val;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // No HP
                  TextField(
                    controller: noHpController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'No. Handphone',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1C3B98),
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (tglController.text.isEmpty ||
                                      noHpController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Tanggal lahir dan nomor handphone tidak boleh kosong.'),
                                      ),
                                    );
                                    return;
                                  }

                                  final hp =
                                      int.tryParse(noHpController.text.trim());
                                  if (hp == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Nomor handphone harus berupa angka.'),
                                      ),
                                    );
                                    return;
                                  }

                                  DateTime tgl;
                                  try {
                                    tgl = DateFormat('dd-MM-yyyy')
                                        .parse(tglController.text);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Format tanggal lahir tidak valid.'),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    isSaving = true;
                                  });

                                  try {
                                    await profilProvider.adminUpdateUserProfil(
                                      idProfil: pakai.id_profil!,
                                      jkl: selectedJkl,
                                      kontak: hp,
                                      tgllahir: tgl,
                                    );

                                    if (context.mounted) {
                                      Navigator.of(ctx).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Informasi pengguna berhasil diperbarui.'),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Gagal memperbarui informasi: $e'),
                                        ),
                                      );
                                    }
                                  } finally {
                                    setState(() {
                                      isSaving = false;
                                    });
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1C3B98),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Simpan Perubahan',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
