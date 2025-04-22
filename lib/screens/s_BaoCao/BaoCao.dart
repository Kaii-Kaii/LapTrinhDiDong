import 'package:flutter/material.dart';
import 'package:qltncn/screens/HomePage.dart';
import 'package:qltncn/model/GirdItem.dart';

class Main_BaoCao extends StatelessWidget {
  final List<GirdItem> items = [
    GirdItem(title: 'Tài chính hiện tại', icon: Icons.show_chart, iconColor: Colors.blue),
    GirdItem(title: 'Tình hình thu chi', icon: Icons.stacked_line_chart, iconColor: Colors.teal),
    GirdItem(title: 'Phân tích chi tiêu', icon: Icons.bar_chart, iconColor: Colors.red),
    GirdItem(title: 'Phân tích thu', icon: Icons.bar_chart, iconColor: Colors.green),
    GirdItem(title: 'Theo dõi vay nợ', icon: Icons.receipt_long, iconColor: Colors.orange),
    GirdItem(title: 'Đối tượng thu/chi', icon: Icons.group, iconColor: Colors.lightBlue),
    GirdItem(title: 'Chuyến đi/Sự kiện', icon: Icons.event, iconColor: Colors.lightGreen),
    GirdItem(title: 'Phân tích tài chính', icon: Icons.pie_chart_outline, iconColor: Colors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Căn giữa tiêu đề
        backgroundColor: Colors.lightBlue, // Màu nền AppBar
        title: const Text(
          'Báo cáo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Màu chữ trắng
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: List.generate(items.length, (index) {
            final item = items[index];
            return InkWell(
              onTap: () {
                // 👉 Tại đây bạn xử lý điều hướng tới Widget tương ứng
                switch (index) {
                  case 0:
                    // TODO: Mở Widget Tài chính hiện tại
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                    break;
                  case 1:
                    // TODO: Mở Widget Tình hình thu chi
                    break;
                  case 2:
                    // TODO: Mở Widget Phân tích chi tiêu
                    break;
                  case 3:
                    // TODO: Mở Widget Phân tích thu
                    break;
                  case 4:
                    // TODO: Mở Widget Theo dõi vay nợ
                    break;
                  case 5:
                    // TODO: Mở Widget Đối tượng thu/chi
                    break;
                  case 6:
                    // TODO: Mở Widget Chuyến đi/Sự kiện
                    break;
                  case 7:
                    // TODO: Mở Widget Phân tích tài chính
                    break;
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, color: item.iconColor, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
    );
  }
}
