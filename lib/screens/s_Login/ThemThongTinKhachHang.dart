import 'package:flutter/material.dart';
import 'package:qltncn/screens/HomePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AddCustomerInfoScreen extends StatefulWidget {
  final String maTaiKhoan;

  const AddCustomerInfoScreen({super.key, required this.maTaiKhoan});

  @override
  _AddCustomerInfoScreenState createState() => _AddCustomerInfoScreenState();
}

class _AddCustomerInfoScreenState extends State<AddCustomerInfoScreen>
    with TickerProviderStateMixin {
  final TextEditingController hoTenController = TextEditingController();
  final TextEditingController soDTController = TextEditingController();
  DateTime? ngaySinh;
  bool isLoading = false;

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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: ngaySinh ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF03A9F4),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        ngaySinh = picked;
      });
    }
  }

  Future<void> _submit() async {
    final hoten = hoTenController.text.trim();
    final sodt = soDTController.text.trim();

    if (hoten.isEmpty || ngaySinh == null || sodt.isEmpty) {
      _showSnackBar('Vui lòng nhập đầy đủ thông tin', Colors.red[400]!);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final response = await http.post(
        Uri.parse('https://10.0.2.2:7283/api/KhachHang'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mataikhoan': widget.maTaiKhoan,
          'hoten': hoten,
          'ngaysinh': ngaySinh!.toIso8601String(),
          'sodt': sodt,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final maKH = data['makh']?.toString();

        if (maKH == null || maKH.isEmpty) {
          _showSnackBar(
            'Không nhận được mã khách hàng từ server',
            Colors.red[400]!,
          );
          return;
        }

        await _onRegisterSuccess(context, maKH);
        _showSnackBar(
          'Đã thêm thông tin khách hàng thành công!',
          Colors.green[400]!,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(maKH: maKH, userName: hoten),
          ),
        );
      } else {
        _showSnackBar('Lỗi: ${response.body}', Colors.red[400]!);
      }
    } catch (e) {
      _showSnackBar('Lỗi kết nối: $e', Colors.red[400]!);
    } finally {
      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _onRegisterSuccess(BuildContext context, String maKH) async {
    try {
      final response = await http.post(
        Uri.parse('https://10.0.2.2:7283/api/ViNguoiDung'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'maNguoiDung': maKH,
          'maVi': 1,
          'tenTaiKhoan': 'Ví Tiền Mặt',
          'maLoaiTien': 1,
          'dienGiai': 'Ví Tiền Mặt',
          'soDu': 0.0,
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Tạo ví thất bại');
      }
    } catch (e) {
      _showSnackBar('Lỗi tạo ví: $e', Colors.red[400]!);
    }
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
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    Widget? suffixIcon,
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
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
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
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF03A9F4);
    final size = MediaQuery.of(context).size;
    final dateFormat = DateFormat('dd/MM/yyyy');

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
                            "Thêm thông tin cá nhân",
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
                            "Hoàn thiện hồ sơ để sử dụng ứng dụng",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Form container
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
                                // Full name field
                                _buildTextField(
                                  controller: hoTenController,
                                  labelText: "Họ và tên",
                                  prefixIcon: Icons.person_outline,
                                ),
                                const SizedBox(height: 20),

                                // Date of birth field
                                _buildTextField(
                                  controller: TextEditingController(
                                    text:
                                        ngaySinh != null
                                            ? dateFormat.format(ngaySinh!)
                                            : '',
                                  ),
                                  labelText: "Ngày sinh",
                                  prefixIcon: Icons.cake_outlined,
                                  readOnly: true,
                                  onTap: _selectDate,
                                  suffixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: mainColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.calendar_today,
                                      color: mainColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Phone number field
                                _buildTextField(
                                  controller: soDTController,
                                  labelText: "Số điện thoại",
                                  prefixIcon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 30),

                                // Submit button
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
                                      onPressed: _submit,
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
                                        "Lưu thông tin",
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

                          // Info text
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: mainColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: mainColor.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: mainColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Thông tin này sẽ được sử dụng để tạo hồ sơ khách hàng và ví tiền mặt mặc định cho bạn.",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
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
