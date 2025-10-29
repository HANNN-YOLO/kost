import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kost_saw/widgets/main_navigation_admin.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/profil_provider.dart';

import 'test.dart';
import 'screens/auth/Login.dart';
import 'screens/auth/Register.dart';
import 'package:kost_saw/widgets/main_navigation.dart';

import 'screens/main/admin/dashboard.dart';

import 'screens/main/user/Home.dart';
import 'screens/main/user/Profile.dart';
import 'screens/main/user/recommendation.dart';

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
            previous?.terisi(value.accesstoken!, value.email!, value.id_auth!);
            // return previous!;
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
              } else if (cek.role == "User") {
                menuju = MainNavigation();
                // KostHomePage();
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
