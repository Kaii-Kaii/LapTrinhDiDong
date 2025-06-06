import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Thêm màu chủ đạo
const Color kPrimaryColor = Color(0xFF03A9F4); // Xanh dương giống ảnh

class HangMucScreen extends StatefulWidget {
  final String maNguoiDung;
  final int initialTabIndex; // Thêm tham số này
  const HangMucScreen({
    Key? key,
    required this.maNguoiDung,
    this.initialTabIndex = 0, // Mặc định là tab 0 (chi)
  }) : super(key: key);

  @override
  State<HangMucScreen> createState() => _HangMucScreenState();
}

class _HangMucScreenState extends State<HangMucScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchText = '';
  List<HangMuc> danhSachHangMuc = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex, // Sử dụng initialTabIndex
    );
    fetchHangMuc();
  }

  Future<void> fetchHangMuc() async {
    setState(() {
      isLoading = true;
    });
    try {
      print('maNguoiDung: ${widget.maNguoiDung}');
      final response = await http.get(
        Uri.parse(
          'https://10.0.2.2:7283/api/HangMuc/bykhachhang/${widget.maNguoiDung}',
        ),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        try {
          setState(() {
            danhSachHangMuc = data.map((e) => HangMuc.fromJson(e)).toList();
            isLoading = false;
          });
        } catch (e) {
          print('Lỗi parse dữ liệu: $e');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('Lỗi API: ${response.statusCode} - ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Lỗi kết nối: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _isTenHangMucExists(String ten, String loai) {
    return danhSachHangMuc.any(
      (hm) =>
          hm.tenHangMuc.trim().toLowerCase() == ten.trim().toLowerCase() &&
          hm.loai == loai,
    );
  }

  Future<void> _addHangMuc(
    String ten,
    String icon,
    String loai,
    bool hayDung,
  ) async {
    // Kiểm tra tên hạng mục đã tồn tại theo từng loại
    if (_isTenHangMucExists(ten, loai)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên hạng mục đã tồn tại trong mục này!')),
      );
      return;
    }

    final url = Uri.parse('https://10.0.2.2:7283/api/HangMuc/add');
    final body = jsonEncode({
      'MAHANGMUC': '',
      'MaNguoiDung': widget.maNguoiDung,
      'TENHANGMUC': ten,
      'ICON': icon,
      'LOAI': loai,
      'HAYDUNG': hayDung,
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) {
        fetchHangMuc(); // Làm mới danh sách
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Thêm thành công!')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi kết nối: $e')));
    }
  }

  void _showAddHangMucDialog() {
    String tenHangMuc = '';
    String icon = '';
    String loai = _tabController.index == 0 ? 'chi' : 'thu';
    bool hayDung = false;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: kPrimaryColor.withOpacity(0.15),
                          radius: 28,
                          child: Icon(
                            getFontAwesomeIconByName(icon) ??
                                getFontAwesomeIconByName('home'),
                            size: 32,
                            color: getIconColor(icon),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Thêm hạng mục',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Tên hạng mục',
                        prefixIcon: const Icon(Icons.edit),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: kPrimaryColor),
                        ),
                      ),
                      onChanged: (value) => tenHangMuc = value,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Icon:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            getFontAwesomeIconByName(icon) ??
                                getFontAwesomeIconByName('home'),
                          ),
                          onPressed: () async {
                            final selected = await showDialog<String>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Chọn icon'),
                                    content: SizedBox(
                                      width: double.maxFinite,
                                      child: GridView.builder(
                                        shrinkWrap: true,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 5,
                                              mainAxisSpacing: 8,
                                              crossAxisSpacing: 8,
                                            ),
                                        itemCount: fontAwesomeIconNames.length,
                                        itemBuilder: (context, index) {
                                          final name =
                                              fontAwesomeIconNames[index];
                                          return IconButton(
                                            icon: Icon(
                                              getFontAwesomeIconByName(name) ??
                                                  FontAwesomeIcons
                                                      .circleQuestion,
                                              color: getIconColor(
                                                name,
                                              ), // Thêm dòng này để icon có màu riêng
                                            ),
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  name,
                                                ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                            );
                            if (selected != null) {
                              setStateDialog(() {
                                icon = selected;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          icon,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: loai,
                      decoration: InputDecoration(
                        labelText: 'Loại',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'chi', child: Text('Chi')),
                        DropdownMenuItem(value: 'thu', child: Text('Thu')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() {
                            loai = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Hay dùng'),
                      value: hayDung,
                      activeColor: kPrimaryColor,
                      onChanged: (value) {
                        setStateDialog(() {
                          hayDung = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Hủy'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            if (tenHangMuc.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Tên hạng mục không được để trống!',
                                  ),
                                ),
                              );
                              return;
                            }
                            await _addHangMuc(tenHangMuc, icon, loai, hayDung);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Thêm',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showEditHangMucDialog(HangMuc hm) {
    final tenController = TextEditingController(text: hm.tenHangMuc);
    String icon = hm.icon;
    String loai = hm.loai;
    bool hayDung = hm.hayDung;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: kPrimaryColor.withOpacity(0.15),
                          radius: 28,
                          child: Icon(
                            getFontAwesomeIconByName(icon) ??
                                getFontAwesomeIconByName('home'),
                            color: getIconColor(hm.icon),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Chỉnh sửa hạng mục',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: tenController,
                      decoration: InputDecoration(
                        labelText: 'Tên hạng mục',
                        prefixIcon: const Icon(Icons.edit),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: kPrimaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Icon:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            getFontAwesomeIconByName(icon) ??
                                getFontAwesomeIconByName('home'),
                          ),
                          onPressed: () async {
                            final selected = await showDialog<String>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Chọn icon'),
                                    content: SizedBox(
                                      width: double.maxFinite,
                                      child: GridView.builder(
                                        shrinkWrap: true,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 5,
                                              mainAxisSpacing: 8,
                                              crossAxisSpacing: 8,
                                            ),
                                        itemCount: fontAwesomeIconNames.length,
                                        itemBuilder: (context, index) {
                                          final name =
                                              fontAwesomeIconNames[index];
                                          return IconButton(
                                            icon: Icon(
                                              getFontAwesomeIconByName(name) ??
                                                  FontAwesomeIcons
                                                      .circleQuestion,
                                              color: getIconColor(
                                                name,
                                              ), // Thêm dòng này để icon có màu riêng
                                            ),
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  name,
                                                ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                            );
                            if (selected != null) {
                              setStateDialog(() {
                                icon = selected;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          icon,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: loai,
                      decoration: InputDecoration(
                        labelText: 'Loại',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'chi', child: Text('Chi')),
                        DropdownMenuItem(value: 'thu', child: Text('Thu')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() {
                            loai = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Hay dùng'),
                      value: hayDung,
                      activeColor: kPrimaryColor,
                      onChanged: (value) {
                        setStateDialog(() {
                          hayDung = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Hủy'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            await _editHangMuc(
                              hm.maHangMuc,
                              tenController.text,
                              icon,
                              loai,
                              hayDung,
                            );
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Lưu',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _editHangMuc(
    String maHangMuc,
    String ten,
    String icon,
    String loai,
    bool hayDung,
  ) async {
    // Kiểm tra trùng tên (trừ chính nó)
    if (danhSachHangMuc.any(
      (hm) =>
          hm.tenHangMuc.trim().toLowerCase() == ten.trim().toLowerCase() &&
          hm.loai == loai &&
          hm.maHangMuc != maHangMuc,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên hạng mục đã tồn tại trong mục này!')),
      );
      return;
    }

    final url = Uri.parse('https://10.0.2.2:7283/api/HangMuc/update');
    final body = jsonEncode({
      'MAHANGMUC': maHangMuc,
      'MaNguoiDung': widget.maNguoiDung,
      'TENHANGMUC': ten,
      'ICON': icon,
      'LOAI': loai,
      'HAYDUNG': hayDung,
    });
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) {
        await fetchHangMuc();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi kết nối: $e')));
    }
  }

  Future<void> _deleteHangMuc(String maHangMuc) async {
    final url = Uri.parse(
      'https://10.0.2.2:7283/api/HangMuc/delete/$maHangMuc',
    );
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        await fetchHangMuc();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Xóa thành công!')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi kết nối: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<HangMuc> filteredChi =
        danhSachHangMuc
            .where(
              (hm) =>
                  hm.loai == 'chi' &&
                  hm.tenHangMuc.toLowerCase().contains(
                    searchText.toLowerCase(),
                  ),
            )
            .toList();
    List<HangMuc> filteredThu =
        danhSachHangMuc
            .where(
              (hm) =>
                  hm.loai == 'thu' &&
                  hm.tenHangMuc.toLowerCase().contains(
                    searchText.toLowerCase(),
                  ),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text(
          'Sửa hạng mục',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: 'MỤC CHI'), Tab(text: 'MỤC THU')],
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm theo tên hạng mục',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: kPrimaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: kPrimaryColor),
                        ),
                      ),
                      onChanged: (value) => setState(() => searchText = value),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildHangMucList(filteredChi),
                        _buildHangMucList(filteredThu),
                      ],
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        onPressed: _showAddHangMucDialog,
        child: const Icon(Icons.add, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildHangMucList(List<HangMuc> list) {
    // Sắp xếp: hayDung=true lên đầu
    final sortedList = [...list]..sort((a, b) {
      if (a.hayDung == b.hayDung) return 0;
      return a.hayDung ? -1 : 1;
    });

    return ListView.separated(
      itemCount: sortedList.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final hm = sortedList[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: kPrimaryColor.withOpacity(0.1),
            child: Icon(
              getFontAwesomeIconByName(hm.icon) ??
                  getFontAwesomeIconByName('home'),
              size: 28,
              color: getIconColor(hm.icon),
            ),
          ),
          title: Text(
            hm.tenHangMuc,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon ngôi sao để chọn/hủy "hay dùng"
              IconButton(
                icon: Icon(
                  hm.hayDung ? Icons.star : Icons.star_border,
                  color: hm.hayDung ? Colors.amber : Colors.grey,
                ),
                onPressed: () => _toggleHayDung(hm),
                tooltip: hm.hayDung ? 'Bỏ hay dùng' : 'Đánh dấu hay dùng',
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: kPrimaryColor),
                onPressed: () {
                  _showEditHangMucDialog(hm);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 24,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Xác nhận xóa',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Bạn có chắc muốn xóa hạng mục này?',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.grey[700],
                                      ),
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text('Hủy'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text(
                                        'Xóa',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                  );
                  if (confirm == true) {
                    await _deleteHangMuc(hm.maHangMuc);
                  }
                },
              ),
            ],
          ),
          onTap: () {
            Navigator.pop(context, {
              'maDanhMuc': hm.maHangMuc,
              'tenDanhMuc': hm.tenHangMuc,
            });
          },
        );
      },
    );
  }

  Future<void> _toggleHayDung(HangMuc hm) async {
    final url = Uri.parse('https://10.0.2.2:7283/api/HangMuc/updateHayDung');
    final body = jsonEncode({
      'MAHANGMUC': hm.maHangMuc,
      'MaNguoiDung': hm.maNguoiDung, // <-- thêm dòng này
      'HAYDUNG': !hm.hayDung,
    });
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) {
        await fetchHangMuc();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi kết nối: $e')));
    }
  }
}

class HangMuc {
  final String maHangMuc;
  final String maNguoiDung;
  final String tenHangMuc;
  final String icon;
  final String loai;
  final bool hayDung;

  HangMuc({
    required this.maHangMuc,
    required this.maNguoiDung,
    required this.tenHangMuc,
    required this.icon,
    required this.loai,
    required this.hayDung,
  });

  factory HangMuc.fromJson(Map<String, dynamic> json) {
    return HangMuc(
      maHangMuc: json['mahangmuc'],
      maNguoiDung: json['maNguoiDung'],
      tenHangMuc: json['tenhangmuc'],
      icon: json['icon'] ?? '',
      loai: json['loai'],
      hayDung: json['haydung'] ?? false,
    );
  }
}

const List<String> fontAwesomeIconNames = [
  'home',
  'star',
  'shopping_cart',
  'restaurant',
  'car',
  'plane',
  'school',
  'heart',
  'briefcase',
  'dog',
  'coffee',
  'store',
  'hospital',
  'tag',
  'money_bill',
  'phone',
  'computer',
  'futbol',
  'music',
  'film',
  'book',
  // Thêm các icon mới:
  'gift', // Quà tặng
  'piggy_bank', // Tiết kiệm
  'chart_line', // Đầu tư
  'umbrella', // Bảo hiểm
  'bolt', // Điện
  'water', // Nước
  'wifi', // Internet
  'house_chimney', // Thuê nhà
  'tools', // Sửa chữa
  'child', // Trẻ em
  'cat', // Vật nuôi
  'shirt', // Thời trang
  'spa', // Mỹ phẩm/chăm sóc cá nhân
  'bus', // Xe buýt/công cộng
  'train', // Tàu hỏa
  'plane_departure', // Du lịch
  'beer_mug_empty', // Giải trí
  'receipt', // Hóa đơn
  'apple_whole', // Thực phẩm
  'user_group', // Gia đình
  // Thêm mới:
  'medal', // Thưởng/thành tích
  'hand_holding_medical', // Y tế/bảo hiểm sức khỏe
  'truck', // Vận chuyển/giao hàng
  'coins', // Tiền lẻ/tiền xu
];

IconData? getFontAwesomeIconByName(String name) {
  final iconData = <String, IconData>{
    'home': FontAwesomeIcons.house,
    'star': FontAwesomeIcons.star,
    'shopping_cart': FontAwesomeIcons.cartShopping,
    'restaurant': FontAwesomeIcons.utensils,
    'car': FontAwesomeIcons.car,
    'plane': FontAwesomeIcons.plane,
    'school': FontAwesomeIcons.school,
    'heart': FontAwesomeIcons.heart,
    'briefcase': FontAwesomeIcons.briefcase,
    'dog': FontAwesomeIcons.dog,
    'coffee': FontAwesomeIcons.mugSaucer,
    'store': FontAwesomeIcons.store,
    'hospital': FontAwesomeIcons.hospital,
    'tag': FontAwesomeIcons.tag,
    'money_bill': FontAwesomeIcons.moneyBill,
    'phone': FontAwesomeIcons.phone,
    'computer': FontAwesomeIcons.computer,
    'futbol': FontAwesomeIcons.futbol,
    'music': FontAwesomeIcons.music,
    'film': FontAwesomeIcons.film,
    'book': FontAwesomeIcons.book,
    'gift': FontAwesomeIcons.gift,
    'piggy_bank': FontAwesomeIcons.piggyBank,
    'chart_line': FontAwesomeIcons.chartLine,
    'umbrella': FontAwesomeIcons.umbrella,
    'bolt': FontAwesomeIcons.bolt,
    'water': FontAwesomeIcons.droplet,
    'wifi': FontAwesomeIcons.wifi,
    'house_chimney': FontAwesomeIcons.houseChimney,
    'tools': FontAwesomeIcons.screwdriverWrench,
    'child': FontAwesomeIcons.child,
    'cat': FontAwesomeIcons.cat,
    'shirt': FontAwesomeIcons.shirt,
    'spa': FontAwesomeIcons.spa,
    'bus': FontAwesomeIcons.bus,
    'train': FontAwesomeIcons.trainSubway,
    'plane_departure': FontAwesomeIcons.planeDeparture,
    'beer_mug_empty': FontAwesomeIcons.beerMugEmpty,
    'receipt': FontAwesomeIcons.receipt,
    'apple_whole': FontAwesomeIcons.appleWhole,
    'user_group': FontAwesomeIcons.userGroup,
    'medal': FontAwesomeIcons.medal,
    'hand_holding_medical': FontAwesomeIcons.handHoldingMedical,
    'truck': FontAwesomeIcons.truck,
    'coins': FontAwesomeIcons.coins,
  };
  return iconData[name];
}

Color getIconColor(String iconName) {
  final colorMap = <String, Color>{
    'home': Colors.blue,
    'star': Colors.amber,
    'shopping_cart': Colors.purple,
    'restaurant': Colors.deepOrange,
    'car': Colors.teal,
    'plane': Colors.indigo,
    'school': Colors.green,
    'heart': Colors.red,
    'briefcase': Colors.brown,
    'dog': Colors.orange,
    'coffee': Colors.brown,
    'store': Colors.blueGrey,
    'hospital': Colors.redAccent,
    'tag': Colors.pink,
    'money_bill': Colors.green,
    'phone': Colors.teal,
    'computer': Colors.blueGrey,
    'futbol': Colors.deepPurple,
    'music': Colors.purple,
    'film': Colors.indigo,
    'book': Colors.deepOrange,
    'gift': Colors.pinkAccent,
    'piggy_bank': Colors.pink,
    'chart_line': Colors.green,
    'umbrella': Colors.blueAccent,
    'bolt': Colors.yellow,
    'water': Colors.lightBlue,
    'wifi': Colors.indigo,
    'house_chimney': Colors.brown,
    'tools': Colors.grey,
    'child': Colors.orangeAccent,
    'cat': Colors.deepOrange,
    'shirt': Colors.teal,
    'spa': Colors.purpleAccent,
    'bus': Colors.blue,
    'train': Colors.deepPurple,
    'plane_departure': Colors.cyan,
    'beer_mug_empty': Colors.amber,
    'receipt': Colors.blueGrey,
    'apple_whole': Colors.red,
    'user_group': Colors.greenAccent,
    'medal': Colors.orange,
    'hand_holding_medical': Colors.redAccent,
    'truck': Colors.blueGrey,
    'coins': Colors.amber,
  };
  return colorMap[iconName] ?? Colors.grey;
}
