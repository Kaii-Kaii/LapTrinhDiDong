import 'package:flutter/material.dart';

class TraCuuTyGia extends StatefulWidget {
  const TraCuuTyGia({super.key});

  @override
  _TraCuuTyGiaState createState() => _TraCuuTyGiaState();
}

class _TraCuuTyGiaState extends State<TraCuuTyGia> {
  final List<String> currencies = ['VND', 'USD', 'EUR', 'JPY', 'KRW', 'CNY'];
  String fromCurrency = 'VND';
  String toCurrency = 'USD';
  double amount = 0;
  double convertedAmount = 0;
  double exchangeRate = 0;

  // Giả lập tỷ giá (trong thực tế sẽ lấy từ API)
  final Map<String, double> vndRates = {
    'USD': 0.000041,
    'EUR': 0.000038,
    'JPY': 0.0061,
    'KRW': 0.055,
    'CNY': 0.00030,
  };

  void calculateConversion() {
    if (fromCurrency == 'VND') {
      exchangeRate = vndRates[toCurrency] ?? 1;
      convertedAmount = amount * exchangeRate;
    } else if (toCurrency == 'VND') {
      exchangeRate = 1 / (vndRates[fromCurrency] ?? 1);
      convertedAmount = amount * exchangeRate;
    } else {
      // Chuyển đổi qua VND trung gian
      double toVndRate = 1 / (vndRates[fromCurrency] ?? 1);
      double fromVndRate = vndRates[toCurrency] ?? 1;
      exchangeRate = toVndRate * fromVndRate;
      convertedAmount = amount * exchangeRate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Tra cứu tỷ giá'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card thông tin tỷ giá
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tỷ giá hiện tại',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1 $fromCurrency ='),
                      Text(
                        '${exchangeRate.toStringAsFixed(6)} $toCurrency',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Form quy đổi tiền tệ
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quy đổi tiền tệ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Chọn loại tiền gốc
                  DropdownButtonFormField<String>(
                    value: fromCurrency,
                    decoration: InputDecoration(
                      labelText: 'Từ loại tiền',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: currencies.map((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        fromCurrency = newValue!;
                        calculateConversion();
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  // Chọn loại tiền đích
                  DropdownButtonFormField<String>(
                    value: toCurrency,
                    decoration: InputDecoration(
                      labelText: 'Sang loại tiền',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: currencies.map((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        toCurrency = newValue!;
                        calculateConversion();
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  // Nhập số tiền
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Số tiền cần quy đổi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        amount = double.tryParse(value) ?? 0;
                        calculateConversion();
                      });
                    },
                  ),
                  SizedBox(height: 24),
                  // Kết quả quy đổi
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kết quả quy đổi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$amount $fromCurrency ='),
                            Text(
                              '${convertedAmount.toStringAsFixed(2)} $toCurrency',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 