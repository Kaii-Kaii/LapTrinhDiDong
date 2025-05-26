import 'package:flutter/material.dart';
import 'package:qltncn/model/Vi/Vi/Vi.dart';
import 'package:qltncn/model/Vi/Vi/ViModel.dart';

/// Danh sách các loại ví mẫu với icon dưới dạng string
final List<Vi> tinhNangList = [
  Vi(maVi: 1, tenVi: "Tiền mặt", loaiVi: "Chi tiêu", iconVi: "Icons.money"),
  Vi(maVi: 2, tenVi: 'Tài khoản ngân hàng', loaiVi: 'Tiết kiệm', iconVi: 'Icons.account_balance'),
  Vi(maVi: 3, tenVi: 'Thẻ tín dụng', loaiVi: 'Chi tiêu', iconVi: 'Icons.credit_card'),
  Vi(maVi: 4, tenVi: 'Tài khoản đầu tư', loaiVi: 'Đầu tư', iconVi: 'Icons.trending_up'),
  Vi(maVi: 5, tenVi: 'Ví điện tử', loaiVi: 'Chi tiêu', iconVi: 'Icons.phone_android'),
  Vi(maVi: 6, tenVi: 'Khác', loaiVi: 'Khác', iconVi: 'Icons.more_horiz'),
];

/// Trả về Icon tương ứng từ string
Widget getIconWidget(String iconVi) {
  switch (iconVi) {
    case 'Icons.money':
      return const Icon(Icons.money, color: Colors.tealAccent);
    case 'Icons.account_balance':
      return const Icon(Icons.account_balance, color: Colors.blue);
    case 'Icons.credit_card':
      return const Icon(Icons.credit_card, color: Colors.white);
    case 'Icons.trending_up':
      return const Icon(Icons.trending_up, color: Colors.pinkAccent);
    case 'Icons.phone_android':
      return const Icon(Icons.phone_android, color: Colors.greenAccent);
    case 'Icons.more_horiz':
      return const Icon(Icons.more_horiz, color: Colors.amberAccent);
    default:
      return const Icon(Icons.account_balance_wallet, color: Colors.limeAccent);
  }
}

/// Màu nền avatar theo mã ví
Color getColorForLoaiVi(int maVi) {
  switch (maVi) {
    case 1:
      return const Color(0xFFFF9800); // Cam
    case 2:
      return const Color(0xFF4CAF50); // Xanh lá
    case 3:
      return const Color(0xFF2196F3); // Xanh dương
    case 4:
      return const Color(0xFF9E9E9E); // Xám
    case 5:
      return Colors.grey;
    case 6:
      return Colors.brown;
    default:
      return const Color(0xFF009688); // Teal
  }
}
Widget chonLoaiViBottomSheet({
  required List<ViModel> danhSach,
  required String viDangChon,
  required Function(String) onChon,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Loại tài khoản',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      ...danhSach.map((vi) {
        final bool isSelected = vi.ten == viDangChon;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: vi.iconColor.withOpacity(0.2),
            child: Icon(vi.icon, color: vi.iconColor),
          ),
          title: Text(vi.ten),
          trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
          onTap: () => onChon(vi.ten),
        );
      }).toList(),
      const SizedBox(height: 16),
    ],
  );
}
