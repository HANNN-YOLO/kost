import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'test.dart';
import 'screens/auth/Login.dart';
import 'screens/main/admin/dashboard.dart';
import 'package:kost_saw/screens/auth/Register.dart';
import 'package:kost_saw/screens/main/user/Home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        "/test": (_) => Test(),
        "/login": (_) => LoginPage(),
        "/register": (_) => RegisterPage(),
        "/kost_home": (_) => KostHomePage(),
        "/dashboard": (_) => Dashboard()
      },
      initialRoute: "/login",
    );
  }
}
