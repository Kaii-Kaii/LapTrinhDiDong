import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CapNhatMatKhauScreen extends StatefulWidget {
  @override
  _CapNhatMatKhauScreenState createState() => _CapNhatMatKhauScreenState();
}

class _CapNhatMatKhauScreenState extends State<CapNhatMatKhauScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool isLoading = false;
  bool isNewPasswordObscured = true;
  bool isConfirmPasswordObscured = true;

  bool isValidPassword(String password) {
    final regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~_])[A-Za-z\d!@#\$&*~_]{8,}$',
    );
    return regex.hasMatch(password);
  }

  Future<void> resetPassword() async {
    final username = usernameController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final otp = int.tryParse(otpController.text.trim());

    if (username.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty ||
        otp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }
    if (!isValidPassword(newPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mật khẩu tối thiểu 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt',
          ),
        ),
      );
      return;
    }
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu xác nhận không khớp')),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      // Thêm delay 1.5 giây
      await Future.delayed(const Duration(milliseconds: 500));

      final response = await http.post(
        Uri.parse('https://10.0.2.2:7283/api/TaiKhoan/ResetPassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": username,
          "newPassword": newPassword,
          "otp": otp,
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đổi mật khẩu thành công!')),
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

  Future<void> sendOtp() async {
    final username = usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên đăng nhập')),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://10.0.2.2:7283/api/TaiKhoan/SendOtp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"username": username}),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP đã được gửi về email!')),
        );
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
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: otpController,
                      decoration: InputDecoration(
                        labelText: "OTP",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: mainColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: mainColor,
                            width: 2,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_clock,
                          color: mainColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: sendOtp,
                    child: const Text(
                      "Gửi OTP",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: isNewPasswordObscured,
                decoration: InputDecoration(
                  labelText: "Mật khẩu mới",
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
                      isNewPasswordObscured
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: mainColor,
                    ),
                    onPressed: () {
                      setState(() {
                        isNewPasswordObscured = !isNewPasswordObscured;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: isConfirmPasswordObscured,
                decoration: InputDecoration(
                  labelText: "Xác nhận mật khẩu mới",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: mainColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: mainColor, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline, color: mainColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isConfirmPasswordObscured
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: mainColor,
                    ),
                    onPressed: () {
                      setState(() {
                        isConfirmPasswordObscured = !isConfirmPasswordObscured;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const LinearProgressIndicator(
                    color: mainColor,
                    backgroundColor: Colors.grey,
                    minHeight: 4,
                  )
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: resetPassword,
                      child: const Text(
                        "Đổi mật khẩu",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
