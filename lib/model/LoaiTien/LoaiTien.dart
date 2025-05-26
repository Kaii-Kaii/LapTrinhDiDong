class LoaiTien {
  final int maLoai;
  final String tenLoai;
  final String menhGia;
  final String kyHieu;

  LoaiTien({
    required this.maLoai,
    required this.tenLoai,
    required this.menhGia,
    required this.kyHieu,
  });
}

final List<LoaiTien> danhSachLoaiTien = [
  LoaiTien(maLoai: 1, tenLoai: 'Việt Nam Đồng', menhGia: 'VND', kyHieu: 'đ'),
  LoaiTien(maLoai: 2, tenLoai: 'United States Dollar', menhGia: 'USD', kyHieu: r'$'),
  LoaiTien(maLoai: 3, tenLoai: 'Euro', menhGia: 'EUR', kyHieu: '€'),
  LoaiTien(maLoai: 4, tenLoai: 'Japanese Yen', menhGia: 'JPY', kyHieu: '¥'),
  LoaiTien(maLoai: 5, tenLoai: 'British Pound', menhGia: 'GBP', kyHieu: '£'),
  LoaiTien(maLoai: 6, tenLoai: 'Korean Won', menhGia: 'KRW', kyHieu: 'W'),
  LoaiTien(maLoai: 7, tenLoai: 'Swiss Franc', menhGia: 'CHF', kyHieu: 'Fr'),
  LoaiTien(maLoai: 8, tenLoai: 'Chinese Yuan', menhGia: 'CNY', kyHieu: '¥'),
  LoaiTien(maLoai: 9, tenLoai: 'Canadian Dollar', menhGia: 'CAD', kyHieu: r'$'),
  LoaiTien(maLoai: 10, tenLoai: 'Australian Dollar', menhGia: 'AUD', kyHieu: r'$'),
  LoaiTien(maLoai: 11, tenLoai: 'Singapore Dollar', menhGia: 'SGD', kyHieu: r'$'),
  LoaiTien(maLoai: 12, tenLoai: 'Thai Baht', menhGia: 'THB', kyHieu: 'B'),
  LoaiTien(maLoai: 13, tenLoai: 'Indian Rupee', menhGia: 'INR', kyHieu: 'Rs'),
  LoaiTien(maLoai: 14, tenLoai: 'Malaysian Ringgit', menhGia: 'MYR', kyHieu: 'RM'),
  LoaiTien(maLoai: 15, tenLoai: 'Indonesian Rupiah', menhGia: 'IDR', kyHieu: 'Rp'),
  LoaiTien(maLoai: 16, tenLoai: 'Hong Kong Dollar', menhGia: 'HKD', kyHieu: r'$'),
  LoaiTien(maLoai: 17, tenLoai: 'Philippine Peso', menhGia: 'PHP', kyHieu: '?'),
  LoaiTien(maLoai: 18, tenLoai: 'New Zealand Dollar', menhGia: 'NZD', kyHieu: r'$'),
  LoaiTien(maLoai: 19, tenLoai: 'Russian Ruble', menhGia: 'RUB', kyHieu: 'py6'),
  LoaiTien(maLoai: 20, tenLoai: 'South African Rand', menhGia: 'ZAR', kyHieu: 'R'),
  LoaiTien(maLoai: 21, tenLoai: 'Saudi Riyal', menhGia: 'SAR', kyHieu: '~~'),
  LoaiTien(maLoai: 22, tenLoai: 'United Arab Emirates Dirham', menhGia: 'AED', kyHieu: '!~'),
];
LoaiTien? getLoaiTienByMa(int maLoaiTien) {
  try {
    return danhSachLoaiTien.firstWhere((lt) => lt.maLoai == maLoaiTien);
  } catch (e) {
    return null; // hoặc trả về 1 LoaiTien mặc định
  }
}
