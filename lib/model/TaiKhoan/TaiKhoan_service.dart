import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qltncn/model/TaiKhoan/TaiKhoan.dart';

Future<TaiKhoan?> fetchTaiKhoan(String maKH) async {
  try {
    final response = await http.get(
      Uri.parse('https://10.0.2.2:7283/api/TaiKhoan'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      for (var item in data) {
        String accountId = item['khachHang'].trim();
        if (accountId == maKH || accountId.substring(2) == maKH.substring(2)) {
          final taiKhoan = TaiKhoan.fromJson(item);
          return taiKhoan;
        }
      }

      return null; // Tài khoản không tìm thấy
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    throw Exception('Failed to load data: $e');
  }
}
Future<TaiKhoan?> fetchTaiKhoanByMaTaiKhoan(String maTaiKhoan) async {
  try {
    final response = await http.get(
      Uri.parse('https://10.0.2.2:7283/api/TaiKhoan'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      for (var item in data) {
        if (item['mataikhoan']?.trim() == maTaiKhoan.trim()) {
          return TaiKhoan.fromJson(item);
        }
      }

      return null; // Không tìm thấy tài khoản
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  } catch (e) {
    print('Lỗi fetchTaiKhoanByMaTaiKhoan: $e');
    return null;
  }
}

