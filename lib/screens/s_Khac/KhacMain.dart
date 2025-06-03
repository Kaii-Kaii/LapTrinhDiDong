import 'package:flutter/material.dart';
import 'package:qltncn/model/GirdItem.dart';
import 'package:qltncn/model/KhachHang/Khach_Hang.dart';
import 'package:qltncn/screens/s_Khac/TienIch/han_muc_chi_screen.dart';
import 'package:qltncn/model/TaiKhoan/TaiKhoan.dart';
import 'package:qltncn/model/TaiKhoan/TaiKhoan_service.dart';
import 'package:qltncn/model/KhachHang/khachhang_service.dart';
import 'package:qltncn/screens/s_Khac/TienIch/TyGiaScreen.dart';
import 'package:qltncn/screens/s_Khac/TienIch/TinhThueThuNhapCaNhanScreen.dart';
import 'package:qltncn/screens/s_Khac/TienIch/TinhLaiVayScreen.dart';
import 'package:qltncn/screens/s_Khac/TienIch/TinhLaiTienGui.dart';
import 'package:qltncn/screens/s_Khac/TienIch/ChiaTien.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qltncn/screens/s_Login/DangNhap.dart';

class KhacMain extends StatefulWidget {
  final String maKH;
  const KhacMain({super.key, required this.maKH});

  @override
  State<KhacMain> createState() => _KhacMainState();
}

class _KhacMainState extends State<KhacMain> {
  final List<GirdItem> tinhNangList = [
    GirdItem(
      title: 'Hạn mức chi',
      icon: Icons.money_off,
      iconColor: Colors.red,
    ),
    GirdItem(
      title: 'Hạng mục thu/chi',
      icon: Icons.list_alt,
      iconColor: Colors.blueAccent,
    ),
    GirdItem(
      title: 'Danh sách mua sắm',
      icon: Icons.shopping_cart,
      iconColor: Colors.blue,
    ),
    GirdItem(
      title: 'Ghi chép định kỳ',
      icon: Icons.repeat,
      iconColor: Colors.orange,
    ),
    GirdItem(title: 'Ghi chép mẫu', icon: Icons.note, iconColor: Colors.purple),
    GirdItem(
      title: 'Du lịch',
      icon: Icons.travel_explore,
      iconColor: Colors.green,
    ),
    GirdItem(
      title: 'Dự thu/Dự chi',
      icon: Icons.archive,
      iconColor: Colors.amber,
    ),
    GirdItem(
      title: 'Xuất khẩu dữ liệu',
      icon: Icons.file_upload,
      iconColor: Colors.deepPurple,
    ),
  ];

  final List<GirdItem> tienIchList = [
    GirdItem(
      title: 'Tra cứu tỷ giá',
      icon: Icons.money_off_csred_outlined,
      iconColor: Colors.blue,
    ),
    GirdItem(
      title: 'Tính lãi vay',
      icon: Icons.calculate,
      iconColor: Colors.teal,
    ),
    GirdItem(
      title: 'Tiết kiệm gửi góp',
      icon: Icons.savings,
      iconColor: Colors.red,
    ),
    GirdItem(
      title: 'Thuế TNCN',
      icon: Icons.people_outline,
      iconColor: Colors.green,
    ),
    GirdItem(
      title: 'Chia tiền',
      icon: Icons.money_rounded,
      iconColor: Colors.orange,
    ),
    GirdItem(
      title: 'Widget',
      icon: Icons.widgets_rounded,
      iconColor: Colors.lightBlue,
    ),
    GirdItem(
      title: 'Tìm kế toán dịch vụ',
      icon: Icons.event,
      iconColor: Colors.lightGreen,
    ),
    GirdItem(
      title: 'Premium miễn phí',
      icon: Icons.compare_arrows_rounded,
      iconColor: Colors.purple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserInfo(widget.maKH),
            _buildPremiumBanner(),
            _buildPointAndCode(),
            _buildSection(context, "Tính năng", tinhNangList),
            _buildSection(context, "Tiện ích", tienIchList),
            const SizedBox(height: 12),
            _buildSettingsAndSupport(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<TaiKhoan?> getTaiKhoanFromMaKH(String maKH) async {
    try {
      final maTaiKhoan = await KhachHangService.fetchMaTaiKhoanByMaKH(maKH);
      if (maTaiKhoan == null) {
        print('Không tìm thấy maTaiKhoan cho maKH: $maKH');
        return null;
      }

      final taiKhoan = await fetchTaiKhoanByMaTaiKhoan(maTaiKhoan);
      if (taiKhoan == null) {
        print('Không tìm thấy thông tin TaiKhoan cho maTaiKhoan: $maTaiKhoan');
      }
      return taiKhoan;
    } catch (e) {
      print('Lỗi trong getTaiKhoanFromMaKH: $e');
      return null;
    }
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
        } else if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("Lỗi khi tải thông tin người dùng"),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("Không tìm thấy thông tin người dùng"),
          );
        }

        final taiKhoan = snapshot.data!;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.lightBlue,
                child: Text(
                  taiKhoan.tendangnhap.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taiKhoan.tendangnhap,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      taiKhoan.email,
                      style: const TextStyle(color: Colors.grey),
                    ),
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
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orangeAccent, Colors.deepOrange],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Nâng cấp Premium",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(width: 10),
          Icon(Icons.rocket_launch, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildPointAndCode() {
    return FutureBuilder<KhachHang?>(
      future: KhachHangService.fetchKhachHangByMaKH(
        widget.maKH,
      ), // Lấy thông tin khách hàng
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ), // Hiển thị loading khi đang chờ dữ liệu
          );
        } else if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Lỗi khi tải thông tin khách hàng",
            ), // Xử lý lỗi khi lấy dữ liệu
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Không tìm thấy thông tin khách hàng",
            ), // Nếu không có dữ liệu
          );
        }

        final khachHang = snapshot.data!; // Lấy dữ liệu khách hàng
        String xuText =
            (khachHang.xu > 0)
                ? "${khachHang.xu} xu" // Nếu có xu và số xu > 0
                : "Chưa có xu"; // Nếu không có xu hoặc xu = 0

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildInfoCard(
                Icons.monetization_on,
                "Xu của bạn",
                xuText,
                Colors.orange,
              ),
              const SizedBox(width: 8),
              _buildInfoCard(Icons.share, "Mã chia sẻ", "44010", Colors.blue),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Expanded(
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  Icon(icon, color: iconColor),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<GirdItem> items,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
              children: List.generate(items.length, (index) {
                final item = items[index];
                return InkWell(
                  onTap: () => _handleTap(context, item.title),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 6,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: item.iconColor.withOpacity(0.1),
                          child: Icon(item.icon, color: item.iconColor),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, String title) {
    switch (title) {
      case 'Hạn mức chi':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HanMucChiScreen()),
        );
        break;
      case 'Tra cứu tỷ giá':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TraCuuTyGiaScreen()),
        );
        break;
      case 'Thuế TNCN':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TinhThueScreen()),
        );
        break;
      case 'Tính lãi vay':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TinhLaiVayScreen()),
        );
        break;
      case 'Tiết kiệm gửi góp':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TinhLaiTienGuiScreen()),
        );
        break;
      case 'Chia tiền':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChiaTienScreen()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chức năng "$title" đang phát triển')),
        );
    }
  }

  Widget _buildSettingsAndSupport() {
    return Column(
      children: [
        _buildSettingsTile(Icons.settings, "Cài đặt chung", () {}),
        _buildSettingsTile(Icons.storage, "Cài đặt dữ liệu", () {}),
        _buildSettingsTile(
          Icons.share,
          "Giới thiệu cho bạn",
          () {
            // Chia sẻ
          },
          trailing: const Text(
            "Chia sẻ ngay",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        _buildSettingsTile(Icons.star_border, "Đánh giá ứng dụng", () {}),
        _buildSettingsTile(
          Icons.feedback_outlined,
          "Góp ý với nhà phát triển",
          () {},
        ),
        _buildSettingsTile(Icons.info_outline, "Trợ giúp và thông tin", () {}),
        // đăng xuất
        _buildSettingsTile(Icons.logout, "Đăng xuất", () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('username');
          await prefs.remove('password');
          // Xóa thêm các thông tin khác nếu cần
          if (Navigator.canPop(context)) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }),
        const SizedBox(height: 8),
        Container(
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
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
      tileColor: Colors.white,
      dense: true,
    );
  }
}
