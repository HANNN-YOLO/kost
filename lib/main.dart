import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kost_saw/models/auth_model.dart';
import 'package:kost_saw/providers/tujuan_providers.dart';
import 'package:kost_saw/screens/main/pemilik/form_house_pemilik.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/profil_provider.dart';
import 'providers/kost_provider.dart';
import 'providers/kriteria_provider.dart';

import 'test.dart';
import 'screens/auth/Login.dart';
import 'screens/auth/Register.dart';
import 'package:kost_saw/widgets/main_navigation.dart';
import 'package:kost_saw/widgets/main_navigation_admin.dart';
import 'package:kost_saw/widgets/main_navigation_pemilik.dart';

import 'screens/main/admin/criteria_management.dart';
import 'screens/main/admin/detail_user.dart';
import 'screens/main/admin/form_house.dart';
import 'screens/main/admin/management_boarding_house.dart';
import 'screens/main/admin/user_management.dart';
import 'screens/main/detail_kost.dart';

import 'screens/main/penyewa/Home.dart';
import 'screens/main/penyewa/Profile.dart';
import 'screens/main/penyewa/recommendation.dart';

import 'screens/main/pemilik/dashboard_income.dart';
import 'screens/main/pemilik/management_kost_pemilik.dart';
import 'screens/main/pemilik/profile_pemilik.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AuthProvider()),
      ChangeNotifierProxyProvider<AuthProvider, ProfilProvider>(
        create: (context) => ProfilProvider(),
        update: (context, value, previous) {
          previous ?? ProfilProvider();
          if (value.accesstoken != null &&
              value.email != null &&
              value.id_auth != null) {
            previous?.terisi(
              value.accesstoken!,
              value.email!,
              value.id_auth!,
              value.hasilnya,
            );
            // return previous!;
          }
          return previous!;
        },
      ),
      ChangeNotifierProxyProvider<AuthProvider, KostProvider>(
        create: (context) => KostProvider(),
        update: (context, value, previous) {
          previous ?? KostProvider();
          if (value.accesstoken != null &&
              value.email != null &&
              value.id_auth != null &&
              value.hasilnya != null &&
              value.expiresIn != null) {
            previous?.isi(
              value.accesstoken!,
              value.email!,
              value.expiresIn!,
              value.hasilnya,
              value.id_auth!,
            );
            // print("done ambil data");
            // return previous!;
          }
          return previous!;
        },
      ),
      ChangeNotifierProxyProvider<AuthProvider, KriteriaProvider>(
        create: (_) => KriteriaProvider(),
        update: (context, value, previous) {
          previous ?? KriteriaProvider();
          if (value.accesstoken != null &&
              value.email != null &&
              value.expiresIn != null &&
              value.id_auth != null) {
            previous!.wajiib_terisi(
              value.accesstoken!,
              value.email!,
              value.expiresIn!,
              value.id_auth!,
            );
          }
          return previous!;
        },
      ),
      ChangeNotifierProxyProvider<AuthProvider, TujuanProviders>(
        create: (_) => TujuanProviders(),
        update: (context, value, previous) {
          previous ?? TujuanProviders();
          if (value.accesstoken != null &&
              value.email != null &&
              value.expiresIn != null) {
            previous?.terisi(
              value.accesstoken!,
              value.email!,
              value.expiresIn!,
            );
          }
          return previous!;
        },
      ),
    ],
    builder: (context, child) {
      return App();
    },
  ));
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final penghubung = Provider.of<AuthProvider>(context, listen: false);

    return FutureBuilder(
      future: penghubung.autologinbaca(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        return Consumer<AuthProvider>(
          builder: (context, value, child) {
            final login = value.token;
            Widget? menuju;

            if (login) {
              AuthModel? cek;
              try {
                cek = value.mydata.firstWhere(
                  (element) => element.Email == value.email,
                );
              } catch (_) {
                cek = null;
              }

              if (cek == null) {
                // Data role belum siap / gagal dimuat -> jangan crash
                menuju = const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (cek.role == "Admin") {
                menuju = MainNavigationAdmin();
              } else if (cek.role == "Penyewa") {
                menuju = MainNavigation();
              } else if (cek.role == "Pemilik") {
                menuju = const MainNavigationPemilik();
              } else {
                menuju = LoginPage();
              }
            } else {
              menuju = LoginPage();
            }

            return MaterialApp(
              key: ValueKey(value.tokens),
              debugShowCheckedModeBanner: false,
              routes: {
                "/test": (_) => Test(),

                // state halaman
                "/login": (_) => LoginPage(),
                "/register": (_) => RegisterPage(),

                // state user
                "/mainavigation": (_) => MainNavigation(),
                "/kost-home": (_) => KostHomePage(),
                "/profil-user": (_) => UserProfilePage(),
                "/recomended-user": (_) => UserRecommendationPage(),

                // state Admin
                "/mainavigation-admin": (_) => MainNavigationAdmin(),
                "/criteria-admin": (_) => CriteriaManagement(),
                "/detail-user-admin": (_) => DetailUser(),
                "/form-house-admin": (_) => FormHouse(),
                "/management-board-admin": (_) => ManagementBoardingHouse(),
                "/user-management-admin": (_) => UserManagement(),

                // state pemilik
                'dashboard-pemilik': (_) => DashboardIncome(),
                '/management-board-pemilik': (_) => ManagementKostPemilik(),
                '/mainavigation-pemilik': (_) => const MainNavigationPemilik(),
                '/form-house-pemilik': (_) => FormAddHousePemilik(),
                '/profil-pemilik': (_) => ProfilePemilikPage(),

                // reusable
                "detail-kost": (_) => DetailKost(),
              },
              // initialRoute: "/login",
              // home: value.token ? KostHomePage() : LoginPage(),
              home: menuju,
            );
          },
        );
      },
    );
  }
}
// s
