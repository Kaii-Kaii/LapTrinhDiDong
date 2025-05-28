import 'package:flutter/material.dart';
import 'package:qltncn/model/Vi/ViNguoiDung/ViNguoiDung.dart';

class ChiTietViScreen extends StatelessWidget {
  final ViNguoiDung viNguoiDung;

  const ChiTietViScreen({super.key, required this.viNguoiDung});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết ví: ${viNguoiDung.tenTaiKhoan}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tên tài khoản:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(viNguoiDung.tenTaiKhoan, style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),

            Text('Mã ví:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(viNguoiDung.maVi.toString(), style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),

            Text('Loại tiền:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(viNguoiDung.maLoaiTien.toString(), style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),

            Text('Diễn giải:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(viNguoiDung.dienGiai ?? 'Không có', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),

            Text('Số dư:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text('${viNguoiDung.soDu.toStringAsFixed(0)} đ', style: TextStyle(fontSize: 18, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
