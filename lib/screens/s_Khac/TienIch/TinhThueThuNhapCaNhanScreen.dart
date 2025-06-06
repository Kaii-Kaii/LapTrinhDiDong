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
  final Color primaryColor = const Color(0xFF03A9F4);

  bool _isFormattingThuNhap = false;
  bool _isFormattingLuongBH = false;

  double thuNhap = 0;
  double luongDongBH = 0;
  int nguoiPhuThuoc = 0;

  double trichNopBH = 0;
  final double giamTruBanThan = 11000000;
  double giamTruNguoiPhuThuoc = 0;
  double thuNhapTinhThue = 0;
  double thuePhaiDong = 0;
  double thuNhapSauThue = 0;

  double _parseCurrency(String formatted) {
    String onlyDigits = formatted.replaceAll(RegExp(r'[^0-9]'), '');
    if (onlyDigits.isEmpty) return 0;
    return double.parse(onlyDigits);
  }

  void _formatCurrency(
    TextEditingController controller,
    String value,
    bool isFormattingFlag,
    void Function(bool) setFlag,
  ) {
    if (isFormattingFlag) return;

    String onlyDigits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (onlyDigits.isEmpty) {
      controller.text = '';
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: 0),
      );
      return;
    }

    setFlag(true);
    String newText = _currencyFormatter.format(int.parse(onlyDigits));
    controller.text = newText;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: newText.length),
    );
    setFlag(false);
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

  void _tinhToan() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        thuNhap = _parseCurrency(_thuNhapController.text);
        luongDongBH = _parseCurrency(_luongDongBHController.text);
        nguoiPhuThuoc = int.parse(_nguoiPhuThuocController.text);

        trichNopBH = luongDongBH * 0.105;
        giamTruNguoiPhuThuoc = nguoiPhuThuoc * (4400000);
        double tongGiamTru = trichNopBH + giamTruBanThan + giamTruNguoiPhuThuoc;
        thuNhapTinhThue = max(0, thuNhap - tongGiamTru);
        thuePhaiDong = _tinhThueTNCN(thuNhapTinhThue);
        thuNhapSauThue = thuNhap - trichNopBH - thuePhaiDong;
      });
    }
  }

  @override
  void dispose() {
    _thuNhapController.dispose();
    _luongDongBHController.dispose();
    _nguoiPhuThuocController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.1),
              Colors.white,
              primaryColor.withOpacity(0.05),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background decorations
            Positioned(
              top: -120,
              right: -120,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              top: 150,
              left: -80,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              right: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.12),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Custom AppBar
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: primaryColor,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              "Tính thuế TNCN",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),

                          // Header với icon
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor,
                                  primaryColor.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tính thuế thu nhập cá nhân",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Nhập thông tin để tính toán thuế TNCN",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Form inputs
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    _buildInputField(
                                      controller: _thuNhapController,
                                      label: 'Thu nhập hàng tháng',
                                      icon: Icons.attach_money,
                                      suffix: 'VNĐ',
                                      onChanged: (val) {
                                        _formatCurrency(
                                          _thuNhapController,
                                          val,
                                          _isFormattingThuNhap,
                                          (flag) => _isFormattingThuNhap = flag,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    _buildInputField(
                                      controller: _luongDongBHController,
                                      label: 'Lương đóng bảo hiểm',
                                      icon: Icons.account_balance_wallet,
                                      suffix: 'VNĐ',
                                      onChanged: (val) {
                                        _formatCurrency(
                                          _luongDongBHController,
                                          val,
                                          _isFormattingLuongBH,
                                          (flag) => _isFormattingLuongBH = flag,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    _buildNumberField(
                                      controller: _nguoiPhuThuocController,
                                      label: 'Số người phụ thuộc',
                                      icon: Icons.people,
                                      suffix: 'người',
                                    ),
                                    const SizedBox(height: 30),

                                    // Action buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 56,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: primaryColor,
                                                width: 2,
                                              ),
                                            ),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                _thuNhapController.clear();
                                                _luongDongBHController.clear();
                                                _nguoiPhuThuocController
                                                    .clear();
                                                setState(() {
                                                  thuNhap = 0;
                                                  luongDongBH = 0;
                                                  nguoiPhuThuoc = 0;
                                                  trichNopBH = 0;
                                                  giamTruNguoiPhuThuoc = 0;
                                                  thuNhapTinhThue = 0;
                                                  thuePhaiDong = 0;
                                                  thuNhapSauThue = 0;
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                foregroundColor: primaryColor,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: const Text(
                                                "NHẬP LẠI",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Container(
                                            height: 56,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              gradient: LinearGradient(
                                                colors: [
                                                  primaryColor,
                                                  primaryColor.withOpacity(0.8),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: primaryColor
                                                      .withOpacity(0.4),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton(
                                              onPressed: _tinhToan,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.calculate),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "TÍNH",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Results section
                          if (thuNhap > 0) _buildResultsCard(),

                          const SizedBox(height: 30),
                        ],
                      ),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String suffix,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: "Nhập ${label.toLowerCase()}",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: primaryColor.withOpacity(0.5)),
                ),
                style: TextStyle(
                  fontSize: 18,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
                onTap: () => controller.clear(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập $label';
                  }
                  return null;
                },
                onChanged: onChanged,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                suffix,
                style: TextStyle(
                  fontSize: 14,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Container(
          height: 1,
          margin: const EdgeInsets.only(top: 8),
          color: primaryColor.withOpacity(0.2),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: "Nhập ${label.toLowerCase()}",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: primaryColor.withOpacity(0.5)),
                ),
                style: TextStyle(
                  fontSize: 18,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
                onTap: () => controller.clear(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập $label';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Phải là số nguyên hợp lệ';
                  }
                  return null;
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                suffix,
                style: TextStyle(
                  fontSize: 14,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Container(
          height: 1,
          margin: const EdgeInsets.only(top: 8),
          color: primaryColor.withOpacity(0.2),
        ),
      ],
    );
  }

  Widget _buildResultsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.assessment, color: primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  'Kết quả tính toán',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.3)],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(height: 20),
            _buildResultItem("Thu nhập", thuNhap, Colors.green),
            _buildResultItem("Lương đóng BH", luongDongBH, Colors.orange),
            _buildResultItem("Trích nộp BH (10.5%)", trichNopBH, Colors.red),
            _buildDivider(),
            _buildResultItem("Giảm trừ bản thân", 11000000, Colors.blue),
            _buildResultItem(
              "Giảm trừ người phụ thuộc",
              giamTruNguoiPhuThuoc,
              Colors.blue,
            ),
            _buildDivider(),
            _buildResultItem(
              "Thu nhập tính thuế",
              thuNhapTinhThue,
              Colors.purple,
            ),
            _buildResultItem("Thuế phải đóng", thuePhaiDong, Colors.red),
            _buildDivider(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.1),
                    primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildResultItem(
                "Thu nhập sau thuế",
                thuNhapSauThue,
                primaryColor,
                isHighlight: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(
    String label,
    double value,
    Color color, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHighlight ? 18 : 16,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            "${_currencyFormatter.format(value)} đ",
            style: TextStyle(
              fontSize: isHighlight ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.grey[300],
    );
  }
}
