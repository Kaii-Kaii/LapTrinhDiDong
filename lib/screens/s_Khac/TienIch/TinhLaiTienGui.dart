import 'package:flutter/material.dart';
import 'TinhSoTienNhanDuocCuoiKyScreen.dart';
import 'TinhSoTienCanGuiHangThangScreen.dart';

class TinhLaiTienGuiScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tiết kiệm gửi góp"),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Tính số tiền nhận được cuối kỳ
          _buildOptionCard(
            context,
            icon: Icons.attach_money,
            title: "Tính số tiền nhận được cuối kỳ",
            description:
                "Nhập số tiền cần tiết kiệm hàng tháng và thời gian tích lũy, bạn sẽ biết số tiền nhận được cuối kỳ.",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TinhSoTienNhanDuocCuoiKyScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Tính số tiền cần gửi hàng tháng
          _buildOptionCard(
            context,
            icon: Icons.bar_chart,
            title: "Tính số tiền cần gửi hàng tháng",
            description:
                "Nhập số tiền bạn muốn đạt được trong tương lai và thời gian tích lũy, bạn sẽ biết số tiền cần gửi hàng tháng.",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TinhSoTienCanGuiHangThangScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 40),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
        onTap: onTap,
      ),
    );
  }
}
