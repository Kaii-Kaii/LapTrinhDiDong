import 'package:flutter/material.dart';
import 'package:qltncn/screens/s_BaoCao/BaoCao.dart';
import 'package:qltncn/screens/s_GiaoDich/NhapVaoScreen.dart';
import 'package:qltncn/screens/s_Khac/KhacMain.dart';
import 'package:qltncn/screens/s_TaiKhoan/TaiKhoanMain.dart';
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
      BaoCaoThangNam(maKH: widget.maKH),
      KhacMain(maKH: widget.maKH),
      HangMucScreen(maKhachHang: widget.maKH), // <-- Thêm dòng này
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

class HangMucScreen extends StatefulWidget {
  final String maKhachHang;
  const HangMucScreen({Key? key, required this.maKhachHang}) : super(key: key);

  @override
  State<HangMucScreen> createState() => _HangMucScreenState();
}

class _HangMucScreenState extends State<HangMucScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hạng mục')),
      body: Center(
        child: Text('Nội dung hạng mục cho khách hàng ${widget.maKhachHang}'),
      ),
    );
  }
}

// List<Map<String, dynamic>> getDefaultAccounts(String maKhachHang) {
//   return [
//     {
//       'maNguoiDung': maKhachHang,
//       'maVi': 1,
//       'maLoaiTien': 1,
//       'tenTaiKhoan': 'Ví Tiền Mặt',
//       'dienGiai': 'Ví Tiền Mặt',
//       'soDu': 0.0,
//     },
//     {
//       'maNguoiDung': maKhachHang,
//       'maVi': 2,
//       'maLoaiTien': 1,
//       'tenTaiKhoan': 'Tài khoản Vietcombank',
//       'dienGiai': 'Tài khoản tiết kiệm',
//       'soDu': 15000000.0,
//     },
//     {
//       'maNguoiDung': maKhachHang,
//       'maVi': 3,
//       'maLoaiTien': 1,
//       'tenTaiKhoan': 'Thẻ tín dụng Techcombank',
//       'dienGiai': 'Thẻ tín dụng chính',
//       'soDu': 0.0,
//     },
//     {
//       'maNguoiDung': maKhachHang,
//       'maVi': 5,
//       'maLoaiTien': 1,
//       'tenTaiKhoan': 'Ví điện tử Momo',
//       'dienGiai': 'Ví điện tử sử dụng thường xuyên',
//       'soDu': 12000000.0,
//     },
//   ];
// }

// Future<void> _onRegisterSuccess(String maKhachHang) async {
//   final defaultAccounts = getDefaultAccounts(maKhachHang);
//   for (final acc in defaultAccounts) {
//     final response = await http.post(
//       Uri.parse('https://your-api-url.com/api/ViNguoiDung'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(acc),
//     );
//     if (response.statusCode != 200 && response.statusCode != 201) {
//       print('Lỗi khi tạo ví: ${response.body}');
//     }
//   }
//   // Chuyển sang HomePage hoặc thông báo thành công
// }
