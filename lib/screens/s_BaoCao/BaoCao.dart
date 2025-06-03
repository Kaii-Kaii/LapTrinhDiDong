import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Main_BaoCao extends StatefulWidget {
  final String maKH;
  const Main_BaoCao({super.key, required this.maKH});

  @override
  State<Main_BaoCao> createState() => _Main_BaoCaoState();
}

class _Main_BaoCaoState extends State<Main_BaoCao> {
  Map<String, double> dataThu = {};
  Map<String, double> dataChi = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDanhMuc();
  }

  Future<void> fetchDanhMuc() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
          'https://10.0.2.2:7283/api/DanhMucNguoiDung/user/${widget.maKH}',
        ),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        Map<String, double> thu = {};
        Map<String, double> chi = {};
        for (var item in data) {
          final tenDanhMuc = item['tenDanhMucNguoiDung'] ?? 'Không rõ';
          final soTien = (item['soTienHienTai'] ?? 0).toDouble();
          final thuChi = (item['thuChi'] ?? '').trim();
          if (thuChi == 'Thu') {
            thu[tenDanhMuc] = soTien;
          } else if (thuChi == 'Chi') {
            chi[tenDanhMuc] = soTien;
          }
        }
        setState(() {
          dataThu = thu;
          dataChi = chi;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo thu/chi theo danh mục'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Biểu đồ Thu theo danh mục',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  PieChart(
                    dataMap:
                        dataThu.isNotEmpty ? dataThu : {'Không có dữ liệu': 1},
                    chartType: ChartType.disc,
                    chartRadius: 160,
                    legendOptions: const LegendOptions(
                      showLegends: true,
                      legendPosition: LegendPosition.right,
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValuesInPercentage: true,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Biểu đồ Chi theo danh mục',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  PieChart(
                    dataMap:
                        dataChi.isNotEmpty ? dataChi : {'Không có dữ liệu': 1},
                    chartType: ChartType.disc,
                    chartRadius: 160,
                    legendOptions: const LegendOptions(
                      showLegends: true,
                      legendPosition: LegendPosition.right,
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValuesInPercentage: true,
                    ),
                  ),
                ],
              ),
      backgroundColor: const Color(0xFFF5F5F5),
    );
  }
}
