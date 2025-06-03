import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool isPasswordObscured = true;
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
    if (isLoading) return;
    setState(() => isLoading = true);

    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar('Vui lòng điền đầy đủ thông tin', Colors.red[400]!);
      setState(() => isLoading = false);
      return;
    }

    if (!isValidUsername(username)) {
      _showSnackBar(
        'Tên đăng nhập phải từ 4-20 ký tự, không chứa ký tự đặc biệt',
        Colors.red[400]!,
      );
      setState(() => isLoading = false);
      return;
    }

    if (await isUsernameExists(username)) {
      _showSnackBar('Tên đăng nhập đã tồn tại', Colors.red[400]!);
      setState(() => isLoading = false);
      return;
    }

    if (!isValidEmail(email)) {
      _showSnackBar('Email không hợp lệ', Colors.red[400]!);
      setState(() => isLoading = false);
      return;
    }

    if (!isValidPassword(password)) {
      _showSnackBar(
        'Mật khẩu tối thiểu 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt',
        Colors.red[400]!,
      );
      setState(() => isLoading = false);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Mật khẩu không khớp', Colors.red[400]!);
      setState(() => isLoading = false);
      return;
    }

    try {
      await Future.delayed(const Duration(seconds: 1));

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
        _showSnackBar(
          'Đăng ký thành công! Vui lòng kiểm tra email để xác thực tài khoản.',
          Colors.green[400]!,
        );
        Navigator.pop(context);
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
                              Icons.person_add_alt_1,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Title
                          const Text(
                            "Tạo tài khoản mới",
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
                            "Điền thông tin để bắt đầu",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Register form container
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

                                // Email field
                                _buildTextField(
                                  controller: emailController,
                                  labelText: "Email",
                                  prefixIcon: Icons.email_outlined,
                                ),
                                const SizedBox(height: 20),

                                // Password field
                                _buildTextField(
                                  controller: passwordController,
                                  labelText: "Mật khẩu",
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: isPasswordObscured,
                                  hasVisibilityToggle: true,
                                  isPasswordVisible: !isPasswordObscured,
                                  onVisibilityToggle: () {
                                    setState(() {
                                      isPasswordObscured = !isPasswordObscured;
                                    });
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Confirm Password field
                                _buildTextField(
                                  controller: confirmPasswordController,
                                  labelText: "Nhập lại mật khẩu",
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

                                // Register button
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
                                      onPressed: () => _register(context),
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
                                        "Đăng ký",
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

                          // Login link
                          TextButton(
                            onPressed:
                                isLoading ? null : () => Navigator.pop(context),
                            child: Text(
                              "Đã có tài khoản? Đăng nhập",
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
