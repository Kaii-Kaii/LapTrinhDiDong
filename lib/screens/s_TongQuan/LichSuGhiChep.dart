import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:qltncn/screens/services/cloudinary_service.dart';
import 'TongQuan.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Transaction {
  final int maLichSu;
  final int maGiaoDich;
  final String hanhDong;
  final double? soTienCu;
  final double soTienMoi;
  final String thucHienBoi;
  final DateTime thoiGian;
  final String ghiChu;
  final String loaiGiaoDich;
  final String? tenVi;
  final String? tenDanhMucNguoiDung;
  final double? soTienGiaoDich;
  final int? maVi;
  final String? maHangMuc;

  Transaction({
    required this.maLichSu,
    required this.maGiaoDich,
    required this.hanhDong,
    this.soTienCu,
    required this.soTienMoi,
    required this.thucHienBoi,
    required this.thoiGian,
    required this.ghiChu,
    required this.loaiGiaoDich,
    this.tenVi,
    this.tenDanhMucNguoiDung,
    this.soTienGiaoDich,
    this.maVi,
    this.maHangMuc,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    try {
      print('Processing transaction JSON:');
      print('Raw JSON: $json');
      print('giaoDich data: ${json['giaoDich']}');
      print('vi data: ${json['giaoDich']?['vi']}');
      print('danhMucNguoiDung data: ${json['giaoDich']?['danhMucNguoiDung']}');
      return Transaction(
        maLichSu: json['maLichSu'] ?? 0,
        maGiaoDich: json['maGiaoDich'] ?? 0,
        hanhDong: json['hanhDong']?.toString() ?? '',
        soTienCu: json['soTienCu']?.toDouble(),
        soTienMoi: (json['soTienMoi'] ?? 0).toDouble(),
        thucHienBoi: json['thucHienBoi']?.toString().trim() ?? '',
        thoiGian:
            json['thoiGian'] != null
                ? DateTime.parse(json['thoiGian'].toString())
                : DateTime.now(),
        ghiChu: json['giaoDich']?['ghiChu']?.toString() ?? '',
        loaiGiaoDich: json['giaoDich']?['loaiGiaoDich']?.toString() ?? '',
        tenVi: json['giaoDich']?['vi']?['tenVi']?.toString(),
        tenDanhMucNguoiDung:
            json['giaoDich']?['danhMucNguoiDung']?['tenDanhMucNguoiDung']
                ?.toString(),
        soTienGiaoDich: json['giaoDich']?['soTien']?.toDouble(),
        maVi: json['giaoDich']?['maVi'],
        maHangMuc: json['giaoDich']?['maHangMuc'],
      );
    } catch (e) {
      print('Error parsing transaction: $e');
      rethrow;
    }
  }
}

class LichSuGhiChep extends StatefulWidget {
  final String maKH;
  const LichSuGhiChep({super.key, required this.maKH});

  @override
  State<LichSuGhiChep> createState() => _LichSuGhiChepState();
}

class _LichSuGhiChepState extends State<LichSuGhiChep> {
  List<Transaction> allTransactions = [];
  List<Transaction> filteredTransactions = [];
  bool isLoading = true;
  String? error;
  DateTime selectedDate = DateTime.now();
  bool showAllTransactions = false;
  Map<int, String> viNames = {};
  Map<String, String> danhMucNames = {};
  bool showBalance = false;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  List<Map<String, dynamic>> danhSachHangMuc = [];
  String? selectedHangMuc; // Mã hạng mục được chọn

  @override
  void initState() {
    super.initState();
    fetchTransactions();
    fetchDanhSachHangMuc();
  }

  Future<void> fetchViDetails(int maVi) async {
    if (viNames.containsKey(maVi)) return;

    try {
      final response = await http.get(
        Uri.parse('https://10.0.2.2:7283/api/Vi/$maVi'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          viNames[maVi] = data['tenVi']?.toString() ?? 'Không xác định';
        });
      }
    } catch (e) {
      print('Error fetching vi details: $e');
    }
  }

  Future<void> fetchDanhMucDetails(String maHangMuc) async {
    if (danhMucNames.containsKey(maHangMuc)) return;

    try {
      final response = await http.get(
        Uri.parse('https://10.0.2.2:7283/api/HangMuc/$maHangMuc'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          danhMucNames[maHangMuc] =
              data['tenhangmuc']?.toString() ?? 'Không xác định';
        });
      }
    } catch (e) {
      print('Error fetching hang muc details: $e');
    }
  }

  Future<void> fetchTransactions() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://10.0.2.2:7283/api/LichSuGiaoDich/nguoidung/${widget.maKH}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Transaction> transactionList =
            data.map((json) => Transaction.fromJson(json)).toList();

        // Fetch vi and danh muc details for each transaction
        for (var transaction in transactionList) {
          if (transaction.maVi != null) {
            await fetchViDetails(transaction.maVi!);
          }
          if (transaction.maHangMuc != null) {
            await fetchDanhMucDetails(transaction.maHangMuc!);
          }
        }

        setState(() {
          allTransactions = transactionList;
          _filterTransactionsByDate();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Lỗi: ${response.statusCode} - ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      setState(() {
        error = 'Lỗi kết nối: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchDanhSachHangMuc() async {
    try {
      final response = await http.get(
        Uri.parse('https://10.0.2.2:7283/api/HangMuc/user/${widget.maKH}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          danhSachHangMuc = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print('Error fetching danh sách hạng mục: $e');
    }
  }

  void _filterTransactionsByDate() {
    // Sort transactions by date in descending order (newest first)
    allTransactions.sort((a, b) => b.thoiGian.compareTo(a.thoiGian));

    // Group transactions by maGiaoDich and keep only the latest update for each
    Map<int, Transaction> latestTransactions = {};
    for (var transaction in allTransactions) {
      if (!latestTransactions.containsKey(transaction.maGiaoDich)) {
        // For new transactions (hanhDong == 'TaoMoi'), always show them
        if (transaction.hanhDong == 'TaoMoi') {
          latestTransactions[transaction.maGiaoDich] = transaction;
        } else {
          // For updates, only keep the latest one
          latestTransactions[transaction.maGiaoDich] = transaction;
        }
      }
    }

    // Convert the map values back to a list
    List<Transaction> uniqueTransactions = latestTransactions.values.toList();
    // Sort again by date
    uniqueTransactions.sort((a, b) => b.thoiGian.compareTo(a.thoiGian));

    if (showAllTransactions) {
      // Show all transactions
      filteredTransactions = uniqueTransactions;
    } else {
      // Filter by selected date
      filteredTransactions =
          uniqueTransactions.where((transaction) {
            return transaction.thoiGian.year == selectedDate.year &&
                transaction.thoiGian.month == selectedDate.month &&
                transaction.thoiGian.day == selectedDate.day;
          }).toList();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        showAllTransactions = false; // Reset to date filter mode
        _filterTransactionsByDate();
      });
    }
  }

  Future<void> _showEditDialog(Transaction transaction) async {
    _amountController.text = transaction.soTienGiaoDich?.toString() ?? '0';
    selectedHangMuc = transaction.maHangMuc;
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Chỉnh sửa giao dịch',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ví: ${viNames[transaction.maVi] ?? 'Đang tải...'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Danh mục: ${danhMucNames[transaction.maHangMuc] ?? 'Đang tải...'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Loại giao dịch: ${transaction.loaiGiaoDich}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ghi chú: ${transaction.ghiChu}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
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
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập số tiền';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Số tiền không hợp lệ';
                      }
                      final amount = double.parse(value);
                      if (amount <= 0) {
                        return 'Số tiền phải lớn hơn 0';
                      }
                      if (transaction.loaiGiaoDich == "Chi") {
                        final currentBalance = transaction.soTienCu ?? 0;
                        final oldAmount = transaction.soTienGiaoDich ?? 0;
                        final difference = amount - oldAmount;
                        if (difference > 0 && currentBalance < difference) {
                          return 'Số dư không đủ';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedHangMuc ?? transaction.maHangMuc,
                    decoration: InputDecoration(
                      labelText: 'Hạng mục',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items:
                        danhSachHangMuc.map((hm) {
                          return DropdownMenuItem<String>(
                            value: hm['mahangmuc'],
                            child: Text(hm['tenhangmuc']),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedHangMuc = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final newAmount = double.parse(
                            _amountController.text,
                          );
                          final oldAmount = transaction.soTienGiaoDich ?? 0;

                          // Calculate the difference in amount
                          final amountDifference = newAmount - oldAmount;

                          // Calculate new balances based on transaction type
                          double newSoTienCu = transaction.soTienCu ?? 0;
                          double newSoTienMoi;

                          if (transaction.loaiGiaoDich == "Thu") {
                            // For income, subtract old amount and add new amount
                            newSoTienMoi = newSoTienCu + amountDifference;
                          } else {
                            // For expense, add old amount and subtract new amount
                            newSoTienMoi = newSoTienCu - amountDifference;

                            // Check if there's enough balance for expense
                            if (amountDifference > 0 &&
                                newSoTienCu < amountDifference) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Không đủ số dư để thực hiện giao dịch này',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                          }

                          final response = await http.put(
                            Uri.parse(
                              'https://10.0.2.2:7283/api/GiaoDich/${transaction.maGiaoDich}',
                            ),
                            headers: {
                              'Content-Type': 'application/json',
                              'Accept': 'application/json',
                            },
                            body: jsonEncode({
                              'maGiaoDich': transaction.maGiaoDich,
                              'maNguoiDung': widget.maKH,
                              'maVi': transaction.maVi,
                              'maHangMuc':
                                  selectedHangMuc ?? transaction.maHangMuc,
                              'soTien': newAmount,
                              'soTienCu': newSoTienCu,
                              'soTienMoi': newSoTienMoi,
                              'ghiChu': transaction.ghiChu,
                              'ngayGiaoDich':
                                  transaction.thoiGian.toIso8601String(),
                              'loaiGiaoDich': transaction.loaiGiaoDich,
                              'maViNhan': null,
                            }),
                          );

                          if (response.statusCode == 200) {
                            // Create new transaction history entry with updated balances
                            await _createTransactionHistory(
                              transaction.maGiaoDich,
                              newSoTienCu,
                              newSoTienMoi,
                              'CapNhat',
                            );

                            // Notify other screens about the transaction update
                            transactionUpdateController.add(null);

                            // Refresh the transaction list
                            await fetchTransactions();
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Cập nhật giao dịch thành công',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            throw Exception(
                              'Lỗi khi cập nhật giao dịch: ${response.statusCode}',
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Lưu',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  Future<void> _createTransactionHistory(
    int maGiaoDich,
    double soTienCu,
    double soTienMoi,
    String hanhDong,
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
          'hanhDong': hanhDong,
          'soTienCu': soTienCu,
          'soTienMoi': soTienMoi,
          'thucHienBoi': widget.maKH,
          'thoiGian': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 201) {
        print('Lỗi khi tạo lịch sử giao dịch: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
          'Lỗi khi tạo lịch sử giao dịch: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Lỗi khi tạo lịch sử giao dịch: $e');
      throw Exception('Lỗi khi tạo lịch sử giao dịch: $e');
    }
  }

  void _showLogDialog(
    BuildContext context,
    String message,
    Transaction transaction,
  ) {
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
  }

  Future<void> _viewTransactionImage(int maGiaoDich) async {
    try {
      final response = await http.get(
        Uri.parse('https://10.0.2.2:7283/api/AnhHoaDon/giaodich/$maGiaoDich'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Image API Response status: ${response.statusCode}');
      print('Image API Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty && data[0]['duongDanAnh'] != null) {
          String imageUrl = data[0]['duongDanAnh'];

          // Remove transformation parameters from the URL
          if (imageUrl.contains('/w_')) {
            imageUrl = imageUrl.substring(0, imageUrl.indexOf('/w_'));
          }

          print('Original URL from API: ${data[0]['duongDanAnh']}');
          print('Cleaned URL: $imageUrl');

          if (!mounted) return;
          showDialog(
            context: context,
            builder:
                (context) => Dialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.7,
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image: $error');
                            print('Stack trace: $stackTrace');
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Không thể tải ảnh',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Lỗi: $error',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Đóng'),
                      ),
                    ],
                  ),
                ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không tìm thấy ảnh giao dịch')),
          );
        }
      }
    } catch (e) {
      print('Error fetching transaction image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<void> _reuploadTransactionImage(Transaction transaction) async {
    try {
      // Show dialog to choose image source
      final source = await showDialog<String>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Chọn nguồn ảnh'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Chụp ảnh mới'),
                    onTap: () => Navigator.pop(context, 'camera'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Chọn từ thư viện'),
                    onTap: () => Navigator.pop(context, 'gallery'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.folder),
                    title: const Text('Chọn từ thư mục'),
                    onTap: () => Navigator.pop(context, 'folder'),
                  ),
                ],
              ),
            ),
      );

      if (source == null) return;

      File? imageFile;
      final picker = ImagePicker();

      if (source == 'camera') {
        final pickedFile = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 100,
        );
        if (pickedFile != null) {
          imageFile = File(pickedFile.path);
        }
      } else if (source == 'gallery') {
        final pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 100,
        );
        if (pickedFile != null) {
          imageFile = File(pickedFile.path);
        }
      } else if (source == 'folder') {
        // For folder selection, we'll use gallery source with special configuration
        final pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 100,
          // This will show the system file picker
          requestFullMetadata: true,
          // Allow selecting from any folder
          maxWidth: null,
          maxHeight: null,
        );
        if (pickedFile != null) {
          imageFile = File(pickedFile.path);
          print('Selected file path: ${pickedFile.path}');
        }
      }

      if (imageFile == null) return;

      print('Starting image upload process...');
      final imageUrl = await _cloudinaryService.uploadImage(imageFile);
      if (imageUrl == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi tải ảnh lên Cloudinary')),
        );
        return;
      }

      print('Image uploaded successfully to Cloudinary: $imageUrl');
      print(
        'Updating image URL in database for transaction: ${transaction.maGiaoDich}',
      );

      // Update image URL in database
      final response = await http.post(
        Uri.parse('https://10.0.2.2:7283/api/AnhHoaDon'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'maGiaoDich': transaction.maGiaoDich,
          'duongDanAnh': imageUrl,
        }),
      );

      print('Database update response status: ${response.statusCode}');
      print('Database update response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật ảnh thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('Error response from database: ${response.body}');
        throw Exception(
          'Lỗi khi cập nhật ảnh: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error reuploading image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        title: const Text(
          'Lịch sử ghi chép',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF03A9F4),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(showBalance ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  showBalance = !showBalance;
                });
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                showAllTransactions ? Icons.calendar_today : Icons.list,
              ),
              onPressed: () {
                setState(() {
                  showAllTransactions = !showAllTransactions;
                  _filterTransactionsByDate();
                });
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8, left: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: () => _selectDate(context),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF03A9F4), Color(0xFFF8FFFE)],
            stops: [0.0, 0.3],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF03A9F4).withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          showAllTransactions
                              ? 'Tất cả giao dịch'
                              : 'Giao dịch theo ngày',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF03A9F4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (!showAllTransactions)
                          Text(
                            DateFormat('dd/MM/yyyy').format(selectedDate),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!showAllTransactions)
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF03A9F4), Color(0xFF0288D1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF03A9F4).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            showAllTransactions = true;
                            _filterTransactionsByDate();
                          });
                        },
                        icon: const Icon(
                          Icons.list,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'Xem tất cả',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Transaction List
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child:
                    isLoading
                        ? _buildLoadingWidget()
                        : error != null
                        ? _buildErrorWidget()
                        : filteredTransactions.isEmpty
                        ? _buildEmptyWidget()
                        : _buildTransactionList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF03A9F4).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFF03A9F4),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Đang tải dữ liệu...',
            style: TextStyle(
              color: Color(0xFF03A9F4),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              error!,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF03A9F4).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              color: Colors.grey[400],
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Không có giao dịch nào',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
      itemCount: filteredTransactions.length,
      padding: const EdgeInsets.only(bottom: 20),
      itemBuilder: (context, index) {
        final transaction = filteredTransactions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF03A9F4).withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            onTap: () => _showEditDialog(transaction),
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      transaction.loaiGiaoDich == "Thu"
                          ? [Colors.green.shade400, Colors.green.shade600]
                          : [Colors.red.shade400, Colors.red.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (transaction.loaiGiaoDich == "Thu"
                            ? Colors.green
                            : Colors.red)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                transaction.loaiGiaoDich == "Thu"
                    ? Icons.trending_up
                    : Icons.trending_down,
                color: Colors.white,
                size: 24,
              ),
            ),
            title: Text(
              '${transaction.tenDanhMucNguoiDung ?? danhMucNames[transaction.maHangMuc] ?? 'Không có danh mục'}'
              '${transaction.ghiChu.isNotEmpty ? ' - ${transaction.ghiChu}' : ''}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF03A9F4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Ví: ${viNames[transaction.maVi] ?? 'Đang tải...'}',
                    style: const TextStyle(
                      color: Color(0xFF03A9F4),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format(transaction.thoiGian),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (transaction.soTienCu != null && showBalance) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Số dư cũ: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(transaction.soTienCu)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
                if (showBalance) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Số dư mới: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(transaction.soTienMoi)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF03A9F4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            trailing: SizedBox(
              width: 90, // Giảm width từ 120 xuống 90
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (transaction.soTienGiaoDich != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4, // Giảm padding
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (transaction.loaiGiaoDich == "Thu"
                                ? Colors.green
                                : Colors.red)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${transaction.loaiGiaoDich == "Thu" ? "+" : "-"}${_formatCurrency(transaction.soTienGiaoDich!)}',
                        style: TextStyle(
                          fontSize: 10, // Giảm từ 11 xuống 10
                          color:
                              transaction.loaiGiaoDich == "Thu"
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3, // Giảm padding
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF03A9F4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          transaction.hanhDong,
                          style: const TextStyle(
                            fontSize: 8, // Giảm từ 9 xuống 8
                            color: Color(0xFF03A9F4),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 28, // Giảm từ 32 xuống 28
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF03A9F4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.more_vert,
                            color: Color(0xFF03A9F4),
                            size: 16, // Giảm từ 18 xuống 16
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _showEditDialog(transaction);
                                break;
                              case 'view_image':
                                _viewTransactionImage(transaction.maGiaoDich);
                                break;
                              case 'reupload_image':
                                _reuploadTransactionImage(transaction);
                                break;
                            }
                          },
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.edit,
                                      color: Color(0xFF03A9F4),
                                    ),
                                    title: Text('Sửa số tiền'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'view_image',
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.image,
                                      color: Color(0xFF03A9F4),
                                    ),
                                    title: Text('Xem ảnh giao dịch'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'reupload_image',
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.upload,
                                      color: Color(0xFF03A9F4),
                                    ),
                                    title: Text('Tải lại ảnh'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Thêm hàm format currency ngắn gọn hơn
  String _formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B₫';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M₫';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K₫';
    } else {
      return '${amount.toStringAsFixed(0)}₫';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
