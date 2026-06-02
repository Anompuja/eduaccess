class StaffRowData {
  final String staffId;
  final String userId;
  final String schoolId;
  final String name;
  final String email;
  final String username;
  final String avatar;
  final String phoneNumber;
  final String address;
  final String gender;
  final String religion;
  final String birthPlace;
  final String birthDate;
  final String nik;
  final String ktpImagePath;
  final String deletedAt;
  final String createdAt;
  final String updatedAt;

  const StaffRowData({
    required this.staffId,
    required this.userId,
    required this.schoolId,
    required this.name,
    required this.email,
    required this.username,
    required this.avatar,
    required this.phoneNumber,
    required this.address,
    required this.gender,
    required this.religion,
    required this.birthPlace,
    required this.birthDate,
    required this.nik,
    required this.ktpImagePath,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => deletedAt.isEmpty;

  String get status => isActive ? 'Aktif' : 'Nonaktif';

  factory StaffRowData.fromJson(Map<String, dynamic> json) {
    return StaffRowData(
      staffId: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      schoolId: json['school_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      address: json['address'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      religion: json['religion'] as String? ?? '',
      birthPlace: json['birth_place'] as String? ?? '',
      birthDate: _formatDate(json['birth_date']),
      nik: json['nik'] as String? ?? '',
      ktpImagePath: json['ktp_image_path'] as String? ?? '',
      deletedAt: _formatDate(json['deleted_at']),
      createdAt: _formatDate(json['created_at']),
      updatedAt: _formatDate(json['updated_at']),
    );
  }

  static String _formatDate(dynamic value) {
    if (value == null) return '';

    final text = value.toString();
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return text;

    final local = parsed.toLocal();
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final ampm = local.hour >= 12 ? 'PM' : 'AM';

    return '$day ${months[local.month - 1]} ${local.year}, ${hour.toString().padLeft(2, '0')}:$minute $ampm';
  }
}
