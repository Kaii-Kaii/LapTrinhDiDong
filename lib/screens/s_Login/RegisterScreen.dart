import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool isPasswordObscured = true;
  bool isConfirmPasswordObscured = true;

  bool isValidUsername(String username) {
    final regex = RegExp(r'^[a-zA-Z0-9_]{4,20}$');
    return regex.hasMatch(username);
  }

  bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    final regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~_])[A-Za-z\d!@#\$&*~_]{8,}$',
    );
    return regex.hasMatch(password);
  }

  Future<bool> isUsernameExists(String username) async {
    final response = await http.get(
      Uri.parse(
        'https://10.0.2.2:7283/api/TaiKhoan/CheckUsername?username=$username',
      ),
    );
    if (response.statusCode == 200) {
      return response.body.toLowerCase() == 'true';
    }
    return true;
  }

  Future<void> _register(BuildContext context) async {
    if (isLoading) return; // Ngăn spam
    setState(() => isLoading = true);

    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      setState(() => isLoading = false);
      return;
    }

    if (!isValidUsername(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tên đăng nhập phải từ 4-20 ký tự, không chứa ký tự đặc biệt',
          ),
        ),
      );
      setState(() => isLoading = false);
      return;
    }

    if (await isUsernameExists(username)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tên đăng nhập đã tồn tại')));
      setState(() => isLoading = false);
      return;
    }

    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email không hợp lệ')));
      setState(() => isLoading = false);
      return;
    }

    if (!isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mật khẩu tối thiểu 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt',
          ),
        ),
      );
      setState(() => isLoading = false);
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mật khẩu không khớp')));
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://10.0.2.2:7283/api/TaiKhoan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "mataikhoan": "",
          "maquyen": "Q002",
          "tendangnhap": username,
          "matkhau": password,
          "email": email,
          "isemailconfirmed": 0,
          "emailconfirmationtoken": null,
          "otp": null,
          "khachHang": null,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Đăng ký thành công! Vui lòng kiểm tra email để xác thực tài khoản.',
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi kết nối: $e')));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF03A9F4);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: mainColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Đăng ký",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: usernameController,
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
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: mainColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: mainColor, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.email, color: mainColor),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: isPasswordObscured,
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
                        isPasswordObscured
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: mainColor,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordObscured = !isPasswordObscured;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: isConfirmPasswordObscured,
                  decoration: InputDecoration(
                    labelText: "Nhập lại mật khẩu",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: mainColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: mainColor, width: 2),
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: mainColor,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isConfirmPasswordObscured
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: mainColor,
                      ),
                      onPressed: () {
                        setState(() {
                          isConfirmPasswordObscured =
                              !isConfirmPasswordObscured;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    if (isLoading)
                      const LinearProgressIndicator(
                        color: mainColor,
                        backgroundColor: Colors.grey,
                        minHeight: 4, // Độ dày của thanh
                      )
                    else
                      ElevatedButton(
                        onPressed: isLoading ? null : () => _register(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size(double.infinity, 60),
                        ),
                        child: const Text(
                          "Đăng ký",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed:
                      isLoading
                          ? null
                          : () {
                            Navigator.pop(context);
                          },
                  child: const Text(
                    "Đã có tài khoản? Đăng nhập",
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
}
