import 'package:flutter/material.dart';
import 'package:qltncn/database/database_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class OverviewScreen extends StatefulWidget {
  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  //final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, double> incomeData = {};
  Map<String, double> expenseData = {};
  double totalIncome = 0;
  double totalExpense = 0;
  int touchedIndex = -1;

  String selectedFilter = "Tháng";
  DateTime selectedDate = DateTime.now();

  final List<Color> availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.indigo,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    // _loadData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chi tiêu cá nhân")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedFilter,
                  items:
                      ["Ngày", "Tháng", "Năm"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                    });
                    // _loadData();
                  },
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text("Chọn ${selectedFilter.toLowerCase()}"),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "Số tiền còn lại: ${(totalIncome - totalExpense).toStringAsFixed(2)} đ",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildChart("Biểu đồ Thu Nhập", incomeData),
                  SizedBox(height: 20),
                  _buildChart("Biểu đồ Chi Tiêu", expenseData),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(String title, Map<String, double> data) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 200, child: PieChart(_generatePieChartData(data))),
      ],
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
          title: "${category}\n${value.toStringAsFixed(2)} đ",
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
}
