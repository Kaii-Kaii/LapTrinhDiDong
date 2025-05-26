class Vi {
  final int maVi;
  final String tenVi;
  final String? loaiVi;
  final String? iconVi;

  const Vi({
    required this.maVi,
    required this.tenVi,
    this.loaiVi,
    this.iconVi,
  });

  factory Vi.fromJson(Map<String, dynamic> json) {
    return Vi(
      maVi: json['maVi'] is int ? json['maVi'] : int.tryParse(json['maVi'].toString()) ?? 0,
      tenVi: (json['tenVi'] as String?)?.trim() ?? '',
      loaiVi: (json['loaiVi'] as String?)?.trim(),
      iconVi: (json['iconVi'] as String?)?.trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maVi': maVi,
      'tenVi': tenVi,
      'loaiVi': loaiVi,
      'iconVi': iconVi,
    };
  }
}
