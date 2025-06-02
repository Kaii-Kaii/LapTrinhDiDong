import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:qltncn/screens/services/cloudinary_service.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import '../s_TongQuan/TongQuan.dart';
import 'package:qltncn/screens/s_HangMuc/HangMucScreen.dart';

class NhapVaoScreen extends StatefulWidget {
  final String maKH;
  final Function? onTransactionAdded;
  const NhapVaoScreen({super.key, required this.maKH, this.onTransactionAdded});

  @override
  State<NhapVaoScreen> createState() => _NhapVaoScreenState();
}

class _NhapVaoScreenState extends State<NhapVaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedType = 'Thu';
  String? _selectedWallet;
  String? _selectedCategory;
  String? selectedCategory; // Add this missing variable
  double _walletBalance = 0.0;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _wallets = [];
  List<Map<String, dynamic>> _categories = [];
  final CloudinaryService _cloudinaryService = CloudinaryService();
  File? _selectedImage;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadWallets();
    _loadCategories();
  }

  Future<void> _loadWallets() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://10.0.2.2:7283/api/ViNguoiDung/khachhang/${widget.maKH}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Wallets Response status: ${response.statusCode}');
      print('Wallets Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> wallets = [];

        for (var wallet in data) {
          final String uniqueId =
              '${wallet['maVi']}_${wallet['tenTaiKhoan'] ?? 'none'}';
          wallets.add({
            'maVi': wallet['maVi'],
            'tenVi': wallet['vi']['tenVi'],
            'tenTaiKhoan': wallet['tenTaiKhoan'] ?? 'Không có tên',
            'soDu': wallet['soDu']?.toDouble() ?? 0.0,
            'loaiVi': wallet['vi']['loaiVi'],
            'iconVi': wallet['vi']['iconVi'],
            'uniqueId': uniqueId,
          });
        }

        print('Final wallets list: $wallets');

        setState(() {
          _wallets = wallets;
          if (_wallets.isNotEmpty) {
            _selectedWallet = _wallets[0]['uniqueId'] as String;
            _walletBalance = _wallets[0]['soDu'];
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _error =
              'Lỗi khi tải danh sách ví: ${response.statusCode} - ${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading wallets: $e');
      setState(() {
        _error = 'Lỗi kết nối: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://10.0.2.2:7283/api/DanhMucNguoiDung/user/${widget.maKH}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Categories Response status: ${response.statusCode}');
      print('Categories Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _categories =
              data.map((category) {
                return {
                  'maDanhMuc': category['maDanhMucNguoiDung'],
                  'tenDanhMuc': category['tenDanhMucNguoiDung'],
                  'thuChi': category['thuChi'], // Sử dụng trường thuChi
                };
              }).toList();
          if (_categories.isNotEmpty) {
            _selectedCategory = _categories[0]['maDanhMuc'].toString();
          }
        });
      } else {
        setState(() {
          _error =
              'Lỗi khi tải danh mục: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        _error = 'Lỗi kết nối: $e';
      });
    }
  }

  Future<void> _loadWalletBalance() async {
    if (_selectedWallet != null) {
      try {
        final selectedWallet = _wallets.firstWhere(
          (w) => w['uniqueId'] == _selectedWallet,
          orElse: () => _wallets.first,
        );

        setState(() {
          _walletBalance = selectedWallet['soDu'];
          _isLoading = false;
        });
      } catch (e) {
        print('Error loading wallet balance: $e');
        setState(() {
          _error = 'Lỗi khi tải số dư: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _showLogDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nhập thành công!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final imageFile = await _cloudinaryService.pickImage();
      if (imageFile == null) return;

      if (!mounted) return;
      setState(() {
        _selectedImage = imageFile;
      });
    } catch (e) {
      print('Error in _pickAndUploadImage: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhập vào'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text(
                                'Số dư ví',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                NumberFormat(
                                      '#,###',
                                      'en_US',
                                    ).format(_walletBalance) +
                                    ' VND',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: 'Loại giao dịch',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!),
                          ),
                          labelStyle: TextStyle(color: Colors.blue[700]),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Thu', child: Text('Thu')),
                          DropdownMenuItem(value: 'Chi', child: Text('Chi')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                            _selectedCategory = null; // Reset danh mục
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedWallet,
                        decoration: InputDecoration(
                          labelText: 'Chọn ví',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!),
                          ),
                          labelStyle: TextStyle(color: Colors.blue[700]),
                        ),
                        items:
                            _wallets.map<DropdownMenuItem<String>>((wallet) {
                              return DropdownMenuItem<String>(
                                value: wallet['uniqueId'] as String,
                                child: Text(
                                  '${wallet['tenVi']} (${wallet['tenTaiKhoan']})',
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedWallet = value;
                            final selectedWallet = _wallets.firstWhere(
                              (w) => w['uniqueId'] == value,
                              orElse: () => _wallets.first,
                            );
                            _walletBalance = selectedWallet['soDu'];
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Chọn danh mục',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!),
                          ),
                          labelStyle: TextStyle(color: Colors.blue[700]),
                        ),
                        items:
                            _categories
                                .where(
                                  (category) =>
                                      category['thuChi'] == _selectedType,
                                ) // Lọc theo thuChi
                                .map((category) {
                                  return DropdownMenuItem(
                                    value: category['maDanhMuc'].toString(),
                                    child: Text(category['tenDanhMuc']),
                                  );
                                })
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Số tiền',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!),
                          ),
                          labelStyle: TextStyle(color: Colors.blue[700]),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          CurrencyInputFormatter(),
                        ], // Use currency formatter
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập số tiền';
                          }
                          // Remove formatting for validation
                          String cleanValue = value.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          if (double.tryParse(cleanValue) == null) {
                            return 'Số tiền không hợp lệ';
                          }
                          final amount = double.parse(cleanValue);
                          if (amount <= 0) {
                            return 'Số tiền phải lớn hơn 0';
                          }
                          if (_selectedType == 'Chi' &&
                              amount > _walletBalance) {
                            return 'Số dư không đủ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          labelText: 'Ghi chú',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!),
                          ),
                          labelStyle: TextStyle(color: Colors.blue[700]),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _pickAndUploadImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Chọn ảnh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                      if (_selectedImage != null) ...[
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _saveTransaction,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Lưu',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final selectedWallet = _wallets.firstWhere(
          (w) => w['uniqueId'] == _selectedWallet,
        );

        // Upload image first if exists
        String? imageUrl;
        if (_selectedImage != null) {
          try {
            imageUrl = await _cloudinaryService.uploadImage(_selectedImage!);
            if (imageUrl == null) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lỗi khi tải ảnh lên Cloudinary')),
              );
              return;
            }
          } catch (e) {
            print('Error uploading image: $e');
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Lỗi khi tải ảnh: $e')));
            return;
          }
        }

        // Clean amount text for parsing
        String cleanAmount = _amountController.text.replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );
        double amount = double.parse(cleanAmount);

        // Create transaction
        final response = await http.post(
          Uri.parse('https://10.0.2.2:7283/api/GiaoDich'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({
            'maNguoiDung': widget.maKH,
            'maVi': selectedWallet['maVi'],
            'maDanhMucNguoiDung': int.parse(_selectedCategory!),
            'soTien': amount,
            'soTienCu': selectedWallet['soDu'],
            'soTienMoi':
                _selectedType == 'Thu'
                    ? selectedWallet['soDu'] + amount
                    : selectedWallet['soDu'] - amount,
            'ghiChu': _noteController.text,
            'ngayGiaoDich': DateTime.now().toIso8601String(),
            'loaiGiaoDich': _selectedType,
            'maViNhan': null,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final giaoDichData = json.decode(response.body);
          print('Giao dịch được tạo thành công: ${response.body}');

          try {
            await _saveTransactionHistory(
              giaoDichData['maGiaoDich'],
              selectedWallet['soDu'],
              _selectedType == 'Thu'
                  ? selectedWallet['soDu'] + amount
                  : selectedWallet['soDu'] - amount,
            );

            // Save image URL if exists
            if (imageUrl != null) {
              await http.post(
                Uri.parse('https://10.0.2.2:7283/api/AnhHoaDon'),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: json.encode({
                  'maGiaoDich': giaoDichData['maGiaoDich'],
                  'duongDanAnh': imageUrl,
                }),
              );
            }

            await _loadWallets();

            if (widget.onTransactionAdded != null) {
              widget.onTransactionAdded!();
            }

            transactionUpdateController.add(null);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Giao dịch đã được lưu thành công'),
                  backgroundColor: Colors.green,
                ),
              );

              _amountController.clear();
              _noteController.clear();
              setState(() {
                _selectedImage = null;
                _imageUrl = null;
              });
            }
          } catch (e) {
            print('Lỗi khi lưu lịch sử giao dịch: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Giao dịch đã được tạo nhưng lỗi khi lưu lịch sử: $e',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        } else {
          throw Exception(
            'Lỗi khi tạo giao dịch: ${response.statusCode} - ${response.body}',
          );
        }
      } catch (e) {
        print('Lỗi khi tạo giao dịch: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _saveTransactionHistory(
    int maGiaoDich,
    double soTienCu,
    double soTienMoi,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://10.0.2.2:7283/api/LichSuGiaoDich'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'maGiaoDich': maGiaoDich,
          'hanhDong': 'TaoMoi',
          'soTienCu': soTienCu,
          'soTienMoi': soTienMoi,
          'thucHienBoi': widget.maKH,
          'thoiGian': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        print('Lưu lịch sử giao dịch thành công');
        print('Response body: ${response.body}');
      } else {
        print('Lỗi khi lưu lịch sử giao dịch: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
          'Lỗi khi lưu lịch sử giao dịch: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Lỗi khi lưu lịch sử giao dịch: $e');
      throw Exception('Lỗi khi lưu lịch sử giao dịch: $e');
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _showCategorySelection(BuildContext context) async {
    // Chuyển sang trang HangMucScreen và nhận kết quả trả về
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HangMucScreen(maKhachHang: widget.maKH),
      ),
    );
    if (result != null && result is String) {
      setState(() {
        selectedCategory = result;
      });
    }
  }

  // List<String> get _incomeCategories => [
  //   "Lương",
  //   "Thưởng",
  //   "Lãi",
  //   "Lãi tiết kiệm",
  //   "Khác",
  // ];
  // List<String> get _expenseCategories => [
  //   "Ăn uống",
  //   "Dịch vụ",
  //   "Đi lại",
  //   "Con cái",
  //   "Trang phục",
  //   "Sức khỏe",
  //   "Hiếu hỉ",
  //   "Khác",
  // ];
}

// Add CurrencyInputFormatter class
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
