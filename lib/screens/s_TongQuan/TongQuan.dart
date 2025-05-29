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
import 'package:qltncn/widget/vi_utils.dart';
import 'package:qltncn/model/Vi/Vi/Vi.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TongQuanScreen extends StatefulWidget {
  final String userName;
  final String maKH;

  @override
  _TongQuanScreenState createState() => _TongQuanScreenState();
  const TongQuanScreen({super.key, required this.userName, required this.maKH});
}

class _TongQuanScreenState extends State<TongQuanScreen> {
  //final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, double> incomeData = {};
  Map<String, double> expenseData = {};
  double totalIncome = 0;
  double totalExpense = 0;
  int touchedIndex = -1;

  String selectedFilter = "Tháng";
  String selectedTimePeriod = "Tháng này";
  DateTime selectedDate = DateTime.now();

  late String userName; // Tên người dùng sẽ được gán từ widget
  late String maKH;
  String? hoTenKhachHang;

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
    if (khachHang != null && khachHang.hoTen != null && khachHang.hoTen!.isNotEmpty) {
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
    'Sổ tiết kiệm': true,
    'Theo dõi vay nợ': true,
    'Du lịch': true,
    'Tra cứu tỷ giá': true,
  };

  Map<String, bool> tempCardVisibility = {};

  @override
  void initState() {
    super.initState();
    userName = widget.userName; // Gán tên người dùng từ widget
    maKH = widget.maKH; // Gán maKH từ widget
    
    _loadDanhSachVi(); // Gọi phương thức để tải dữ liệu
    _loadKhachHang();
    _loadBalanceVisibility();
  }

  // Future<void> _loadData() async {
  //   Map<String, double> income = await _dbHelper.getIncomeByCategory(
  //     filter: selectedFilter,
  //     date: selectedDate,
  //   );
  //   Map<String, double> expense = await _dbHelper.getExpenseByCategory(
  //     filter: selectedFilter,
  //     date: selectedDate,
  //   );

  //   setState(() {
  //     incomeData = income;
  //     expenseData = expense;
  //     totalIncome = income.values.fold(0, (sum, value) => sum + value);
  //     totalExpense = expense.values.fold(0, (sum, value) => sum + value);
  //   });
  // }
  
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
    return Scaffold(
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
                        "Chào ${hoTenKhachHang ?? userName}!",
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
                            icon: Icon(Icons.notifications, color: Colors.blue),
                            onPressed: () {
                              // TODO: Implement notification functionality
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        value: selectedFilter,
                        items:
                            ["Ngày", "Tháng", "Năm"]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedFilter = value!;
                          });
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _selectDate(context),
                        child: Text("Chọn ${selectedFilter.toLowerCase()}"),
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
                          "Số dư hiện tại" + (isBalanceVisible ? "" : " (Ẩn)"),
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
                            _saveBalanceVisibility(isBalanceVisible); // Lưu trạng thái mới
                          },
                        ),

                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      isBalanceVisible ? "${formattedTongSoDu} đ" : "****** đ",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: currentBalance >= 0 ? Colors.green : Colors.red,
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
                    _buildChartCard("Tình hình thu chi", incomeData),
                    SizedBox(height: 16),
                  ],
                  if (cardVisibility['Hạn mức chi']!) ...[
                    _buildChartCard("Hạn mức chi", expenseData),
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
                  if (cardVisibility['Sổ tiết kiệm']!) ...[
                    _buildSavingsCard(),
                    SizedBox(height: 16),
                  ],
                  if (cardVisibility['Theo dõi vay nợ']!) ...[
                    _buildLoanTrackingCard(),
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
    );
  }

  Widget _buildChartCard(String title, Map<String, double> data) {
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
              if (title == "Tình hình thu chi")
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LichSuGhiChep(maKH: widget.maKH)),
                    );
                  },
                  icon: Icon(Icons.history, size: 18),
                  label: Text(
                    "Lịch sử ghi chép",
                    style: TextStyle(fontSize: 14),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
            ],
          ),
          if (title == "Tình hình thu chi")
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedTimePeriod,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
                    items:
                        [
                          "Hôm nay",
                          "Tuần này",
                          "Tháng này",
                          "Quý này",
                          "Năm nay",
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Text(
                                value,
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedTimePeriod = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          SizedBox(height: 16),
          if (data.isEmpty)
            Container(
              height: 200,
              alignment: Alignment.center,
              child:
                  title == "Hạn mức chi"
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Tháng này bạn chưa có ghi chép nào",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ThemHanMucChi(),
                                ),
                              );
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
                        ],
                      )
                      : Text(
                        "Tháng này bạn chưa có ghi chép nào",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
            )
          else
            SizedBox(height: 200, child: PieChart(_generatePieChartData(data))),
        ],
      ),
    );
  }

  PieChartData _generatePieChartData(Map<String, double> data) {
    final random = Random();
    List<Color> colors = List.generate(
      data.length,
      (index) => availableColors[random.nextInt(availableColors.length)],
    );

    return PieChartData(
      sections: List.generate(data.length, (index) {
        String category = data.keys.elementAt(index);
        double value = data.values.elementAt(index);
        return PieChartSectionData(
          value: value,
          title: "$category\n${value.toStringAsFixed(2)} đ",
          color: colors[index],
          radius: touchedIndex == index ? 70 : 60,
          titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }),
      sectionsSpace: 2,
      centerSpaceRadius: 40,
      pieTouchData: PieTouchData(
        touchCallback: (FlTouchEvent event, pieTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                pieTouchResponse == null ||
                pieTouchResponse.touchedSection == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
          });
        },
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

  Widget _buildSavingsCard() {
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
            "Sổ tiết kiệm",
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
            child: Text(
              "Hiện tại, bạn chưa có sổ tiết kiệm nào",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanTrackingCard() {
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
            "Theo dõi vay nợ",
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
            child: Text(
              "Hiện tại bạn không có khoản cho vay và còn nợ nào",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
