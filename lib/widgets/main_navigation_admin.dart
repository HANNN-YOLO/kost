import 'package:flutter/material.dart';
import 'package:kost_saw/screens/main/admin/criteria_management.dart';
import 'package:kost_saw/screens/main/admin/management_boarding_house.dart';
import 'package:kost_saw/screens/main/admin/user_management.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/kost_provider.dart';
import 'package:kost_saw/screens/main/admin/subcriteria_management.dart';

class MainNavigationAdmin extends StatefulWidget {
  const MainNavigationAdmin({Key? key}) : super(key: key);
  static const arah = "/mainavigation-admin";

  @override
  _MainNavigationAdminState createState() => _MainNavigationAdminState();
}

class _MainNavigationAdminState extends State<MainNavigationAdmin> {
  int _selectedIndex = 2;
  final List<int> _history = [2]; // menyimpan urutan tab terakhir

  // Fungsi untuk menampilkan halaman sesuai index
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return ManagementBoardingHouse();
      case 1:
        return CriteriaManagement();
      case 2:
        return SubcriteriaManagement();
      // Sementara();
      case 3:
        return UserManagement();
      default:
        return CriteriaManagement();
    }
  }

  // Fungsi konfirmasi logout
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          "Konfirmasi Logout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text("Apakah Anda yakin ingin keluar dari akun admin?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final kost = Provider.of<KostProvider>(context, listen: false);
              final rootNavigator = Navigator.of(
                context,
                rootNavigator: true,
              );

              await auth.logout();
              kost.resetSession();

              if (!mounted) return;
              rootNavigator.pop();
              rootNavigator.pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
            child: Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Fungsi ketika bottom nav ditekan
  void _onItemTapped(int index) {
    if (index == 4) {
      // Jika tombol logout ditekan
      _showLogoutConfirmation();
    } else if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
        _history.add(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _history.length <= 1,
      onPopInvoked: (didPop) {
        // Jika route sudah benar-benar di-pop, jangan ubah state.
        if (didPop) return;
        if (_history.length <= 1) return;

        _history.removeLast();
        final nextIndex = _history.last;

        // Tunda setState agar tidak memicu rebuild saat framework sedang "locked"
        // (kasus: back navigation di tengah transisi / pop).
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _selectedIndex = nextIndex;
          });
        });
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF8F7F7),
        body: _getPage(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFF237EF2),
          unselectedItemColor: Color(0xFFA4A4A4),
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Daftar Kos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_border_outlined),
              label: 'Kriteria',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grain),
              label: 'subkriteria',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Daftar Pengguna',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout, color: Colors.red),
              label: 'Logout',
            ),
          ],
        ),
      ),
    );
  }
}
