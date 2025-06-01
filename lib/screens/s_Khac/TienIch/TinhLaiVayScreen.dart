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
        const SnackBar(
          content: Text("Vui lòng nhập đầy đủ và chính xác thông tin"),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Tính toán khoản vay",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Số tiền
              _buildInputCard(
                title: "Số tiền",
                child: TextField(
                  controller: soTienController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Nhập số tiền",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.blue[200]),
                  ),
                  style: const TextStyle(fontSize: 24, color: Colors.blue),
                  onChanged: (value) {
                    String newValue = value
                        .replaceAll('.', '')
                        .replaceAll(',', '');
                    if (newValue.isEmpty) return;
                    final number = int.tryParse(newValue);
                    if (number == null) return;
                    final formatted = currencyFormatter.format(number);
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

              // Lãi suất tiền vay
              _buildInputCard(
                title: "Lãi suất tiền vay",
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: laiSuatController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Nhập lãi suất",
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.blue[200]),
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "%/năm",
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Kỳ hạn
              _buildInputCard(
                title: "Kỳ hạn",
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: kyHanController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Nhập kỳ hạn",
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.blue[200]),
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "tháng",
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Trả lãi theo
              _buildInputCard(
                title: "Trả lãi theo",
                child: DropdownButtonFormField<String>(
                  value: traLaiTheo,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  dropdownColor: Colors.white,
                  iconEnabledColor: Colors.blue,
                  style: const TextStyle(color: Colors.blue, fontSize: 18),
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
                            style: const TextStyle(color: Colors.blue),
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

              // Ngày
              _buildInputCard(
                title: "Ngày",
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blue),
                  title: Text(
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                    style: const TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                  onTap: () => _selectDate(context),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  Expanded(
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
                        backgroundColor: Colors.blue[50],
                        foregroundColor: Colors.blue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.blue),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "NHẬP LẠI",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _tinhToan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "TÍNH TOÁN",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({required String title, required Widget child}) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue[50]!, width: 2),
      ),
      shadowColor: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
