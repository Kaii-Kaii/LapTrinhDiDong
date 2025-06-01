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
  List<double> chiaTien = [];
  List<double> phanTram = [];
  List<bool> phanTramDaNhap = [];
  List<bool> tienDaNhap = []; // Thêm vào danh sách biến của class
  List<TextEditingController> phanTramControllers = [];
  List<TextEditingController> tienControllers = [];
  String _cheDoChia = "Chia theo %";

  @override
  void initState() {
    super.initState();
    _initChiaTien();
    phanTramControllers = List.generate(
      widget.soThanhVien,
      (index) =>
          TextEditingController(text: phanTram[index].toStringAsFixed(2)),
    );
    tienControllers = List.generate(
      widget.soThanhVien,
      (index) =>
          TextEditingController(text: chiaTien[index].toStringAsFixed(2)),
    );
  }

  void _initChiaTien() {
    chiaTien = List.filled(
      widget.soThanhVien,
      widget.tongTien / widget.soThanhVien,
    );
    phanTram = List.filled(widget.soThanhVien, 100 / widget.soThanhVien);
    phanTramDaNhap = List.filled(widget.soThanhVien, false);
    tienDaNhap = List.filled(widget.soThanhVien, false);
  }

  void _reset() {
    setState(() {
      _initChiaTien();
      for (int i = 0; i < widget.soThanhVien; i++) {
        phanTramControllers[i].text = phanTram[i].toStringAsFixed(2);
        tienControllers[i].text = chiaTien[i].toStringAsFixed(2);
      }
    });
  }

  void _updatePhanTram(int index, double value) {
    setState(() {
      phanTramDaNhap[index] = true;
      phanTram[index] = value;

      double tongDaNhap = 0;
      int chuaNhapCount = 0;

      for (int i = 0; i < widget.soThanhVien; i++) {
        if (phanTramDaNhap[i]) {
          tongDaNhap += phanTram[i];
        } else {
          chuaNhapCount++;
        }
      }

      double phanTramConLai = 100 - tongDaNhap;
      for (int i = 0; i < widget.soThanhVien; i++) {
        if (!phanTramDaNhap[i]) {
          phanTram[i] = chuaNhapCount > 0 ? phanTramConLai / chuaNhapCount : 0;
          phanTramControllers[i].text = phanTram[i].toStringAsFixed(2);
        }
      }

      for (int i = 0; i < widget.soThanhVien; i++) {
        chiaTien[i] = (phanTram[i] / 100) * widget.tongTien;
      }
    });
  }

  void _updateTien(int index, double value) {
    setState(() {
      tienDaNhap[index] = true;
      chiaTien[index] = value;

      // Tính tổng tiền đã nhập
      double tongDaNhap = 0;
      int chuaNhapCount = 0;

      for (int i = 0; i < widget.soThanhVien; i++) {
        if (tienDaNhap[i]) {
          tongDaNhap += chiaTien[i];
        } else {
          chuaNhapCount++;
        }
      }

      // Kiểm tra nếu tổng tiền đã nhập vượt quá tổng tiền
      if (tongDaNhap > widget.tongTien) {
        _reset();
        return;
      }

      // Phân bổ số tiền còn lại cho các thành viên chưa nhập
      double tienConLai = widget.tongTien - tongDaNhap;
      for (int i = 0; i < widget.soThanhVien; i++) {
        if (!tienDaNhap[i]) {
          chiaTien[i] = chuaNhapCount > 0 ? tienConLai / chuaNhapCount : 0;
          tienControllers[i].text = chiaTien[i].toStringAsFixed(2);
        }
      }

      // Cập nhật phần trăm cho tất cả thành viên
      for (int i = 0; i < widget.soThanhVien; i++) {
        phanTram[i] = (chiaTien[i] / widget.tongTien) * 100;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe3f2fd),
      appBar: AppBar(
        title: const Text("Chọn chế độ chia tiền"),
        backgroundColor: const Color(0xFF1976d2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reset),
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(
                          color: Color(0xFF1976d2),
                          width: 2,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      title: Row(
                        children: const [
                          Icon(Icons.check_circle, color: Color(0xFF1976d2)),
                          SizedBox(width: 8),
                          Text(
                            "Kết quả chia tiền",
                            style: TextStyle(
                              color: Color(0xFF1976d2),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      content: SizedBox(
                        width: 300,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: widget.soThanhVien,
                          separatorBuilder: (_, __) => const Divider(height: 8),
                          itemBuilder: (context, i) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF1976d2),
                                child: Text(
                                  "${i + 1}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                "Thành viên ${i + 1}",
                                style: const TextStyle(
                                  color: Color(0xFF1976d2),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "${chiaTien[i].toStringAsFixed(2)} đ  (${phanTram[i].toStringAsFixed(2)}%)",
                                style: const TextStyle(
                                  color: Color(0xFF1976d2),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF1976d2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Đóng"),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              "Tổng tiền: ${widget.tongTien.toStringAsFixed(0)} đ",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976d2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _cheDoChia = "Chia theo %";
                        _reset();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _cheDoChia == "Chia theo %"
                              ? const Color(0xFF1976d2)
                              : Colors.white,
                      foregroundColor:
                          _cheDoChia == "Chia theo %"
                              ? Colors.white
                              : const Color(0xFF1976d2),
                      side: const BorderSide(
                        color: Color(0xFF90caf9),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      "Chia theo %",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _cheDoChia = "Chia đều";
                        _reset();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _cheDoChia == "Chia đều"
                              ? const Color(0xFF1976d2)
                              : Colors.white,
                      foregroundColor:
                          _cheDoChia == "Chia đều"
                              ? Colors.white
                              : const Color(0xFF1976d2),
                      side: const BorderSide(
                        color: Color(0xFF90caf9),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      "Chia đều",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _cheDoChia = "Chia theo số tiền";
                        _reset();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _cheDoChia == "Chia theo số tiền"
                              ? const Color(0xFF1976d2)
                              : Colors.white,
                      foregroundColor:
                          _cheDoChia == "Chia theo số tiền"
                              ? Colors.white
                              : const Color(0xFF1976d2),
                      side: const BorderSide(
                        color: Color(0xFF90caf9),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      "Chia theo số tiền",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_cheDoChia == "Chia theo %")
              Expanded(
                child: ListView.builder(
                  itemCount: widget.soThanhVien,
                  itemBuilder: (context, i) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 4,
                      ),
                      elevation: 3,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFF90caf9)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFF1976d2),
                              child: Text(
                                (i + 1).toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Thành viên ${i + 1}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF1976d2),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${chiaTien[i].toStringAsFixed(2)} đ",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1976d2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 70,
                              child: TextField(
                                controller: phanTramControllers[i],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText: "%",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF90caf9),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF1976d2),
                                      width: 2,
                                    ),
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 8,
                                  ),
                                  fillColor: const Color(0xFFe3f2fd),
                                  filled: true,
                                ),
                                onTap: () {
                                  phanTramControllers[i]
                                      .selection = TextSelection(
                                    baseOffset: 0,
                                    extentOffset:
                                        phanTramControllers[i].text.length,
                                  );
                                },
                                onChanged: (value) {
                                  double newVal = double.tryParse(value) ?? 0;
                                  if (newVal < 0) newVal = 0;
                                  if (newVal > 100) newVal = 100;
                                  _updatePhanTram(i, newVal);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            else if (_cheDoChia == "Chia đều")
              Expanded(
                child: ListView.builder(
                  itemCount: widget.soThanhVien,
                  itemBuilder: (context, i) {
                    double tienMoiNguoi = widget.tongTien / widget.soThanhVien;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 4,
                      ),
                      elevation: 3,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFF90caf9)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFF1976d2),
                              child: Text(
                                (i + 1).toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Thành viên ${i + 1}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF1976d2),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${tienMoiNguoi.toStringAsFixed(2)} đ",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1976d2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            else if (_cheDoChia == "Chia theo số tiền")
              Expanded(
                child: ListView.builder(
                  itemCount: widget.soThanhVien,
                  itemBuilder: (context, i) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 4,
                      ),
                      elevation: 3,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFF90caf9)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFF1976d2),
                              child: Text(
                                (i + 1).toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Thành viên ${i + 1}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF1976d2),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${phanTram[i].toStringAsFixed(2)}%",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1976d2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: TextField(
                                controller: tienControllers[i],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText: "Số tiền",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF90caf9),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF1976d2),
                                      width: 2,
                                    ),
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  fillColor: const Color(0xFFe3f2fd),
                                  filled: true,
                                ),
                                onTap: () {
                                  tienControllers[i].selection = TextSelection(
                                    baseOffset: 0,
                                    extentOffset:
                                        tienControllers[i].text.length,
                                  );
                                },
                                onChanged: (value) {
                                  double newVal = double.tryParse(value) ?? 0;
                                  if (newVal < 0) newVal = 0;
                                  if (newVal > widget.tongTien) {
                                    newVal = widget.tongTien;
                                  }
                                  _updateTien(i, newVal);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in phanTramControllers) {
      controller.dispose();
    }
    for (var controller in tienControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
