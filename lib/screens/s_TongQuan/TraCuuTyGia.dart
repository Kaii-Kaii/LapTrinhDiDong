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
  final TextEditingController _amountController = TextEditingController();

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
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    calculateConversion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF03A9F4), Color(0xFF0288D1), Color(0xFF0277BD)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Tra cứu tỷ giá',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.refresh, color: Colors.white),
                        onPressed: calculateConversion,
                      ),
                    ),
                  ],
                ),
              ),

              // Decorative elements
              Container(
                height: 80,
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      right: 30,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 30,
                      left: 50,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      left: 100,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Exchange Rate Display Card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF03A9F4).withOpacity(0.8),
                                Color(0xFF0288D1).withOpacity(0.9),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF03A9F4).withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 15,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.currency_exchange,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Tỷ giá hiện tại',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '1 $fromCurrency =',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${exchangeRate.toStringAsFixed(6)} $toCurrency',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 32),

                        // Currency Converter Card
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quy đổi tiền tệ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 24),

                              // From Currency
                              _buildCurrencyDropdown(
                                label: 'Từ loại tiền',
                                value: fromCurrency,
                                icon: Icons.currency_exchange,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    fromCurrency = newValue!;
                                    calculateConversion();
                                  });
                                },
                              ),

                              SizedBox(height: 20),

                              // Swap button
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF03A9F4).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.swap_vert,
                                      color: Color(0xFF03A9F4),
                                      size: 28,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        String temp = fromCurrency;
                                        fromCurrency = toCurrency;
                                        toCurrency = temp;
                                        calculateConversion();
                                      });
                                    },
                                  ),
                                ),
                              ),

                              SizedBox(height: 20),

                              // To Currency
                              _buildCurrencyDropdown(
                                label: 'Sang loại tiền',
                                value: toCurrency,
                                icon: Icons.monetization_on,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    toCurrency = newValue!;
                                    calculateConversion();
                                  });
                                },
                              ),

                              SizedBox(height: 24),

                              // Amount input
                              TextFormField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Số tiền cần quy đổi',
                                  prefixIcon: Icon(
                                    Icons.attach_money,
                                    color: Color(0xFF03A9F4),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Color(
                                    0xFF03A9F4,
                                  ).withOpacity(0.05),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Color(0xFF03A9F4),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  amount = double.tryParse(value) ?? 0;
                                  calculateConversion();
                                },
                              ),

                              SizedBox(height: 32),

                              // Result display
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF03A9F4).withOpacity(0.1),
                                      Color(0xFF0288D1).withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Color(0xFF03A9F4).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.calculate,
                                          color: Color(0xFF03A9F4),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Kết quả quy đổi',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF03A9F4),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${amount.toStringAsFixed(2)} $fromCurrency',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: Color(0xFF03A9F4),
                                        ),
                                        Text(
                                          '${convertedAmount.toStringAsFixed(2)} $toCurrency',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF03A9F4),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown({
    required String label,
    required String value,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF03A9F4)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Color(0xFF03A9F4).withOpacity(0.05),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFF03A9F4), width: 2),
        ),
      ),
      items:
          currencies.map((String currency) {
            return DropdownMenuItem<String>(
              value: currency,
              child: Text(
                currency,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            );
          }).toList(),
      onChanged: onChanged,
    );
  }
}
