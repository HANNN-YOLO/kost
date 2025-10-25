import 'package:flutter/material.dart';
import 'package:kost_saw/screens/main/user/recommendation.dart';
import 'package:kost_saw/screens/main/user/Home.dart';
import 'package:kost_saw/screens/main/user/Profile.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);
  static const arah = "/mainavigation";

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 1;
  final List<int> _history = [1]; // menyimpan urutan tab terakhir

  // Fungsi untuk menampilkan halaman sesuai index
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return UserRecommendationPage();
      case 1:
        return KostHomePage();
      case 2:
        return UserProfilePage();
      default:
        return KostHomePage();
    }
  }

  // Fungsi ketika bottom nav ditekan
  void _onItemTapped(int index) {
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
              icon: Icon(Icons.star_border_outlined),
              label: 'Rekomendasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
