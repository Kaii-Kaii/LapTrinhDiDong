// File: ViNguoiDung_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ViNguoiDung.dart';

class ViNguoiDungService {
  static const String baseUrl = 'https://10.0.2.2:7283/api/ViNguoiDung';

  /// Lấy danh sách Ví người dùng theo mã khách hàng (maKhachHang)
  static Future<List<ViNguoiDung>> fetchViNguoiDungByMaKhachHang(String maKhachHang) async {
    final List<ViNguoiDung> danhSachVi = [];

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        for (var item in data) {
          if (item['maNguoiDung']?.toString().trim() == maKhachHang.trim()) {
            danhSachVi.add(ViNguoiDung.fromJson(item));
          }
        }
      } else {
        print('Lỗi tải danh sách Ví người dùng: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi fetchViNguoiDungByMaKhachHang: $e');
    }

    return danhSachVi;
  }

  /// Thêm Ví người dùng mới, trả về true nếu thành công
  static Future<bool> themViNguoiDung(ViNguoiDung viNguoiDung) async {
    try {
      final body = jsonEncode(viNguoiDung.toJson());
      print('Dữ liệu gửi lên: $body');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Mã phản hồi: ${response.statusCode}');
      print('Nội dung trả về: ${response.body}');

      return response.statusCode == 201;
    } catch (e) {
      print('Lỗi themViNguoiDung: $e');
      return false;
    }
  }
}
