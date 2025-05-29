import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  double _walletBalance = 0.0;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _wallets = [];
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadWallets();
    _loadCategories();
  }

  Future<void> _loadWallets() async {
    try {
      // Get all wallet types first
      final viResponse = await http.get(
        Uri.parse('https://10.0.2.2:7283/api/Vi'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Vi Response status: ${viResponse.statusCode}');
      print('Vi Response body: ${viResponse.body}');

      if (viResponse.statusCode == 200) {
        final List<dynamic> viData = json.decode(viResponse.body);
        List<Map<String, dynamic>> wallets = [];

        // For each wallet type, get user's wallet info
        for (var vi in viData) {
          try {
            print('Processing wallet type: ${vi['tenVi']}');

            // Define wallet names based on type
            String walletName;
            if (vi['maVi'] == 1) {
              walletName = 'Ví Tiền Mặt';
            } else if (vi['maVi'] == 2) {
              walletName = 'Tài khoản Vietcombank';
            } else {
              walletName = 'Ví ${vi['tenVi']}';
            }

            final encodedWalletName = Uri.encodeComponent(walletName);
            final url =
                'https://10.0.2.2:7283/api/ViNguoiDung/${widget.maKH}/${vi['maVi']}/$encodedWalletName';
            print('Trying URL: $url');

            final response = await http.get(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            );

            print('Wallet Response status: ${response.statusCode}');
            print('Wallet Response body: ${response.body}');

            if (response.statusCode == 200) {
              final walletData = json.decode(response.body);
              wallets.add({
                'maVi': walletData['maVi'],
                'tenVi': walletData['tenTaiKhoan'],
                'soDu': walletData['soDu']?.toDouble() ?? 0.0,
                'loaiVi': walletData['vi']['loaiVi'],
                'iconVi': walletData['vi']['iconVi'],
              });
            }
          } catch (e) {
            print('Error loading wallet ${vi['maVi']}: $e');
          }
        }

        print('Final wallets list: $wallets');

        setState(() {
          _wallets = wallets;
          if (_wallets.isNotEmpty) {
            _selectedWallet = _wallets[0]['maVi'].toString();
            _walletBalance = _wallets[0]['soDu'];
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _error =
              'Lỗi khi tải danh sách ví: ${viResponse.statusCode} - ${viResponse.body}';
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
              data
                  .map(
                    (category) => {
                      'maDanhMuc': category['maDanhMucNguoiDung'],
                      'tenDanhMuc': category['tenDanhMucNguoiDung'],
                      'toiDa': category['toiDa']?.toDouble() ?? 0.0,
                      'soTienHienTai':
                          category['soTienHienTai']?.toDouble() ?? 0.0,
                    },
                  )
                  .toList();
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
          (w) => w['maVi'].toString() == _selectedWallet,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nhập vào')),
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
                      // Hiển thị số dư ví
                      Card(
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
                                NumberFormat.currency(
                                  locale: 'vi_VN',
                                  symbol: '₫',
                                ).format(_walletBalance),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Chọn loại giao dịch
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Loại giao dịch',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Thu', child: Text('Thu')),
                          DropdownMenuItem(value: 'Chi', child: Text('Chi')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Chọn ví
                      DropdownButtonFormField<String>(
                        value: _selectedWallet,
                        decoration: const InputDecoration(
                          labelText: 'Chọn ví',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _wallets.map((wallet) {
                              return DropdownMenuItem(
                                value: wallet['maVi'].toString(),
                                child: Text(wallet['tenVi']),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedWallet = value;
                            // Cập nhật số dư khi chọn ví khác
                            final selectedWallet = _wallets.firstWhere(
                              (w) => w['maVi'].toString() == value,
                              orElse: () => _wallets.first,
                            );
                            _walletBalance = selectedWallet['soDu'];
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Chọn danh mục
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Chọn danh mục',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _categories.map((category) {
                              return DropdownMenuItem(
                                value: category['maDanhMuc'].toString(),
                                child: Text(category['tenDanhMuc']),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Nhập số tiền
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Số tiền',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập số tiền';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Vui lòng nhập số hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Nhập ghi chú
                      TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          labelText: 'Ghi chú',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      // Nút lưu
                      ElevatedButton(
                        onPressed: _saveTransaction,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
        // Lấy thông tin ví hiện tại
        final currentWallet = _wallets.firstWhere(
          (w) => w['maVi'].toString() == _selectedWallet,
        );

        // Tạo giao dịch mới
        final response = await http.post(
          Uri.parse('https://10.0.2.2:7283/api/GiaoDich'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({
            'maNguoiDung': widget.maKH,
            'maVi': int.parse(_selectedWallet!),
            'maDanhMucNguoiDung': int.parse(_selectedCategory!),
            'soTien': double.parse(_amountController.text),
            'soTienCu': currentWallet['soDu'],
            'soTienMoi':
                currentWallet['soDu'] + double.parse(_amountController.text),
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
            // Lưu lịch sử giao dịch
            await _saveTransactionHistory(
              giaoDichData['maGiaoDich'],
              currentWallet['soDu'],
              currentWallet['soDu'] + double.parse(_amountController.text),
            );

            // Cập nhật lại danh sách ví để lấy số dư mới
            await _loadWallets();

            // Thông báo cho màn hình lịch sử giao dịch
            if (widget.onTransactionAdded != null) {
              widget.onTransactionAdded!();
            }

            // Hiển thị thông báo thành công
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Giao dịch đã được lưu thành công'),
                  backgroundColor: Colors.green,
                ),
              );

              // Xóa form
              _amountController.clear();
              _noteController.clear();
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
        body: jsonEncode({
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
}
