import 'package:flutter/material.dart';
import 'package:qltncn/model/LoaiTien/LoaiTien.dart';
import 'package:qltncn/model/Vi/Vi/ViModel.dart';
import 'package:qltncn/model/Vi/ViNguoiDung/ViNguoiDung.dart';
import 'package:qltncn/model/Vi/ViNguoiDung/ViNguoiDung_service.dart';
import 'package:qltncn/widget/vi_utils.dart';

class ThemTaiKhoanScreen extends StatefulWidget {
  final String maKH;
  const ThemTaiKhoanScreen({super.key, required this.maKH});

  @override
  State<ThemTaiKhoanScreen> createState() => _ThemTaiKhoanScreenState();
}

class _ThemTaiKhoanScreenState extends State<ThemTaiKhoanScreen> {
  final TextEditingController soDuController = TextEditingController();
  final TextEditingController tenTaiKhoanController = TextEditingController();
  final TextEditingController dienGiaiController = TextEditingController();

  bool khongTinhBaoCao = false;

  // Lưu mã ví được chọn thay vì tên ví
  int maViChon = 1; // Mặc định chọn mã ví = 1 (Tiền mặt)

  LoaiTien loaiTien = danhSachLoaiTien[0]; // Mặc định chọn tiền Việt Nam Đồng

  final List<ViModel> danhSachVi = [
    ViModel(maVi: 1, ten: 'Tiền mặt', icon: Icons.account_balance_wallet, iconColor: Colors.orange),
    ViModel(maVi: 2, ten: 'Tài khoản ngân hàng', icon: Icons.account_balance, iconColor: Colors.red),
    ViModel(maVi: 3, ten: 'Thẻ tín dụng', icon: Icons.credit_card, iconColor: Colors.blue),
    ViModel(maVi: 4, ten: 'Tài khoản đầu tư', icon: Icons.show_chart, iconColor: Colors.green),
    ViModel(maVi: 5, ten: 'Ví điện tử', icon: Icons.phone_android, iconColor: Colors.deepOrange),
    ViModel(maVi: 6, ten: 'Khác', icon: Icons.attach_money, iconColor: Colors.brown),
  ];

  @override
  Widget build(BuildContext context) {
    // Tìm ViModel theo mã ví
    final viDaChon = danhSachVi.firstWhere((vi) => vi.maVi == maViChon);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm tài khoản'),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // TODO: Lưu thông tin tài khoản
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  kToolbarHeight -
                  MediaQuery.of(context).padding.top -
                  32, // 32 là tổng padding dọc (16 trên + 16 dưới)
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Số dư ban đầu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: soDuController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '0',
                      suffixText: loaiTien.kyHieu,
                      suffixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),

                  const Divider(),

                  TextField(
                    controller: tenTaiKhoanController,
                    decoration: const InputDecoration(
                      labelText: 'Tên tài khoản',
                      prefixIcon: Icon(Icons.account_balance_wallet),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: viDaChon.iconColor.withOpacity(0.2),
                      child: Icon(viDaChon.icon, color: viDaChon.iconColor),
                    ),
                    title: Text(viDaChon.ten),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final int? maViMoi = await showModalBottomSheet<int>(
                        context: context,
                        builder: (context) {
                          return ListView(
                            shrinkWrap: true,
                            children: danhSachVi.map((vi) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: vi.iconColor.withOpacity(0.2),
                                  child: Icon(vi.icon, color: vi.iconColor),
                                ),
                                title: Text(vi.ten),
                                onTap: () {
                                  Navigator.pop(context, vi.maVi); // Trả về mã ví
                                },
                              );
                            }).toList(),
                          );
                        },
                      );

                      if (maViMoi != null) {
                        setState(() {
                          maViChon = maViMoi;
                        });
                      }
                    },
                  ),

                  ListTile(
                    leading: Text(
                      loaiTien.kyHieu,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    title: Text('${loaiTien.tenLoai} (${loaiTien.menhGia})'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final LoaiTien? loaiTienMoi = await showModalBottomSheet<LoaiTien>(
                        context: context,
                        builder: (context) {
                          return ListView(
                            shrinkWrap: true,
                            children: danhSachLoaiTien.map((lt) {
                              return ListTile(
                                leading: Text(
                                  lt.kyHieu,
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                                title: Text(lt.tenLoai),
                                subtitle: Text(lt.menhGia),
                                onTap: () {
                                  Navigator.pop(context, lt);
                                },
                              );
                            }).toList(),
                          );
                        },
                      );

                      if (loaiTienMoi != null) {
                        setState(() {
                          loaiTien = loaiTienMoi;
                        });
                      }
                    },
                  ),

                  TextField(
                    controller: dienGiaiController,
                    decoration: const InputDecoration(
                      labelText: 'Diễn giải',
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Không tính vào báo cáo'),
                      Switch(
                        value: khongTinhBaoCao,
                        onChanged: (value) {
                          setState(() {
                            khongTinhBaoCao = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ghi chép trên tài khoản này sẽ không được thống kê vào TẤT CẢ các báo cáo (trừ báo cáo theo dõi vay nợ)',
                    style: TextStyle(color: Colors.grey),
                  ),

                  Expanded(child: Container()),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.lightBlue,
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text('Lưu'),
                    onPressed: () async {
                      final tenTaiKhoan = tenTaiKhoanController.text.trim();
                      final dienGiai = dienGiaiController.text.trim();
                      final soDuStr = soDuController.text.trim();

                      if (tenTaiKhoan.isEmpty || soDuStr.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
                        );
                        return;
                      }

                      final soDu = double.tryParse(soDuStr.replaceAll(',', '')) ?? 0;

                      // Hiển thị dữ liệu kiểm tra bằng AlertDialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận dữ liệu'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tên tài khoản: $tenTaiKhoan'),
                              Text('Số dư: $soDu (${loaiTien.kyHieu})'),
                              Text('Loại ví (mã): $maViChon'),
                              Text('Loại tiền (mã): ${loaiTien.maLoai}'),
                              Text('Diễn giải: $dienGiai'),
                              Text('Không tính vào báo cáo: ${khongTinhBaoCao ? "Có" : "Không"}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Huỷ'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context); // Đóng dialog

                                final viMoi = ViNguoiDung(
                                  maNguoiDung: widget.maKH,
                                  tenTaiKhoan: tenTaiKhoan,
                                  maLoaiTien: int.tryParse(loaiTien.maLoai.toString()) ?? 0,
                                  dienGiai: dienGiai,
                                  soDu: soDu,
                                  maVi: maViChon, // Gán mã ví ở đây
                                  vi: null,
                                  loaiTien: null,
                                  khachHang: null,
                                );

                                final success = await ViNguoiDungService.themViNguoiDung(viMoi);

                                if (success && context.mounted) {
                                  Navigator.pop(context, true);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Thêm tài khoản thành công')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Thêm tài khoản thất bại')),
                                  );
                                }
                              },
                              child: const Text('Xác nhận'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
