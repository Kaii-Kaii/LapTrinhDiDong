import 'package:flutter/material.dart';
import 'package:qltncn/model/Khac/tygia_model.dart';

class TraCuuTyGiaScreen extends StatefulWidget {
  const TraCuuTyGiaScreen({super.key});

  @override
  State<TraCuuTyGiaScreen> createState() => _TraCuuTyGiaScreenState();
}

class _TraCuuTyGiaScreenState extends State<TraCuuTyGiaScreen> {
  late Future<List<TyGiaModel>> tyGiaFuture;
  double? soTien;
  String? fromCurrency;
  String? toCurrency;
  double? ketQua;

  List<TyGiaModel> tyGiaList = [];

  @override
  void initState() {
    super.initState();
    tyGiaFuture = TyGiaRepository.fetchTyGia();
    tyGiaFuture.then((value) {
      setState(() {
        tyGiaList = value;
        if (tyGiaList.isNotEmpty) {
          fromCurrency = tyGiaList.first.currency;
          toCurrency = tyGiaList.last.currency;
        }
      });
    });
  }

  void doiTien() {
    if (soTien == null || fromCurrency == null || toCurrency == null) return;
    final result = doiTyGia(
      tyGiaList: tyGiaList,
      fromCurrency: fromCurrency!,
      toCurrency: toCurrency!,
      amount: soTien!,
    );
    setState(() {
      ketQua = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe3f2fd), // nền xanh hương nhạt
      appBar: AppBar(
        title: const Text("Tra cứu & Đổi tỷ giá"),
        backgroundColor: const Color(0xFF1976d2), // xanh hương đậm
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<TyGiaModel>>(
        future: tyGiaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Không có dữ liệu'));
          }

          final list = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Giao diện đổi tiền
                Card(
                  elevation: 8,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xFF90caf9), width: 2),
                  ),
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          "Chuyển đổi tiền tệ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: const Color(0xFF1976d2),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Số tiền',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF90caf9),
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.attach_money,
                              color: Color(0xFF1976d2),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFe3f2fd),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              soTien = double.tryParse(value);
                              doiTien();
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: fromCurrency,
                                items:
                                    list
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e.currency,
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: Image.network(
                                                    e.flagUrl,
                                                    width: 32,
                                                    height: 24,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return const Icon(
                                                        Icons.flag_outlined,
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  e.currency,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    fromCurrency = value;
                                    doiTien();
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Từ',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF90caf9),
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFe3f2fd),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Nút hoán đổi
                            Material(
                              color: const Color(0xFF1976d2).withOpacity(0.1),
                              shape: const CircleBorder(),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.swap_horiz,
                                  size: 28,
                                  color: Color(0xFF1976d2),
                                ),
                                tooltip: 'Đổi chiều',
                                onPressed: () {
                                  setState(() {
                                    final temp = fromCurrency;
                                    fromCurrency = toCurrency;
                                    toCurrency = temp;
                                    doiTien();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: toCurrency,
                                items:
                                    list
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e.currency,
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: Image.network(
                                                    e.flagUrl,
                                                    width: 32,
                                                    height: 24,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return const Icon(
                                                        Icons.flag_outlined,
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  e.currency,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    toCurrency = value;
                                    doiTien();
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Sang',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF90caf9),
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFe3f2fd),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFbbdefb),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF1976d2),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              ketQua != null && toCurrency != null
                                  ? '${ketQua!.toStringAsFixed(2)} $toCurrency'
                                  : 'Kết quả sẽ hiển thị ở đây',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Color(0xFF1976d2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Danh sách tỷ giá
                const Text(
                  'Bảng tỷ giá',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF1976d2),
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return Card(
                      elevation: 2,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFF90caf9)),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            item.flagUrl,
                            width: 40,
                            height: 30,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.flag_outlined);
                            },
                          ),
                        ),
                        title: Text(
                          item.currency,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976d2),
                          ),
                        ),
                        trailing: Text(
                          item.rate.toStringAsFixed(2),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976d2),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
