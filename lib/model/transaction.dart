// class Transaction {
//   final int? id;
//   final String date;
//   final double amount;
//   final String? note;
//   final String category; // Thêm trường category

//   Transaction({
//     this.id,
//     required this.date,
//     required this.amount,
//     this.note,
//     required this.category, // Đảm bảo trường này có giá trị
//   });

//   // Chuyển đổi từ Map (dữ liệu database) sang Transaction object
//   factory Transaction.fromMap(Map<String, dynamic> map) {
//     return Transaction(
//       id: map['id'],
//       date: map['date'],
//       amount: map['amount'],
//       note: map['note'],
//       category:
//           map['category'] ??
//           'Khác', // Nếu không có danh mục thì mặc định là "Khác"
//     );
//   }

//   // Chuyển từ Transaction object sang Map (để lưu vào database)
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'date': date,
//       'amount': amount,
//       'note': note,
//       'category': category,
//     };
//   }
// }
