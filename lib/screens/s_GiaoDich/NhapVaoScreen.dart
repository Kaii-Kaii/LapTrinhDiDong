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
  String? _selectedWalletName; // Tên ví được chọn
  String? _selectedWalletAccount; // Tài khoản ví cụ thể được chọn
  String? _selectedCategory;
  String? selectedCategory;
  double _walletBalance = 0.0;
  bool _isLoading = true;
  bool _isLoadingAccounts = false; // Loading cho danh sách tài khoản
  String? _error;
  List<Map<String, dynamic>> _allWallets = []; // Tất cả ví
  List<Map<String, dynamic>> _filteredAccounts =
      []; // Tài khoản đã lọc theo tên ví
  List<String> _walletNames = []; // Danh sách tên ví
  List<Map<String, dynamic>> _categories = [];
  final CloudinaryService _cloudinaryService = CloudinaryService();
  File? _selectedImage;
  String? _imageUrl;
  String? _selectedCategoryName; // Tên danh mục được chọn

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
        Set<String> walletNamesSet = {};

        for (var wallet in data) {
          final String uniqueId =
              '${wallet['maVi']}_${wallet['tenTaiKhoan'] ?? 'none'}';
          final String walletName = wallet['vi']['tenVi'] ?? 'Không xác định';

          wallets.add({
            'maVi': wallet['maVi'],
            'tenVi': walletName,
            'tenTaiKhoan': wallet['tenTaiKhoan'] ?? 'Không có tên',
            'soDu': wallet['soDu']?.toDouble() ?? 0.0,
            'loaiVi': wallet['vi']['loaiVi'] ?? 'Không xác định',
            'iconVi': wallet['vi']['iconVi'],
            'uniqueId': uniqueId,
          });

          walletNamesSet.add(walletName);
        }

        print('Final wallets list: $wallets');
        print('Wallet names: $walletNamesSet');

        setState(() {
          _allWallets = wallets;
          _walletNames = walletNamesSet.toList()..sort();
          _isLoading = false;

          // Reset selections khi load lại
          _selectedWalletName = null;
          _selectedWalletAccount = null;
          _filteredAccounts = [];
          _walletBalance = 0.0;
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

  void _onWalletNameChanged(String? walletName) {
    setState(() {
      _selectedWalletName = walletName;
      _selectedWalletAccount = null;
      _walletBalance = 0.0;
      _isLoadingAccounts = true;
    });

    if (walletName != null) {
      // Lọc tài khoản theo tên ví
      final filteredAccounts =
          _allWallets.where((wallet) => wallet['tenVi'] == walletName).toList();

      setState(() {
        _filteredAccounts = filteredAccounts;
        _isLoadingAccounts = false;

        // Tự động chọn tài khoản đầu tiên nếu có
        if (_filteredAccounts.isNotEmpty) {
          _selectedWalletAccount = _filteredAccounts[0]['uniqueId'] as String;
          _walletBalance = _filteredAccounts[0]['soDu'];
        }
      });
    } else {
      setState(() {
        _filteredAccounts = [];
        _isLoadingAccounts = false;
      });
    }
  }

  void _onWalletAccountChanged(String? accountId) {
    if (accountId != null) {
      final selectedAccount = _filteredAccounts.firstWhere(
        (w) => w['uniqueId'] == accountId,
        orElse: () => _filteredAccounts.first,
      );

      setState(() {
        _selectedWalletAccount = accountId;
        _walletBalance = selectedAccount['soDu'];
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response = await http.get(
        Uri.parse('https://10.0.2.2:7283/api/HangMuc/user/${widget.maKH}'),
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
                  'maDanhMuc': category['maHangMuc'],
                  'tenDanhMuc': category['tenDanhMucNguoiDung'],
                  'thuChi': category['thuChi'],
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
    final Color primaryBlue = Colors.blue[700]!;
    final Color lightBlue = Colors.blue[50]!;

    return DefaultTabController(
      length: 2,
      initialIndex: _selectedType == 'Thu' ? 0 : 1,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Nhập vào'),
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            onTap: (index) {
              setState(() {
                _selectedType = index == 0 ? 'Thu' : 'Chi';
                _selectedCategory = null;
              });
            },
            tabs: const [Tab(text: 'Thu'), Tab(text: 'Chi')],
          ),
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
                : TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildTransactionForm(
                      context,
                      'Thu',
                      primaryBlue,
                      lightBlue,
                    ),
                    _buildTransactionForm(
                      context,
                      'Chi',
                      primaryBlue,
                      lightBlue,
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildTransactionForm(
    BuildContext context,
    String type,
    Color primaryBlue,
    Color lightBlue,
  ) {
    // Chỉ hiển thị form nếu đúng tab
    if (_selectedType != type) {
      return const SizedBox.shrink();
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card số dư ví
            Card(
              color: lightBlue,
              elevation: 6,
              shadowColor: primaryBlue.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    const Text(
                      'Số dư ví',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      NumberFormat('#,###', 'en_US').format(_walletBalance) +
                          ' VND',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Tên ví
            _buildLabel('Chọn tên ví'),
            const SizedBox(height: 6),
            DecoratedBox(
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedWalletName,
                decoration: _inputDecoration(),
                items:
                    _walletNames.map<DropdownMenuItem<String>>((name) {
                      return DropdownMenuItem<String>(
                        value: name,
                        child: Text(name),
                      );
                    }).toList(),
                onChanged: _onWalletNameChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn tên ví';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 18),
            // Tài khoản ví
            _buildLabel('Chọn tài khoản ví'),
            const SizedBox(height: 6),
            DecoratedBox(
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedWalletAccount,
                decoration: _inputDecoration(
                  suffixIcon:
                      _isLoadingAccounts
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : null,
                ),
                items:
                    _filteredAccounts.map<DropdownMenuItem<String>>((account) {
                      return DropdownMenuItem<String>(
                        value: account['uniqueId'] as String,
                        child: Text(account['tenTaiKhoan']),
                      );
                    }).toList(),
                onChanged:
                    _selectedWalletName != null
                        ? _onWalletAccountChanged
                        : null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn tài khoản ví';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 18),
            // Danh mục
            _buildLabel('Chọn danh mục'),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => HangMucScreen(maNguoiDung: widget.maKH),
                  ),
                );
                if (result != null && result is Map<String, dynamic>) {
                  setState(() {
                    _selectedCategory = result['maDanhMuc'].toString();
                    // Lưu luôn tên danh mục để hiển thị
                    _selectedCategoryName = result['tenDanhMuc'] as String?;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // Nếu đã chọn thì hiện tên, chưa chọn thì hiện mặc định
                      _selectedCategoryName ?? 'Chọn danh mục',
                      style: TextStyle(color: Colors.blue[700], fontSize: 16),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Số tiền
            _buildLabel('Số tiền'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _amountController,
              decoration: _inputDecoration(hintText: 'Nhập số tiền'),
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số tiền';
                }
                String cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (double.tryParse(cleanValue) == null) {
                  return 'Số tiền không hợp lệ';
                }
                final amount = double.parse(cleanValue);
                if (amount <= 0) {
                  return 'Số tiền phải lớn hơn 0';
                }
                if (_selectedType == 'Chi' && _selectedWalletAccount != null) {
                  final selectedAccount = _filteredAccounts.firstWhere(
                    (w) => w['uniqueId'] == _selectedWalletAccount,
                    orElse: () => _filteredAccounts.first,
                  );
                  double currentBalance = selectedAccount['soDu'];
                  if (amount > currentBalance) {
                    return 'Số dư không đủ';
                  }
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
              onPressed: _showConfirmationDialog,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Lưu giao dịch',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionSummary() {
    String walletName =
        _selectedWalletAccount != null
            ? _filteredAccounts.firstWhere(
              (w) => w['uniqueId'] == _selectedWalletAccount,
              orElse: () => {'tenTaiKhoan': 'Không có tài khoản'},
            )['tenTaiKhoan']
            : 'Không có tài khoản';

    String type = _selectedType;
    String amount = _amountController.text;
    String note = _noteController.text;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Thông tin giao dịch'),
            content: Text(
              'Tài khoản: $walletName\nLoại: $type\nSố tiền: $amount\nGhi chú: $note',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  void _showConfirmationDialog() {
    String walletName =
        _selectedWalletAccount != null
            ? _filteredAccounts.firstWhere(
              (w) => w['uniqueId'] == _selectedWalletAccount,
              orElse: () => {'tenTaiKhoan': 'Không có tài khoản'},
            )['tenTaiKhoan']
            : 'Không có tài khoản';

    String type = _selectedType;
    String amount = _amountController.text;
    String note = _noteController.text;
    String categoryName = _selectedCategoryName ?? 'Chưa chọn';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận giao dịch'),
            content: Text(
              'Tài khoản: $walletName\n'
              'Loại: $type\n'
              'Danh mục: $categoryName\n' // <-- Thêm dòng này
              'Số tiền: $amount\n'
              'Ghi chú: $note\n\n'
              'Bạn có muốn lưu giao dịch này?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _saveTransaction();
                },
                child: const Text('Xác nhận'),
              ),
            ],
          ),
    );
  }

  Future<void> _saveTransaction() async {
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn danh mục!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_selectedWalletAccount == null) {
          throw Exception('Vui lòng chọn tài khoản ví');
        }

        final selectedAccount = _filteredAccounts.firstWhere(
          (w) => w['uniqueId'] == _selectedWalletAccount,
          orElse: () => throw Exception('Không tìm thấy tài khoản đã chọn'),
        );

        print('Selected account: $selectedAccount');

        double currentBalance = selectedAccount['soDu']?.toDouble() ?? 0.0;

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

        String cleanAmount = _amountController.text.replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );
        double amount = double.parse(cleanAmount);

        if (_selectedType == 'Chi' && amount > currentBalance) {
          throw Exception(
            'Số dư không đủ. Số dư hiện tại: ${NumberFormat('#,###', 'en_US').format(currentBalance)} VND',
          );
        }

        double newBalance =
            _selectedType == 'Thu'
                ? currentBalance + amount
                : currentBalance - amount;

        print('Current balance: $currentBalance');
        print('Amount: $amount');
        print('New balance: $newBalance');
        print('Wallet maVi: ${selectedAccount['maVi']}');
        print('Category ID: $_selectedCategory');

        final response = await http.post(
          Uri.parse('https://10.0.2.2:7283/api/GiaoDich'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({
            'maNguoiDung': widget.maKH,
            'maVi': selectedAccount['maVi'],
            'maHangMuc':
                _selectedCategory, // <-- Đảm bảo đúng tên trường backend
            'soTien': amount,
            'soTienCu': currentBalance,
            'soTienMoi': newBalance,
            'ghiChu': _noteController.text,
            'ngayGiaoDich': DateTime.now().toIso8601String(),
            'loaiGiaoDich': _selectedType,
            'maViNhan': null,
          }),
        );

        print(
          'Transaction request body: ${json.encode({
            'maNguoiDung': widget.maKH,
            'maVi': selectedAccount['maVi'],
            'maHangMuc': _selectedCategory, // <-- Đảm bảo đúng tên trường backend
            'soTien': amount,
            'soTienCu': currentBalance,
            'soTienMoi': newBalance,
            'ghiChu': _noteController.text,
            'ngayGiaoDich': DateTime.now().toIso8601String(),
            'loaiGiaoDich': _selectedType,
            'maViNhan': null,
          })}',
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final giaoDichData = json.decode(response.body);
          print('Giao dịch được tạo thành công: ${response.body}');

          try {
            // Cập nhật số dư ví trong cơ sở dữ liệu
            await _updateWalletBalance(
              selectedAccount['maVi'],
              selectedAccount['tenTaiKhoan'],
              newBalance,
            );

            await _saveTransactionHistory(
              giaoDichData['maGiaoDich'],
              currentBalance,
              newBalance,
            );
            await _updateSoTienHienTai(_selectedCategory!);

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

            // Cập nhật số dư trong danh sách tài khoản local
            setState(() {
              final accountIndex = _filteredAccounts.indexWhere(
                (w) => w['uniqueId'] == _selectedWalletAccount,
              );
              if (accountIndex != -1) {
                _filteredAccounts[accountIndex]['soDu'] = newBalance;
                _walletBalance = newBalance;
              }

              // Cập nhật trong _allWallets
              final allAccountIndex = _allWallets.indexWhere(
                (w) => w['uniqueId'] == _selectedWalletAccount,
              );
              if (allAccountIndex != -1) {
                _allWallets[allAccountIndex]['soDu'] = newBalance;
              }
            });

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
            print('Lỗi khi lưu lịch sử giao dịch hoặc cập nhật số dư: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Giao dịch đã được tạo nhưng lỗi khi cập nhật: $e',
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

  // Sửa method _updateWalletBalance để sử dụng đúng API
  Future<void> _updateWalletBalance(
    int maVi,
    String tenTaiKhoan,
    double newBalance,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(
          'https://10.0.2.2:7283/api/ViNguoiDung/${widget.maKH}/$maVi/${Uri.encodeComponent(tenTaiKhoan)}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'tenTaiKhoan': tenTaiKhoan,
          'maLoaiTien': 1, // Mặc định luôn là 1
          'dienGiai': 'Cập nhật số dư từ giao dịch',
          'soDu': newBalance,
        }),
      );

      print(
        'Update balance request: maVi=$maVi, tenTaiKhoan=$tenTaiKhoan, newBalance=$newBalance',
      );
      print(
        'Update balance request body: ${json.encode({'tenTaiKhoan': tenTaiKhoan, 'maLoaiTien': 1, 'dienGiai': 'Cập nhật số dư từ giao dịch', 'soDu': newBalance})}',
      );
      print('Update balance response status: ${response.statusCode}');
      print('Update balance response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Lỗi khi cập nhật số dư ví: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Lỗi khi cập nhật số dư ví: $e');
      throw Exception('Lỗi khi cập nhật số dư ví: $e');
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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HangMucScreen(maNguoiDung: widget.maKH),
      ),
    );
    if (result != null && result is String) {
      setState(() {
        selectedCategory = result;
      });
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 2),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.blue[700],
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.transparent,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue[100]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue[100]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue[700]!),
      ),
      labelStyle: TextStyle(color: Colors.blue[700]),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 16,
      ), // <-- Đặt ở đây!
    );
  }

  Future<void> _updateSoTienHienTai(String maHangMuc) async {
    final response = await http.put(
      Uri.parse(
        'https://10.0.2.2:7283/api/HangMuc/capnhat-sotienhientai/$maHangMuc',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      print('Lỗi cập nhật sotienhientai: ${response.body}');
    }
  }
}

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
