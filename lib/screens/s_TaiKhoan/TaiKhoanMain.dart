import 'package:flutter/material.dart';
import 'tabs/TabTaiKhoan.dart';
import 'tabs/TabSoTietKiem.dart';
import 'tabs/TabTichLuy.dart';

class TaikhoanMain extends StatelessWidget {
  const TaikhoanMain({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          centerTitle: true,
          title: const Text(
            'Tài khoản',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white
              ),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,              // Màu chữ khi được chọn
            unselectedLabelColor: Colors.white70,  // Màu chữ khi không được chọn
            indicatorColor: Colors.white,          // Màu thanh gạch dưới
            tabs: [
              Tab(text: 'TÀI KHOẢN'),
              Tab(text: 'SỔ TIẾT KIỆM'),
              Tab(text: 'TÍCH LUỸ'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TabTaiKhoan(),
            TabSoTietKiem(),
            TabTichLuy(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: xử lý thêm ví
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
