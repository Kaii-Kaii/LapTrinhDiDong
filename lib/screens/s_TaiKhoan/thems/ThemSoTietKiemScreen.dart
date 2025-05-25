import 'package:flutter/material.dart';

class ThemSoTietKiemScreen extends StatelessWidget {
  const ThemSoTietKiemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm sổ tiết kiệm'),
        backgroundColor: Colors.lightBlue,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // TODO: xử lý lưu sổ tiết kiệm
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildRowTitle('Số tiền', '0 đ'),
          const Divider(),

          buildTile(icon: Icons.account_balance_wallet, label: 'Tên tài khoản'),
          buildTile(icon: Icons.money, label: 'VND'),
          buildTile(icon: Icons.account_balance, label: 'Ngân hàng'),
          buildTile(icon: Icons.today, label: 'Ngày gửi', value: 'Hôm nay'),
          buildTile(icon: Icons.schedule, label: 'Kỳ hạn'),
          const Divider(),

          buildRowTitle('Lãi suất', '0 %/năm'),
          buildRowTitle('Lãi suất không kỳ hạn', '0.05 %/năm'),
          buildRowTitle('Số ngày tính lãi / năm', '365 Ngày'),
          const Divider(),

          buildTile(icon: Icons.attach_money, label: 'Trả lãi', value: 'Cuối kỳ'),
          buildTile(icon: Icons.repeat, label: 'Khi đến hạn', value: 'Tái tục gốc và lãi'),
          buildTile(icon: Icons.swap_horiz, label: 'Tiền gửi được chuyển từ TK'),

          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Lưu'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.lightBlue,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget buildRowTitle(String left, String right) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(left),
            Text(right, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget buildTile({required IconData icon, required String label, String? value}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: value != null ? Text(value) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // TODO: xử lý khi chọn
      },
    );
  }
}
