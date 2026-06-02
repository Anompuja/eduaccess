class StudentRowData {
  final String studentId;
  final String userId;
  final String schoolId;
  final String name;
  final String email;
  final String username;
  final String avatar;
  final String nis;
  final String nisn;
  final String phone;
  final String address;
  final String gender;
  final String religion;
  final String birthPlace;
  final String birthDate;
  final String tahunMasuk;
  final String jalurMasukSekolah;
  final String educationLevelId;
  final String classId;
  final String subClassId;
  final String studentClass; // For UI display
  final String status;
  final String createdAt;
  final String updatedAt;
  final String deletedAt;

  const StudentRowData({
    required this.studentId,
    required this.name,
    required this.nis,
    required this.nisn,
    required this.email,
    required this.phone,
    required this.studentClass,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.userId = '',
    this.schoolId = '',
    this.username = '',
    this.avatar = '',
    this.address = '',
    this.gender = '',
    this.religion = '',
    this.birthPlace = '',
    this.birthDate = '',
    this.tahunMasuk = '',
    this.jalurMasukSekolah = '',
    this.educationLevelId = '',
    this.classId = '',
    this.subClassId = '',
    this.deletedAt = '',
  });

  bool get isActive => deletedAt.isEmpty;

  factory StudentRowData.fromJson(Map<String, dynamic> json) {
    // Attempt to formulate a 'studentClass' string from sub class, class, etc. if provided, or default it.
    // The backend might return relations or just IDs. For now, if there's no name, we might not show it perfectly.
    // In many cases, it might come back in an aggregated field or we just leave it blank if unknown.
    String studentClassLabel = json['sub_class_name'] as String? ?? 
                               json['class_name'] as String? ?? 
                               'Belum ada kelas';

    return StudentRowData(
      studentId: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      schoolId: json['school_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      nis: json['nis'] as String? ?? '',
      nisn: json['nisn'] as String? ?? '',
      phone: json['phone_number'] as String? ?? '',
      address: json['address'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      religion: json['religion'] as String? ?? '',
      birthPlace: json['birth_place'] as String? ?? '',
      birthDate: _formatDate(json['birth_date']),
      tahunMasuk: json['tahun_masuk'] as String? ?? '',
      jalurMasukSekolah: json['jalur_masuk_sekolah'] as String? ?? '',
      educationLevelId: json['education_level_id'] as String? ?? '',
      classId: json['class_id'] as String? ?? '',
      subClassId: json['sub_class_id'] as String? ?? '',
      studentClass: studentClassLabel,
      status: (json['deleted_at'] == null || json['deleted_at'].toString().isEmpty)
          ? 'Aktif'
          : 'Nonaktif',
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