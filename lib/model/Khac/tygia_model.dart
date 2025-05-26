import 'dart:convert';
import 'package:http/http.dart' as http;

class TyGiaModel {
  final String currency;
  final double rate;
  final String flagUrl;

  TyGiaModel({
    required this.currency,
    required this.rate,
    required this.flagUrl,
  });

  static const Map<String, String> currencyToCountryCode = {
    'USD': 'us',
    'VND': 'vn',
    // ... các mã khác
  };

  factory TyGiaModel.fromMap(String currency, dynamic rate) {
    String countryCode = currencyToCountryCode[currency.toUpperCase()] ?? 'un';
    String flagUrl = 'https://flagcdn.com/48x36/$countryCode.png';
    return TyGiaModel(
      currency: currency,
      rate: (rate as num).toDouble(),
      flagUrl: flagUrl,
    );
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

double? doiTyGia({
  required List<TyGiaModel> tyGiaList,
  required String fromCurrency,
  required String toCurrency,
  required double amount,
}) {
  final from = tyGiaList.firstWhere(
    (e) => e.currency == fromCurrency,
    orElse: () => TyGiaModel(currency: '', rate: 0, flagUrl: ''),
  );
  final to = tyGiaList.firstWhere(
    (e) => e.currency == toCurrency,
    orElse: () => TyGiaModel(currency: '', rate: 0, flagUrl: ''),
  );
  if (from.rate == 0 || to.rate == 0) return null;

  double usd = amount / from.rate;
  double result = usd * to.rate;
  return result;
}
