import 'package:flutter/material.dart';
import 'dart:math';

class TinhSoTienNhanDuocCuoiKyScreen extends StatefulWidget {
  @override
  _TinhSoTienNhanDuocCuoiKyScreenState createState() =>
      _TinhSoTienNhanDuocCuoiKyScreenState();
}

class _TinhSoTienNhanDuocCuoiKyScreenState
    extends State<TinhSoTienNhanDuocCuoiKyScreen> {
  final TextEditingController soTienGuiController = TextEditingController();
  final TextEditingController thoiGianController = TextEditingController();
  final TextEditingController laiSuatController = TextEditingController();

  double ketQua = 0;

  void _tinhToan() {
    final double soTienGui = double.tryParse(soTienGuiController.text) ?? 0;
    final int thoiGian = int.tryParse(thoiGianController.text) ?? 0;
    final double laiSuat = double.tryParse(laiSuatController.text) ?? 0;

    if (soTienGui > 0 && thoiGian > 0 && laiSuat > 0) {
      final double laiSuatThang = laiSuat / 12 / 100;
      ketQua =
          soTienGui * ((pow(1 + laiSuatThang, thoiGian) - 1) / laiSuatThang);
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập đầy đủ và chính xác các giá trị."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Tính tiền nhận cuối kỳ"),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              soTienGuiController.clear();
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
            const Icon(Icons.attach_money, size: 80, color: Colors.indigo),
            const SizedBox(height: 10),
            const Text(
              "Ước tính số tiền bạn sẽ nhận được vào cuối kỳ\nkhi gửi tiền định kỳ hàng tháng.",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 30),
            _buildInputField(
              controller: soTienGuiController,
              label: "Số tiền gửi hàng tháng (VND)",
              icon: Icons.monetization_on,
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
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Kết quả",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Bạn sẽ nhận được: ${ketQua.toStringAsFixed(0)} VND",
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
