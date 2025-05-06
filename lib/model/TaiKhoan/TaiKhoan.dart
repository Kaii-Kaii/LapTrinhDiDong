class TaiKhoan {
  final String mataikhoan;
  final String email;
  final String tendangnhap;

  TaiKhoan({
    required this.mataikhoan,
    required this.email,
    required this.tendangnhap,
  });

  factory TaiKhoan.fromJson(Map<String, dynamic> json) {
    return TaiKhoan(
      mataikhoan: json['mataikhoan'].trim(),
      email: json['email'],
      tendangnhap: json['tendangnhap'],
    );
  }
}
