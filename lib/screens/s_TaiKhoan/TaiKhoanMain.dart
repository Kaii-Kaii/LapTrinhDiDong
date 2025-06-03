import 'package:flutter/material.dart';
import 'package:qltncn/screens/s_TaiKhoan/thems/ThemSoTietKiemScreen.dart';
import 'package:qltncn/screens/s_TaiKhoan/thems/ThemTaiKhoanScreen.dart';
import 'package:qltncn/screens/s_TaiKhoan/thems/ThemTichLuyScreen.dart';
import 'tabs/TabTaiKhoan.dart';
import 'tabs/TabSoTietKiem.dart';
import 'tabs/TabTichLuy.dart';

class TaikhoanMain extends StatefulWidget {
  final String maKH;
  const TaikhoanMain({super.key, required this.maKH});

  @override
  State<TaikhoanMain> createState() => _TaikhoanMainState();
}

class _TaikhoanMainState extends State<TaikhoanMain>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // GlobalKey để truy cập hàm reload danh sách ví trong TabTaiKhoan
  final GlobalKey<TabTaiKhoanState> _taiKhoanKey =
      GlobalKey<TabTaiKhoanState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'TÀI KHOẢN'),
            Tab(text: 'SỔ TIẾT KIỆM'),
            Tab(text: 'TÍCH LUỸ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TabTaiKhoan(key: _taiKhoanKey, maKH: widget.maKH),
          TabSoTietKiem(maKH: widget.maKH),
          TabTichLuy(maKH: widget.maKH),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () async {
          if (_tabController.index == 0) {
            // Truyền callback khi thêm tài khoản thành công
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
          } else if (_tabController.index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ThemSoTietKiemScreen()),
            );
          } else if (_tabController.index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ThemTichLuyScreen()),
            );
          }
        },
      ),
    );
  }
}
