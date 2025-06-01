import 'package:flutter/material.dart';
import 'package:qltncn/screens/HomePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AddCustomerInfoScreen extends StatefulWidget {
  final String maTaiKhoan;

  const AddCustomerInfoScreen({super.key, required this.maTaiKhoan});

  @override
  _AddCustomerInfoScreenState createState() => _AddCustomerInfoScreenState();
}

class _AddCustomerInfoScreenState extends State<AddCustomerInfoScreen> {
  final TextEditingController hoTenController = TextEditingController();
  final TextEditingController soDTController = TextEditingController();
  DateTime? ngaySinh;
  bool isLoading = false; // Biến trạng thái loading

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: ngaySinh ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        ngaySinh = picked;
      });
    }
  }

  Future<void> _submit() async {
    final hoten = hoTenController.text.trim();
    final sodt = soDTController.text.trim();

    if (hoten.isEmpty || ngaySinh == null || sodt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    setState(() {
      isLoading = true; // Bắt đầu loading
    });

    try {
      final response = await http.post(
        Uri.parse('https://10.0.2.2:7283/api/KhachHang'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mataikhoan': widget.maTaiKhoan,
          'hoten': hoten,
          'ngaysinh': ngaySinh!.toIso8601String(),
          'sodt': sodt,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final maKH = data['makh']?.toString();

        if (maKH == null || maKH.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không nhận được mã khách hàng từ server'),
            ),
          );
          return;
        }

        await _onRegisterSuccess(context, maKH);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm thông tin khách hàng')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(maKH: maKH, userName: hoten),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi kết nối: $e')));
    } finally {
      // Thêm delay 1.5 giây trước khi dừng loading
      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
      if (mounted) {
        // Kiểm tra widget có còn tồn tại không
        setState(() {
          isLoading = false; // Dừng loading
        });
      }
    }
  }

  Future<void> _onRegisterSuccess(BuildContext context, String maKH) async {
    try {
      final response = await http.post(
        Uri.parse('https://10.0.2.2:7283/api/ViNguoiDung'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'maNguoiDung': maKH,
          'maVi': 1,
          'tenTaiKhoan': 'Ví Tiền Mặt',
          'maLoaiTien': 1,
          'dienGiai': 'Ví Tiền Mặt',
          'soDu': 0.0,
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Tạo ví thất bại');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tạo ví: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF03A9F4);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm thông tin khách hàng'),
        foregroundColor: Colors.white,
        backgroundColor: mainColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: hoTenController,
              decoration: InputDecoration(
                labelText: 'Họ tên',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: mainColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: mainColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Ngày sinh',
                    hintText: 'Chọn ngày sinh',
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      color: mainColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: mainColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: mainColor, width: 2),
                    ),
                  ),
                  controller: TextEditingController(
                    text: ngaySinh != null ? dateFormat.format(ngaySinh!) : '',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: soDTController,
              decoration: InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: mainColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: mainColor, width: 2),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const LinearProgressIndicator(
                color: mainColor,
                backgroundColor: Colors.grey,
                minHeight: 4,
              )
            else
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Lưu thông tin',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
