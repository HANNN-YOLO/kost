import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kost_saw/models/fasilitas_model.dart';
import 'package:kost_saw/screens/main/pemilik/form_add_house_pemilik.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/profil_provider.dart';
import 'providers/kost_provider.dart';

import 'test.dart';
import 'screens/auth/Login.dart';
import 'screens/auth/Register.dart';
import 'package:kost_saw/widgets/main_navigation.dart';
import 'package:kost_saw/widgets/main_navigation_admin.dart';
import 'package:kost_saw/widgets/main_navigation_pemilik.dart';

import 'screens/main/admin/dashboard.dart';
import 'screens/main/admin/criteria_management.dart';
import 'screens/main/admin/detail_user.dart';
import 'screens/main/admin/form_house.dart';
import 'screens/main/admin/management_boarding_house.dart';
import 'screens/main/admin/user_management.dart';
import 'screens/main/admin/detail_kost.dart';

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
              value.id_auth != null) {
            previous?.isi(
              value.accesstoken!,
              value.email!,
              value.expiresIn!,
              value.hasilnya,
              value.id_auth!,
            );
            print("done ambil data");
            // return previous!;
          }
          return previous!;
        },
      ),
      ChangeNotifierProvider(create: (_) => FasilitasModel()),
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
              value.readrole();

              // if (value.mydata.isEmpty) {
              //   return MaterialApp(
              //     home: Scaffold(
              //       body: Center(
              //         child: CircularProgressIndicator(),
              //       ),
              //     ),
              //   );
              // }

              final cek = value.mydata
                  .firstWhere((element) => element.Email == value.email);

              if (cek.role == "Admin") {
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
                "/dashboard": (_) => Dashboard(),
                "/mainavigation-admin": (_) => MainNavigationAdmin(),
                "/criteria-admin": (_) => CriteriaManagement(),
                "/detail-user-admin": (_) => DetailUser(),
                "/house-admin": (_) => FormHouse(),
                "/management-board-admin": (_) => ManagementBoardingHouse(),
                "/user-management-admin": (_) => UserManagement(),
                "detail-kost-admin": (_) => DetailKost(),

                // state pemilik
                'dashboard-pemilik': (_) => DashboardIncome(),
                '/management-board-pemilik': (_) => ManagementKostPemilik(),
                '/mainavigation-pemilik': (_) => const MainNavigationPemilik(),
                '/form-add-house-pemilik': (_) => FormAddHousePemilik(),
                '/profil-pemilik': (_) => const ProfilePemilikPage(),
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
