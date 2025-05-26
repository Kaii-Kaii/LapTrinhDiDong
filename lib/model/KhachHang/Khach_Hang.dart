class KhachHang {
  final String maKH;
  final String maTaiKhoan;
  final String? hoTen;
  final DateTime? ngaySinh;
  final String? soDT;
  final int xu;
  final String? avatar;

  const KhachHang({
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
      maKH: (json['makh'] as String?)?.trim() ?? '',
      maTaiKhoan: (json['mataikhoan'] as String?)?.trim() ?? '',
      hoTen: json['hoten'] as String?,
      ngaySinh: json['ngaysinh'] != null
          ? DateTime.tryParse(json['ngaysinh'].toString())
          : null,
      soDT: (json['sodt'] as String?)?.trim(),
      xu: json['xu'] is int ? json['xu'] : int.tryParse(json['xu'].toString()) ?? 0,
      avatar: json['avatar'] as String?,
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
