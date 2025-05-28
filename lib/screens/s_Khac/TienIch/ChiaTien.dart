import 'package:flutter/material.dart';
import 'XuLyChiaTien.dart';

class ChiaTienScreen extends StatefulWidget {
  @override
  _ChiaTienScreenState createState() => _ChiaTienScreenState();
}

class _ChiaTienScreenState extends State<ChiaTienScreen> {
  final TextEditingController soTienController = TextEditingController();
  final TextEditingController soThanhVienController = TextEditingController();
  bool isThanhVienUngTruoc = false;
  List<Map<String, dynamic>> thanhVienUngTruoc = [];

  @override
  void initState() {
    super.initState();
    soTienController.text = "7000000"; // Giá trị mặc định
    soThanhVienController.text = "3"; // Giá trị mặc định
  }

  void _themThanhVienUngTruoc() {
    setState(() {
      thanhVienUngTruoc.add({"ten": "", "soTien": 0});
    });
  }

  void _xoaThanhVienUngTruoc(int index) {
    setState(() {
      thanhVienUngTruoc.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chia tiền"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                soTienController.text = "7000000";
                soThanhVienController.text = "3";
                isThanhVienUngTruoc = false;
                thanhVienUngTruoc.clear();
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                decoration: const InputDecoration(border: InputBorder.none),
                style: const TextStyle(fontSize: 24, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 16),

            // Số thành viên
            _buildInputCard(
              title: "Số thành viên",
              child: Row(
                children: [
                  const Icon(Icons.people, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: soThanhVienController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 24, color: Colors.blue),
                    ),
                  ),
                  const Icon(Icons.edit, color: Colors.blue),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Thành viên ứng trước
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Thành viên ứng trước",
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  value: isThanhVienUngTruoc,
                  onChanged: (value) {
                    setState(() {
                      isThanhVienUngTruoc = value;
                    });
                  },
                ),
              ],
            ),
            if (isThanhVienUngTruoc) ...[
              for (int i = 0; i < thanhVienUngTruoc.length; i++)
                _buildThanhVienUngTruocCard(i),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _themThanhVienUngTruoc,
                child: Row(
                  children: const [
                    Icon(Icons.add, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      "Thêm thành viên ứng trước",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Nút Chia tiền
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final double tongTien = double.tryParse(soTienController.text) ?? 0;
                  final int soThanhVien = int.tryParse(soThanhVienController.text) ?? 0;

                  if (tongTien > 0 && soThanhVien > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CachChiaScreen(
                          tongTien: tongTien,
                          soThanhVien: soThanhVien,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Vui lòng nhập số tiền và số thành viên hợp lệ!")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Chia tiền", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
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

  Widget _buildThanhVienUngTruocCard(int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => _xoaThanhVienUngTruoc(index),
            ),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "Nhập tên",
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  thanhVienUngTruoc[index]["ten"] = value;
                },
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: thanhVienUngTruoc[index]["soTien"],
              items:
                  List.generate(11, (i) => i * 1000000).map((value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  thanhVienUngTruoc[index]["soTien"] = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
