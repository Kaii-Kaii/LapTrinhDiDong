import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CapNhatMatKhauScreen extends StatefulWidget {
  @override
  _CapNhatMatKhauScreenState createState() => _CapNhatMatKhauScreenState();
}

class _CapNhatMatKhauScreenState extends State<CapNhatMatKhauScreen>
    with TickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool isLoading = false;
  bool isNewPasswordObscured = true;
  bool isConfirmPasswordObscured = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

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
      _showSnackBar('Vui lòng nhập đầy đủ thông tin', Colors.red[400]!);
      return;
    }

    if (!isValidPassword(newPassword)) {
      _showSnackBar(
        'Mật khẩu tối thiểu 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt',
        Colors.red[400]!,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar('Mật khẩu xác nhận không khớp', Colors.red[400]!);
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
        _showSnackBar('Đổi mật khẩu thành công!', Colors.green[400]!);
        Navigator.pop(context);
      } else {
        _showSnackBar('Lỗi: ${response.body}', Colors.red[400]!);
      }
    } catch (e) {
      _showSnackBar('Lỗi kết nối: $e', Colors.red[400]!);
    }
    setState(() => isLoading = false);
  }

  Future<void> sendOtp() async {
    final username = usernameController.text.trim();
    if (username.isEmpty) {
      _showSnackBar('Vui lòng nhập tên đăng nhập', Colors.red[400]!);
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
        _showSnackBar('OTP đã được gửi về email!', Colors.green[400]!);
      } else {
        _showSnackBar('Lỗi: ${response.body}', Colors.red[400]!);
      }
    } catch (e) {
      _showSnackBar('Lỗi kết nối: $e', Colors.red[400]!);
    }
    setState(() => isLoading = false);
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
    bool hasVisibilityToggle = false,
    VoidCallback? onVisibilityToggle,
    bool isPasswordVisible = false,
  }) {
    const mainColor = Color(0xFF03A9F4);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(prefixIcon, color: mainColor, size: 20),
          ),
          suffixIcon:
              hasVisibilityToggle
                  ? IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey[600],
                    ),
                    onPressed: onVisibilityToggle,
                  )
                  : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF03A9F4);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              mainColor.withOpacity(0.1),
              Colors.white,
              mainColor.withOpacity(0.05),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mainColor.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mainColor.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.15,
              right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mainColor.withOpacity(0.08),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Back button
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: mainColor.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: mainColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Logo/Icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [mainColor, mainColor.withOpacity(0.8)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: mainColor.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.lock_reset,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Title
                          const Text(
                            "Đặt lại mật khẩu",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Nhập thông tin để khôi phục tài khoản",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Reset password form container
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: mainColor.withOpacity(0.1),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Username field
                                _buildTextField(
                                  controller: usernameController,
                                  labelText: "Tên đăng nhập",
                                  prefixIcon: Icons.person_outline,
                                ),
                                const SizedBox(height: 20),

                                // OTP field with send button
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _buildTextField(
                                        controller: otpController,
                                        labelText: "Mã OTP",
                                        prefixIcon: Icons.security,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              mainColor.withOpacity(0.8),
                                              mainColor.withOpacity(0.6),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: mainColor.withOpacity(0.2),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: isLoading ? null : sendOtp,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: const Text(
                                            "Gửi OTP",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // New Password field
                                _buildTextField(
                                  controller: newPasswordController,
                                  labelText: "Mật khẩu mới",
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: isNewPasswordObscured,
                                  hasVisibilityToggle: true,
                                  isPasswordVisible: !isNewPasswordObscured,
                                  onVisibilityToggle: () {
                                    setState(() {
                                      isNewPasswordObscured =
                                          !isNewPasswordObscured;
                                    });
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Confirm Password field
                                _buildTextField(
                                  controller: confirmPasswordController,
                                  labelText: "Xác nhận mật khẩu mới",
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: isConfirmPasswordObscured,
                                  hasVisibilityToggle: true,
                                  isPasswordVisible: !isConfirmPasswordObscured,
                                  onVisibilityToggle: () {
                                    setState(() {
                                      isConfirmPasswordObscured =
                                          !isConfirmPasswordObscured;
                                    });
                                  },
                                ),
                                const SizedBox(height: 30),

                                // Reset button
                                if (isLoading)
                                  Container(
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        colors: [
                                          mainColor.withOpacity(0.7),
                                          mainColor.withOpacity(0.5),
                                        ],
                                      ),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          mainColor,
                                          mainColor.withOpacity(0.8),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: mainColor.withOpacity(0.3),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: resetPassword,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "Đổi mật khẩu",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Back to login link
                          TextButton(
                            onPressed:
                                isLoading ? null : () => Navigator.pop(context),
                            child: Text(
                              "Quay lại đăng nhập",
                              style: TextStyle(
                                color: mainColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
