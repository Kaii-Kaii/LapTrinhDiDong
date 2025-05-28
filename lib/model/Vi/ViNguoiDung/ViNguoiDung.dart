

class ViNguoiDung {
  String maNguoiDung;
  int? maVi;
  String tenTaiKhoan;
  int maLoaiTien;
  String dienGiai;
  double soDu;

  ViNguoiDung({
    required this.maNguoiDung,
    this.maVi,
    required this.tenTaiKhoan,
    required this.maLoaiTien,
    required this.dienGiai,
    required this.soDu,
  });

  Map<String, dynamic> toJson() {
  return {
    'maNguoiDung': maNguoiDung,
    'maVi': maVi,
    'tenTaiKhoan': tenTaiKhoan,
    'maLoaiTien': maLoaiTien,
    'dienGiai': dienGiai,
    'soDu': soDu,
  };
}


  factory ViNguoiDung.fromJson(Map<String, dynamic> json) {
    return ViNguoiDung(
      maNguoiDung: json['maNguoiDung'] ?? '',
      maVi: json['maVi'],
      tenTaiKhoan: json['tenTaiKhoan'] ?? '',
      maLoaiTien: json['maLoaiTien'] ?? 0,
      dienGiai: json['dienGiai'] ?? '',
      soDu: (json['soDu'] ?? 0).toDouble(),
    );
  }
}
