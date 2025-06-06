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
  List<bool> tienDaNhap = [];
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

      double tongDaNhap = 0;
      int chuaNhapCount = 0;

      for (int i = 0; i < widget.soThanhVien; i++) {
        if (tienDaNhap[i]) {
          tongDaNhap += chiaTien[i];
        } else {
          chuaNhapCount++;
        }
      }

      if (tongDaNhap > widget.tongTien) {
        _reset();
        return;
      }

      double tienConLai = widget.tongTien - tongDaNhap;
      for (int i = 0; i < widget.soThanhVien; i++) {
        if (!tienDaNhap[i]) {
          chiaTien[i] = chuaNhapCount > 0 ? tienConLai / chuaNhapCount : 0;
          tienControllers[i].text = chiaTien[i].toStringAsFixed(2);
        }
      }

      for (int i = 0; i < widget.soThanhVien; i++) {
        phanTram[i] = (chiaTien[i] / widget.tongTien) * 100;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF03A9F4), Color(0xFF0288D1), Color(0xFF0277BD)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        "Chọn chế độ chia tiền",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            onPressed: _reset,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.check, color: Colors.white),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      backgroundColor: Colors.white,
                                      title: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF03A9F4),
                                              Color(0xFF0288D1),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: const [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Kết quả chia tiền",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      content: Container(
                                        width: 300,
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          itemCount: widget.soThanhVien,
                                          separatorBuilder:
                                              (_, __) =>
                                                  const Divider(height: 16),
                                          itemBuilder: (context, i) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF03A9F4,
                                                ).withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: ListTile(
                                                leading: Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                              colors: [
                                                                Color(
                                                                  0xFF03A9F4,
                                                                ),
                                                                Color(
                                                                  0xFF0288D1,
                                                                ),
                                                              ],
                                                            ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: Text(
                                                    "${i + 1}",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                title: Text(
                                                  "Thành viên ${i + 1}",
                                                  style: const TextStyle(
                                                    color: Color(0xFF03A9F4),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  "${chiaTien[i].toStringAsFixed(2)} đ  (${phanTram[i].toStringAsFixed(2)}%)",
                                                  style: const TextStyle(
                                                    color: Color(0xFF0288D1),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      actions: [
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF03A9F4),
                                                Color(0xFF0288D1),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: const Text(
                                              "Đóng",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tổng tiền header
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Tổng tiền: ${widget.tongTien.toStringAsFixed(0)} đ",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Mode selection buttons
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: _buildModeButton("Chia theo %")),
                    const SizedBox(width: 8),
                    Expanded(child: _buildModeButton("Chia đều")),
                    const SizedBox(width: 8),
                    Expanded(child: _buildModeButton("Chia theo số tiền")),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Main content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FFFE),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFF03A9F4).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Content based on mode
                      Expanded(child: _buildModeContent()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(String mode) {
    bool isSelected = _cheDoChia == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _cheDoChia = mode;
          _reset();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border:
              isSelected
                  ? null
                  : Border.all(color: Colors.white.withOpacity(0.5)),
        ),
        child: Text(
          mode,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? const Color(0xFF03A9F4) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildModeContent() {
    if (_cheDoChia == "Chia theo %") {
      return _buildPercentageMode();
    } else if (_cheDoChia == "Chia đều") {
      return _buildEqualMode();
    } else {
      return _buildAmountMode();
    }
  }

  Widget _buildPercentageMode() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.soThanhVien,
      itemBuilder: (context, i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF03A9F4).withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF03A9F4), Color(0xFF0288D1)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (i + 1).toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Thành viên ${i + 1}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${chiaTien[i].toStringAsFixed(2)} đ",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF03A9F4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF03A9F4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: phanTramControllers[i],
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      suffixText: "%",
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF03A9F4),
                      fontWeight: FontWeight.bold,
                    ),
                    onTap: () {
                      phanTramControllers[i].selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: phanTramControllers[i].text.length,
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
    );
  }

  Widget _buildEqualMode() {
    double tienMoiNguoi = widget.tongTien / widget.soThanhVien;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.soThanhVien,
      itemBuilder: (context, i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF03A9F4).withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF03A9F4), Color(0xFF0288D1)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (i + 1).toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Thành viên ${i + 1}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${tienMoiNguoi.toStringAsFixed(2)} đ",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF03A9F4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF03A9F4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.balance, color: Color(0xFF03A9F4)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountMode() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.soThanhVien,
      itemBuilder: (context, i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF03A9F4).withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF03A9F4), Color(0xFF0288D1)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (i + 1).toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Thành viên ${i + 1}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${phanTram[i].toStringAsFixed(2)}%",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF03A9F4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF03A9F4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: tienControllers[i],
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Số tiền",
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF03A9F4),
                      fontWeight: FontWeight.bold,
                    ),
                    onTap: () {
                      tienControllers[i].selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: tienControllers[i].text.length,
                      );
                    },
                    onChanged: (value) {
                      double newVal = double.tryParse(value) ?? 0;
                      if (newVal < 0) newVal = 0;
                      if (newVal > widget.tongTien) newVal = widget.tongTien;
                      _updateTien(i, newVal);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
