import 'package:flutter/material.dart';

class ProfilePemilikPage extends StatefulWidget {
  const ProfilePemilikPage({super.key});

  static const Color warnaLatar = Color(0xFFF5F7FB);
  static const Color warnaKartu = Colors.white;
  static const Color warnaUtama = Color(0xFF1E3A8A);

  @override
  State<ProfilePemilikPage> createState() => _ProfilePemilikPageState();
}

class _ProfilePemilikPageState extends State<ProfilePemilikPage> {
  final TextEditingController _namaController =
      TextEditingController(text: 'Nama Pemilik');
  final TextEditingController _usernameController =
      TextEditingController(text: 'pemilik123');
  final TextEditingController _emailController =
      TextEditingController(text: 'pemilik@example.com');
  final TextEditingController _teleponController =
      TextEditingController(text: '+62 812-3456-7890');
  final TextEditingController _alamatController =
      TextEditingController(text: 'Jl. Melati No. 12, Kota');

  bool _editNama = false;
  bool _editUsername = false;
  bool _editEmail = false;
  bool _editTelepon = false;
  bool _editAlamat = false;

  String? _backupNama;
  String? _backupUsername;
  String? _backupEmail;
  String? _backupTelepon;
  String? _backupAlamat;

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ProfilePemilikPage.warnaLatar,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: size.height * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header dengan cover gradient + avatar
              const _HeaderProfile(),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.015,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Informasi Akun'),
                    const SizedBox(height: 10),
                    _InfoFieldCard(
                      icon: Icons.person_outline,
                      label: 'Nama Lengkap',
                      controller: _namaController,
                      isEditing: _editNama,
                      onEdit: () => setState(() {
                        _backupNama = _namaController.text;
                        _editNama = true;
                      }),
                      onCancel: () => setState(() {
                        _namaController.text =
                            _backupNama ?? _namaController.text;
                        _editNama = false;
                      }),
                    ),
                    const SizedBox(height: 10),
                    _InfoFieldCard(
                      icon: Icons.alternate_email,
                      label: 'Username',
                      controller: _usernameController,
                      isEditing: _editUsername,
                      onEdit: () => setState(() {
                        _backupUsername = _usernameController.text;
                        _editUsername = true;
                      }),
                      onCancel: () => setState(() {
                        _usernameController.text =
                            _backupUsername ?? _usernameController.text;
                        _editUsername = false;
                      }),
                    ),
                    const SizedBox(height: 10),
                    _InfoFieldCard(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      controller: _emailController,
                      isEditing: _editEmail,
                      onEdit: () => setState(() {
                        _backupEmail = _emailController.text;
                        _editEmail = true;
                      }),
                      onCancel: () => setState(() {
                        _emailController.text =
                            _backupEmail ?? _emailController.text;
                        _editEmail = false;
                      }),
                    ),
                    const SizedBox(height: 10),
                    _InfoFieldCard(
                      icon: Icons.phone_outlined,
                      label: 'Telepon',
                      controller: _teleponController,
                      isEditing: _editTelepon,
                      onEdit: () => setState(() {
                        _backupTelepon = _teleponController.text;
                        _editTelepon = true;
                      }),
                      onCancel: () => setState(() {
                        _teleponController.text =
                            _backupTelepon ?? _teleponController.text;
                        _editTelepon = false;
                      }),
                    ),
                    const SizedBox(height: 10),
                    _InfoFieldCard(
                      icon: Icons.location_on_outlined,
                      label: 'Alamat',
                      controller: _alamatController,
                      isEditing: _editAlamat,
                      onEdit: () => setState(() {
                        _backupAlamat = _alamatController.text;
                        _editAlamat = true;
                      }),
                      onCancel: () => setState(() {
                        _alamatController.text =
                            _backupAlamat ?? _alamatController.text;
                        _editAlamat = false;
                      }),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.015,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Preferensi'),
                    const SizedBox(height: 10),
                    _SwitchCard(
                      icon: Icons.notifications_none,
                      label: 'Notifikasi',
                      value: true,
                      onChanged: (v, ctx) => _toast(
                          ctx, 'UI-only: Notifikasi ${v ? 'ON' : 'OFF'}'),
                    ),
                    const SizedBox(height: 10),
                    _SwitchCard(
                      icon: Icons.dark_mode_outlined,
                      label: 'Mode Gelap',
                      value: false,
                      onChanged: (v, ctx) => _toast(
                          ctx, 'UI-only: Mode Gelap ${v ? 'ON' : 'OFF'}'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.015,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                _toast(context, 'UI-only: Data pemilik disimpan');
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Simpan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ProfilePemilikPage.warnaUtama,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderProfile extends StatelessWidget {
  static const Color warnaUtama = Color(0xFF1E3A8A);

  const _HeaderProfile();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Cover gradient
        Container(
          height: 180,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [warnaUtama, Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Wave shape (simple decor)
        Positioned(
          right: -60,
          top: -40,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -40,
          bottom: -50,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Content
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Title only (back icon removed)
              Row(
                children: const [
                  Expanded(
                    child: Text(
                      'Profil Pemilik',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Avatar + tombol ubah foto
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 34,
                          backgroundColor: Color(0xFFDDE6FF),
                          child:
                              Icon(Icons.person, color: warnaUtama, size: 36),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit,
                                  size: 16, color: warnaUtama),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nama Pemilik',
                            style: TextStyle(
                              color: warnaUtama,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'pemilik@example.com',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('UI-only: Ubah Foto Profil')),
                        );
                      },
                      style:
                          TextButton.styleFrom(foregroundColor: Colors.white),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Ubah Foto'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        )
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _InfoFieldCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  const _InfoFieldCard({
    required this.icon,
    required this.label,
    required this.controller,
    required this.isEditing,
    required this.onEdit,
    required this.onCancel,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFDDE6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1E3A8A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 4),
                if (isEditing)
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF5F7FB),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  )
                else
                  Text(
                    controller.text,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          InkWell(
            onTap: isEditing ? onCancel : onEdit,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFF1E3A8A).withOpacity(0.25)),
              ),
              child: Text(
                isEditing ? 'Batal' : 'Ubah',
                style: const TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final void Function(bool, BuildContext) onChanged;

  const _SwitchCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
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
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFDDE6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1E3A8A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFF1E3A8A),
            onChanged: (v) => onChanged(v, context),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final void Function(BuildContext) onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Color(0xFFDDE6FF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF1E3A8A)),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => onTap(context),
      ),
    );
  }
}
