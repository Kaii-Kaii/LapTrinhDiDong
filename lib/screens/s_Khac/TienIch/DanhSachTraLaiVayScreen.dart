import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DanhSachTraLaiVayScreen extends StatelessWidget {
  final double soTien;
  final double tongLai;
  final double tongTra;
  final List<Map<String, dynamic>> danhSachTraLai;

  const DanhSachTraLaiVayScreen({
    super.key,
    required this.soTien,
    required this.tongLai,
    required this.tongTra,
    required this.danhSachTraLai,
  });

  String formatCurrency(double amount) {
    final formatter = NumberFormat("#,###", "vi_VN");
    return "${formatter.format(amount)} đ";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Lịch trả lãi"),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Thông tin tổng quan
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _infoColumn("Số tiền vay", formatCurrency(soTien)),
                    _infoColumn("Tổng lãi", formatCurrency(tongLai)),
                    _infoColumn("Tổng phải trả", formatCurrency(tongTra)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tiêu đề danh sách
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Chi tiết các kỳ thanh toán",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            // Danh sách trả lãi
            Expanded(
              child: ListView.separated(
                itemCount: danhSachTraLai.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = danhSachTraLai[index];
                  final ngayTra = item['ngayTra'] as DateTime;
                  return Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.indigo,
                        child: Icon(Icons.payments, color: Colors.white),
                      ),
                      title: Text(
                        "Kỳ ${item['kyHan']} - ${DateFormat('dd/MM/yyyy').format(ngayTra)}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Gốc: ${formatCurrency(item['tienGoc'])}"),
                            Text("Lãi: ${formatCurrency(item['tienLai'])}"),
                            Text("Tổng: ${formatCurrency(item['tongTra'])}"),
                            Text(
                              "Dư nợ còn lại: ${formatCurrency(item['duNoConLai'])}",
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
      ],
    );
  }
}
