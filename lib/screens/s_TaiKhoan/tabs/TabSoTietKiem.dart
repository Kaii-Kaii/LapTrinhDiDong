import 'package:flutter/material.dart';

class TabSoTietKiem extends StatelessWidget {
  final String maKH;
  const TabSoTietKiem({super.key,required this.maKH});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Sổ tiết kiệm'),
    );
  }
}
