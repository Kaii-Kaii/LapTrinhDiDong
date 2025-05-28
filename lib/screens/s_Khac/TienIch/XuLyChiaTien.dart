import 'package:flutter/material.dart';

class CachChiaScreen extends StatefulWidget {
  final double tongTien;
  final int soThanhVien;

  const CachChiaScreen({
    Key? key,
    required this.tongTien,
    required this.soThanhVien,
  }) : super(key: key);

  @override
  _CachChiaScreenState createState() => _CachChiaScreenState();
}

class _CachChiaScreenState extends State<CachChiaScreen> {
  int selectedTab =
      0; // 0: Chia đều, 1: Chia theo phần trăm, 2: Chia chênh lệch
  List<double> chiaTien = [];
  List<double> phanTram = [];
  List<double> chenhLech = [];

  @override
  void initState() {
    super.initState();
    _initChiaTien();
  }

  void _initChiaTien() {
    chiaTien = List.filled(
      widget.soThanhVien,
      widget.tongTien / widget.soThanhVien,
    );
    phanTram = List.filled(widget.soThanhVien, 100 / widget.soThanhVien);
    chenhLech = List.filled(widget.soThanhVien, 0);
  }

  void _reset() {
    setState(() {
      _initChiaTien();
    });
  }

  void _updateChenhLech(int index, double value) {
    setState(() {
      chenhLech[index] = value;
      double tongChenhLech = chenhLech.reduce((a, b) => a + b);
      double chiaTrungBinh =
          (widget.tongTien - tongChenhLech) / widget.soThanhVien;

      for (int i = 0; i < widget.soThanhVien; i++) {
        chiaTien[i] = chiaTrungBinh + chenhLech[i];
      }
    });
  }

  void _updatePhanTram(int index, double value) {
    setState(() {
      phanTram[index] = value;
      double tongPhanTram = phanTram.reduce((a, b) => a + b);

      // Điều chỉnh phần trăm còn lại cho các thành viên khác
      if (tongPhanTram > 100) {
        double phanTramConLai = 100 - value;
        for (int i = 0; i < widget.soThanhVien; i++) {
          if (i != index) {
            phanTram[i] = phanTramConLai / (widget.soThanhVien - 1);
          }
        }
      }

      // Cập nhật số tiền dựa trên phần trăm
      for (int i = 0; i < widget.soThanhVien; i++) {
        chiaTien[i] = (phanTram[i] / 100) * widget.tongTien;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cách chia"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reset),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              // Ví dụ: Hiển thị kết quả chia tiền
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Kết quả chia tiền"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(widget.soThanhVien, (i) {
                        return Text(
                          "Thành viên ${i + 1}: ${chiaTien[i].toStringAsFixed(2)}",
                        );
                      }),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Đóng"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTabButton("=", 0),
              _buildTabButton("%", 1),
              _buildTabButton("+/-", 2),
            ],
          ),
          const SizedBox(height: 16),

          // Tổng tiền
          Text(
            "Tổng tiền: ${widget.tongTien.toStringAsFixed(0)}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Nội dung theo tab
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child:
                  selectedTab == 0
                      ? _buildChiaDeu()
                      : selectedTab == 1
                      ? _buildChiaTheoPhanTram()
                      : _buildChiaChenhLech(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: selectedTab == index ? Colors.blue : Colors.grey,
            ),
          ),
          if (selectedTab == index)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 40,
              color: Colors.blue,
            ),
        ],
      ),
    );
  }

  Widget _buildChiaDeu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "CHIA ĐỀU",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        for (int i = 0; i < widget.soThanhVien; i++)
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Text((i + 1).toString()),
            ),
            title: Text("Thành viên ${i + 1}"),
            trailing: Text(
              chiaTien[i].toStringAsFixed(2),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildChiaTheoPhanTram() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "CHIA THEO PHẦN TRĂM",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        for (int i = 0; i < widget.soThanhVien; i++)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orangeAccent,
                    child: Text((i + 1).toString()),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "Thành viên ${i + 1}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: TextEditingController(
                        text: phanTram[i].toStringAsFixed(2),
                      ),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        suffixText: "%",
                      ),
                      onChanged: (value) {
                        _updatePhanTram(i, double.tryParse(value) ?? 0);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${chiaTien[i].toStringAsFixed(2)} đ",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChiaChenhLech() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "CHIA CHÊNH LỆCH",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        for (int i = 0; i < widget.soThanhVien; i++)
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.yellowAccent,
              child: Text((i + 1).toString()),
            ),
            title: Text("Thành viên ${i + 1}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 60,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "+/-",
                    ),
                    onChanged: (value) {
                      _updateChenhLech(i, double.tryParse(value) ?? 0);
                    },
                  ),
                ),
                Text(
                  "${chiaTien[i].toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
