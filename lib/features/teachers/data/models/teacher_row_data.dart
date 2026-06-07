class TeacherRowData {
  final String teacherId;
  final String userId;
  final String schoolId;
  final String name;
  final String email;
  final String username;
  final String phone;
  final String avatar;
  final String nip;
  final String nuptk;
  final String address;
  final String gender;
  final String religion;
  final String birthPlace;
  final String birthDate;
  final String nik;
  final String ktpImagePath;
  final String kewarganegaraan;
  final String golonganDarah;
  final String beratBadan;
  final String tinggiBadan;
  final String penyakitYangSeringKambuh;
  final String kelainanJasmani;
  final String penyakitKronisYangPernahDiderita;
  final String rtRw;
  final String kodePos;
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
    required this.email,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
    this.userId = '',
    this.schoolId = '',
    this.username = '',
    this.avatar = '',
    this.nip = '',
    this.nuptk = '',
    this.address = '',
    this.gender = '',
    this.religion = '',
    this.birthPlace = '',
    this.birthDate = '',
    this.nik = '',
    this.ktpImagePath = '',
    this.kewarganegaraan = '',
    this.golonganDarah = '',
    this.beratBadan = '',
    this.tinggiBadan = '',
    this.penyakitYangSeringKambuh = '',
    this.kelainanJasmani = '',
    this.penyakitKronisYangPernahDiderita = '',
    this.rtRw = '',
    this.kodePos = '',
    this.pendidikanTerakhir = '',
    this.jurusan = '',
    this.tahunLulus = '',
    this.tahunMasuk = '',
    this.deletedAt = '',
  });

  bool get isActive => deletedAt.isEmpty;

  String get genderLabel {
    switch (gender.trim().toLowerCase()) {
      case 'male':
        return 'Laki-laki';
      case 'female':
        return 'Perempuan';
      case 'other':
        return 'Lainnya';
      default:
        return gender;
    }
  }

  factory TeacherRowData.fromJson(Map<String, dynamic> json) {
    return TeacherRowData(
      teacherId: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      schoolId: json['school_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      phone: json['phone_number'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      nip: json['nip'] as String? ?? '',
      nuptk: json['nuptk'] as String? ?? '',
      address: json['address'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      religion: json['religion'] as String? ?? '',
      birthPlace: json['birth_place'] as String? ?? '',
      birthDate: json['birth_date']?.toString() ?? '',
      nik: json['nik'] as String? ?? '',
      ktpImagePath: json['ktp_image_path'] as String? ?? '',
      kewarganegaraan: json['kewarganegaraan'] as String? ?? '',
      golonganDarah: json['golongan_darah'] as String? ?? '',
      beratBadan: json['berat_badan'] as String? ?? '',
      tinggiBadan: json['tinggi_badan'] as String? ?? '',
      penyakitYangSeringKambuh: json['penyakit_yang_sering_kambuh'] as String? ?? '',
      kelainanJasmani: json['kelainan_jasmani'] as String? ?? '',
      penyakitKronisYangPernahDiderita: json['penyakit_kronis_yang_pernah_diderita'] as String? ?? '',
      rtRw: json['rt_rw'] as String? ?? '',
      kodePos: json['kode_pos'] as String? ?? '',
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

  const months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  final day = parsed.day.toString().padLeft(2, '0');

  return '$day ${months[parsed.month - 1]} ${parsed.year}';
}
}
