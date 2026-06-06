class HeadmasterRowData {
  final String headmasterId;
  final String userId;
  final String schoolId;
  final String name;
  final String nip;
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

  const HeadmasterRowData({
    required this.headmasterId,
    required this.userId,
    required this.schoolId,
    required this.name,
    required this.nip,
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
  String get genderLabel => _genderLabel(gender);

  String get birthDateLabel => _formatDate(birthDate);

  String get deletedAtLabel => _formatDate(deletedAt);

  String get createdAtLabel => _formatDate(createdAt);

  String get updatedAtLabel => _formatDate(updatedAt);

  factory HeadmasterRowData.fromJson(Map<String, dynamic> json) {
    return HeadmasterRowData(
      headmasterId: _stringValue(json['id']),
      userId: _stringValue(json['user_id']),
      schoolId: _stringValue(json['school_id']),
      name: _stringValue(json['name']),
      nip: _stringValue(json['nip']),
      email: _stringValue(json['email']),
      username: _stringValue(json['username']),
      avatar: _stringValue(json['avatar']),
      phoneNumber: _stringValue(json['phone_number']),
      address: _stringValue(json['address']),
      gender: _stringValue(json['gender']),
      religion: _stringValue(json['religion']),
      birthPlace: _stringValue(json['birth_place']),
      birthDate: _stringValue(json['birth_date']),
      nik: _stringValue(json['nik']),
      ktpImagePath: _stringValue(json['ktp_image_path']),
      deletedAt: _stringValue(json['deleted_at']),
      createdAt: _stringValue(json['created_at']),
      updatedAt: _stringValue(json['updated_at']),
    );
  }

  static String _stringValue(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }

  static String _formatDate(String value) {
    if (value.isEmpty) return '';

    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;

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

  static String _genderLabel(String value) {
    switch (value.trim().toUpperCase()) {
      case 'L':
        return 'Laki-laki';
      case 'P':
        return 'Perempuan';
      default:
        return value;
    }
  }
}
