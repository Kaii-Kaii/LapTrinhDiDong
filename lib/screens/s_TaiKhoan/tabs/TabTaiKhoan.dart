import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qltncn/model/Vi/Vi/Vi.dart';
import 'package:qltncn/model/Vi/ViNguoiDung/ViNguoiDung.dart';
import 'package:qltncn/model/Vi/ViNguoiDung/ViNguoiDung_service.dart';

class TabTaiKhoan extends StatefulWidget {
  final String maKH;
  const TabTaiKhoan({super.key, required this.maKH});

  @override
  TabTaiKhoanState createState() => TabTaiKhoanState();
}

class TabTaiKhoanState extends State<TabTaiKhoan>
    with TickerProviderStateMixin {
  List<ViNguoiDung> danhSachVi = [];
  bool isLoading = true;
  final NumberFormat currencyFormat = NumberFormat('#,###', 'en_US');
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    loadDanhSachVi();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadDanhSachVi() async {
    final data = await ViNguoiDungService.fetchViNguoiDungByMaKhachHang(
      widget.maKH,
    );
    setState(() {
      danhSachVi = data;
      isLoading = false;
    });
    _animationController.forward();
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

  final List<Vi> danhSachViMau = [
    Vi(maVi: 1, tenVi: 'Tiền mặt', loaiVi: 'cash', iconVi: 'wallet'),
    Vi(maVi: 2, tenVi: 'Ngân hàng', loaiVi: 'bank', iconVi: 'bank'),
    Vi(maVi: 3, tenVi: 'Thẻ tín dụng', loaiVi: 'credit', iconVi: 'credit_card'),
  ];

  Icon getCustomIcon(String iconVi) {
    switch (iconVi) {
      case 'wallet':
        return const Icon(
          Icons.account_balance_wallet,
          color: Color(0xFF03A9F4),
        );
      case 'bank':
        return const Icon(Icons.account_balance, color: Color(0xFF03A9F4));
      case 'credit_card':
        return const Icon(Icons.credit_card, color: Color(0xFF03A9F4));
      default:
        return const Icon(Icons.wallet, color: Color(0xFF03A9F4));
    }
  }

  Color getColorByMaVi(int maVi) {
    switch (maVi) {
      case 1:
        return const Color(0xFF03A9F4);
      case 2:
        return const Color(0xFF0288D1);
      case 3:
        return const Color(0xFF0277BD);
      default:
        return const Color(0xFF03A9F4);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        decoration: _buildBackgroundDecoration(),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF03A9F4)),
            strokeWidth: 3,
          ),
        ),
      );
    }

    return Container(
      decoration: _buildBackgroundDecoration(),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header với thiết kế hiện đại
            _buildModernHeader(),

            // Danh sách ví với thiết kế mới
            Expanded(child: _buildWalletList()),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF03A9F4).withOpacity(0.1),
          const Color(0xFF81D4FA).withOpacity(0.05),
          Colors.white,
          const Color(0xFFE1F5FE).withOpacity(0.3),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Stack(
        children: [
          // Background với hiệu ứng
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF03A9F4),
                  Color(0xFF0288D1),
                  Color(0xFF0277BD),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF03A9F4).withOpacity(0.4),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFF03A9F4).withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
          ),

          // Decorative elements
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          // Content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tài khoản của tôi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Quản lý ví tiền',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  const Text(
                    'Tổng số dư',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${currencyFormat.format(tongSoDu)} VND',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${danhSachVi.length} ví',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletList() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header của danh sách
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF03A9F4).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF03A9F4),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF03A9F4).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Danh sách ví',
                    style: TextStyle(
                      color: Color(0xFF03A9F4),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Danh sách ví
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: danhSachVi.length,
              itemBuilder: (context, index) {
                final viNguoiDung = danhSachVi[index];
                final viMau = danhSachViMau.firstWhere(
                  (vi) => vi.maVi == viNguoiDung.maVi,
                  orElse: () => Vi(maVi: 0, tenVi: '', loaiVi: '', iconVi: ''),
                );

                final color = getColorByMaVi(viMau.maVi ?? 0);
                final iconWidget = getCustomIcon(viMau.iconVi ?? '');

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF03A9F4).withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.06),
                        spreadRadius: 0,
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.1),
                            color.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: color.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: iconWidget,
                    ),
                    title: Text(
                      viNguoiDung.tenTaiKhoan,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${currencyFormat.format(viNguoiDung.soDu)} VND',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF03A9F4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF03A9F4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Color(0xFF03A9F4),
                        ),
                        onSelected:
                            (value) => _handleMenuAction(value, viNguoiDung),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        itemBuilder:
                            (context) => [
                              _buildPopupMenuItem(
                                'chi_tiet',
                                Icons.visibility,
                                'Chi tiết ví',
                              ),
                              _buildPopupMenuItem(
                                'dieu_chinh',
                                Icons.tune,
                                'Điều chỉnh số dư',
                              ),
                              _buildPopupMenuItem('sua', Icons.edit, 'Sửa'),
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
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    String value,
    IconData icon,
    String text, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : const Color(0xFF03A9F4),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: isDestructive ? Colors.red : const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            content: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF03A9F4), Color(0xFF0288D1)],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.tune, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Điều chỉnh số dư',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      decoration: InputDecoration(
                        labelText: 'Số dư mới',
                        labelStyle: const TextStyle(color: Color(0xFF03A9F4)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF03A9F4),
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF03A9F4),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        prefixIcon: const Icon(
                          Icons.account_balance_wallet,
                          color: Color(0xFF03A9F4),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF03A9F4).withOpacity(0.05),
                      ),
                    ),
                  ),

                  // Actions
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Hủy',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF03A9F4), Color(0xFF0288D1)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
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
                                      content: Text(
                                        '✅ Cập nhật số dư thành công',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.pop(context);
                                  if (mounted) loadDanhSachVi();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '❌ Cập nhật số dư thất bại',
                                      ),
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showDialogChiTietVi(ViNguoiDung viNguoiDung) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF03A9F4), Color(0xFF0288D1)],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.account_balance,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Chi tiết ví',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildDetailCard(
                          'Tên ví',
                          viNguoiDung.tenTaiKhoan,
                          Icons.account_balance_wallet,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailCard(
                          'Diễn giải',
                          viNguoiDung.dienGiai ?? 'Không có',
                          Icons.description,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailCard(
                          'Số dư',
                          '${currencyFormat.format(viNguoiDung.soDu)} VND',
                          Icons.monetization_on,
                        ),
                      ],
                    ),
                  ),

                  // Action
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF03A9F4), Color(0xFF0288D1)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
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
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF03A9F4).withOpacity(0.05),
            const Color(0xFF03A9F4).withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF03A9F4).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF03A9F4),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF03A9F4).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF03A9F4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1A1A1A),
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
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF03A9F4), Color(0xFF0288D1)],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.edit, color: Colors.white, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'Sửa thông tin ví',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
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

                    // Actions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Hủy',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF03A9F4),
                                    Color(0xFF0288D1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (viNguoiDung.maVi == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            '❌ Tên ví đã tồn tại cho loại tiền này. Vui lòng chọn tên khác hoặc đổi loại tiền.',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    String cleanSoDu = soDuController.text
                                        .replaceAll(RegExp(r'[^0-9]'), '');

                                    bool success =
                                        await ViNguoiDungService.capNhatViNguoiDungFull(
                                          maNguoiDung:
                                              viNguoiDung.maNguoiDung.trim(),
                                          maVi: viNguoiDung.maVi!,
                                          tenTaiKhoanCu:
                                              viNguoiDung.tenTaiKhoan,
                                          viNguoiDungMoi: ViNguoiDung(
                                            maNguoiDung:
                                                viNguoiDung.maNguoiDung,
                                            maVi: viNguoiDung.maVi,
                                            tenTaiKhoan:
                                                tenTaiKhoanController.text
                                                    .trim(),
                                            dienGiai:
                                                dienGiaiController.text.trim(),
                                            soDu: double.parse(cleanSoDu),
                                            maLoaiTien: viNguoiDung.maLoaiTien,
                                          ),
                                        );

                                    if (success) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            '✅ Cập nhật ví thành công',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pop(context);
                                      if (mounted) loadDanhSachVi();
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            '❌ Cập nhật ví thất bại',
                                          ),
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
                    ),
                  ],
                ),
              ),
            ),
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
        labelStyle: const TextStyle(color: Color(0xFF03A9F4)),
        prefixIcon: Icon(icon, color: const Color(0xFF03A9F4)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF03A9F4)),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF03A9F4), width: 2),
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
        fillColor: const Color(0xFF03A9F4).withOpacity(0.05),
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

    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    final formatter = NumberFormat('#,###', 'en_US');
    String formatted = formatter.format(int.parse(digitsOnly));

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
