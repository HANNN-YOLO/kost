// import 'package:flutter/material.dart';
// import 'package:kost_saw/screens/main/admin/criteria_management.dart';
// import 'package:kost_saw/screens/main/admin/management_boarding_house.dart';
// import 'package:kost_saw/screens/main/admin/user_management.dart';

// class MainNavigationAdmin extends StatefulWidget {
//   const MainNavigationAdmin({Key? key}) : super(key: key);
//   static const arah = "/mainavigation";

//   @override
//   _MainNavigationAdminState createState() => _MainNavigationAdminState();
// }

// class _MainNavigationAdminState extends State<MainNavigationAdmin> {
//   int _selectedIndex = 1;
//   final List<int> _history = [1]; // menyimpan urutan tab terakhir

//   // Fungsi untuk menampilkan halaman sesuai index
//   Widget _getPage(int index) {
//     switch (index) {
//       case 0:
//         return ManagementBoardingHouse();
//       case 1:
//         return CriteriaManagement();
//       case 2:
//         return UserManagement();
//       default:
//         return CriteriaManagement();
//     }
//   }

//   // Fungsi ketika bottom nav ditekan
//   void _onItemTapped(int index) {
//     if (_selectedIndex != index) {
//       setState(() {
//         _selectedIndex = index;
//         _history.add(index);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: _history.length <= 1,
//       onPopInvoked: (didPop) {
//         if (_history.length > 1) {
//           _history.removeLast();
//           setState(() {
//             _selectedIndex = _history.last;
//           });
//         }
//       },
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF8F7F7),
//         body: _getPage(_selectedIndex),
//         bottomNavigationBar: BottomNavigationBar(
//           type: BottomNavigationBarType.fixed,
//           currentIndex: _selectedIndex,
//           selectedItemColor: const Color(0xFF237EF2),
//           unselectedItemColor: const Color(0xFFA4A4A4),
//           onTap: _onItemTapped,
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined),
//               label: 'Daftar Kos',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.star_border_outlined),
//               label: 'Kriteria',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person_outline),
//               label: 'Daftar Pengguna',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:kost_saw/screens/main/admin/criteria_management.dart';
import 'package:kost_saw/screens/main/admin/management_boarding_house.dart';
import 'package:kost_saw/screens/main/admin/user_management.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class MainNavigationAdmin extends StatefulWidget {
  const MainNavigationAdmin({Key? key}) : super(key: key);
  static const arah = "/mainavigation-admin";

  @override
  _MainNavigationAdminState createState() => _MainNavigationAdminState();
}

class _MainNavigationAdminState extends State<MainNavigationAdmin> {
  int _selectedIndex = 2;
  final List<int> _history = [1]; // menyimpan urutan tab terakhir

  // Fungsi untuk menampilkan halaman sesuai index
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const ManagementBoardingHouse();
      case 1:
        return const CriteriaManagement();
      case 2:
        return UserManagement();
      default:
        return const CriteriaManagement();
    }
  }

  // Fungsi konfirmasi logout
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Konfirmasi Logout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Apakah Anda yakin ingin keluar dari akun admin?"),
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

  // Fungsi ketika bottom nav ditekan
  void _onItemTapped(int index) {
    if (index == 3) {
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
              icon: Icon(Icons.home_outlined),
              label: 'Daftar Kos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_border_outlined),
              label: 'Kriteria',
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
