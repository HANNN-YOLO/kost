import 'package:flutter/material.dart';
import 'package:kost_saw/screens/main/pemilik/dashboard_income.dart';
import 'package:kost_saw/screens/main/pemilik/management_kost_pemilik.dart';
import 'package:kost_saw/screens/main/pemilik/profile_pemilik.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class MainNavigationPemilik extends StatefulWidget {
  const MainNavigationPemilik({Key? key}) : super(key: key);
  static const arah = "/mainavigation-pemilik";

  @override
  _MainNavigationPemilikState createState() => _MainNavigationPemilikState();
}

class _MainNavigationPemilikState extends State<MainNavigationPemilik> {
  int _selectedIndex = 0;
  final List<int> _history = [0];

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const ManagementKostPemilik();
      case 1:
        return DashboardIncome();
      case 2:
        return const ProfilePemilikPage();
      case 3:
        return const SizedBox.shrink(); // handled by logout
      default:
        return const ManagementKostPemilik();
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Konfirmasi Logout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Apakah Anda yakin ingin keluar dari akun?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      _showLogoutConfirmation();
      return;
    }
    if (_selectedIndex != index) {
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
        if (_history.length > 1) {
          _history.removeLast();
          setState(() {
            _selectedIndex = _history.last;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F7F7),
        body: _getPage(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF237EF2),
          unselectedItemColor: const Color(0xFFA4A4A4),
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.other_houses_outlined),
              label: 'Daftar Kost Anda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Ringkasan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profil',
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
