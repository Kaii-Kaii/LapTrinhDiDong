import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    try {
      return Transaction(
        maLichSu: json['maLichSu'] ?? 0,
        maGiaoDich: json['maGiaoDich'] ?? 0,
        hanhDong: json['hanhDong']?.toString() ?? 'Không xác định',
        soTienCu: json['soTienCu']?.toDouble(),
        soTienMoi: (json['soTienMoi'] ?? 0).toDouble(),
        thucHienBoi: json['thucHienBoi']?.toString().trim() ?? 'Không xác định',
        thoiGian:
            json['thoiGian'] != null
                ? DateTime.parse(json['thoiGian'].toString())
                : DateTime.now(),
        ghiChu: json['giaoDich']?['ghiChu']?.toString() ?? '',
        loaiGiaoDich:
            json['giaoDich']?['loaiGiaoDich']?.toString() ?? 'Không xác định',
        tenVi: json['giaoDich']?['vi']?['tenVi']?.toString(),
        tenDanhMucNguoiDung:
            json['giaoDich']?['danhMucNguoiDung']?['tenDanhMucNguoiDung']
                ?.toString(),
        soTienGiaoDich: json['giaoDich']?['soTien']?.toDouble(),
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

  @override
  void initState() {
    super.initState();
    fetchTransactions();
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

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Transaction> transactionList =
            data.map((json) => Transaction.fromJson(json)).toList();

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

  void _filterTransactionsByDate() {
    // Sort transactions by date in descending order (newest first)
    allTransactions.sort((a, b) => b.thoiGian.compareTo(a.thoiGian));

    if (showAllTransactions) {
      // Show all transactions
      filteredTransactions = allTransactions;
    } else {
      // Filter by selected date
      filteredTransactions =
          allTransactions.where((transaction) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử ghi chép'),
        actions: [
          IconButton(
            icon: Icon(showAllTransactions ? Icons.calendar_today : Icons.list),
            onPressed: () {
              setState(() {
                showAllTransactions = !showAllTransactions;
                _filterTransactionsByDate();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  showAllTransactions
                      ? 'Tất cả giao dịch'
                      : 'Ngày: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!showAllTransactions)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        showAllTransactions = true;
                        _filterTransactionsByDate();
                      });
                    },
                    icon: Icon(Icons.list),
                    label: Text('Xem tất cả'),
                  ),
              ],
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : error != null
                    ? Center(
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                    : filteredTransactions.isEmpty
                    ? const Center(child: Text('Không có giao dịch nào'))
                    : ListView.builder(
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: Icon(
                              transaction.loaiGiaoDich == "Thu"
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color:
                                  transaction.loaiGiaoDich == "Thu"
                                      ? Colors.green
                                      : Colors.red,
                            ),
                            title: Text(transaction.ghiChu),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${transaction.tenVi ?? "Không xác định"} - ${transaction.tenDanhMucNguoiDung ?? "Không xác định"}',
                                ),
                                Text(
                                  'Thời gian: ${DateFormat('dd/MM/yyyy HH:mm').format(transaction.thoiGian)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (transaction.soTienCu != null)
                                  Text(
                                    'Số dư cũ: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(transaction.soTienCu)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                Text(
                                  'Số dư mới: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(transaction.soTienMoi)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (transaction.soTienGiaoDich != null)
                                  Text(
                                    '${transaction.loaiGiaoDich == "Thu" ? "+" : "-"}${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(transaction.soTienGiaoDich)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          transaction.loaiGiaoDich == "Thu"
                                              ? Colors.green
                                              : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                Text(
                                  transaction.hanhDong,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
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
}
