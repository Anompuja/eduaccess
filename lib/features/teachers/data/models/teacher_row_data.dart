class TeacherRowData {
  final String teacherId;
  final String userId;
  final String schoolId;
  final String name;
  final String nip;
  final String subject;
  final String subjectValue;
  final String username;
  final String email;
  final String phone;
  final String status;
  final String avatar;
  final String nuptk;
  final String address;
  final String birthPlace;
  final String birthDate;
  final String nik;
  final String ktpImagePath;
  final String kewarganegaraan;
  final String golonganDarah;
  final String beratBadan;
  final String tinggiBadan;
  final String pendidikanTerakhir;
  final String jurusan;
  final String tahunLulus;
  final String tahunMasuk;
  final String createdAt;
  final String updatedAt;
  final String deletedAt;

  const TeacherRowData({
    required this.teacherId,
    required this.name,
    required this.nip,
    required this.subject,
    required this.email,
    required this.phone,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.subjectValue = '',
    this.userId = '',
    this.schoolId = '',
    this.username = '',
    this.avatar = '',
    this.nuptk = '',
    this.address = '',
    this.birthPlace = '',
    this.birthDate = '',
    this.nik = '',
    this.ktpImagePath = '',
    this.kewarganegaraan = '',
    this.golonganDarah = '',
    this.beratBadan = '',
    this.tinggiBadan = '',
    this.pendidikanTerakhir = '',
    this.jurusan = '',
    this.tahunLulus = '',
    this.tahunMasuk = '',
    this.deletedAt = '',
  });

  bool get isActive => deletedAt.isEmpty;

  factory TeacherRowData.fromJson(Map<String, dynamic> json) {
    return TeacherRowData(
      teacherId: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      schoolId: json['school_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nip: json['nip'] as String? ?? '',
      subject: (json['pendidikan_terakhir'] as String? ?? json['jurusan'] as String? ?? '').trim(),
      subjectValue: '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone_number'] as String? ?? '',
      status: (json['deleted_at'] == null || json['deleted_at'].toString().isEmpty)
          ? 'Aktif'
          : 'Nonaktif',
      avatar: json['avatar'] as String? ?? '',
      nuptk: json['nuptk'] as String? ?? '',
      address: json['address'] as String? ?? '',
      birthPlace: json['birth_place'] as String? ?? '',
      birthDate: _formatDate(json['birth_date']),
      nik: json['nik'] as String? ?? '',
      ktpImagePath: json['ktp_image_path'] as String? ?? '',
      kewarganegaraan: json['kewarganegaraan'] as String? ?? '',
      golonganDarah: json['golongan_darah'] as String? ?? '',
      beratBadan: json['berat_badan'] as String? ?? '',
      tinggiBadan: json['tinggi_badan'] as String? ?? '',
      pendidikanTerakhir: json['pendidikan_terakhir'] as String? ?? '',
      jurusan: json['jurusan'] as String? ?? '',
      tahunLulus: json['tahun_lulus'] as String? ?? '',
      tahunMasuk: json['tahun_masuk'] as String? ?? '',
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
