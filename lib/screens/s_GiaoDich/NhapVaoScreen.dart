import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../database/database_helper.dart';

class NhapVaoScreen extends StatefulWidget {
  const NhapVaoScreen({super.key});

  @override
  State<NhapVaoScreen> createState() => _NhapVaoScreenState();
}

class _NhapVaoScreenState extends State<NhapVaoScreen> {
  DateTime selectedDate = DateTime.now();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  //final DatabaseHelper _dbHelper = DatabaseHelper();
  bool isTienThu = false;
  String selectedCategory = "Khác";

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveTransaction() async {
    String dateString = DateFormat('yyyy-MM-dd HH:mm').format(selectedDate);
    String note = _noteController.text.trim();
    double? amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
      );
      return;
    }

    if (!isTienThu) {
      amount = -amount;
    }

    // await _dbHelper.insertTransaction(
    //   dateString,
    //   note,
    //   amount,
    //   selectedCategory,
    // );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nhập thành công!'),
        backgroundColor: Colors.blue,
      ),
    );

    setState(() {
      selectedDate = DateTime.now();
      _noteController.clear();
      _amountController.clear();
      selectedCategory = "Khác";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nhập giao dịch")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chọn loại giao dịch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTransactionTypeButton("Tiền chi", false),
                _buildTransactionTypeButton("Tiền thu", true),
              ],
            ),
            const Divider(thickness: 1),

            // Chọn ngày giao dịch
            ListTile(
              title: const Text("Ngày"),
              subtitle: Text(
                DateFormat('dd/MM/yyyy HH:mm').format(selectedDate),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.blue),
                onPressed: () => _selectDate(context),
              ),
            ),

            // Chọn danh mục
            ListTile(
              title: const Text("Danh mục"),
              subtitle: Text(selectedCategory),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                onPressed: () => _showCategorySelection(context),
              ),
            ),

            const SizedBox(height: 10),

            // Nhập ghi chú
            _buildTextField("Ghi chú", _noteController),

            // Nhập số tiền
            _buildTextField("Số tiền", _amountController, isNumber: true),

            // Nút lưu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: _saveTransaction,
                child: Text(
                  isTienThu ? "Nhập Tiền thu" : "Nhập Tiền chi",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeButton(String text, bool value) {
    return Expanded(
      child: TextButton(
        onPressed: () {
          setState(() {
            isTienThu = value;
          });
        },
        child: Text(
          text,
          style: TextStyle(
            color: isTienThu == value ? Colors.blue : Colors.grey,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return ListTile(
      title: Text(label),
      subtitle: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters:
            isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
        decoration: const InputDecoration(hintText: "Nhập dữ liệu..."),
      ),
    );
  }

  void _showCategorySelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children:
                (isTienThu ? _incomeCategories : _expenseCategories)
                    .map((category) => _buildCategoryItem(category))
                    .toList(),
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(String category) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCategory = category;
        });
        Navigator.pop(context);
      },
      child: Text(category),
    );
  }

  List<String> get _incomeCategories => [
    "Lương",
    "Thưởng",
    "Lãi",
    "Lãi tiết kiệm",
    "Khác",
  ];
  List<String> get _expenseCategories => [
    "Ăn uống",
    "Dịch vụ",
    "Đi lại",
    "Con cái",
    "Trang phục",
    "Sức khỏe",
    "Hiếu hỉ",
    "Khác",
  ];
}
