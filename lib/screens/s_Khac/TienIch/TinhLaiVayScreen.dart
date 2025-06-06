import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'DanhSachTraLaiVayScreen.dart';

class TinhLaiVayScreen extends StatefulWidget {
  @override
  _TinhLaiVayScreenState createState() => _TinhLaiVayScreenState();
}

class _TinhLaiVayScreenState extends State<TinhLaiVayScreen> {
  final TextEditingController soTienController = TextEditingController();
  final TextEditingController laiSuatController = TextEditingController();
  final TextEditingController kyHanController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String traLaiTheo = "Dư nợ thực tế";

  final NumberFormat currencyFormatter = NumberFormat("#,##0", "vi_VN");
  final Color primaryColor = const Color(0xFF03A9F4);

  @override
  void initState() {
    super.initState();
    soTienController.text = "";
    laiSuatController.text = "";
    kyHanController.text = "";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _tinhToan() {
    final String soTienRaw = soTienController.text
        .replaceAll('.', '')
        .replaceAll(',', '');
    final double soTien = double.tryParse(soTienRaw) ?? 0;
    final double laiSuat = double.tryParse(laiSuatController.text) ?? 0;
    final int kyHan = int.tryParse(kyHanController.text) ?? 0;

    if (soTien <= 0 || laiSuat <= 0 || kyHan <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Vui lòng nhập đầy đủ và chính xác thông tin"),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final double laiSuatThang = laiSuat / 12 / 100;
    double duNoConLai = soTien;
    final List<Map<String, dynamic>> danhSachTraLai = [];

    if (traLaiTheo == "Dư nợ thực tế") {
      for (int i = 1; i <= kyHan; i++) {
        final double tienLai = duNoConLai * laiSuatThang;
        final double tienGoc = soTien / kyHan;
        final double tongTra = tienGoc + tienLai;

        danhSachTraLai.add({
          "kyHan": i,
          "tienGoc": tienGoc,
          "tienLai": tienLai,
          "tongTra": tongTra,
          "duNoConLai": duNoConLai - tienGoc,
          "ngayTra": DateTime(
            selectedDate.year,
            selectedDate.month + i,
            selectedDate.day,
          ),
        });

        duNoConLai -= tienGoc;
      }
    } else if (traLaiTheo == "Dư nợ ban đầu") {
      final double tienLai = soTien * laiSuatThang;
      final double tienGoc = soTien / kyHan;
      final double tongTra = tienGoc + tienLai;

      for (int i = 1; i <= kyHan; i++) {
        danhSachTraLai.add({
          "kyHan": i,
          "tienGoc": tienGoc,
          "tienLai": tienLai,
          "tongTra": tongTra,
          "duNoConLai": soTien - (tienGoc * i),
          "ngayTra": DateTime(
            selectedDate.year,
            selectedDate.month + i,
            selectedDate.day,
          ),
        });
      }
    } else if (traLaiTheo == "Niên kim cố định") {
      final double tongTraHangThang =
          (soTien * laiSuatThang) / (1 - pow(1 / (1 + laiSuatThang), kyHan));
      for (int i = 1; i <= kyHan; i++) {
        final double tienLai = duNoConLai * laiSuatThang;
        final double tienGoc = tongTraHangThang - tienLai;

        danhSachTraLai.add({
          "kyHan": i,
          "tienGoc": tienGoc,
          "tienLai": tienLai,
          "tongTra": tongTraHangThang,
          "duNoConLai": duNoConLai - tienGoc,
          "ngayTra": DateTime(
            selectedDate.year,
            selectedDate.month + i,
            selectedDate.day,
          ),
        });

        duNoConLai -= tienGoc;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => DanhSachTraLaiVayScreen(
              soTien: soTien,
              tongLai: danhSachTraLai.fold(
                0,
                (sum, item) => sum + item["tienLai"],
              ),
              tongTra: danhSachTraLai.fold(
                0,
                (sum, item) => sum + item["tongTra"],
              ),
              danhSachTraLai: danhSachTraLai,
            ),
      ),
    );
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
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background decorations
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              top: 100,
              left: -50,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 160,
                height: 160,
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
                              "Tính toán khoản vay",
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
                                    Icons.calculate,
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
                                        "Tính toán lãi vay",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Nhập thông tin để tính toán chi tiết",
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
                          _buildInputCard(
                            title: "Số tiền vay",
                            icon: Icons.attach_money,
                            child: TextField(
                              controller: soTienController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "Nhập số tiền cần vay",
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: primaryColor.withOpacity(0.5),
                                ),
                                suffixText: "VNĐ",
                                suffixStyle: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 18,
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                              onChanged: (value) {
                                String newValue = value
                                    .replaceAll('.', '')
                                    .replaceAll(',', '');
                                if (newValue.isEmpty) return;
                                final number = int.tryParse(newValue);
                                if (number == null) return;
                                final formatted = currencyFormatter.format(
                                  number,
                                );
                                soTienController.value = TextEditingValue(
                                  text: formatted,
                                  selection: TextSelection.collapsed(
                                    offset: formatted.length,
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          _buildInputCard(
                            title: "Lãi suất",
                            icon: Icons.percent,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: laiSuatController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: "Nhập lãi suất",
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                        color: primaryColor.withOpacity(0.5),
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "%/năm",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          _buildInputCard(
                            title: "Thời hạn vay",
                            icon: Icons.schedule,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: kyHanController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: "Nhập số tháng",
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                        color: primaryColor.withOpacity(0.5),
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "tháng",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          _buildInputCard(
                            title: "Phương thức trả lãi",
                            icon: Icons.payment,
                            child: DropdownButtonFormField<String>(
                              value: traLaiTheo,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              dropdownColor: Colors.white,
                              iconEnabledColor: primaryColor,
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              items:
                                  [
                                    "Dư nợ thực tế",
                                    "Dư nợ ban đầu",
                                    "Niên kim cố định",
                                  ].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(color: primaryColor),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  traLaiTheo = newValue!;
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          _buildInputCard(
                            title: "Ngày bắt đầu vay",
                            icon: Icons.calendar_today,
                            child: InkWell(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.event,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: primaryColor,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      soTienController.clear();
                                      laiSuatController.clear();
                                      kyHanController.clear();
                                      setState(() {
                                        selectedDate = DateTime.now();
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: primaryColor,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
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
                                    borderRadius: BorderRadius.circular(16),
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
                                        color: primaryColor.withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _tinhToan,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.calculate),
                                        SizedBox(width: 8),
                                        Text(
                                          "TÍNH TOÁN",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
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

  Widget _buildInputCard({
    required String title,
    required Widget child,
    required IconData icon,
  }) {
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
        padding: const EdgeInsets.all(20),
        child: Column(
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
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
