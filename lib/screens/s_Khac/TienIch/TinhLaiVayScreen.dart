import 'dart:ffi';
import 'dart:math';
import 'package:flutter/material.dart';
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
  String traLaiTheo = "Dư nợ thực tế"; // Giá trị mặc định

  @override
  void initState() {
    super.initState();
    soTienController.text = ""; // Giá trị mặc định
    laiSuatController.text = ""; // Giá trị mặc định
    kyHanController.text = ""; // Giá trị mặc định
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
    final double soTien = double.tryParse(soTienController.text) ?? 0;
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

    // Điều hướng đến màn hình danh sách trả lãi
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
      appBar: AppBar(
        title: const Text("Tính toán khoản vay"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Số tiền
              _buildInputCard(
                title: "Số tiền",
                child: TextField(
                  controller: soTienController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Nhập số tiền",
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 24, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 16),

              // Lãi suất tiền vay
              _buildInputCard(
                title: "Lãi suất tiền vay",
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: laiSuatController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Nhập lãi suất",
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text("%/năm", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Kỳ hạn
              _buildInputCard(
                title: "Kỳ hạn",
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: kyHanController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Nhập kỳ hạn",
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text("tháng", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Trả lãi theo
              _buildInputCard(
                title: "Trả lãi theo",
                child: DropdownButton<String>(
                  value: traLaiTheo,
                  isExpanded: true,
                  items:
                      [
                        "Dư nợ thực tế",
                        "Dư nợ ban đầu",
                        "Niên kim cố định",
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      traLaiTheo = newValue!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Ngày
              _buildInputCard(
                title: "Ngày",
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blue),
                  title: Text(
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: () => _selectDate(context),
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
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("NHẬP LẠI"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _tinhToan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("TÍNH TOÁN"),
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
