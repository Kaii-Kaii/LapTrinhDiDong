class KhachHang {
  final String maKH;
  final String maTaiKhoan;
  final String? hoTen;
  final DateTime? ngaySinh;
  final String? soDT;
  final int xu;
  final String? avatar;

  KhachHang({
    required this.maKH,
    required this.maTaiKhoan,
    this.hoTen,
    this.ngaySinh,
    this.soDT,
    required this.xu,
    this.avatar,
  });

  factory KhachHang.fromJson(Map<String, dynamic> json) {
    return KhachHang(
      maKH: json['makh']?.trim() ?? '',
      maTaiKhoan: json['mataikhoan']?.trim() ?? '',
      hoTen: json['hoten'],
      ngaySinh: json['ngaysinh'] != null
          ? DateTime.tryParse(json['ngaysinh'])
          : null,
      soDT: json['sodt']?.trim(),
      xu: json['xu'] ?? 0,
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'makh': maKH,
      'mataikhoan': maTaiKhoan,
      'hoten': hoTen,
      'ngaysinh': ngaySinh?.toIso8601String(),
      'sodt': soDT,
      'xu': xu,
      'avatar': avatar,
    };
  }
}
