import 'package:flutter/material.dart';
import 'package:qltncn/model/LoaiTien/LoaiTien.dart';
// Import file danh sách loại tiền

class ThemTaiKhoanScreen extends StatefulWidget {
  const ThemTaiKhoanScreen({super.key});

  @override
  State<ThemTaiKhoanScreen> createState() => _ThemTaiKhoanScreenState();
}

class _ThemTaiKhoanScreenState extends State<ThemTaiKhoanScreen> {
  LoaiTien loaiTien = danhSachLoaiTien[0]; // Mặc định chọn loại đầu tiên

  // ... các controller, biến khác

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm tài khoản')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: Text(loaiTien.kyHieu, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              title: Text(loaiTien.tenLoai),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                final LoaiTien? selectedLoaiTien = await showModalBottomSheet<LoaiTien>(
                  context: context,
                  builder: (context) {
                    return ListView(
                      children: danhSachLoaiTien.map((tien) {
                        return ListTile(
                          leading: Text(tien.kyHieu, style: const TextStyle(fontSize: 20)),
                          title: Text(tien.tenLoai),
                          subtitle: Text(tien.menhGia),
                          onTap: () => Navigator.pop(context, tien),
                        );
                      }).toList(),
                    );
                  },
                );

                if (selectedLoaiTien != null) {
                  setState(() {
                    loaiTien = selectedLoaiTien;
                  });
                }
              },
            ),

            // Các widget khác...
          ],
        ),
      ),
    );
  }
}
