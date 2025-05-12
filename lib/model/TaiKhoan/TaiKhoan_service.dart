import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qltncn/model/TaiKhoan/TaiKhoan.dart';

Future<TaiKhoan?> fetchTaiKhoan(String maKH) async {
  try {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5203/api/TaiKhoan'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      for (var item in data) {
        String accountId = item['mataikhoan'].trim();
        // Kiểm tra nếu mã tài khoản trùng với maKH hoặc hai mã bắt đầu giống nhau
        if (accountId == maKH || accountId.substring(2) == maKH.substring(2)) {
          return TaiKhoan.fromJson(item);
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
