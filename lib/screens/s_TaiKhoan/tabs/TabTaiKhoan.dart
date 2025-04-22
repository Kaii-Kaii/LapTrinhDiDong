import 'package:flutter/material.dart';

class TabTaiKhoan extends StatelessWidget {
  const TabTaiKhoan({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng tiền:', style: TextStyle(fontSize: 16)),
              Text('0 đ', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const Divider(height: 1),
        const ExpansionTile(
          title: Text(
            'Đang sử dụng (0 đ)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orangeAccent,
                child: Icon(Icons.account_balance_wallet, color: Colors.white),
              ),
              title: Text('Ví tiền mặt'),
              subtitle: Text('0 đ'),
              trailing: Icon(Icons.more_vert),
            )
          ],
        ),
      ],
    );
  }
}
