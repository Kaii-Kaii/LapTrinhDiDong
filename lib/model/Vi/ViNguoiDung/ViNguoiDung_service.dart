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
          // Kiểm tra mã người dùng có khớp với maKhachHang truyền vào không
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
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(viNguoiDung.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Lỗi khi thêm Ví người dùng: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Lỗi themViNguoiDung: $e');
      return false;
    }
  }
}
