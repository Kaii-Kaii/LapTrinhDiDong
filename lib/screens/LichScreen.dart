// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:intl/intl.dart';
// import 'package:qltncn/model/transaction.dart';
// import '../database/database_helper.dart';

// class LichScreen extends StatefulWidget {
//   @override
//   _LichScreenState createState() => _LichScreenState();
// }

// class _LichScreenState extends State<LichScreen> {
//   CalendarFormat _calendarFormat = CalendarFormat.month;
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//   bool _isExpanded = true;

//   Map<String, List<Transaction>> _groupedTransactions = {};
//   Map<DateTime, Map<String, double>> _transactionsByDay = {};
//   double _totalIncome = 0;
//   double _totalExpense = 0;

//   @override
//   void initState() {
//     super.initState();
//     _loadTransactions();
//   }

//   Future<void> _loadTransactions() async {
//     int year = _focusedDay.year;
//     int month = _focusedDay.month;

//     // Lấy dữ liệu từ database
//     Map<String, List<Transaction>> allTransactions =
//         await DatabaseHelper().fetchAllTransactionsGroupedByDate();

//     _groupedTransactions.clear();
//     _transactionsByDay.clear();

//     _totalIncome = 0;
//     _totalExpense = 0;

//     allTransactions.forEach((date, transactions) {
//       DateTime transactionDate = DateTime.parse(date);
//       if (transactionDate.year == year && transactionDate.month == month) {
//         _groupedTransactions[date] = transactions;

//         double income = 0;
//         double expense = 0;

//         for (var transaction in transactions) {
//           if (transaction.amount > 0) {
//             income += transaction.amount;
//           } else {
//             expense += transaction.amount.abs();
//           }
//         }

//         _transactionsByDay[transactionDate] = {
//           'income': income,
//           'expense': expense,
//         };

//         _totalIncome += income;
//         _totalExpense += expense;
//       }
//     });
//     setState(() {});
//     print("Dữ liệu _transactionsByDay: $_transactionsByDay");
//   }

//   Future<void> _deleteTransaction(Transaction transaction) async {
//     if (transaction.id != null) {
//       await DatabaseHelper().deleteTransaction(transaction.id!);
//     } else {
//       print("Lỗi: ID giao dịch không hợp lệ!");
//     }
//     // Xóa khỏi database
//     _loadTransactions(); // Tải lại dữ liệu
//   }

//   void _confirmDeleteTransaction(Transaction transaction) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Text("Xác nhận xóa"),
//             content: Text("Bạn có chắc muốn xóa giao dịch này?"),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context), // Hủy bỏ
//                 child: Text("Hủy"),
//               ),
//               TextButton(
//                 onPressed: () async {
//                   Navigator.pop(context);
//                   await _deleteTransaction(transaction);
//                 },
//                 child: Text("Xóa", style: TextStyle(color: Colors.red)),
//               ),
//             ],
//           ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           TableCalendar(
//             focusedDay: _focusedDay,
//             firstDay: DateTime(2000),
//             lastDay: DateTime(2100),
//             calendarFormat: _calendarFormat,
//             selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//             onDaySelected: (selectedDay, focusedDay) {
//               setState(() {
//                 _selectedDay = selectedDay;
//                 _focusedDay = focusedDay;
//               });
//             },
//             onPageChanged: (focusedDay) {
//               setState(() {
//                 _focusedDay = focusedDay;
//               });
//               _loadTransactions();
//             },
//             calendarBuilders: CalendarBuilders(
//               defaultBuilder: (context, day, focusedDay) {
//                 return _buildDayCell(day);
//               },
//             ),
//           ),

//           // 📊 Thống kê tháng
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Column(
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _isExpanded = !_isExpanded;
//                       });
//                     },
//                     child: Container(
//                       padding: EdgeInsets.all(12),
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: Colors.blue.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Center(
//                         child: Text(
//                           "Thống kê tháng ${_focusedDay.month}/${_focusedDay.year}",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   AnimatedContainer(
//                     duration: Duration(milliseconds: 300),
//                     height: _isExpanded ? null : 0,
//                     child:
//                         _isExpanded
//                             ? Padding(
//                               padding: const EdgeInsets.all(16.0),
//                               child: Column(
//                                 children: [
//                                   Divider(),
//                                   _buildSummaryRow(
//                                     "Tổng Thu",
//                                     _totalIncome,
//                                     Colors.green,
//                                   ),
//                                   _buildSummaryRow(
//                                     "Tổng Chi",
//                                     _totalExpense,
//                                     Colors.red,
//                                   ),
//                                   Divider(),
//                                   _buildSummaryRow(
//                                     "Số Dư",
//                                     _totalIncome - _totalExpense,
//                                     (_totalIncome - _totalExpense) >= 0
//                                         ? Colors.blue
//                                         : Colors.red,
//                                   ),
//                                 ],
//                               ),
//                             )
//                             : SizedBox(),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: _groupedTransactions.keys.length,
//               itemBuilder: (context, index) {
//                 String date = _groupedTransactions.keys.elementAt(index);
//                 List<Transaction> transactions = _groupedTransactions[date]!;

//                 return Card(
//                   margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           DateFormat('dd/MM/yyyy').format(DateTime.parse(date)),
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue,
//                           ),
//                         ),
//                         Divider(),
//                         ...transactions.map((transaction) {
//                           return Dismissible(
//                             key: Key(
//                               transaction.id.toString(),
//                             ), // Định danh duy nhất
//                             direction:
//                                 DismissDirection
//                                     .endToStart, // Vuốt từ phải sang trái
//                             background: Container(
//                               color: Colors.red,
//                               padding: EdgeInsets.symmetric(horizontal: 20),
//                               alignment: Alignment.centerRight,
//                               child: Icon(Icons.delete, color: Colors.white),
//                             ),
//                             onDismissed: (direction) {
//                               _confirmDeleteTransaction(
//                                 transaction,
//                               ); // Hiển thị hộp thoại xác nhận
//                             },
//                             child: ListTile(
//                               leading: Icon(
//                                 transaction.amount >= 0
//                                     ? Icons.arrow_upward
//                                     : Icons.arrow_downward,
//                                 color:
//                                     transaction.amount >= 0
//                                         ? Colors.green
//                                         : Colors.red,
//                               ),
//                               title: Text(
//                                 transaction.note ?? "Không có ghi chú",
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                               subtitle: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Danh mục: ${transaction.category ?? 'Không xác định'}",
//                                   ),
//                                   Text(
//                                     "${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(transaction.amount)}",
//                                     style: TextStyle(
//                                       color:
//                                           transaction.amount >= 0
//                                               ? Colors.green
//                                               : Colors.red,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ), 
//                               trailing: IconButton(
//                                 icon: Icon(Icons.delete, color: Colors.red),
//                                 onPressed:
//                                     () => _confirmDeleteTransaction(
//                                       transaction,
//                                     ), // Bấm vào để xác nhận xóa
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryRow(String title, double amount, Color color) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           Text(
//             "${NumberFormat.decimalPattern('vi_VN').format(amount)} ₫",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDayCell(DateTime day) {
//     // Chuẩn hóa ngày về 00:00:00 để khớp với dữ liệu trong _transactionsByDay
//     DateTime normalizedDay = DateTime(day.year, day.month, day.day);

//     // Lấy dữ liệu thu/chi của ngày đó
//     Map<String, double>? data = _transactionsByDay[normalizedDay];

//     double income = data?['income'] ?? 0;
//     double expense = data?['expense'] ?? 0;

//     return Container(
//       width: 900, // Đặt kích thước phù hợp
//       height: 900,
//       margin: EdgeInsets.all(1),
//       padding: EdgeInsets.all(1),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(1),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Stack(
//         children: [
//           Align(
//             alignment: Alignment.topRight, // Đưa số ngày lên góc trên bên phải
//             child: Text(
//               '${day.day}',
//               style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//             ),
//           ),
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               if (income > 0)
//                 Text(
//                   '+${NumberFormat.decimalPattern('vi_VN').format(income)}',
//                   style: TextStyle(
//                     color: Colors.green,
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               if (expense > 0)
//                 Text(
//                   '-${NumberFormat.decimalPattern('vi_VN').format(expense)}',
//                   style: TextStyle(
//                     color: Colors.red,
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
