import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class TinhThueScreen extends StatefulWidget {
  const TinhThueScreen({super.key});

  @override
  State<TinhThueScreen> createState() => _TinhThueScreenState();
}

class _TinhThueScreenState extends State<TinhThueScreen> {
  final _formKey = GlobalKey<FormState>();

  final _thuNhapController = TextEditingController();
  final _luongDongBHController = TextEditingController();
  final _nguoiPhuThuocController = TextEditingController();

  final NumberFormat _currencyFormatter = NumberFormat("#,##0", "vi_VN");

  bool _isFormattingThuNhap = false;
  bool _isFormattingLuongBH = false;

  double thuNhap = 0;
  double luongDongBH = 0;
  int nguoiPhuThuoc = 0;

  double trichNopBH = 0;
  final double giamTruBanThan = 11_000_000;
  double giamTruNguoiPhuThuoc = 0;
  double thuNhapTinhThue = 0;
  double thuePhaiDong = 0;
  double thuNhapSauThue = 0;

  void _tinhToan() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        thuNhap = _parseCurrency(_thuNhapController.text);
        luongDongBH = _parseCurrency(_luongDongBHController.text);
        nguoiPhuThuoc = int.parse(_nguoiPhuThuocController.text);

        trichNopBH = luongDongBH * 0.105;
        giamTruNguoiPhuThuoc = nguoiPhuThuoc * 4_400_000;
        double tongGiamTru = trichNopBH + giamTruBanThan + giamTruNguoiPhuThuoc;
        thuNhapTinhThue = max(0, thuNhap - tongGiamTru);
        thuePhaiDong = _tinhThueTNCN(thuNhapTinhThue);
        thuNhapSauThue = thuNhap - trichNopBH - thuePhaiDong;
      });
    }
  }

  double _parseCurrency(String formatted) {
    // Bỏ dấu chấm để chuyển về số nguyên rồi trả về double
    return double.tryParse(formatted.replaceAll('.', '').trim()) ?? 0;
  }

  double _tinhThueTNCN(double thuNhapTinhThue) {
    double thue = 0;
    final bac = [
      [0.0, 5_000_000.0, 0.05],
      [5_000_000.0, 10_000_000.0, 0.10],
      [10_000_000.0, 18_000_000.0, 0.15],
      [18_000_000.0, 32_000_000.0, 0.20],
      [32_000_000.0, 52_000_000.0, 0.25],
      [52_000_000.0, 80_000_000.0, 0.30],
      [80_000_000.0, double.infinity, 0.35],
    ];

    for (var b in bac) {
      double from = b[0];
      double to = b[1];
      double rate = b[2];

      if (thuNhapTinhThue > from) {
        double taxable = min(to - from, thuNhapTinhThue - from);
        thue += taxable * rate;
      } else {
        break;
      }
    }

    return thue;
  }

  @override
  void dispose() {
    _thuNhapController.dispose();
    _luongDongBHController.dispose();
    _nguoiPhuThuocController.dispose();
    super.dispose();
  }

  // Hàm định dạng tiền tệ khi nhập vào (thêm dấu chấm hàng nghìn)
  void _formatCurrency(
    TextEditingController controller,
    String value,
    bool isFormattingFlag,
  ) {
    if (isFormattingFlag) return; // tránh loop vô hạn

    String onlyDigits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (onlyDigits.isEmpty) {
      controller.text = '';
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: 0),
      );
      return;
    }

    _isFormattingThuNhap = true;
    String newText = _currencyFormatter.format(int.parse(onlyDigits));
    controller.text = newText;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: newText.length),
    );
    _isFormattingThuNhap = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tính thuế TNCN',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildCurrencyField(
                        controller: _thuNhapController,
                        label: 'Thu nhập (VND)',
                        hint: 'Nhập tổng thu nhập',
                        icon: Icons.attach_money,
                        onChanged: (val) {
                          if (_isFormattingThuNhap) return;
                          String onlyDigits = val.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          if (onlyDigits.isEmpty) {
                            _thuNhapController.text = '';
                            _thuNhapController
                                .selection = TextSelection.collapsed(offset: 0);
                            return;
                          }
                          _isFormattingThuNhap = true;
                          String newText = _currencyFormatter.format(
                            int.parse(onlyDigits),
                          );
                          _thuNhapController.text = newText;
                          _thuNhapController.selection =
                              TextSelection.collapsed(offset: newText.length);
                          _isFormattingThuNhap = false;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildCurrencyField(
                        controller: _luongDongBHController,
                        label: 'Lương đóng BH (VND)',
                        hint: 'Nhập lương đóng bảo hiểm',
                        icon: Icons.account_balance_wallet,
                        onChanged: (val) {
                          if (_isFormattingLuongBH) return;
                          String onlyDigits = val.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          if (onlyDigits.isEmpty) {
                            _luongDongBHController.text = '';
                            _luongDongBHController
                                .selection = TextSelection.collapsed(offset: 0);
                            return;
                          }
                          _isFormattingLuongBH = true;
                          String newText = _currencyFormatter.format(
                            int.parse(onlyDigits),
                          );
                          _luongDongBHController.text = newText;
                          _luongDongBHController.selection =
                              TextSelection.collapsed(offset: newText.length);
                          _isFormattingLuongBH = false;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nguoiPhuThuocController,
                        decoration: InputDecoration(
                          labelText: 'Số người phụ thuộc',
                          hintText: 'Nhập số nguyên',
                          prefixIcon: const Icon(Icons.people),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập số người phụ thuộc';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Phải là số nguyên hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _tinhToan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Tính toán',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (thuNhap > 0)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Kết quả tính toán',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(height: 30, thickness: 2),
                      _buildResultRow("Thu nhập", thuNhap),
                      _buildResultRow("Lương đóng BH", luongDongBH),
                      _buildResultRow("Trích nộp BH (10.5%)", trichNopBH),
                      const Divider(),
                      _buildResultRow("Giảm trừ bản thân", giamTruBanThan),
                      _buildResultRow(
                        "Giảm trừ người phụ thuộc",
                        giamTruNguoiPhuThuoc,
                      ),
                      const Divider(),
                      _buildResultRow("Thu nhập tính thuế", thuNhapTinhThue),
                      _buildResultRow("Thuế phải đóng", thuePhaiDong),
                      const Divider(),
                      _buildResultRow("Thu nhập sau thuế", thuNhapSauThue),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập $label';
        }
        return null;
      },
      onChanged: onChanged,
    );
  }

  Widget _buildResultRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            "${_currencyFormatter.format(value)} đ",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
