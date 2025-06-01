import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qltncn/model/LoaiTien/LoaiTien.dart';
import 'package:qltncn/model/Vi/Vi/ViModel.dart';
import 'package:qltncn/model/Vi/ViNguoiDung/ViNguoiDung.dart';
import 'package:qltncn/model/Vi/ViNguoiDung/ViNguoiDung_service.dart';

class ThemTaiKhoanScreen extends StatefulWidget {
  final String maKH;
  final VoidCallback? onAccountAdded; // Thêm callback

  const ThemTaiKhoanScreen({
    super.key,
    required this.maKH,
    this.onAccountAdded,
  });

  @override
  State<ThemTaiKhoanScreen> createState() => _ThemTaiKhoanScreenState();
}

class _ThemTaiKhoanScreenState extends State<ThemTaiKhoanScreen> {
  final TextEditingController soDuController = TextEditingController();
  final TextEditingController tenTaiKhoanController = TextEditingController();
  final TextEditingController dienGiaiController = TextEditingController();

  int maViChon = 1;
  LoaiTien loaiTien = danhSachLoaiTien[0];

  final List<ViModel> danhSachVi = [
    ViModel(
      maVi: 1,
      ten: 'Tiền mặt',
      icon: Icons.account_balance_wallet,
      iconColor: Colors.orange,
    ),
    ViModel(
      maVi: 2,
      ten: 'Tài khoản ngân hàng',
      icon: Icons.account_balance,
      iconColor: Colors.red,
    ),
    ViModel(
      maVi: 3,
      ten: 'Thẻ tín dụng',
      icon: Icons.credit_card,
      iconColor: Colors.blue,
    ),
    ViModel(
      maVi: 4,
      ten: 'Tài khoản đầu tư',
      icon: Icons.show_chart,
      iconColor: Colors.green,
    ),
    ViModel(
      maVi: 5,
      ten: 'Ví điện tử',
      icon: Icons.phone_android,
      iconColor: Colors.deepOrange,
    ),
    ViModel(
      maVi: 6,
      ten: 'Khác',
      icon: Icons.attach_money,
      iconColor: Colors.brown,
    ),
  ];

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: "vi_VN",
    symbol: "",
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    soDuController.addListener(_formatSoDu);
  }

  @override
  void dispose() {
    soDuController.removeListener(_formatSoDu);
    soDuController.dispose();
    tenTaiKhoanController.dispose();
    dienGiaiController.dispose();
    super.dispose();
  }

  void _formatSoDu() {
    String text = soDuController.text.replaceAll('.', '').replaceAll(',', '');
    if (text.isEmpty) return;
    final value = double.tryParse(text);
    if (value == null) return;
    final newText = currencyFormat.format(value).trim();
    if (soDuController.text != newText) {
      soDuController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viDaChon = danhSachVi.firstWhere((vi) => vi.maVi == maViChon);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Thêm tài khoản'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.blue.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Số dư ban đầu',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: soDuController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              decoration: const InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              cursorColor: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 4),
                            child: Text(
                              loaiTien.kyHieu,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildInputCard(
                  child: TextField(
                    controller: tenTaiKhoanController,
                    decoration: const InputDecoration(
                      labelText: 'Tên tài khoản',
                      prefixIcon: Icon(Icons.account_balance_wallet),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _buildInputCard(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: viDaChon.iconColor.withOpacity(0.15),
                      child: Icon(viDaChon.icon, color: viDaChon.iconColor),
                    ),
                    title: Text(viDaChon.ten),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () async {
                      final int? maViMoi = await showModalBottomSheet<int>(
                        context: context,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                        ),
                        builder:
                            (context) => ListView(
                              shrinkWrap: true,
                              children:
                                  danhSachVi.map((vi) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: vi.iconColor
                                            .withOpacity(0.15),
                                        child: Icon(
                                          vi.icon,
                                          color: vi.iconColor,
                                        ),
                                      ),
                                      title: Text(vi.ten),
                                      onTap:
                                          () => Navigator.pop(context, vi.maVi),
                                    );
                                  }).toList(),
                            ),
                      );
                      if (maViMoi != null) {
                        setState(() => maViChon = maViMoi);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _buildInputCard(
                  child: ListTile(
                    leading: Text(
                      loaiTien.kyHieu,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    title: Text('${loaiTien.tenLoai} (${loaiTien.menhGia})'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () async {
                      final LoaiTien? loaiTienMoi =
                          await showModalBottomSheet<LoaiTien>(
                            context: context,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(18),
                              ),
                            ),
                            builder:
                                (context) => ListView(
                                  shrinkWrap: true,
                                  children:
                                      danhSachLoaiTien.map((lt) {
                                        return ListTile(
                                          leading: Text(
                                            lt.kyHieu,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                          title: Text(lt.tenLoai),
                                          subtitle: Text(lt.menhGia),
                                          onTap:
                                              () => Navigator.pop(context, lt),
                                        );
                                      }).toList(),
                                ),
                          );
                      if (loaiTienMoi != null) {
                        setState(() => loaiTien = loaiTienMoi);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _buildInputCard(
                  child: TextField(
                    controller: dienGiaiController,
                    decoration: const InputDecoration(
                      labelText: 'Diễn giải',
                      prefixIcon: Icon(Icons.notes),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                    ),
                    onPressed: _onSavePressed,
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade700, Colors.blue.shade400],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text(
                          'Lưu tài khoản',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade50,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.blue.shade50),
      ),
      child: child,
    );
  }

  Future<void> _onSavePressed() async {
    final tenTaiKhoan = tenTaiKhoanController.text.trim();
    final dienGiai = dienGiaiController.text.trim();
    final soDuStr = soDuController.text
        .trim()
        .replaceAll('.', '')
        .replaceAll(',', '');

    if (tenTaiKhoan.isEmpty || soDuStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    final danhSachViNguoiDung =
        await ViNguoiDungService.fetchViNguoiDungByMaKhachHang(widget.maKH);

    final trungVi = danhSachViNguoiDung.any(
      (vi) =>
          vi.tenTaiKhoan.trim().toLowerCase() == tenTaiKhoan.toLowerCase() &&
          vi.maVi == maViChon &&
          vi.maLoaiTien == (int.tryParse(loaiTien.maLoai.toString()) ?? 0),
    );

    if (trungVi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Đã tồn tại tài khoản với tên, loại ví và loại tiền này',
          ),
        ),
      );
      return;
    }

    final soDu = double.tryParse(soDuStr) ?? 0;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận dữ liệu'),
            content: const Text('Bạn có chắc chắn muốn thêm tài khoản này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Huỷ'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xác nhận'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    final viMoi = ViNguoiDung(
      maNguoiDung: widget.maKH,
      tenTaiKhoan: tenTaiKhoan,
      maLoaiTien: int.tryParse(loaiTien.maLoai.toString()) ?? 0,
      dienGiai: dienGiai,
      soDu: soDu,
      maVi: maViChon,
    );

    final success = await ViNguoiDungService.themViNguoiDung(viMoi);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Thêm tài khoản thành công'),
          backgroundColor: Colors.green,
        ),
      );

      // Gọi callback để reload trang chính ngay lập tức
      widget.onAccountAdded?.call();

      // Reset form để người dùng có thể thêm tài khoản khác
      _resetForm();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Thêm tài khoản thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetForm() {
    setState(() {
      soDuController.clear();
      tenTaiKhoanController.clear();
      dienGiaiController.clear();
      maViChon = 1;
      loaiTien = danhSachLoaiTien[0];
    });
  }
}
