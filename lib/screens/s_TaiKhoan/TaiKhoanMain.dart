import 'package:flutter/material.dart';
import 'package:qltncn/screens/s_TaiKhoan/thems/ThemSoTietKiemScreen.dart';
import 'package:qltncn/screens/s_TaiKhoan/thems/ThemTaiKhoanScreen.dart';
import 'package:qltncn/screens/s_TaiKhoan/thems/ThemTichLuyScreen.dart';
import 'tabs/TabTaiKhoan.dart';

class TaikhoanMain extends StatefulWidget {
  final String maKH;
  const TaikhoanMain({super.key, required this.maKH});

  @override
  State<TaikhoanMain> createState() => _TaikhoanMainState();
}

class _TaikhoanMainState extends State<TaikhoanMain>
    with SingleTickerProviderStateMixin {
  // Không cần TabController nữa
  final GlobalKey<TabTaiKhoanState> _taiKhoanKey =
      GlobalKey<TabTaiKhoanState>();

  @override
  void initState() {
    super.initState();
    // Xoá TabController
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        title: const Text(
          'Tài khoản',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        // Xoá TabBar
      ),
      body: TabTaiKhoan(key: _taiKhoanKey, maKH: widget.maKH),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () async {
          // Luôn mở ThemTaiKhoanScreen
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ThemTaiKhoanScreen(
                    maKH: widget.maKH,
                    onAccountAdded: () {
                      _taiKhoanKey.currentState?.loadDanhSachVi();
                    },
                  ),
            ),
          );
        },
      ),
    );
  }
}
