import 'package:flutter/material.dart';
import 'package:qltncn/model/KhachHang/Khach_Hang.dart';
import 'package:qltncn/model/KhachHang/khachhang_service.dart';
import 'package:qltncn/model/TaiKhoan/TaiKhoan.dart';
import 'package:qltncn/model/TaiKhoan/TaiKhoan_service.dart';
import 'ChinhSuaThongTinScreen.dart';

class HoSoCaNhanScreen extends StatefulWidget {
  final String maKH;
  final String maTaiKhoan;

  const HoSoCaNhanScreen({
    Key? key,
    required this.maKH,
    required this.maTaiKhoan,
  }) : super(key: key);

  @override
  State<HoSoCaNhanScreen> createState() => _HoSoCaNhanScreenState();
}

class _HoSoCaNhanScreenState extends State<HoSoCaNhanScreen> {
  KhachHang? _khachHang;
  TaiKhoan? _taiKhoan;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final khachHang = await KhachHangService.fetchKhachHangByMaKH(widget.maKH);
    final taiKhoan = await fetchTaiKhoanByMaTaiKhoan(widget.maTaiKhoan);

    if (!mounted) return;

    setState(() {
      _khachHang = khachHang;
      _taiKhoan = taiKhoan;
      _loading = false;
    });
  }

  Future<void> _navigateToEdit() async {
    if (_khachHang == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChinhSuaThongTinScreen(
              hoTen: _khachHang!.hoTen ?? '',
              soDT: _khachHang!.soDT ?? '',
              ngaySinh: _khachHang!.ngaySinh,
            ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      final updated = await KhachHangService.updateThongTinKhachHang(
        maKH: widget.maKH,
        hoTen: result['hoTen'],
        soDT: result['soDT'],
        ngaySinh: result['ngaySinh'],
      );

      if (!mounted) return;

      if (updated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cập nhật thành công'),
            backgroundColor: const Color(0xFF03A9F4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        _fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cập nhật thất bại'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF03A9F4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF03A9F4), size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
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
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Hồ Sơ Cá Nhân',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child:
                      _loading
                          ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF03A9F4),
                              ),
                            ),
                          )
                          : (_khachHang == null || _taiKhoan == null)
                          ? const Center(
                            child: Text(
                              'Không tìm thấy thông tin',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                          )
                          : SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // Avatar Section
                                Container(
                                  margin: const EdgeInsets.only(bottom: 30),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF03A9F4),
                                              Color(0xFF0288D1),
                                            ],
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _khachHang?.hoTen ?? "Người dùng",
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2C3E50),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Customer Info Card
                                _buildInfoCard(
                                  title: 'Thông tin khách hàng',
                                  icon: Icons.person_outline,
                                  children: [
                                    _buildInfoRow(
                                      label: 'Họ tên',
                                      value: _khachHang?.hoTen ?? "Không có",
                                    ),
                                    _buildInfoRow(
                                      label: 'Số điện thoại',
                                      value: _khachHang?.soDT ?? "Không có",
                                    ),
                                    _buildInfoRow(
                                      label: 'Ngày sinh',
                                      value:
                                          _khachHang?.ngaySinh != null
                                              ? _formatDate(
                                                _khachHang!.ngaySinh!,
                                              )
                                              : "Không có",
                                    ),
                                  ],
                                ),

                                // Account Info Card
                                _buildInfoCard(
                                  title: 'Tài khoản đăng nhập',
                                  icon: Icons.account_circle_outlined,
                                  children: [
                                    _buildInfoRow(
                                      label: 'Tên đăng nhập',
                                      value:
                                          _taiKhoan?.tendangnhap ?? "Không có",
                                    ),
                                    _buildInfoRow(
                                      label: 'Email',
                                      value: _taiKhoan?.email ?? "Không có",
                                    ),
                                  ],
                                ),

                                // Edit Button
                                Container(
                                  width: double.infinity,
                                  height: 55,
                                  margin: const EdgeInsets.only(top: 10),
                                  child: ElevatedButton(
                                    onPressed: _navigateToEdit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF03A9F4),
                                      foregroundColor: Colors.white,
                                      elevation: 8,
                                      shadowColor: const Color(
                                        0xFF03A9F4,
                                      ).withOpacity(0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Chỉnh sửa thông tin',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
