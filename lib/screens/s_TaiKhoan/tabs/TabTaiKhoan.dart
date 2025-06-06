import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qltncn/model/Vi/Vi/Vi.dart';
import 'package:qltncn/model/Vi/ViNguoiDung/ViNguoiDung.dart';
import 'package:qltncn/model/Vi/ViNguoiDung/ViNguoiDung_service.dart';
import 'package:qltncn/widget/vi_utils.dart';

class TabTaiKhoan extends StatefulWidget {
  final String maKH;
  const TabTaiKhoan({super.key, required this.maKH});

  @override
  TabTaiKhoanState createState() => TabTaiKhoanState(); // <- bỏ dấu _
}

class TabTaiKhoanState extends State<TabTaiKhoan> {
  List<ViNguoiDung> danhSachVi = [];
  bool isLoading = true;
  final NumberFormat currencyFormat = NumberFormat('#,###', 'en_US');

  @override
  void initState() {
    super.initState();
    loadDanhSachVi();
  }

  Future<void> loadDanhSachVi() async {
    final data = await ViNguoiDungService.fetchViNguoiDungByMaKhachHang(
      widget.maKH,
    );
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
  // Ví dụ dữ liệu mô phỏng để thay thế tinhNangList
  final List<Vi> danhSachViMau = [
    Vi(maVi: 1, tenVi: 'Tiền mặt', loaiVi: 'cash', iconVi: 'wallet'),
    Vi(maVi: 2, tenVi: 'Ngân hàng', loaiVi: 'bank', iconVi: 'bank'),
    Vi(maVi: 3, tenVi: 'Thẻ tín dụng', loaiVi: 'credit', iconVi: 'credit_card'),
  ];

  // Hàm trả về icon theo chuỗi iconVi
  Icon getCustomIcon(String iconVi) {
    switch (iconVi) {
      case 'wallet':
        return const Icon(Icons.account_balance_wallet, color: Color(0xFF1565C0));
      case 'bank':
        return const Icon(Icons.account_balance, color: Color(0xFF1565C0));
      case 'credit_card':
        return const Icon(Icons.credit_card, color: Color(0xFF1565C0));
      default:
        return const Icon(Icons.wallet, color: Color(0xFF1565C0));
    }
  }

  // Hàm trả về màu theo mã ví (hoặc loại ví)
  Color getColorByMaVi(int maVi) {
    switch (maVi) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.purple;
      default:
        return const Color(0xFF1565C0);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEAF3FF), Colors.white],
        ),
      ),
      child: Column(
        children: [
          // Header tổng tiền
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1565C0).withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tổng số dư',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${currencyFormat.format(tongSoDu)} VND',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Danh sách ví
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1565C0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.credit_card,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Danh sách ví (${danhSachVi.length})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: danhSachVi.length,
                      itemBuilder: (context, index) {
                        final viNguoiDung = danhSachVi[index];
                        final viMau = danhSachViMau.firstWhere(
                          (vi) => vi.maVi == viNguoiDung.maVi,
                          orElse: () => Vi(
                            maVi: 0,
                            tenVi: '',
                            loaiVi: '',
                            iconVi: '',
                          ),
                        );

                        final color = getColorByMaVi(viMau.maVi ?? 0);
                        final iconWidget = getCustomIcon(viMau.iconVi ?? '');


                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF1565C0).withOpacity(0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.05),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: iconWidget,
                            ),
                            title: Text(
                              viNguoiDung.tenTaiKhoan,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                            subtitle: Text(
                              '${currencyFormat.format(viNguoiDung.soDu)} VND',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1565C0).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Color(0xFF1565C0),
                                ),
                                onSelected:
                                    (value) =>
                                        _handleMenuAction(value, viNguoiDung),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                itemBuilder:
                                    (context) => [
                                      PopupMenuItem(
                                        value: 'chi_tiet',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.account_balance,
                                                color: Color(0xFF1565C0),
                                              ),
                                              SizedBox(width: 12),
                                              Text('Chi tiết ví'),
                                            ],
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'dieu_chinh',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.tune,
                                                color: Color(0xFF1565C0),
                                              ),
                                              SizedBox(width: 12),
                                              Text('Điều chỉnh số dư'),
                                            ],
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'sua',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                color: Color(0xFF1565C0),
                                              ),
                                              SizedBox(width: 12),
                                              Text('Sửa'),
                                            ],
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'xoa',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Xóa',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showDialogDieuChinhSoDu(ViNguoiDung viNguoiDung) {
    final TextEditingController controller = TextEditingController(
      text: currencyFormat.format(viNguoiDung.soDu),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.tune, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Điều chỉnh số dư',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            content: Container(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                decoration: InputDecoration(
                  labelText: 'Số dư mới',
                  labelStyle: const TextStyle(color: Color(0xFF1565C0)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF1565C0)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF1565C0),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  prefixIcon: const Icon(
                    Icons.account_balance_wallet,
                    color: Color(0xFF1565C0),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFEAF3FF),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: const Text('Hủy', style: TextStyle(fontSize: 16)),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    // Remove formatting for parsing
                    String cleanValue = controller.text.replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    );
                    final newSoDu = double.tryParse(cleanValue);

                    if (newSoDu == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Số dư không hợp lệ'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    ViNguoiDung viCapNhat = ViNguoiDung(
                      maNguoiDung: viNguoiDung.maNguoiDung,
                      maVi: viNguoiDung.maVi,
                      tenTaiKhoan: viNguoiDung.tenTaiKhoan,
                      maLoaiTien: viNguoiDung.maLoaiTien,
                      dienGiai: viNguoiDung.dienGiai,
                      soDu: newSoDu,
                    );

                    bool success =
                        await ViNguoiDungService.capNhatViNguoiDungFull(
                          maNguoiDung: viCapNhat.maNguoiDung,
                          maVi: viCapNhat.maVi!,
                          tenTaiKhoanCu: viCapNhat.tenTaiKhoan,
                          viNguoiDungMoi: viCapNhat,
                        );

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Cập nhật số dư thành công'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                      if (mounted) loadDanhSachVi();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('❌ Cập nhật số dư thất bại'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Lưu',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showDialogChiTietVi(ViNguoiDung viNguoiDung) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.account_balance, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Chi tiết ví',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailCard(
                    'Tên ví',
                    viNguoiDung.tenTaiKhoan,
                    Icons.account_balance_wallet,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    'Diễn giải',
                    viNguoiDung.dienGiai ?? 'Không có',
                    Icons.description,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    'Số dư',
                    '${currencyFormat.format(viNguoiDung.soDu)} VND',
                    Icons.monetization_on,
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1565C0), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1565C0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDialogSuaVi(ViNguoiDung viNguoiDung) {
    final _formKey = GlobalKey<FormState>();

    final TextEditingController tenTaiKhoanController = TextEditingController(
      text: viNguoiDung.tenTaiKhoan,
    );
    final TextEditingController dienGiaiController = TextEditingController(
      text: viNguoiDung.dienGiai ?? '',
    );
    final TextEditingController soDuController = TextEditingController(
      text: currencyFormat.format(viNguoiDung.soDu),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.edit, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Sửa thông tin ví',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildInputField(
                      controller: tenTaiKhoanController,
                      label: 'Tên ví',
                      icon: Icons.account_balance_wallet,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tên ví không được để trống';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: dienGiaiController,
                      label: 'Diễn giải',
                      icon: Icons.description,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: soDuController,
                      label: 'Số dư',
                      icon: Icons.monetization_on,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Số dư không được để trống';
                        }
                        String cleanValue = value.replaceAll(
                          RegExp(r'[^0-9]'),
                          '',
                        );
                        if (double.tryParse(cleanValue) == null) {
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
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Hủy', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (viNguoiDung.maVi == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mã ví không hợp lệ.'),
                                ),
                              );
                              return;
                            }

                            bool isTrung =
                                await ViNguoiDungService.kiemTraTenViTrung(
                                  maNguoiDung: viNguoiDung.maNguoiDung,
                                  tenTaiKhoan:
                                      tenTaiKhoanController.text.trim(),
                                  maViKhongTinh: viNguoiDung.maVi!,
                                );

                            if (isTrung) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '❌ Tên ví đã tồn tại cho loại tiền này. Vui lòng chọn tên khác hoặc đổi loại tiền.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Parse số dư với formatting
                            String cleanSoDu = soDuController.text.replaceAll(
                              RegExp(r'[^0-9]'),
                              '',
                            );

                            bool success =
                                await ViNguoiDungService.capNhatViNguoiDungFull(
                                  maNguoiDung: viNguoiDung.maNguoiDung.trim(),
                                  maVi: viNguoiDung.maVi!,
                                  tenTaiKhoanCu: viNguoiDung.tenTaiKhoan,
                                  viNguoiDungMoi: ViNguoiDung(
                                    maNguoiDung: viNguoiDung.maNguoiDung,
                                    maVi: viNguoiDung.maVi,
                                    tenTaiKhoan:
                                        tenTaiKhoanController.text.trim(),
                                    dienGiai: dienGiaiController.text.trim(),
                                    soDu: double.parse(cleanSoDu),
                                    maLoaiTien: viNguoiDung.maLoaiTien,
                                  ),
                                );

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ Cập nhật ví thành công'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                              if (mounted) loadDanhSachVi();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('❌ Cập nhật ví thất bại'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Lưu',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF1565C0)),
        prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF1565C0)),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: const Color(0xFFEAF3FF),
      ),
    );
  }
}

// Currency Input Formatter
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    // Format with comma separator
    final formatter = NumberFormat('#,###', 'en_US');
    String formatted = formatter.format(int.parse(digitsOnly));

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
