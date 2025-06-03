import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BaoCaoThangNam extends StatefulWidget {
  final String maKH;
  const BaoCaoThangNam({super.key, required this.maKH});

  @override
  State<BaoCaoThangNam> createState() => _BaoCaoThangNamState();
}

enum ViewMode { year, month }

class _BaoCaoThangNamState extends State<BaoCaoThangNam> {
  Map<int, double> tongThuTheoThang = {};
  Map<int, double> tongChiTheoThang = {};
  Map<int, double> tongThuTheoNgay = {};
  Map<int, double> tongChiTheoNgay = {};
  bool isLoading = true;
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  ViewMode viewMode = ViewMode.year;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://10.0.2.2:7283/api/GiaoDich/user/${widget.maKH}'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        Map<int, double> thuThang = {};
        Map<int, double> chiThang = {};
        Map<int, double> thuNgay = {};
        Map<int, double> chiNgay = {};
        for (var item in data) {
          final ngay = DateTime.parse(item['ngayGiaoDich']);
          final soTien = (item['soTien'] ?? 0).toDouble();
          final loai = (item['loaiGiaoDich'] ?? '').trim();
          if (viewMode == ViewMode.year) {
            if (ngay.year != selectedYear) continue;
            final thang = ngay.month;
            if (loai == 'Thu') {
              thuThang[thang] = (thuThang[thang] ?? 0) + soTien;
            } else if (loai == 'Chi') {
              chiThang[thang] = (chiThang[thang] ?? 0) + soTien;
            }
          } else {
            if (ngay.year != selectedYear || ngay.month != selectedMonth)
              continue;
            final day = ngay.day;
            if (loai == 'Thu') {
              thuNgay[day] = (thuNgay[day] ?? 0) + soTien;
            } else if (loai == 'Chi') {
              chiNgay[day] = (chiNgay[day] ?? 0) + soTien;
            }
          }
        }
        setState(() {
          tongThuTheoThang = thuThang;
          tongChiTheoThang = chiThang;
          tongThuTheoNgay = thuNgay;
          tongChiTheoNgay = chiNgay;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Widget buildDropdowns() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        DropdownButton<ViewMode>(
          value: viewMode,
          underline: Container(),
          onChanged: (mode) {
            if (mode != null) {
              setState(() {
                viewMode = mode;
                fetchData();
              });
            }
          },
          items: [
            DropdownMenuItem(value: ViewMode.year, child: Text('Theo năm')),
            DropdownMenuItem(value: ViewMode.month, child: Text('Theo tháng')),
          ],
        ),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: selectedYear,
          underline: Container(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedYear = value;
                fetchData();
              });
            }
          },
          items: List.generate(5, (i) {
            int year = DateTime.now().year - i;
            return DropdownMenuItem(value: year, child: Text('$year'));
          }),
        ),
        if (viewMode == ViewMode.month) ...[
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: selectedMonth,
            underline: Container(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedMonth = value;
                  fetchData();
                });
              }
            },
            items: List.generate(12, (i) {
              int month = i + 1;
              return DropdownMenuItem(
                value: month,
                child: Text('Tháng $month'),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget buildBarChart() {
    if (viewMode == ViewMode.year) {
      double maxY =
          [
            ...tongThuTheoThang.values,
            ...tongChiTheoThang.values,
          ].fold<double>(0, (p, v) => v > p ? v : p) +
          10000;
      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barGroups: List.generate(12, (i) {
            final thang = i + 1;
            return BarChartGroupData(
              x: thang,
              barRods: [
                BarChartRodData(
                  toY: tongThuTheoThang[thang] ?? 0,
                  color: Colors.green,
                  width: 12,
                  borderRadius: BorderRadius.circular(4),
                  // Xoá hoặc comment dòng này để bỏ nền phía sau
                  // backDrawRodData: BackgroundBarChartRodData(
                  //   show: true,
                  //   toY: maxY,
                  //   color: Colors.green.withOpacity(0.1),
                  // ),
                ),
                BarChartRodData(
                  toY: tongChiTheoThang[thang] ?? 0,
                  color: Colors.red,
                  width: 12,
                  borderRadius: BorderRadius.circular(4),
                  // backDrawRodData: BackgroundBarChartRodData(
                  //   show: true,
                  //   toY: maxY,
                  //   color: Colors.red.withOpacity(0.1),
                  // ),
                ),
              ],
            );
          }),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  // Chỉ hiển thị nhãn cho ngày 1, 5, 10, 15, 20, 25, 30
                  if (viewMode == ViewMode.month) {
                    if (value % 5 == 0 || value == 1) {
                      return Transform.rotate(
                        angle: -0.5,
                        child: Text(
                          '${value.toInt()}',
                          style: TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  } else {
                    // Chỉ hiển thị nhãn cho các tháng chẵn
                    if (value % 2 == 0) {
                      return Text(
                        'T${value.toInt()}',
                        style: TextStyle(fontSize: 12),
                      );
                    }
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(enabled: true),
          gridData: FlGridData(show: true),
        ),
      );
    } else {
      int daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
      double maxY =
          [
            ...tongThuTheoNgay.values,
            ...tongChiTheoNgay.values,
          ].fold<double>(0, (p, v) => v > p ? v : p) +
          10000;
      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barGroups: List.generate(daysInMonth, (i) {
            final day = i + 1;
            return BarChartGroupData(
              x: day,
              barRods: [
                BarChartRodData(
                  toY: tongThuTheoNgay[day] ?? 0,
                  color: Colors.green,
                  width: 8,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: Colors.green.withOpacity(0.1),
                  ),
                ),
                BarChartRodData(
                  toY: tongChiTheoNgay[day] ?? 0,
                  color: Colors.red,
                  width: 8,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: Colors.red.withOpacity(0.1),
                  ),
                ),
              ],
            );
          }),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  // Chỉ hiển thị nhãn cho ngày 1, 5, 10, 15, 20, 25, 30
                  if (viewMode == ViewMode.month) {
                    if (value % 5 == 0 || value == 1) {
                      return Transform.rotate(
                        angle: -0.5,
                        child: Text(
                          '${value.toInt()}',
                          style: TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  } else {
                    // Chỉ hiển thị nhãn cho các tháng chẵn
                    if (value % 2 == 0) {
                      return Text(
                        'T${value.toInt()}',
                        style: TextStyle(fontSize: 12),
                      );
                    }
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(enabled: true),
          gridData: FlGridData(show: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê giao dịch'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [buildDropdowns()],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Expanded(child: buildBarChart()),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.square, color: Colors.green, size: 16),
                            const SizedBox(width: 4),
                            const Text('Thu', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 16),
                            Icon(Icons.square, color: Colors.red, size: 16),
                            const SizedBox(width: 4),
                            const Text('Chi', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
