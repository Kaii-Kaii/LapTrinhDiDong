import 'dart:convert';
import 'package:http/http.dart' as http;

class TyGiaModel {
  final String currency;
  final double rate;

  TyGiaModel({required this.currency, required this.rate});

  factory TyGiaModel.fromMap(String currency, dynamic rate) {
    return TyGiaModel(currency: currency, rate: (rate as num).toDouble());
  }
}

class TyGiaRepository {
  static Future<List<TyGiaModel>> fetchTyGia() async {
    final url = Uri.parse('https://open.er-api.com/v6/latest/USD');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rates = data['rates'] as Map<String, dynamic>;

      final currencies = ['VND', 'EUR', 'JPY', 'CNY', 'GBP'];
      return currencies.map((currency) {
        return TyGiaModel.fromMap(currency, rates[currency]);
      }).toList();
    } else {
      throw Exception('Không thể lấy dữ liệu tỷ giá');
    }
  }
}
