import 'package:flutter/material.dart';
import 'package:qltncn/screens/HomePage.dart';
import 'RegisterScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qltncn/model/KhachHang/khachhang_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Đăng nhập",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Mật khẩu",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // Xử lý đăng nhập
                    _login(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text("Đăng nhập"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterScreen()),
                    );
                  },
                  child: const Text("Chưa có tài khoản? Đăng ký"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login(BuildContext context) async {
    String username = emailController.text.trim();
    String password = passwordController.text.trim();
    String matk = '';

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên đăng nhập và mật khẩu')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://10.0.2.2:7283/api/TaiKhoan'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> taiKhoans = jsonDecode(response.body);

        bool isAuthenticated = false;

        for (var tk in taiKhoans) {
          final tendangnhap = tk['tendangnhap']?.trim();
          final matkhau = tk['matkhau']?.trim();

          if (tendangnhap == username && matkhau == password) {
            isAuthenticated = true;
            matk = tk['mataikhoan']?.trim() ?? '';
            break;
          }
        }

        if (isAuthenticated) {
          final maKH = await KhachHangService.fetchMaKHByMaTaiKhoan(matk);
          if (maKH == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Không tìm thấy khách hàng tương ứng')),
            );
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng nhập thành công!')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage(maKH: maKH)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sai tên đăng nhập hoặc mật khẩu')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi server: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kết nối: $e')),
      );
    }
  }
}