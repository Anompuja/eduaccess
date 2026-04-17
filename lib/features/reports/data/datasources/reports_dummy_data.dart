import '../models/report_entities.dart';

const reportsDummyKpis = <ReportKpi>[
  ReportKpi(label: 'Total Siswa Aktif', value: '742', delta: '+3.2%'),
  ReportKpi(label: 'Kehadiran Rata-rata', value: '91.4%', delta: '+1.1%'),
  ReportKpi(label: 'Rata-rata Nilai', value: '83.7', delta: '+0.8%'),
];

const reportsDummyTopClasses = <ReportCategory>[
  ReportCategory(label: 'X IPA 1', value: 92),
  ReportCategory(label: 'XI IPA 2', value: 89),
  ReportCategory(label: 'X IPS 1', value: 87),
  ReportCategory(label: 'XI IPS 1', value: 85),
];

const reportsDummyAttendanceByMonth = <ReportCategory>[
  ReportCategory(label: 'Jan', value: 88),
  ReportCategory(label: 'Feb', value: 90),
  ReportCategory(label: 'Mar', value: 91),
  ReportCategory(label: 'Apr', value: 93),
];
