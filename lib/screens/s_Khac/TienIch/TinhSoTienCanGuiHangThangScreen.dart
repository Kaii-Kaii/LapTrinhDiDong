import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class TinhSoTienCanGuiHangThangScreen extends StatefulWidget {
  @override
  _TinhSoTienCanGuiHangThangScreenState createState() =>
      _TinhSoTienCanGuiHangThangScreenState();
}

class _TinhSoTienCanGuiHangThangScreenState
    extends State<TinhSoTienCanGuiHangThangScreen> {
  final TextEditingController soTienCuoiKyController = TextEditingController();
  final TextEditingController thoiGianController = TextEditingController();
  final TextEditingController laiSuatController = TextEditingController();

  double ketQua = 0;

  final NumberFormat currencyFormat = NumberFormat('#,###', 'en_US');

  void _tinhToan() {
    // Loại bỏ tất cả ký tự không phải số
    String soTienText = soTienCuoiKyController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final double soTienCuoiKy = double.tryParse(soTienText) ?? 0;
    final int thoiGian = int.tryParse(thoiGianController.text) ?? 0;
    final double laiSuat = double.tryParse(laiSuatController.text) ?? 0;

    if (soTienCuoiKy > 0 && thoiGian > 0 && laiSuat > 0) {
      final double laiSuatThang = laiSuat / 12 / 100;
      ketQua =
          soTienCuoiKy *
          (laiSuatThang / ((pow(1 + laiSuatThang, thoiGian) - 1)));
      setState(() {});
    } else {
      // Hiển thị thông báo lỗi nếu dữ liệu không hợp lệ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FF), // Màu nền xanh nhạt
      appBar: AppBar(
        title: const Text(
          "Tính tiền gửi hàng tháng",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1565C0), // Màu xanh dương đậm
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              soTienCuoiKyController.clear();
              thoiGianController.clear();
              laiSuatController.clear();
              setState(() {
                ketQua = 0;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.savings, size: 80, color: Color(0xFF1565C0)),
            const SizedBox(height: 10),
            const Text(
              "Công cụ tính số tiền bạn cần gửi hàng tháng\nđể đạt mục tiêu tài chính cuối kỳ.",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 30),
            _buildInputField(
              controller: soTienCuoiKyController,
              label: "Số tiền muốn nhận cuối kỳ (VND)",
              icon: Icons.attach_money,
              isCurrency: true,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: thoiGianController,
              label: "Thời gian tích lũy (tháng)",
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: laiSuatController,
              label: "Lãi suất (%/năm)",
              icon: Icons.percent,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _tinhToan,
                icon: const Icon(
                  Icons.calculate,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text(
                  "TÍNH TOÁN", // chữ màu trắng
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (ketQua > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1E9FF), // Màu xanh nhạt cho kết quả
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF90CAF9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Kết quả",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Bạn cần gửi hàng tháng: ${currencyFormat.format(ketQua)} VND",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Function(String)? onChanged,
    bool isCurrency = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: isCurrency ? [CurrencyInputFormatter()] : null,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF1565C0)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1565C0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1565C0)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Loại bỏ tất cả ký tự không phải số
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    // Định dạng số với dấu chấm
    final formatter = NumberFormat('#,###', 'en_US');
    String formatted = formatter.format(int.parse(digitsOnly));

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
