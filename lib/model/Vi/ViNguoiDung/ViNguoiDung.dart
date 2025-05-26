import 'package:qltncn/model/LoaiTien/LoaiTien.dart';

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
    final loaiTien = getLoaiTienByMa(maLoaiTien);

    return {
      'tenTaiKhoan': tenTaiKhoan,
      'dienGiai': dienGiai,
      'soDu': soDu,
      'vi': {
        'maVi': maVi ?? 0,
      },
      'loaiTien': {
        'maLoaiTien': maLoaiTien,
        'tenLoai': loaiTien?.tenLoai ?? 'Unknown',
        'kyHieu': loaiTien?.kyHieu ?? '',
        'menhGia': loaiTien?.menhGia ?? '0',
      },
      'khachHang': {
        'maKH': maNguoiDung,
        'taiKhoan': 'user001',
        'maTaiKhoan': 'TK001',
      },
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
