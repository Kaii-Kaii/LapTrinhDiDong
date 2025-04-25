import 'package:flutter/material.dart';
import 'package:qltncn/screens/HomePage.dart';
import 'package:qltncn/screens/s_Login/DangNhap.dart';

void main() {
  //runApp(const MyApp());
  runApp(MyAppLogin());
}



class MyAppLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QL TNCN',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
