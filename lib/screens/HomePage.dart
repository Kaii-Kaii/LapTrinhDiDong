import 'package:flutter/material.dart';
import 'package:qltncn/screens/s_BaoCao/BaoCao.dart';
import 'package:qltncn/screens/s_GiaoDich/NhapVaoScreen.dart';
import 'package:qltncn/screens/s_Khac/KhacMain.dart';
import 'package:qltncn/screens/s_TaiKhoan/TaiKhoanMain.dart';
//import 'package:qltncn/screens/LichScreen.dart';
import 'package:qltncn/screens/s_TongQuan/TongQuan.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String maKH;

  const HomePage({super.key, required this.userName, required this.maKH});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Khởi tạo _widgetOptions trong phương thức build
  List<Widget> get _widgetOptions {
    return <Widget>[
      TongQuanScreen(
        userName: widget.userName,
        maKH: widget.maKH,
      ), // Truyền userName và maKH vào đây
      TaikhoanMain(maKH: widget.maKH),
      NhapVaoScreen(maKH: widget.maKH),
      Main_BaoCao(),
      KhacMain(maKH: widget.maKH),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Tổng quan'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Tài khoản',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40, color: Colors.blue),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Báo cáo',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Khác'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
