import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kost_saw/widgets/main_navigation.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'test.dart';
import 'screens/auth/Login.dart';
import 'screens/auth/Register.dart';
import 'screens/main/admin/dashboard.dart';
import 'screens/main/user/Home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AuthProvider()),
      //
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
                menuju = Dashboard();
              } else if (cek.role == "User") {
                menuju = MainNavigation();
              } else {
                menuju = RegisterPage();
              }
            } else {
              menuju = LoginPage();
            }

            return MaterialApp(
              key: ValueKey(value.tokens),
              debugShowCheckedModeBanner: false,
              routes: {
                "/test": (_) => Test(),
                "/login": (_) => LoginPage(),
                "/register": (_) => RegisterPage(),
                "/mainavigation": (_) => MainNavigation(),
                // "/dashboard": (_) => Dashboard()
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
