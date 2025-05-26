import 'package:flutter/material.dart';
import 'package:qltncn/model/Khac/tygia_model.dart';
// import model & repo

class TraCuuTyGiaScreen extends StatefulWidget {
  const TraCuuTyGiaScreen({super.key});

  @override
  State<TraCuuTyGiaScreen> createState() => _TraCuuTyGiaScreenState();
}

class _TraCuuTyGiaScreenState extends State<TraCuuTyGiaScreen> {
  late Future<List<TyGiaModel>> tyGiaFuture;

  @override
  void initState() {
    super.initState();
    tyGiaFuture = TyGiaRepository.fetchTyGia();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tra cứu tỷ giá")),
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
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Card(
                child: ListTile(
                  title: Text(item.currency),
                  trailing: Text(item.rate.toStringAsFixed(2)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
