import 'package:flutter/material.dart';
import 'login_page.dart'; // import หน้า Login

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sche-Do Project',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      // เริ่มต้นที่หน้า Login
      home: const LoginPage(),
    );
  }
}