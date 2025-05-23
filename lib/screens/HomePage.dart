import 'package:flutter/material.dart';
import 'package:qltncn/screens/s_BaoCao/BaoCao.dart';
import 'package:qltncn/screens/s_GiaoDich/NhapVaoScreen.dart';
import 'package:qltncn/screens/s_Khac/KhacMain.dart';
import 'package:qltncn/screens/s_TaiKhoan/TaiKhoanMain.dart';
//import 'package:qltncn/screens/LichScreen.dart';
import 'package:qltncn/screens/s_TongQuan/TongQuan.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
   // OverviewScreen(), // Gọi màn hình Tổng quan
    TongQuanScreen(),
    TaikhoanMain(),
    NhapVaoScreen(),
    // LichScreen(),
    Main_BaoCao(),
    KhacMain(),
  ];

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
          BottomNavigationBarItem(
            icon: Icon(Icons.home), 
            label: 'Tổng quan'),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz), 
            label: 'Khác'),
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
