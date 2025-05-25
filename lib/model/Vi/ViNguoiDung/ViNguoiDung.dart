class ViNguoiDung {
  final String maNguoiDung;
  final int maVi;
  final String tenTaiKhoan;
  final int maLoaiTien;
  final String? dienGiai;
  final double soDu;

  // Các trường liên kết (có thể null)
  final Map<String, dynamic>? vi;
  final Map<String, dynamic>? loaiTien;
  final Map<String, dynamic>? khachHang;

  const ViNguoiDung({
    required this.maNguoiDung,
    required this.maVi,
    required this.tenTaiKhoan,
    required this.maLoaiTien,
    this.dienGiai,
    required this.soDu,
    this.vi,
    this.loaiTien,
    this.khachHang,
  });

  factory ViNguoiDung.fromJson(Map<String, dynamic> json) {
    return ViNguoiDung(
      maNguoiDung: (json['maNguoiDung'] as String?)?.trim() ?? '',
      maVi: json['maVi'] is int 
          ? json['maVi'] 
          : int.tryParse(json['maVi'].toString()) ?? 0,
      tenTaiKhoan: (json['tenTaiKhoan'] as String?)?.trim() ?? '',
      maLoaiTien: json['maLoaiTien'] is int
          ? json['maLoaiTien']
          : int.tryParse(json['maLoaiTien'].toString()) ?? 0,
      dienGiai: (json['dienGiai'] as String?)?.trim(),
      soDu: json['soDu'] is double
          ? json['soDu']
          : double.tryParse(json['soDu'].toString()) ?? 0.0,
      vi: json['vi'] as Map<String, dynamic>?,
      loaiTien: json['loaiTien'] as Map<String, dynamic>?,
      khachHang: json['khachHang'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
  return {
    'maNguoiDung': maNguoiDung,
    'maVi': maVi,
    'tenTaiKhoan': tenTaiKhoan,
    'maLoaiTien': maLoaiTien,
    'dienGiai': dienGiai,
    'soDu': soDu,
    'vi': vi ?? {'maVi': maVi},
    'loaiTien': loaiTien ?? {'maLoaiTien': maLoaiTien},
    'khachHang': khachHang ?? {'maKhachHang': maNguoiDung},
  };
}
}
