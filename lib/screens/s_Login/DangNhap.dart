import 'package:flutter/material.dart';
import 'package:qltncn/screens/HomePage.dart';
import 'RegisterScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qltncn/model/KhachHang/khachhang_service.dart';
import 'package:qltncn/screens/s_Login/ThemThongTinKhachHang.dart';
import 'package:qltncn/screens/s_Login/CapNhatMatKhauScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordHidden = true;
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    final savedPassword = prefs.getString('password');

    if (savedUsername != null && savedPassword != null) {
      setState(() {
        emailController.text = savedUsername;
        passwordController.text = savedPassword;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF03A9F4);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: mainColor, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Đăng nhập",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Tên đăng nhập",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: mainColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: mainColor, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.person, color: mainColor),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: _isPasswordHidden,
                  decoration: InputDecoration(
                    labelText: "Mật khẩu",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: mainColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: mainColor, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: mainColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordHidden
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: mainColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordHidden = !_isPasswordHidden;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (isLoading)
                  const LinearProgressIndicator(
                    color: mainColor,
                    backgroundColor: Colors.grey,
                    minHeight: 4,
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      _login(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Đăng nhập",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterScreen()),
                    );
                  },
                  child: const Text(
                    "Chưa có tài khoản? Đăng ký",
                    style: TextStyle(color: mainColor),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CapNhatMatKhauScreen()),
                    );
                  },
                  child: const Text(
                    "Quên mật khẩu?",
                    style: TextStyle(color: mainColor),
                  ),
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
        const SnackBar(
          content: Text('Vui lòng nhập tên đăng nhập và mật khẩu'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

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
          final isEmailConfirmed = tk['isemailconfirmed'];

          if (tendangnhap == username && matkhau == password) {
            if (isEmailConfirmed == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Tài khoản chưa xác thực email. Vui lòng kiểm tra email để xác thực!',
                  ),
                ),
              );
              setState(() {
                isLoading = false;
              });
              return;
            }
            isAuthenticated = true;
            matk = tk['mataikhoan']?.trim() ?? '';
            break;
          }
        }

        if (isAuthenticated) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', username);
          await prefs.setString('password', password);

          final maKH = await KhachHangService.fetchMaKHByMaTaiKhoan(matk);
          if (maKH == null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => AddCustomerInfoScreen(maTaiKhoan: matk),
              ),
            );
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng nhập thành công!')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomePage(maKH: maKH, userName: username),
            ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi kết nối: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
