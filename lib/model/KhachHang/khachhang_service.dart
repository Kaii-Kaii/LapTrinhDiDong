import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qltncn/model/KhachHang/Khach_Hang.dart';

class KhachHangService {
  static Future<KhachHang?> fetchKhachHangByMaKH(String maKH) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5203/api/KhachHang'), // Lấy danh sách tất cả khách hàng
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Tìm khách hàng theo maKH trong danh sách
        final customer = data
            .map((item) => KhachHang.fromJson(item))
            .firstWhere(
              (khachHang) => khachHang.maKH == maKH,
              orElse: () => KhachHang(maKH: '', maTaiKhoan: '', xu: 0), // Trả về đối tượng trống nếu không tìm thấy
            );
        return customer;
      } else {
        throw Exception('Failed to load customer list');
      }
    } catch (e) {
      print('Error fetching customer by maKH: $e');
      return null;
    }
  }
  static Future<String?> fetchMaKHByMaTaiKhoan(String maTaiKhoan) async {
    try {
      final response = await http.get(
        Uri.parse('https://10.0.2.2:7283/api/KhachHang'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        for (var item in data) {
          if (item['mataikhoan']?.trim() == maTaiKhoan.trim()) {
            return item['makh']?.trim();
          }
        }
      } else {
        print('Lỗi khi tải danh sách KhachHang: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi fetchMaKHByMaTaiKhoan: $e');
    }

    return null;
  }


}
