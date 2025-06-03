class TaiKhoan {
  final String mataikhoan;
  final String? maKH; // Nullable
  final String maquyen;
  final String? quyenTruyCap; // Nullable, vì có thể là null
  final String tendangnhap;
  final String matkhau;
  final String email;
  final int isemailconfirmed;
  final String? emailconfirmationtoken; // Nullable
  final String? otp; // Nullable


  TaiKhoan({
    required this.mataikhoan,
    required this.maquyen,
    this.quyenTruyCap,
    required this.tendangnhap,
    required this.matkhau,
    required this.email,
    required this.isemailconfirmed,
    this.emailconfirmationtoken,
    this.otp,
    this.maKH,
  });

  factory TaiKhoan.fromJson(Map<String, dynamic> json) {
    return TaiKhoan(
      mataikhoan: json['mataikhoan']?.toString().trim() ?? '',
      maquyen: json['maquyen']?.toString().trim() ?? '',
      quyenTruyCap: json['quyenTruyCap']?.toString(),
      tendangnhap: json['tendangnhap']?.toString().trim() ?? '',
      matkhau: json['matkhau']?.toString().trim() ?? '',
      email: json['email']?.toString().trim() ?? '',
      isemailconfirmed: json['isemailconfirmed'] is int
          ? json['isemailconfirmed']
          : int.tryParse(json['isemailconfirmed']?.toString() ?? '0') ?? 0,
      emailconfirmationtoken: json['emailconfirmationtoken']?.toString(),
      otp: json['otp']?.toString(),
      maKH: json['khachHang']?.toString().trim(),
    );
  }

}
