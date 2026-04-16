import '../models/school_entities.dart';

const schoolDummyProfile = SchoolProfile(
  id: 'school_001',
  name: 'SMA EduAccess Nusantara',
  address: 'Jl. Pendidikan No. 12, Makassar',
  phone: '+62 411 8899 2211',
  email: 'admin@smaeduaccess.sch.id',
  description:
      'Sekolah menengah berbasis teknologi dengan fokus pada karakter, akademik, dan literasi digital.',
  imagePath: 'assets/images/school_logo.png',
  timeZone: 'Asia/Makassar',
  status: SchoolStatus.active,
);

const schoolDummyRules = <SchoolRule>[
  SchoolRule(
    id: 'rule_01',
    label: 'Batas Keterlambatan (menit)',
    key: 'max_late_minutes',
    value: '15',
    description: 'Batas keterlambatan maksimum sebelum dianggap alfa.',
  ),
  SchoolRule(
    id: 'rule_02',
    label: 'Minimal Kehadiran (%)',
    key: 'minimum_attendance_percentage',
    value: '80',
    description: 'Minimal persentase kehadiran per semester.',
  ),
  SchoolRule(
    id: 'rule_03',
    label: 'Nilai Ketuntasan Minimal',
    key: 'passing_grade',
    value: '75',
    description: 'Nilai minimum ketuntasan mata pelajaran.',
  ),
];
