import 'package:flutter/material.dart';
import 'dart:math';

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

  void _tinhToan() {
    final double soTienCuoiKy =
        double.tryParse(soTienCuoiKyController.text) ?? 0;
    final int thoiGian = int.tryParse(thoiGianController.text) ?? 0;
    final double laiSuat = double.tryParse(laiSuatController.text) ?? 0;

    if (soTienCuoiKy > 0 && thoiGian > 0 && laiSuat > 0) {
      final double laiSuatThang = laiSuat / 12 / 100;
      ketQua =
          soTienCuoiKy *
          (laiSuatThang / ((pow(1 + laiSuatThang, thoiGian) - 1)));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Tính tiền gửi hàng tháng"),
        backgroundColor: Colors.indigo,
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
            const Icon(Icons.savings, size: 80, color: Colors.indigo),
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
                icon: const Icon(Icons.calculate),
                label: const Text("TÍNH TOÁN"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (ketQua > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Kết quả",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Bạn cần gửi hàng tháng: ${ketQua.toStringAsFixed(0)} VND",
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
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
