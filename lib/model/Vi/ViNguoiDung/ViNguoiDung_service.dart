// File: ViNguoiDung_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ViNguoiDung.dart';

class ViNguoiDungService {
  static const String baseUrl = 'https://10.0.2.2:7283/api/ViNguoiDung';

  /// Lấy danh sách Ví người dùng theo mã khách hàng (maKhachHang)
  static Future<List<ViNguoiDung>> fetchViNguoiDungByMaKhachHang(
    String maKhachHang,
  ) async {
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

  /// Cập nhật toàn bộ thông tin ví (full update)
  static Future<bool> capNhatViNguoiDungFull({
    required String maNguoiDung,
    required int maVi,
    required String tenTaiKhoanCu,
    required ViNguoiDung viNguoiDungMoi,
  }) async {
    try {
      final url =
          '$baseUrl/$maNguoiDung/$maVi/${Uri.encodeComponent(tenTaiKhoanCu)}';

      final body = jsonEncode({
        'tenTaiKhoan': viNguoiDungMoi.tenTaiKhoan,
        'maLoaiTien': viNguoiDungMoi.maLoaiTien,
        'dienGiai': viNguoiDungMoi.dienGiai,
        'soDu': viNguoiDungMoi.soDu,
      });

      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('PUT $url với body: $body');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return response.statusCode == 204;
    } catch (e) {
      print('Lỗi cập nhật ví: $e');
      return false;
    }
  }

  /// Kiểm tra tên ví trùng cho cùng loại ví, loại trừ ví đang sửa (theo maVi)
  /// Không cho nhập nếu: tên ví mới trùng tên ví cũ và là chính cái ví đó
  static Future<bool> kiemTraTenViTrung({
    required String maNguoiDung,
    required String tenTaiKhoan,
    required int maViKhongTinh,
  }) async {
    try {
      final danhSach = await fetchViNguoiDungByMaKhachHang(maNguoiDung);

      for (var vi in danhSach) {
        if (vi.maVi != maViKhongTinh && // chỉ kiểm tra với ví khác
            vi.tenTaiKhoan.trim().toLowerCase() ==
                tenTaiKhoan.trim().toLowerCase()) {
          // Tên trùng với ví khác
          return true;
        }
      }

      return false; // Không trùng với ví nào khác thì hợp lệ
    } catch (e) {
      print('Lỗi kiểm tra trùng tên ví: $e');
      return false;
    }
  }
}
