class TaiKhoan {
  final String mataikhoan;
  final String maquyen;
  final String? quyenTruyCap; // Nullable, vì có thể là null
  final String tendangnhap;
  final String matkhau;
  final String email;
  final int isemailconfirmed;
  final String? emailconfirmationtoken; // Nullable
  final String? otp; // Nullable
  final String? khachHang; // Nullable

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
    this.khachHang,
  });

  factory TaiKhoan.fromJson(Map<String, dynamic> json) {
    return TaiKhoan(
      mataikhoan: json['mataikhoan'].trim(),
      maquyen: json['maquyen'].trim(),
      quyenTruyCap: json['quyenTruyCap'], // Trường có thể là null
      tendangnhap: json['tendangnhap'].trim(),
      matkhau: json['matkhau'].trim(),
      email: json['email'].trim(),
      isemailconfirmed: json['isemailconfirmed'],
      emailconfirmationtoken: json['emailconfirmationtoken'], // Có thể là null
      otp: json['otp'], // Có thể là null
      khachHang: json['khachHang'], // Có thể là null
    );
  }
}
