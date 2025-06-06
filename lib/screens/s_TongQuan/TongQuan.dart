import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:qltncn/model/KhachHang/khachhang_service.dart';
import 'dart:math';
import 'LichSuGhiChep.dart';
import 'ThemHanMucChi.dart';
import 'ThemChuyenDi.dart';
import 'TraCuuTyGia.dart';
import 'package:qltncn/model/Vi/ViNguoiDung/ViNguoiDung.dart';
import 'package:qltncn/model/Vi/ViNguoiDung/ViNguoiDung_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:qltncn/screens/s_Khac/TienIch/TyGiaScreen.dart';
import 'package:qltncn/screens/s_Khac/TienIch/TinhThueThuNhapCaNhanScreen.dart';
import 'package:qltncn/screens/s_Khac/TienIch/TinhLaiVayScreen.dart';
import 'package:qltncn/screens/s_Khac/TienIch/TinhLaiTienGui.dart';
import 'package:qltncn/screens/s_Khac/TienIch/ChiaTien.dart';

// Add a global StreamController to handle transaction updates
final StreamController<void> transactionUpdateController =
    StreamController<void>.broadcast();

class TongQuanScreen extends StatefulWidget {
  final String userName;
  final String maKH;

  @override
  _TongQuanScreenState createState() => _TongQuanScreenState();
  const TongQuanScreen({super.key, required this.userName, required this.maKH});
}

class _TongQuanScreenState extends State<TongQuanScreen>
    with WidgetsBindingObserver {
  // Màu chủ đạo
  final Color primaryColor = const Color(0xFF03A9F4);
  final Color backgroundColor = const Color(0xFFF8FAFB);

  Map<String, double> incomeData = {};
  Map<String, Map<String, dynamic>> expenseData = {};
  double totalIncome = 0;
  double totalExpense = 0;
  int touchedIndex = -1;

  String selectedFilter = "Tháng";
  String selectedTimePeriod = "Tháng này";
  DateTime selectedDate = DateTime.now();

  late String userName;
  late String maKH;
  String? hoTenKhachHang;

  final FocusNode _focusNode = FocusNode();

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  StreamSubscription? _transactionUpdateSubscription;

  Future<void> _loadDanhSachVi() async {
    final data = await ViNguoiDungService.fetchViNguoiDungByMaKhachHang(
      widget.maKH,
    );
    setState(() {
      danhSachVi = data;
    });
  }

  Future<void> _loadKhachHang() async {
    final khachHang = await KhachHangService.fetchKhachHangByMaKH(widget.maKH);
    if (khachHang != null &&
        khachHang.hoTen != null &&
        khachHang.hoTen!.isNotEmpty) {
      setState(() {
        hoTenKhachHang = khachHang.hoTen;
      });
    }
  }

  Future<void> _loadBalanceVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    bool? savedVisibility = prefs.getBool('isBalanceVisible');
    if (savedVisibility != null) {
      setState(() {
        isBalanceVisible = savedVisibility;
      });
    }
  }

  Future<void> _saveBalanceVisibility(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBalanceVisible', value);
  }

  List<ViNguoiDung> danhSachVi = [];
  double get tongSoDu {
    return danhSachVi.fold(0.0, (sum, vi) => sum + vi.soDu);
  }

  // thêm dấu . vào tongSoDu
  String get formattedTongSoDu {
    return tongSoDu
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  bool isBalanceVisible = true;

  final List<Color> availableColors = [
    Colors.blue.shade400,
    Colors.red.shade400,
    Colors.green.shade400,
    Colors.orange.shade400,
    Colors.purple.shade400,
    Colors.teal.shade400,
    Colors.pink.shade400,
    Colors.amber.shade400,
    Colors.indigo.shade400,
    Colors.cyan.shade400,
  ];

  Map<String, bool> cardVisibility = {
    'Tình hình thu chi': true,
    'Hạn mức chi': true,
    'Tiện ích khác': true,
  };
  String getShortName(String fullName) {
    List<String> parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[parts.length - 2]} ${parts[parts.length - 1]}';
    } else {
      return fullName;
    }
  }

  Map<String, bool> tempCardVisibility = {};

  @override
  void initState() {
    super.initState();
    userName = widget.userName;
    maKH = widget.maKH;

    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    endDate = DateTime(now.year, now.month + 1, 0);

    _loadDanhSachVi();
    _loadKhachHang();
    _loadBalanceVisibility();
    _loadTransactionData();

    _focusNode.addListener(_onFocusChange);

    _transactionUpdateSubscription = transactionUpdateController.stream.listen((
      _,
    ) {
      _refreshData();
    });
    fetchExpenseData();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _loadDanhSachVi();
      _loadKhachHang();
    }
  }

  Future<void> _refreshData() async {
    await _loadDanhSachVi();
    await _loadTransactionData();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _transactionUpdateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadTransactionData() async {
    try {
      String formattedStartDate =
          "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}T00:00:00";
      String formattedEndDate =
          "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}T23:59:59";

      print(
        'Fetching transactions from $formattedStartDate to $formattedEndDate',
      ); // Debug log

      final response = await http.get(
        Uri.parse(
          'https://10.0.2.2:7283/api/LichSuGiaoDich/nguoidung/$maKH/thoigian?startDate=$formattedStartDate&endDate=$formattedEndDate',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Received ${data.length} transactions'); // Debug log

        // Reset totals
        double totalThu = 0;
        double totalChi = 0;

        Map<String, dynamic> latestTransactions = {};

        for (var transaction in data) {
          if (transaction['giaoDich'] != null) {
            final giaoDich = transaction['giaoDich'];
            final maGiaoDich = giaoDich['maGiaoDich']?.toString();
            final hanhDong = transaction['hanhDong']?.toString();
            final thoiGian = transaction['thoiGian']?.toString();

            print(
              'Processing transaction: maGiaoDich=$maGiaoDich, hanhDong=$hanhDong, thoiGian=$thoiGian',
            ); // Debug log

            if (maGiaoDich != null) {
              if (hanhDong == 'TaoMoi') {
                latestTransactions[maGiaoDich] = transaction;
                print('Added new transaction: $maGiaoDich'); // Debug log
              } else if (hanhDong == 'CapNhat') {
                final currentDate = DateTime.parse(thoiGian ?? '');
                final existingDate =
                    latestTransactions[maGiaoDich] != null
                        ? DateTime.parse(
                          latestTransactions[maGiaoDich]['thoiGian'] ?? '',
                        )
                        : DateTime(1900);

                if (currentDate.isAfter(existingDate)) {
                  latestTransactions[maGiaoDich] = transaction;
                  print(
                    'Updated transaction: $maGiaoDich with date ${currentDate.toString()}',
                  ); // Debug log
                }
              }
            }
          }
        }

        print('Filtered to ${latestTransactions.length} transactions');
        for (var transaction in latestTransactions.values) {
          if (transaction['giaoDich'] != null) {
            final giaoDich = transaction['giaoDich'];
            final soTien = giaoDich['soTien']?.toDouble() ?? 0;
            final loaiGiaoDich = giaoDich['loaiGiaoDich']?.toString() ?? '';

            if (loaiGiaoDich == 'Thu') {
              totalThu += soTien;
            } else if (loaiGiaoDich == 'Chi') {
              totalChi += soTien;
            }
          }
        }

        setState(() {
          totalIncome = totalThu;
          totalExpense = totalChi;
        });
      } else {
        print('Error loading transaction data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading transaction data: $e');
    }
  }

  Future<void> fetchExpenseData() async {
    final response = await http.get(
      Uri.parse('https://10.0.2.2:7283/api/HangMuc/user/$maKH'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final Map<String, Map<String, dynamic>> temp = {};
      for (var hm in data) {
        if (hm['loai'] == 'chi' && hm['toida'] != null) {
          temp[hm['tenhangmuc']] = {
            'toida': hm['toida'],
            'sotienhientai': hm['sotienhientai'] ?? 0,
            'mahangmuc': hm['mahangmuc'],
          };
        }
      }
      setState(() {
        expenseData = temp;
      });
    }
  }

  void _updateDateRange(String timePeriod) {
    final now = DateTime.now();
    setState(() {
      selectedTimePeriod = timePeriod;
      switch (timePeriod) {
        case 'Hôm nay':
          startDate = DateTime(now.year, now.month, now.day);
          endDate = startDate;
          break;
        case 'Tuần này':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          endDate = startDate.add(Duration(days: 6));
          break;
        case 'Tháng này':
          startDate = DateTime(now.year, now.month, 1);
          endDate = DateTime(now.year, now.month + 1, 0);
          break;
        case 'Quý này':
          final quarter = ((now.month - 1) ~/ 3) * 3 + 1;
          startDate = DateTime(now.year, quarter, 1);
          endDate = DateTime(now.year, quarter + 3, 0);
          break;
        case 'Năm nay':
          startDate = DateTime(now.year, 1, 1);
          endDate = DateTime(now.year, 12, 31);
          break;
      }
    });
    print(
      'Date range updated: ${startDate.toString()} to ${endDate.toString()}',
    ); // Debug log
    _loadTransactionData();
  }

  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      // _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    double currentBalance = totalIncome - totalExpense;
    return Focus(
      focusNode: _focusNode,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withOpacity(0.1),
                backgroundColor,
                backgroundColor,
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor.withOpacity(0.8), primaryColor],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Xin chào!",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${hoTenKhachHang != null ? getShortName(hoTenKhachHang!) : userName}",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    _refreshData();
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.notifications,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    // TODO: Implement notification functionality
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Balance Card trong header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.95),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Số dư hiện tại${isBalanceVisible ? "" : " (Ẩn)"}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      isBalanceVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: primaryColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isBalanceVisible = !isBalanceVisible;
                                      });
                                      _saveBalanceVisibility(isBalanceVisible);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isBalanceVisible
                                  ? "${formattedTongSoDu} đ"
                                  : "****** đ",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color:
                                    currentBalance >= 0
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Charts Section - Chỉ 3 card cố định
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildIncomeChartCard("Tình hình thu chi", incomeData),
                      const SizedBox(height: 16),
                      _buildExpenseChartCard("Hạn mức chi", expenseData),
                      const SizedBox(height: 16),
                      _buildUtilitiesCard(),
                      const SizedBox(height: 16),
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

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.08),
            Colors.white.withOpacity(0.95),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 8,
            offset: const Offset(-4, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, color.withOpacity(0.02)],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: color.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Số tiền:",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  NumberFormat.currency(
                    locale: 'vi_VN',
                    symbol: '',
                  ).format(amount).replaceAll(',', '.'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: color,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                        color: color.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
                Text(
                  "đ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeChartCard(String title, Map<String, double> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, primaryColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withOpacity(0.1),
                      primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.analytics_rounded,
                        color: primaryColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withOpacity(0.1),
                      primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LichSuGhiChep(maKH: widget.maKH),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.history_rounded,
                    size: 18,
                    color: primaryColor,
                  ),
                  label: Text(
                    "Lịch sử",
                    style: TextStyle(
                      fontSize: 14,
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.withOpacity(0.25),
                      Colors.green.withOpacity(0.15),
                      Colors.white,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.green.withOpacity(
                              0.3,
                            ), // Tăng từ 0.2 lên 0.3
                            Colors.green.withOpacity(
                              0.2,
                            ), // Tăng từ 0.1 lên 0.2
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(
                              0.4,
                            ), // Tăng từ 0.3 lên 0.4
                            blurRadius: 8, // Tăng từ 6 lên 8
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.trending_up_rounded,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Thu",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color:
                                  Colors.green.shade700, // Thay đổi để đậm hơn
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Số tiền:",
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Colors
                                      .grey[700], // Thay đổi từ grey[600] thành grey[700]
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            NumberFormat.currency(
                              locale: 'vi_VN',
                              symbol: '',
                            ).format(totalIncome).replaceAll(',', '.'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color:
                                  Colors.green.shade700, // Thay đổi để đậm hơn
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            "đ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color:
                                  Colors.green.shade600, // Thay đổi để đậm hơn
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12), // Khoảng cách giữa 2 hàng
              // Hàng thứ hai - Ô Chi
              Container(
                width: double.infinity, // Chiếm toàn bộ chiều rộng
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.red.withOpacity(0.25), // Tăng từ 0.15 lên 0.25
                      Colors.red.withOpacity(0.15), // Tăng từ 0.08 lên 0.15
                      Colors
                          .white, // Thay đổi từ Colors.white.withOpacity(0.95) thành Colors.white
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.4), // Tăng từ 0.3 lên 0.4
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3), // Tăng từ 0.2 lên 0.3
                      blurRadius: 15, // Tăng từ 12 lên 15
                      offset: const Offset(0, 6),
                      spreadRadius: 2, // Tăng từ 1 lên 2
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.red.withOpacity(0.3), // Tăng từ 0.2 lên 0.3
                            Colors.red.withOpacity(0.2), // Tăng từ 0.1 lên 0.2
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(
                              0.4,
                            ), // Tăng từ 0.3 lên 0.4
                            blurRadius: 8, // Tăng từ 6 lên 8
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.trending_down_rounded,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Chi",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.red.shade700, // Thay đổi để đậm hơn
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Số tiền:",
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Colors
                                      .grey[700], // Thay đổi từ grey[600] thành grey[700]
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            NumberFormat.currency(
                              locale: 'vi_VN',
                              symbol: '',
                            ).format(totalExpense).replaceAll(',', '.'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.red.shade700, // Thay đổi để đậm hơn
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            "đ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.red.shade600, // Thay đổi để đậm hơn
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseChartCard(
    String title,
    Map<String, Map<String, dynamic>> data,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, primaryColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ThemHanMucChi(maKH: maKH),
                  ),
                );
                await fetchExpenseData();
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Thêm hạn mức chi",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (data.isEmpty)
            Container(
              height: 100,
              alignment: Alignment.center,
              child: Text(
                "Bạn chưa có hạn mức chi nào",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            )
          else
            ...data.entries.map((entry) {
              final toida = entry.value['toida'];
              final sotienhientai = entry.value['sotienhientai'];
              final maHangMuc = entry.value['mahangmuc'];
              double percent = 0;
              if (toida != null && toida > 0) {
                percent = (sotienhientai ?? 0) / toida;
                if (percent > 1) percent = 1;
              }
              bool isOver = (sotienhientai ?? 0) > (toida ?? 0);

              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isOver
                          ? Colors.red.withOpacity(0.08)
                          : Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isOver ? Colors.red : Colors.blue.withOpacity(0.2),
                    width: isOver ? 2 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                entry.key,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isOver ? Colors.red : Colors.black,
                                ),
                              ),
                              if (isOver)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6.0),
                                  child: Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Hạn mức: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(toida)}',
                            style: TextStyle(
                              color: isOver ? Colors.red : Colors.black87,
                            ),
                          ),
                          Text(
                            'Đã chi: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(sotienhientai ?? 0)}',
                            style: TextStyle(
                              color: isOver ? Colors.red : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: percent,
                              minHeight: 10,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isOver
                                    ? Colors.red
                                    : percent > 0.8
                                    ? Colors.orange
                                    : Colors.blue,
                              ),
                            ),
                          ),
                          if (isOver)
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                "Bạn đã vượt quá hạn mức!",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text('Xác nhận'),
                                content: Text(
                                  'Bạn có chắc muốn xóa hạn mức này không?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: Text('Xóa'),
                                  ),
                                ],
                              ),
                        );
                        if (confirm == true) {
                          final response = await http.put(
                            Uri.parse(
                              'https://10.0.2.2:7283/api/HangMuc/capnhat-toida/$maHangMuc',
                            ),
                            headers: {
                              'Content-Type': 'application/json',
                              'Accept': 'application/json',
                            },
                            body: json.encode({'toida': null}),
                          );
                          if (response.statusCode == 200) {
                            await fetchExpenseData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã xóa hạn mức'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi khi xóa hạn mức'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildUtilitiesCard() {
    final List<Map<String, dynamic>> utilities = [
      {
        'icon': Icons.currency_exchange_rounded,
        'label': 'Tỷ giá',
        'color': const Color(0xFF4CAF50),
      },
      {
        'icon': Icons.account_balance_wallet_rounded,
        'label': 'Chia tiền',
        'color': const Color(0xFF9C27B0),
      },
      {
        'icon': Icons.receipt_long_rounded,
        'label': 'Thuế TNCN',
        'color': const Color(0xFFF44336),
      },
      {
        'icon': Icons.calculate_rounded,
        'label': 'Tính lãi vay',
        'color': const Color(0xFFFF9800),
      },
      {
        'icon': Icons.savings_rounded,
        'label': 'Tính lãi TK',
        'color': const Color(0xFF2196F3),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, primaryColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.1),
                  primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.apps_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Tiện ích khác",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Sử dụng layout cải thiện cho 5 icons
          Column(
            children: [
              // Hàng đầu tiên: 3 icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    utilities.take(3).map((utility) {
                      return _buildUtilityItem(utility);
                    }).toList(),
              ),
              const SizedBox(height: 16),
              // Hàng thứ hai: 2 icons ở giữa
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 80), // Spacer
                  ...utilities.skip(3).take(2).map((utility) {
                    return _buildUtilityItem(utility);
                  }).toList(),
                  const SizedBox(width: 80), // Spacer
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityItem(Map<String, dynamic> utility) {
    return InkWell(
      onTap: () {
        _handleUtilityTap(utility['label']);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              utility['color'].withOpacity(0.15),
              utility['color'].withOpacity(0.08),
              Colors.white.withOpacity(0.95),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: utility['color'].withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: utility['color'].withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 6,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [utility['color'], utility['color'].withOpacity(0.8)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: utility['color'].withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(utility['icon'], color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                utility['label'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: utility['color'],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleUtilityTap(String title) {
    Widget? screen;
    switch (title) {
      case 'Tỷ giá':
        screen = const TraCuuTyGiaScreen();
        break;
      case 'Chia tiền':
        screen = ChiaTienScreen();
        break;
      case 'Thuế TNCN':
        screen = const TinhThueScreen();
        break;
      case 'Tính lãi vay':
        screen = TinhLaiVayScreen();
        break;
      case 'Tính lãi TK':
        screen = TinhLaiTienGuiScreen();
        break;
    }

    if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen!));
    }
  }
}
