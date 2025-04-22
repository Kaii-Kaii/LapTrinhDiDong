// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:qltncn/model/transaction.dart' as model;

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;
//   DatabaseHelper._internal();

//   static Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'transactions.db');
//     return await openDatabase(
//       path,
//       version: 2, // Tăng version để cập nhật database
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE transactions(
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             date TEXT NOT NULL,
//             note TEXT,
//             amount REAL NOT NULL,
//             category TEXT NOT NULL
//           )
//         ''');
//       },
//       onUpgrade: (db, oldVersion, newVersion) async {
//         if (oldVersion < 2) {
//           await db.execute(
//             'ALTER TABLE transactions ADD COLUMN category TEXT NOT NULL DEFAULT ""',
//           );
//         }
//       },
//     );
//   }

//   /// Lấy tổng thu nhập theo danh mục
//   Future<Map<String, double>> getIncomeByCategory({
//     required String filter,
//     required DateTime date,
//   }) async {
//     final db = await database;
//     String whereClause = _buildWhereClause(filter, date);

//     final List<Map<String, dynamic>> result = await db.rawQuery('''
//     SELECT category, SUM(amount) as total FROM transactions
//     WHERE amount > 0 $whereClause
//     GROUP BY category
//   ''');

//     return {
//       for (var row in result) row['category']: (row['total'] as num).toDouble(),
//     };
//   }

//   Future<Map<String, double>> getExpenseByCategory({
//     required String filter,
//     required DateTime date,
//   }) async {
//     final db = await database;
//     String whereClause = _buildWhereClause(filter, date);

//     final List<Map<String, dynamic>> result = await db.rawQuery('''
//     SELECT category, SUM(amount) as total FROM transactions
//     WHERE amount < 0 $whereClause
//     GROUP BY category
//   ''');

//     return {
//       for (var row in result)
//         row['category']: (row['total'] as num).abs().toDouble(),
//     };
//   }

//   Future<int> insertTransaction(
//     String date,
//     String note,
//     double amount,
//     String category,
//   ) async {
//     final db = await database;
//     return await db.insert('transactions', {
//       'date': date,
//       'note': note,
//       'amount': amount,
//       'category': category,
//     }, conflictAlgorithm: ConflictAlgorithm.replace);
//   }

//   String _buildWhereClause(String filter, DateTime date) {
//     if (filter == "Ngày") {
//       return "AND strftime('%Y-%m-%d', date) = '${date.toIso8601String().substring(0, 10)}'";
//     } else if (filter == "Tháng") {
//       return "AND strftime('%Y-%m', date) = '${date.toIso8601String().substring(0, 7)}'";
//     } else if (filter == "Năm") {
//       return "AND strftime('%Y', date) = '${date.year}'";
//     }
//     return "";
//   }

//   Future<List<Map<String, dynamic>>> getTransactions() async {
//     final db = await database;
//     return await db.query('transactions');
//   }

//   Future<Map<DateTime, Map<String, double>>> fetchTransactionsByMonth(
//     int year,
//     int month,
//   ) async {
//     final db = await database;
//     String monthStr = month.toString().padLeft(2, '0');
//     String dateFilter = '$year-$monthStr';

//     final List<Map<String, dynamic>> results = await db.rawQuery(
//       '''
//       SELECT date, 
//              SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END) AS total_income,
//              SUM(CASE WHEN amount < 0 THEN amount ELSE 0 END) AS total_expense
//       FROM transactions
//       WHERE strftime('%Y-%m', date) = ?
//       GROUP BY date
//       ORDER BY date;
//     ''',
//       [dateFilter],
//     );

//     Map<DateTime, Map<String, double>> transactionsMap = {};
//     for (var row in results) {
//       DateTime date = DateTime.parse(row['date']);
//       transactionsMap[date] = {
//         'income': ((row['total_income'] ?? 0) as num).toDouble(),
//         'expense': ((row['total_expense'] ?? 0) as num).toDouble().abs(),
//       };
//     }
//     return transactionsMap;
//   }

//   Future<Map<String, List<model.Transaction>>>
//   fetchAllTransactionsGroupedByDate() async {
//     final db = await database;
//     final List<Map<String, dynamic>> results = await db.rawQuery('''
//       SELECT * FROM transactions ORDER BY date DESC;
//     ''');

//     Map<String, List<model.Transaction>> groupedTransactions = {};
//     for (var row in results) {
//       model.Transaction transaction = model.Transaction(
//         id: row['id'],
//         date: row['date'],
//         amount: row['amount'],
//         note: row['note'],
//         category: row['category'],
//       );
//       if (!groupedTransactions.containsKey(transaction.date)) {
//         groupedTransactions[transaction.date] = [];
//       }
//       groupedTransactions[transaction.date]!.add(transaction);
//     }
//     return groupedTransactions;
//   }

//   Future<void> deleteTransaction(int id) async {
//     final db = await database;
//     await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
//   }
// }
