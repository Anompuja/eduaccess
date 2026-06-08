class AdminRowData {
  final String adminId;
  final String schoolId;
  final String name;
  final String email;
  final String username;
  final String phoneNumber;
  final String address;
  final String gender;
  final String religion;
  final String birthPlace;
  final String birthDate;
  final String nik;
  final String ktpImagePath;
  final String createdAt;
  final String updatedAt;

  const AdminRowData({
    required this.adminId,
    required this.schoolId,
    required this.name,
    required this.email,
    required this.username,
    required this.phoneNumber,
    required this.address,
    required this.gender,
    required this.religion,
    required this.birthPlace,
    required this.birthDate,
    required this.nik,
    required this.ktpImagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminRowData.fromJson(Map<String, dynamic> json) {
    return AdminRowData(
      adminId: json['id'] as String? ?? '',
      schoolId: json['school_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      address: json['address'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      religion: json['religion'] as String? ?? '',
      birthPlace: json['birth_place'] as String? ?? '',
      birthDate: json['birth_date']?.toString() ?? '',
      nik: json['nik'] as String? ?? '',
      ktpImagePath: json['ktp_image_path'] as String? ?? '',
      createdAt: _formatDate(json['created_at']),
      updatedAt: _formatDate(json['updated_at']),
    );
  }

  static String _formatDate(dynamic value) {
  if (value == null) return '';

  final text = value.toString();
  final parsed = DateTime.tryParse(text);
  if (parsed == null) return text;

  const months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  final day = parsed.day.toString().padLeft(2, '0');

  return '$day ${months[parsed.month - 1]} ${parsed.year}';
}
}
