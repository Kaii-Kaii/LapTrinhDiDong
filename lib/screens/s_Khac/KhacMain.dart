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
  final Color primaryColor = const Color(0xFF03A9F4);
  final Color backgroundColor = const Color(0xFFF8FAFB);

  final List<GirdItem> tienIchList = [
    GirdItem(
      title: 'Tra cứu tỷ giá',
      icon: Icons.currency_exchange_rounded,
      iconColor: const Color(0xFF03A9F4),
    ),
    GirdItem(
      title: 'Tính lãi vay',
      icon: Icons.calculate_rounded,
      iconColor: const Color(0xFF0288D1),
    ),
    GirdItem(
      title: 'Tiết kiệm gửi góp',
      icon: Icons.savings_rounded,
      iconColor: const Color(0xFF0277BD),
    ),
    GirdItem(
      title: 'Thuế TNCN',
      icon: Icons.account_balance_wallet_rounded,
      iconColor: const Color(0xFF0288D1),
    ),
    GirdItem(
      title: 'Chia tiền',
      icon: Icons.payments_rounded,
      iconColor: const Color(0xFF03A9F4),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.1),
              backgroundColor,
              backgroundColor,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              _buildUserInfo(widget.maKH),
              _buildPremiumBanner(),
              _buildPointAndCode(),
              _buildListSectionFromGridItem("Tiện ích", tienIchList),
              const SizedBox(height: 20),
              _buildSettingsList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'Hồ Sơ Cá Nhân',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
        ],
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
          return Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          );
        }
        final taiKhoan = snapshot.data;
        if (taiKhoan == null) {
          return Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Text("Không tìm thấy thông tin người dùng"),
          );
        }
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, primaryColor.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, primaryColor.withOpacity(0.7)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.transparent,
                  child: Text(
                    taiKhoan.tendangnhap[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taiKhoan.tendangnhap,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      taiKhoan.email,
                      style: TextStyle(color: Colors.grey[600], fontSize: 15),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withOpacity(0.1),
                      primaryColor.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.notifications_rounded,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.diamond_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            "Nâng cấp Premium",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointAndCode() {
    return FutureBuilder<KhachHang?>(
      future: KhachHangService.fetchKhachHangByMaKH(widget.maKH),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          );
        }
        final khachHang = snapshot.data;
        if (khachHang == null) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("Không tìm thấy thông tin khách hàng"),
          );
        }
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              // Có thể thêm thông tin điểm số hoặc mã khách hàng ở đây
            ],
          ),
        );
      },
    );
  }

  Widget _buildListSectionFromGridItem(String title, List<GirdItem> items) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: primaryColor,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _handleTap(item.title),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, item.iconColor.withOpacity(0.03)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: item.iconColor.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              item.iconColor.withOpacity(0.1),
                              item.iconColor.withOpacity(0.05),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.icon, color: item.iconColor, size: 28),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item.iconColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: item.iconColor,
                          size: 16,
                        ),
                      ),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSettingsTile(
            Icons.logout_rounded,
            "Đăng xuất",
            _logout,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    VoidCallback onTap,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, iconColor.withOpacity(0.03)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [iconColor.withOpacity(0.1), iconColor.withOpacity(0.05)],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            color: iconColor,
            size: 16,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}
