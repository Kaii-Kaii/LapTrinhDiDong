import 'package:flutter/material.dart';
import 'package:qltncn/model/Vi/Vi/Vi.dart';
import 'package:qltncn/model/Vi/ViNguoiDung/ViNguoiDung.dart';
import 'package:qltncn/model/Vi/ViNguoiDung/ViNguoiDung_service.dart';
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
      case 'chuyen_khoan':
        // TODO: xử lý chuyển khoản
        break;
      case 'dieu_chinh':
        // TODO: xử lý điều chỉnh số dư
        break;
      case 'chia_se':
        // TODO: xử lý chia sẻ tài khoản
        break;
      case 'sua':
        // TODO: xử lý sửa tài khoản
        break;
      case 'xoa':
        // TODO: xử lý xóa tài khoản
        break;
      case 'ngung_su_dung':
        // TODO: xử lý ngừng sử dụng
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
}
