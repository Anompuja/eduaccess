class AdminRowData {
  final String adminId;
  final String name;
  final String phoneNumber;
  final String address;
  final String nik;
  final String createdAt;
  final String updatedAt;

  const AdminRowData({
    required this.adminId,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.nik,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminRowData.fromJson(Map<String, dynamic> json) {
    return AdminRowData(
      adminId: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      address: json['address'] as String? ?? '',
      nik: json['nik'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}
