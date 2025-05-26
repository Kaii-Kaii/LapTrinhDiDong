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
      appBar: AppBar(title: const Text("Tra cứu & Đổi tỷ giá")),
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
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Số tiền',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            soTien = double.tryParse(value);
                          },
                        ),
                        const SizedBox(height: 12),
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
                                                Image.network(
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
                                                const SizedBox(width: 8),
                                                Text(e.currency),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    fromCurrency = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Từ',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.arrow_forward),
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
                                                Image.network(
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
                                                const SizedBox(width: 8),
                                                Text(e.currency),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    toCurrency = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Sang',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            doiTien();
                          },
                          child: const Text('Đổi tiền'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Kết quả',
                            border: const OutlineInputBorder(),
                          ),
                          controller: TextEditingController(
                            text:
                                ketQua != null && toCurrency != null
                                    ? '${ketQua!.toStringAsFixed(2)} $toCurrency'
                                    : '',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Danh sách tỷ giá
                const Text(
                  'Bảng tỷ giá',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return Card(
                      child: ListTile(
                        leading: Image.network(
                          item.flagUrl,
                          width: 40,
                          height: 30,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.flag_outlined);
                          },
                        ),
                        title: Text(item.currency),
                        trailing: Text(item.rate.toStringAsFixed(2)),
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
