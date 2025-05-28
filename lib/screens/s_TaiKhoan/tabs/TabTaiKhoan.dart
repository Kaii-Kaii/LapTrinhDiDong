import 'package:flutter/material.dart';
import 'package:qltncn/model/Vi/Vi/Vi.dart';
import 'package:qltncn/model/Vi/ViNguoiDung/ViNguoiDung.dart';
import 'package:qltncn/model/Vi/ViNguoiDung/ViNguoiDung_service.dart';
import 'package:qltncn/screens/s_TaiKhoan/s_TaiKhoan_Khac/ChiTietViScreen.dart';
import 'package:qltncn/widget/vi_utils.dart';

class TabTaiKhoan extends StatefulWidget {
  final String maKH;

  const TabTaiKhoan({super.key, required this.maKH});

  @override
  State<TabTaiKhoan> createState() => _TabTaiKhoanState();
}

class _TabTaiKhoanState extends State<TabTaiKhoan> {
  List<ViNguoiDung> danhSachVi = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDanhSachVi();
  }

  Future<void> _loadDanhSachVi() async {
    final data = await ViNguoiDungService.fetchViNguoiDungByMaKhachHang(widget.maKH);
    setState(() {
      danhSachVi = data;
      isLoading = false;
    });
  }

  double get tongSoDu => danhSachVi.fold(0.0, (sum, vi) => sum + vi.soDu);

  void _handleMenuAction(String action, ViNguoiDung vi) {
    switch (action) {
      case 'chi_tiet':
        _showDialogChiTietVi(vi);
      break;
      case 'dieu_chinh':
        _showDialogDieuChinhSoDu(vi);
        break;
      case 'sua':
        _showDialogSuaVi(vi);
        break;
      case 'xoa':
        // TODO: xử lý xóa tài khoản
        break;

    }
  }
  


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng tiền:', style: TextStyle(fontSize: 16)),
              Text('${tongSoDu.toStringAsFixed(0)} đ',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            children: [
              ExpansionTile(
                title: Text(
                  'Đang sử dụng (${tongSoDu.toStringAsFixed(0)} đ)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: danhSachVi.map((viNguoiDung) {
                  final viMau = tinhNangList.firstWhere(
                    (vi) => vi.maVi == viNguoiDung.maVi,
                    orElse: () => Vi(maVi: 0, tenVi: '', loaiVi: '', iconVi: ''),
                  );

                  final color = getColorForLoaiVi(viMau.maVi ?? 0);
                  final iconWidget = getIconWidget(viMau.iconVi ?? '');

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color,
                      child: iconWidget,
                    ),
                    title: Text(viNguoiDung.tenTaiKhoan),
                    subtitle: Text('${viNguoiDung.soDu.toStringAsFixed(0)} đ'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(value, viNguoiDung),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'chi_tiet',
                          child: ListTile(
                            leading: Icon(Icons.account_balance),
                            title: Text('Chi tiêt ví'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'dieu_chinh',
                          child: ListTile(
                            leading: Icon(Icons.tune),
                            title: Text('Điều chỉnh số dư'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'sua',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Sửa'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'xoa',
                          child: ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Xóa'),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
  void _showDialogDieuChinhSoDu(ViNguoiDung viNguoiDung) {
  final TextEditingController controller = TextEditingController(text: viNguoiDung.soDu.toString());

  showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Điều chỉnh số dư',
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Số dư mới',
            labelStyle: const TextStyle(color: Colors.blue),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blueAccent),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: const Icon(Icons.account_balance_wallet, color: Colors.blueAccent),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () async {
              final newSoDu = double.tryParse(controller.text);
              if (newSoDu == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Số dư không hợp lệ')),
                );
                return;
              }

              // Tạo đối tượng cập nhật toàn bộ, nhưng chỉ thay đổi số dư mới nhập,
              // các trường còn lại giữ nguyên giá trị cũ.
              ViNguoiDung viCapNhat = ViNguoiDung(
                maNguoiDung: viNguoiDung.maNguoiDung,
                maVi: viNguoiDung.maVi,
                tenTaiKhoan: viNguoiDung.tenTaiKhoan,
                maLoaiTien: viNguoiDung.maLoaiTien,
                dienGiai: viNguoiDung.dienGiai,
                soDu: newSoDu,  // thay đổi số dư mới
              );

              bool success = await ViNguoiDungService.capNhatViNguoiDungFull(
                  maNguoiDung: viCapNhat.maNguoiDung,
                  maVi: viCapNhat.maVi!,
                  tenTaiKhoanCu: viCapNhat.tenTaiKhoan,  // tên ví cũ để tìm ví
                  viNguoiDungMoi: viCapNhat,
                );

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Cập nhật số dư thành công')),
                );
                Navigator.pop(context);
                if (mounted) _loadDanhSachVi();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Cập nhật số dư thất bại')),
                );
              }
            },
            child: const Text(
              'Lưu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showDialogChiTietVi(ViNguoiDung viNguoiDung) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        title: const Text(
          'Chi tiết ví',
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        content: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7, // làm to dialog
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Tên ví:', viNguoiDung.tenTaiKhoan),
                const SizedBox(height: 15),
                _buildDetailRow('Diễn giải:', viNguoiDung.dienGiai ?? 'Không có'),
                const SizedBox(height: 15),
                _buildDetailRow('Số dư:', '${viNguoiDung.soDu.toStringAsFixed(0)} đ'),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Đóng',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label + ' ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
              fontSize: 18,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
  void _showDialogSuaVi(ViNguoiDung viNguoiDung) {
    final _formKey = GlobalKey<FormState>();

    final TextEditingController tenTaiKhoanController =
        TextEditingController(text: viNguoiDung.tenTaiKhoan);
    final TextEditingController dienGiaiController =
        TextEditingController(text: viNguoiDung.dienGiai ?? '');
    final TextEditingController soDuController =
        TextEditingController(text: viNguoiDung.soDu.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        title: const Text(
          'Sửa thông tin ví',
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: tenTaiKhoanController,
                  decoration: const InputDecoration(labelText: 'Tên ví'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tên ví không được để trống';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: dienGiaiController,
                  decoration: const InputDecoration(labelText: 'Diễn giải'),
                ),
                TextFormField(
                  controller: soDuController,
                  decoration: const InputDecoration(labelText: 'Số dư'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Số dư không được để trống';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Số dư phải là số';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (viNguoiDung.maVi == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mã ví không hợp lệ.')),
                  );
                  return;
                }

                bool isTrung = await ViNguoiDungService.kiemTraTenViTrung(
                  maNguoiDung: viNguoiDung.maNguoiDung,
                  tenTaiKhoan: tenTaiKhoanController.text.trim(),
                  maViKhongTinh: viNguoiDung.maVi!,
                );
                if (isTrung) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ Tên ví đã tồn tại cho loại tiền này. Vui lòng chọn tên khác hoặc đổi loại tiền.')),
                  );
                  return;
                }
                // Tiếp tục cập nhật
                ViNguoiDung viCapNhat = ViNguoiDung(
                  maNguoiDung: viNguoiDung.maNguoiDung,
                  maVi: viNguoiDung.maVi,
                  tenTaiKhoan: tenTaiKhoanController.text.trim(),
                  dienGiai: dienGiaiController.text.trim(),
                  soDu: double.parse(soDuController.text.trim()),
                  maLoaiTien: viNguoiDung.maLoaiTien,
                );
                bool success = await ViNguoiDungService.capNhatViNguoiDungFull(
                  maNguoiDung: viNguoiDung.maNguoiDung.trim(),
                  maVi: viNguoiDung.maVi!,
                  tenTaiKhoanCu: viNguoiDung.tenTaiKhoan,  // tên cũ
                  viNguoiDungMoi: ViNguoiDung(
                    maNguoiDung: viNguoiDung.maNguoiDung,
                    maVi: viNguoiDung.maVi,
                    tenTaiKhoan: tenTaiKhoanController.text.trim(), // tên mới
                    dienGiai: dienGiaiController.text.trim(),
                    soDu: double.parse(soDuController.text.trim()),
                    maLoaiTien: viNguoiDung.maLoaiTien,
                  ),
                );

                if (success) {
                  if (mounted) {
                    setState(() {
                      viNguoiDung.tenTaiKhoan = viCapNhat.tenTaiKhoan;
                      viNguoiDung.dienGiai = viCapNhat.dienGiai;
                      viNguoiDung.soDu = viCapNhat.soDu;
                    });
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Cập nhật ví thành công')),
                  );
                  Navigator.pop(context);
                  if (mounted) _loadDanhSachVi();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ Cập nhật ví thất bại')),
                  );
                }
              }
            },
            child: const Text('Lưu'),
          ),

        ],
      ),
    );
  }


}
