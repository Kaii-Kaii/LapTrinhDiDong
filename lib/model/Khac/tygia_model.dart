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
    'AED': 'ae',
    'AFN': 'af',
    'ALL': 'al',
    'AMD': 'am',
    'ANG': 'nl', // Netherlands Antilles
    'AOA': 'ao',
    'ARS': 'ar',
    'AUD': 'au',
    'AWG': 'aw',
    'AZN': 'az',
    'BAM': 'ba',
    'BBD': 'bb',
    'BDT': 'bd',
    'BGN': 'bg',
    'BHD': 'bh',
    'BIF': 'bi',
    'BMD': 'bm',
    'BND': 'bn',
    'BOB': 'bo',
    'BRL': 'br',
    'BSD': 'bs',
    'BTN': 'bt',
    'BWP': 'bw',
    'BYN': 'by',
    'BZD': 'bz',
    'CAD': 'ca',
    'CDF': 'cd',
    'CHF': 'ch',
    'CLP': 'cl',
    'CNY': 'cn',
    'COP': 'co',
    'CRC': 'cr',
    'CUP': 'cu',
    'CVE': 'cv',
    'CZK': 'cz',
    'DJF': 'dj',
    'DKK': 'dk',
    'DOP': 'do',
    'DZD': 'dz',
    'EGP': 'eg',
    'ERN': 'er',
    'ETB': 'et',
    'EUR': 'eu',
    'FJD': 'fj',
    'FKP': 'fk',
    'FOK': 'fo',
    'GBP': 'gb',
    'GEL': 'ge',
    'GGP': 'gg',
    'GHS': 'gh',
    'GIP': 'gi',
    'GMD': 'gm',
    'GNF': 'gn',
    'GTQ': 'gt',
    'GYD': 'gy',
    'HKD': 'hk',
    'HNL': 'hn',
    'HRK': 'hr',
    'HTG': 'ht',
    'HUF': 'hu',
    'IDR': 'id',
    'ILS': 'il',
    'IMP': 'im',
    'INR': 'in',
    'IQD': 'iq',
    'IRR': 'ir',
    'ISK': 'is',
    'JEP': 'je',
    'JMD': 'jm',
    'JOD': 'jo',
    'JPY': 'jp',
    'KES': 'ke',
    'KGS': 'kg',
    'KHR': 'kh',
    'KID': 'ki',
    'KMF': 'km',
    'KRW': 'kr',
    'KWD': 'kw',
    'KYD': 'ky',
    'KZT': 'kz',
    'LAK': 'la',
    'LBP': 'lb',
    'LKR': 'lk',
    'LRD': 'lr',
    'LSL': 'ls',
    'LYD': 'ly',
    'MAD': 'ma',
    'MDL': 'md',
    'MGA': 'mg',
    'MKD': 'mk',
    'MMK': 'mm',
    'MNT': 'mn',
    'MOP': 'mo',
    'MRU': 'mr',
    'MUR': 'mu',
    'MVR': 'mv',
    'MWK': 'mw',
    'MXN': 'mx',
    'MYR': 'my',
    'MZN': 'mz',
    'NAD': 'na',
    'NGN': 'ng',
    'NIO': 'ni',
    'NOK': 'no',
    'NPR': 'np',
    'NZD': 'nz',
    'OMR': 'om',
    'PAB': 'pa',
    'PEN': 'pe',
    'PGK': 'pg',
    'PHP': 'ph',
    'PKR': 'pk',
    'PLN': 'pl',
    'PYG': 'py',
    'QAR': 'qa',
    'RON': 'ro',
    'RSD': 'rs',
    'RUB': 'ru',
    'RWF': 'rw',
    'SAR': 'sa',
    'SBD': 'sb',
    'SCR': 'sc',
    'SDG': 'sd',
    'SEK': 'se',
    'SGD': 'sg',
    'SHP': 'sh',
    'SLE': 'sl',
    'SLL': 'sl',
    'SOS': 'so',
    'SRD': 'sr',
    'SSP': 'ss',
    'STN': 'st',
    'SYP': 'sy',
    'SZL': 'sz',
    'THB': 'th',
    'TJS': 'tj',
    'TMT': 'tm',
    'TND': 'tn',
    'TOP': 'to',
    'TRY': 'tr',
    'TTD': 'tt',
    'TVD': 'tv',
    'TWD': 'tw',
    'TZS': 'tz',
    'UAH': 'ua',
    'UGX': 'ug',
    'UYU': 'uy',
    'UZS': 'uz',
    'VES': 've',
    'VND': 'vn',
    'VUV': 'vu',
    'WST': 'ws',
    'XAF': 'cm',
    'XCD': 'ag',
    'XDR': 'un',
    'XOF': 'bj',
    'XPF': 'pf',
    'YER': 'ye',
    'ZAR': 'za',
    'ZMW': 'zm',
    'ZWL': 'zw',
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
        'USD',
        'AED',
        'AFN',
        'ALL',
        'AMD',
        'ANG',
        'AOA',
        'ARS',
        'AUD',
        'AWG',
        'AZN',
        'BAM',
        'BBD',
        'BDT',
        'BGN',
        'BHD',
        'BIF',
        'BMD',
        'BND',
        'BOB',
        'BRL',
        'BSD',
        'BTN',
        'BWP',
        'BYN',
        'BZD',
        'CAD',
        'CDF',
        'CHF',
        'CLP',
        'CNY',
        'COP',
        'CRC',
        'CUP',
        'CVE',
        'CZK',
        'DJF',
        'DKK',
        'DOP',
        'DZD',
        'EGP',
        'ERN',
        'ETB',
        'EUR',
        'FJD',
        'FKP',
        'FOK',
        'GBP',
        'GEL',
        'GGP',
        'GHS',
        'GIP',
        'GMD',
        'GNF',
        'GTQ',
        'GYD',
        'HKD',
        'HNL',
        'HRK',
        'HTG',
        'HUF',
        'IDR',
        'ILS',
        'IMP',
        'INR',
        'IQD',
        'IRR',
        'ISK',
        'JEP',
        'JMD',
        'JOD',
        'JPY',
        'KES',
        'KGS',
        'KHR',
        'KID',
        'KMF',
        'KRW',
        'KWD',
        'KYD',
        'KZT',
        'LAK',
        'LBP',
        'LKR',
        'LRD',
        'LSL',
        'LYD',
        'MAD',
        'MDL',
        'MGA',
        'MKD',
        'MMK',
        'MNT',
        'MOP',
        'MRU',
        'MUR',
        'MVR',
        'MWK',
        'MXN',
        'MYR',
        'MZN',
        'NAD',
        'NGN',
        'NIO',
        'NOK',
        'NPR',
        'NZD',
        'OMR',
        'PAB',
        'PEN',
        'PGK',
        'PHP',
        'PKR',
        'PLN',
        'PYG',
        'QAR',
        'RON',
        'RSD',
        'RUB',
        'RWF',
        'SAR',
        'SBD',
        'SCR',
        'SDG',
        'SEK',
        'SGD',
        'SHP',
        'SLE',
        'SLL',
        'SOS',
        'SRD',
        'SSP',
        'STN',
        'SYP',
        'SZL',
        'THB',
        'TJS',
        'TMT',
        'TND',
        'TOP',
        'TRY',
        'TTD',
        'TVD',
        'TWD',
        'TZS',
        'UAH',
        'UGX',
        'UYU',
        'UZS',
        'VES',
        'VND',
        'VUV',
        'WST',
        'XAF',
        'XCD',
        'XDR',
        'XOF',
        'XPF',
        'YER',
        'ZAR',
        'ZMW',
        'ZWL',
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
