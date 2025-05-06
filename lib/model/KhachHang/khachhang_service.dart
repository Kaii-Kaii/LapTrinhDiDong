import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qltncn/model/KhachHang/Khach_Hang.dart';

class KhachHangService {
  static Future<KhachHang?> fetchKhachHangByMaKH(String maKH) async {
    try {
      final response = await http.get(
        Uri.parse('https://your-api-url/khachhang/$maKH'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return KhachHang.fromJson(data); // assuming you have a `fromJson` method in KhachHang
      } else {
        throw Exception('Failed to load KhachHang data');
      }
    } catch (e) {
      print('Error fetching customer: $e');
      return null;
    }
  }

  static Future<List<KhachHang>> fetchKhachHangs() async {
    try {
      final response = await http.get(
        Uri.parse('https://your-api-url/khachhangs'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => KhachHang.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load KhachHang data');
      }
    } catch (e) {
      print('Error fetching customer list: $e');
      return [];
    }
  }
}
