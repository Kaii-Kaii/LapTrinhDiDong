import 'package:flutter/material.dart';
import 'package:qltncn/model/GirdItem.dart';
import 'package:qltncn/screens/s_Khac/TienIch/han_muc_chi_screen.dart';// Import màn hình đích

class KhacMain extends StatelessWidget {
  final List<GirdItem> tinhNangList = [
    GirdItem(title: 'Hạn mức chi', icon: Icons.money_off, iconColor: Colors.red),
    GirdItem(title: 'Hạng mục thu/chi', icon: Icons.list_alt, iconColor: Colors.blueAccent),
    GirdItem(title: 'Danh sách mua sắm', icon: Icons.shopping_cart, iconColor: Colors.blue),
    GirdItem(title: 'Ghi chép định kỳ', icon: Icons.repeat, iconColor: Colors.orange),
    GirdItem(title: 'Ghi chép mẫu', icon: Icons.note, iconColor: Colors.purple),
    GirdItem(title: 'Du lịch', icon: Icons.travel_explore, iconColor: Colors.green),
    GirdItem(title: 'Dự thu/Dự chi', icon: Icons.archive, iconColor: Colors.amber),
    GirdItem(title: 'Xuất khẩu dữ liệu', icon: Icons.file_upload, iconColor: Colors.deepPurple),
  ];

  final List<GirdItem> tienIchList = [
    GirdItem(title: 'Tra cứu tỷ giá', icon: Icons.money_off_csred_outlined, iconColor: Colors.blue),
    GirdItem(title: 'Tính lãi vay', icon: Icons.calculate, iconColor: Colors.teal),
    GirdItem(title: 'Tiết kiệm gửi góp', icon: Icons.savings, iconColor: Colors.red),
    GirdItem(title: 'Thuế TNCN', icon: Icons.people_outline, iconColor: Colors.green),
    GirdItem(title: 'Chia tiền', icon: Icons.money_rounded, iconColor: Colors.orange),
    GirdItem(title: 'Widget', icon: Icons.widgets_rounded, iconColor: Colors.lightBlue),
    GirdItem(title: 'Tìm kế toán dịch vụ', icon: Icons.event, iconColor: Colors.lightGreen),
    GirdItem(title: 'Premium miễn phí', icon: Icons.compare_arrows_rounded, iconColor: Colors.purple),
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
            _buildUserInfo(),
            _buildPremiumBanner(),
            _buildPointAndCode(),
            _buildSection(context, "Tính năng", tinhNangList),
            _buildSection(context, "Tiện ích", tienIchList),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.lightBlue,
            child: Text("N", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("nguyenvuonghongdao2004", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("nguyenvuonghongdao2004@gmail.com", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Icon(Icons.notifications_none),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrange]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Nâng cấp Premium", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(width: 10),
          Icon(Icons.rocket_launch, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildPointAndCode() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildInfoCard(Icons.monetization_on, "Xu của bạn", "100 xu", Colors.orange),
          const SizedBox(width: 8),
          _buildInfoCard(Icons.share, "Mã chia sẻ", "4402410", Colors.blue),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color iconColor) {
    return Expanded(
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<GirdItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: List.generate(items.length, (index) {
              final item = items[index];
              return InkWell(
                onTap: () => _handleTap(context, item.title),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: item.iconColor.withOpacity(0.1),
                      child: Icon(item.icon, color: item.iconColor),
                    ),
                    const SizedBox(height: 8),
                    Text(item.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _handleTap(BuildContext context, String title) {
    switch (title) {
      case 'Hạn mức chi':
        Navigator.push(context, MaterialPageRoute(builder: (_) => HanMucChiScreen()));
        break;
      // TODO: Thêm các điều hướng khác ở đây
      default:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chức năng "$title" đang phát triển')));
    }
  }
}
