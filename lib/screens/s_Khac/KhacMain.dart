import 'package:flutter/material.dart';
import 'package:qltncn/model/GirdItem.dart';
import 'package:qltncn/model/KhachHang/Khach_Hang.dart';
import 'package:qltncn/model/TaiKhoan/TaiKhoan.dart';
import 'package:qltncn/model/TaiKhoan/TaiKhoan_service.dart';
import 'package:qltncn/model/KhachHang/khachhang_service.dart';
import 'package:qltncn/screens/s_Khac/TienIch/TyGiaScreen.dart';
import 'package:qltncn/screens/s_Khac/TienIch/TinhThueThuNhapCaNhanScreen.dart';
import 'package:qltncn/screens/s_Khac/TienIch/TinhLaiVayScreen.dart';
import 'package:qltncn/screens/s_Khac/TienIch/TinhLaiTienGui.dart';
import 'package:qltncn/screens/s_Khac/TienIch/ChiaTien.dart';
import 'package:qltncn/screens/s_Login/DangNhap.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KhacMain extends StatefulWidget {
  final String maKH;
  const KhacMain({super.key, required this.maKH});

  @override
  State<KhacMain> createState() => _KhacMainState();
}

class _KhacMainState extends State<KhacMain> {
  final List<GirdItem> tienIchList = [
    GirdItem(title: 'Tra cứu tỷ giá', icon: Icons.money, iconColor: Colors.blue),
    GirdItem(title: 'Tính lãi vay', icon: Icons.calculate, iconColor: Colors.teal),
    GirdItem(title: 'Tiết kiệm gửi góp', icon: Icons.savings, iconColor: Colors.red),
    GirdItem(title: 'Thuế TNCN', icon: Icons.people_outline, iconColor: Colors.green),
    GirdItem(title: 'Chia tiền', icon: Icons.money_rounded, iconColor: Colors.orange),
  ];

  final List<Map<String, dynamic>> settingsItems = [
    {'icon': Icons.settings, 'title': 'Cài đặt chung', 'onTap': null},
    {'icon': Icons.storage, 'title': 'Cài đặt dữ liệu', 'onTap': null},
    {'icon': Icons.share, 'title': 'Giới thiệu cho bạn', 'onTap': null, 'trailing': Text('Chia sẻ ngay', style: TextStyle(color: Colors.blue))},
    {'icon': Icons.star_border, 'title': 'Đánh giá ứng dụng', 'onTap': null},
    {'icon': Icons.feedback_outlined, 'title': 'Góp ý với nhà phát triển', 'onTap': null},
    {'icon': Icons.info_outline, 'title': 'Trợ giúp và thông tin', 'onTap': null},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(toolbarHeight: 0, backgroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserInfo(widget.maKH),
            _buildPremiumBanner(),
            _buildPointAndCode(),
            _buildGridSection("Tiện ích", tienIchList),
            const SizedBox(height: 12),
            _buildSettingsList(),
            const SizedBox(height: 12),
            _buildSyncInfo(),
          ],
        ),
      ),
    );
  }

  Future<TaiKhoan?> getTaiKhoanFromMaKH(String maKH) async {
    try {
      final maTaiKhoan = await KhachHangService.fetchMaTaiKhoanByMaKH(maKH);
      if (maTaiKhoan != null) {
        return await fetchTaiKhoanByMaTaiKhoan(maTaiKhoan);
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy thông tin tài khoản: $e');
    }
    return null;
  }

  Widget _buildUserInfo(String maKH) {
    return FutureBuilder<TaiKhoan?>(
      future: getTaiKhoanFromMaKH(maKH),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final taiKhoan = snapshot.data;
        if (taiKhoan == null) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("Không tìm thấy thông tin người dùng"),
          );
        }

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.lightBlue,
                child: Text(
                  taiKhoan.tendangnhap[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(taiKhoan.tendangnhap, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(taiKhoan.email, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.notifications_none),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrange]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Nâng cấp Premium", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          Icon(Icons.rocket_launch, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildPointAndCode() {
    return FutureBuilder<KhachHang?>(
      future: KhachHangService.fetchKhachHangByMaKH(widget.maKH),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final khachHang = snapshot.data;
        if (khachHang == null) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("Không tìm thấy thông tin khách hàng"),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildInfoCard(Icons.monetization_on, "Xu của bạn", "${khachHang.xu} xu", Colors.orange),
              const SizedBox(width: 8),
              _buildInfoCard(Icons.share, "Mã chia sẻ", "44010", Colors.blue),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 14)),
            ]),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildGridSection(String title, List<GirdItem> items) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: () => _handleTap(item.title),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: item.iconColor.withOpacity(0.1),
                        child: Icon(item.icon, color: item.iconColor),
                      ),
                      const SizedBox(height: 8),
                      Text(item.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleTap(String title) {
    Widget? screen;
    switch (title) {
      case 'Tra cứu tỷ giá':
        screen = const TraCuuTyGiaScreen();
        break;
      case 'Tính lãi vay':
        screen = TinhLaiVayScreen();
        break;
      case 'Tiết kiệm gửi góp':
        screen = TinhLaiTienGuiScreen();
        break;
      case 'Thuế TNCN':
        screen = const TinhThueScreen();
        break;
      case 'Chia tiền':
        screen = ChiaTienScreen();
        break;
    }

    if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
    }
  }

  Widget _buildSettingsList() {
    return Column(
      children: [
        ...settingsItems.map((item) => _buildSettingsTile(
              item['icon'],
              item['title'],
              item['onTap'] ?? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Chức năng '${item['title']}' đang phát triển")),
                );
              },
              trailing: item['trailing'],
            )),
        _buildSettingsTile(Icons.logout, "Đăng xuất", _logout),
      ],
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
      tileColor: Colors.white,
      dense: true,
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Xóa toàn bộ dữ liệu login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Widget _buildSyncInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Row(
            children: [
              Icon(Icons.sync, color: Colors.blue),
              SizedBox(width: 8),
              Text("Đồng bộ dữ liệu"),
            ],
          ),
          Text("24/04/2025 12:09", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
