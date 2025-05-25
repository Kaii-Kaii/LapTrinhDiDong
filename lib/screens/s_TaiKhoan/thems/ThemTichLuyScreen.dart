import 'package:flutter/material.dart';

class ThemTichLuyScreen extends StatelessWidget {
  const ThemTichLuyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm tích luỹ'),
        backgroundColor: Colors.lightBlue,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // TODO: lưu dữ liệu tích luỹ
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildRowTitle('Số tiền', '0 đ'),
          const Divider(),

          buildTile(icon: Icons.savings, label: 'Tích luỹ cho việc gì?'),
          buildTile(icon: Icons.money, label: 'VND'),
          buildTile(icon: Icons.calendar_today, label: 'Ngày bắt đầu', value: '25/05/2025'),
          buildTile(icon: Icons.schedule, label: 'Trong bao lâu?'),
          const Divider(),

          SwitchListTile(
            title: const Text('Tạo ghi chép định kỳ'),
            value: false,
            onChanged: (value) {},
          ),
          SwitchListTile(
            title: const Text('Không tính vào báo cáo'),
            value: false,
            onChanged: (value) {},
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              'Ghi chép trên tài khoản này sẽ không được thống kê vào TẤT CẢ các báo cáo (trừ báo cáo theo dõi vay nợ)',
              style: TextStyle(color: Colors.grey),
            ),
          ),
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
        // TODO: chọn thông tin
      },
    );
  }
}
