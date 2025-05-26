import 'dart:convert';
import 'package:http/http.dart' as http;

class TyGiaModel {
  final String currency; // Mã tiền tệ, ví dụ: 'USD', 'VND', 'EUR'
  final double rate; //

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

      final currencies = [
        'VND',
        'EUR',
        'JPY',
        'CNY',
        'GBP',
        'AUD',
        'CAD',
        'CHF',
        'DKK',
        'HKD',
        'INR',
        'KRW',
        'KWD',
        'MYR',
        'NOK',
        'RUB',
        'SAR',
        'SEK',
        'SGD',
        'THB',
        'USD',
      ];

      return currencies.map((currency) {
        return TyGiaModel.fromMap(currency, rates[currency]);
      }).toList();
    } else {
      throw Exception('Không thể lấy dữ liệu tỷ giá');
    }
  }
}

/// Đổi tiền từ [fromCurrency] sang [toCurrency] với số tiền [amount].
/// [tyGiaList] là danh sách tỷ giá lấy từ API.
/// Trả về số tiền đã quy đổi, hoặc null nếu không tìm thấy tỷ giá.
double? doiTyGia({
  required List<TyGiaModel> tyGiaList,
  required String fromCurrency, // Mã tiền tệ gốc
  required String toCurrency, // Mã tiền tệ đích
  required double amount, // Số tiền cần đổi
}) {
  final from = tyGiaList.firstWhere(
    // Tìm tỷ giá của tiền tệ gốc
    (e) => e.currency == fromCurrency,
    orElse: () => TyGiaModel(currency: '', rate: 0),
  );
  final to = tyGiaList.firstWhere(
    (e) => e.currency == toCurrency,
    orElse: () => TyGiaModel(currency: '', rate: 0),
  );
  if (from.rate == 0 || to.rate == 0) return null;
  // Tính theo tỷ giá so với USD
  double usd = amount / from.rate;
  double result = usd * to.rate;
  return result;
}
