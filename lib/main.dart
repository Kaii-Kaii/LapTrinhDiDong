import 'package:flutter/material.dart';
import 'package:qltncn/screens/HomePage.dart';
import 'package:qltncn/screens/s_Login/DangNhap.dart';
import 'dart:io';

void main() {
  //runApp(const MyApp());
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyAppLogin());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyAppLogin extends StatelessWidget {
  const MyAppLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QL TNCN',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
