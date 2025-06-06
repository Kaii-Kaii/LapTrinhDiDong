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
  //final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, double> incomeData = {};
  Map<String, Map<String, dynamic>> expenseData = {};
  double totalIncome = 0;
  double totalExpense = 0;
  int touchedIndex = -1;

  String selectedFilter = "Tháng";
  String selectedTimePeriod = "Tháng này";
  DateTime selectedDate = DateTime.now();

  late String userName; // Tên người dùng sẽ được gán từ widget
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
    'Phân tích chi tiêu': true,
    'Theo dõi vay nợ': true,
    'Du lịch': true,
    'Tra cứu tỷ giá': true,
  };
  String getShortName(String fullName) {
  List<String> parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts[parts.length - 2]} ${parts[parts.length - 1]}';
  } else {
    return fullName; // fallback nếu chỉ có 1 từ
  }
}

  Map<String, bool> tempCardVisibility = {};

  @override
  void initState() {
    super.initState();
    userName = widget.userName;
    maKH = widget.maKH;

    // Set initial date range to current month
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    endDate = DateTime(now.year, now.month + 1, 0);

    _loadDanhSachVi();
    _loadKhachHang();
    _loadBalanceVisibility();
    _loadTransactionData();

    // Add focus listener
    _focusNode.addListener(_onFocusChange);

    // Listen for transaction updates
    _transactionUpdateSubscription = transactionUpdateController.stream.listen((
      _,
    ) {
      _refreshData();
    });
    fetchExpenseData();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Refresh data when screen comes into focus
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
      // Format dates for API with proper padding for month and day
      // Set end date to end of day (23:59:59)
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

        // Group transactions by maGiaoDich to get latest update for each
        Map<String, dynamic> latestTransactions = {};

        // First pass: collect all transactions
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
              // For new transactions, always keep them
              if (hanhDong == 'TaoMoi') {
                latestTransactions[maGiaoDich] = transaction;
                print('Added new transaction: $maGiaoDich'); // Debug log
              }
              // For updates, only keep the latest one
              else if (hanhDong == 'CapNhat') {
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

        print(
          'Filtered to ${latestTransactions.length} transactions',
        ); // Debug log

        // Second pass: calculate totals from filtered transactions
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
      // Chỉ lấy loại chi và có hạn mức
      final Map<String, Map<String, dynamic>> temp = {};
      for (var hm in data) {
        if (hm['loai'] == 'chi' && hm['toida'] != null) {
          temp[hm['tenhangmuc']] = {
            'toida': hm['toida'],
            'sotienhientai': hm['sotienhientai'] ?? 0,
            'mahangmuc': hm['mahangmuc'], // Thêm dòng này
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

  void _showPersonalizationDialog() {
    // Copy current visibility state to temporary state
    tempCardVisibility = Map.from(cardVisibility);

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text('Cá nhân hoá giao diện tổng quan'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: tempCardVisibility.length,
                      itemBuilder: (context, index) {
                        final cardName = tempCardVisibility.keys.elementAt(
                          index,
                        );
                        final isVisible = tempCardVisibility[cardName]!;
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                isVisible
                                    ? Colors.blue.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SwitchListTile(
                            title: Text(
                              cardName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    isVisible ? Colors.blue : Colors.grey[600],
                              ),
                            ),
                            value: isVisible,
                            onChanged: (value) {
                              setDialogState(() {
                                tempCardVisibility[cardName] = value;
                              });
                            },
                            activeColor: Colors.blue,
                            inactiveThumbColor: Colors.grey[400],
                            inactiveTrackColor: Colors.grey[300],
                            activeTrackColor: Colors.blue.withOpacity(0.5),
                          ),
                        );
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Huỷ'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          cardVisibility = Map.from(tempCardVisibility);
                        });
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã lưu thay đổi'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Lưu thay đổi'),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double currentBalance = totalIncome - totalExpense;
    return Focus(
      focusNode: _focusNode,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Chào ${hoTenKhachHang != null ? getShortName(hoTenKhachHang!) : userName}!",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.refresh, color: Colors.blue),
                              onPressed: () {
                                // TODO: Implement reload functionality
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.notifications,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                // TODO: Implement notification functionality
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Balance Card
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
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
                            "Số dư hiện tại" +
                                (isBalanceVisible ? "" : " (Ẩn)"),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isBalanceVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              setState(() {
                                isBalanceVisible = !isBalanceVisible;
                              });
                              _saveBalanceVisibility(
                                isBalanceVisible,
                              ); // Lưu trạng thái mới
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        isBalanceVisible
                            ? "${formattedTongSoDu} đ"
                            : "****** đ",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color:
                              currentBalance >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Charts Section
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    if (cardVisibility['Tình hình thu chi']!) ...[
                      _buildIncomeChartCard("Tình hình thu chi", incomeData),
                      SizedBox(height: 16),
                    ],
                    if (cardVisibility['Hạn mức chi']!) ...[
                      _buildExpenseChartCard("Hạn mức chi", expenseData),
                      SizedBox(height: 16),
                    ],
                    if (cardVisibility['Du lịch']!) ...[
                      _buildTravelCard(),
                      SizedBox(height: 16),
                    ],
                    if (cardVisibility['Tra cứu tỷ giá']!) ...[
                      _buildExchangeRateCard(),
                      SizedBox(height: 16),
                    ],
                    if (cardVisibility['Tiện ích khác']!) ...[
                      _buildUtilitiesCard(),
                      SizedBox(height: 16),
                    ],
                    if (cardVisibility['Phân tích chi tiêu']!) ...[
                      _buildExpenseAnalysisCard(),
                      SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: _showPersonalizationDialog,
                  icon: Icon(Icons.settings),
                  label: Text('Cá nhân hoá giao diện tổng quan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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

  Widget _buildIncomeChartCard(String title, Map<String, double> data) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
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
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LichSuGhiChep(maKH: widget.maKH),
                    ),
                  );
                },
                icon: Icon(Icons.history, size: 18),
                label: Text("Lịch sử ghi chép", style: TextStyle(fontSize: 14)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
          // ... Bạn có thể thêm chart hoặc các widget khác cho thu chi ở đây ...
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: "Thu",
                  amount: totalIncome,
                  icon: Icons.arrow_downward,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: "Chi",
                  amount: totalExpense,
                  icon: Icons.arrow_upward,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Số dư",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                Text(
                  "${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(totalIncome - totalExpense)}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        (totalIncome - totalExpense) >= 0
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Đổi tên hàm cũ thành _buildExpenseChartCard
  Widget _buildExpenseChartCard(
    String title,
    Map<String, Map<String, dynamic>> data,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: () async {
                // Chờ khi quay lại từ màn hình thêm hạn mức thì tự động load lại
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ThemHanMucChi(maKH: maKH),
                  ),
                );
                await fetchExpenseData();
              },
              icon: Icon(Icons.add),
              label: Text("Thêm hạn mức chi"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
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

  Widget _buildTravelCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Du lịch",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 200,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Hãy tạo chuyến đi để theo dõi cùng sổ thu chi",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ThemChuyenDi()),
                    );
                  },
                  icon: Icon(Icons.add),
                  label: Text("Thêm mới"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeRateCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
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
                "Tra cứu tỷ giá",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TraCuuTyGia()),
                  );
                },
                icon: Icon(Icons.arrow_forward),
                color: Colors.blue,
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            height: 100,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Xem tỷ giá và quy đổi tiền tệ",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TraCuuTyGia()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Tra cứu ngay"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseAnalysisCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Phân tích chi tiêu",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Từ tháng",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              DropdownButton<int>(
                value: 1,
                items:
                    List.generate(12, (index) => index + 1)
                        .map(
                          (month) => DropdownMenuItem(
                            value: month,
                            child: Text("Tháng $month"),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  // TODO: Handle from month change
                },
              ),
              Text(
                "đến tháng",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              DropdownButton<int>(
                value: 12,
                items:
                    List.generate(12, (index) => index + 1)
                        .map(
                          (month) => DropdownMenuItem(
                            value: month,
                            child: Text("Tháng $month"),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  // TODO: Handle to month change
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(height: 200, child: _buildBarChart()),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    // Sample data - replace with your actual data
    final List<double> monthlyData = []; // Empty list for no data case

    if (monthlyData.isEmpty) {
      return Center(
        child: Text(
          "Không có dữ liệu",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20, // Set max Y value to 20
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipPadding: EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()}',
                TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  'Tháng ${value.toInt()}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 5, // Show every 5 units
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5, // Grid lines every 5 units
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1);
          },
        ),
        barGroups: List.generate(
          monthlyData.length,
          (index) => BarChartGroupData(
            x: index + 1,
            barRods: [
              BarChartRodData(
                toY: monthlyData[index],
                color: Colors.blue,
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUtilitiesCard() {
    final List<Map<String, dynamic>> utilities = [
      {'icon': Icons.flight, 'label': 'Du lịch'},
      {'icon': Icons.currency_exchange, 'label': 'Tra cứu tỷ giá'},
      {'icon': Icons.shopping_cart, 'label': 'Danh sách mua sắm'},
      {'icon': Icons.account_balance_wallet, 'label': 'Chia tiền'},
      {'icon': Icons.receipt_long, 'label': 'Thuế TNCN'},
      {'icon': Icons.file_download, 'label': 'Xuất khẩu dữ liệu'},
      {'icon': Icons.facebook, 'label': 'Fanpage'},
      {'icon': Icons.group, 'label': 'Group'},
    ];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tiện ích khác",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: utilities.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  // TODO: Handle utility tap
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        utilities[index]['icon'],
                        color: Colors.blue,
                        size: 24,
                      ),
                      SizedBox(height: 8),
                      Text(
                        utilities[index]['label'],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
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
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                NumberFormat.currency(
                  locale: 'vi_VN',
                  symbol: '₫',
                ).format(amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
