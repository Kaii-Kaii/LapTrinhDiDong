import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LichSuGhiChep extends StatefulWidget {
  const LichSuGhiChep({super.key});

  @override
  _LichSuGhiChepState createState() => _LichSuGhiChepState();
}

class _LichSuGhiChepState extends State<LichSuGhiChep> {
  String selectedFilter = "Tất cả";
  DateTime selectedDate = DateTime.now();
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  // Sample data - replace with your actual data
  final List<Map<String, dynamic>> transactions = [
    {
      'type': 'Thu',
      'category': 'Lương',
      'amount': 10000000,
      'date': DateTime.now().subtract(Duration(days: 1)),
      'note': 'Lương tháng 3',
    },
    {
      'type': 'Chi',
      'category': 'Ăn uống',
      'amount': 500000,
      'date': DateTime.now().subtract(Duration(days: 2)),
      'note': 'Ăn trưa',
    },
    {
      'type': 'Chi',
      'category': 'Mua sắm',
      'amount': 2000000,
      'date': DateTime.now().subtract(Duration(days: 3)),
      'note': 'Mua quần áo',
    },
  ];

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Lịch sử ghi chép'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: selectedFilter,
                      items: ["Tất cả", "Thu", "Chi"]
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
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
                      child: Text("Chọn ngày"),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  "Ngày đã chọn: ${dateFormat.format(selectedDate)}",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: transaction['type'] == 'Thu'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        transaction['type'] == 'Thu'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: transaction['type'] == 'Thu'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    title: Text(
                      transaction['category'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(transaction['note']),
                        Text(
                          dateFormat.format(transaction['date']),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      "${transaction['amount'].toStringAsFixed(0)} đ",
                      style: TextStyle(
                        color: transaction['type'] == 'Thu'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 