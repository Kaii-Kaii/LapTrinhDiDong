import 'package:flutter/material.dart';
import 'XuLyChiaTien.dart';

class ChiaTienScreen extends StatefulWidget {
  @override
  _ChiaTienScreenState createState() => _ChiaTienScreenState();
}

class _ChiaTienScreenState extends State<ChiaTienScreen> {
  final TextEditingController soTienController = TextEditingController();
  final TextEditingController soThanhVienController = TextEditingController();

  @override
  void initState() {
    super.initState();
    soTienController.text = "7000000"; // Giá trị mặc định
    soThanhVienController.text = "3"; // Giá trị mặc định
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chia tiền"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                soTienController.text = "7000000";
                soThanhVienController.text = "3";
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Số tiền
            _buildInputCard(
              title: "Số tiền",
              child: TextField(
                controller: soTienController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: InputBorder.none),
                style: const TextStyle(fontSize: 24, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 16),

            // Số thành viên
            _buildInputCard(
              title: "Số thành viên",
              child: Row(
                children: [
                  const Icon(Icons.people, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: soThanhVienController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 24, color: Colors.blue),
                    ),
                  ),
                  const Icon(Icons.edit, color: Colors.blue),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nút Chia tiền
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final double tongTien =
                      double.tryParse(soTienController.text) ?? 0;
                  final int soThanhVien =
                      int.tryParse(soThanhVienController.text) ?? 0;

                  if (tongTien > 0 && soThanhVien > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => CachChiaScreen(
                              tongTien: tongTien,
                              soThanhVien: soThanhVien,
                            ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Vui lòng nhập số tiền và số thành viên hợp lệ!",
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Chia tiền", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
