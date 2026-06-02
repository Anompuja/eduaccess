import '../../domain/entities/dashboard_stats.dart';
import 'dashboard_school_model.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    super.school,
    super.schoolUsersCount,
    super.studentsCount,
    super.activeStudentsCount,
    super.enrollmentsCount,
    super.attendancePresent,
    super.attendanceLate,
    super.attendanceAbsent,
    super.attendanceExcused,
    super.attendanceTotal,
    super.attendanceRate,
    super.subscriptionPlanName,
    super.subscriptionStatus,
    super.subscriptionCycle,
    super.subscriptionPrice,
    super.subscriptionEndsAt,
    required super.totalStudents,
    required super.totalTeachers,
    required super.activeClasses,
    required super.subscriptionPlan,
    required super.weeklyAttendance,
    required super.recentActivities,
    required super.activeExams,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final schoolJson = _map(json['school']);
    final counts = _map(json['counts']);
    final attendance = _map(json['attendance']);
    final subscription = _map(json['subscription']);

    return DashboardStatsModel(
      school: schoolJson.isEmpty
          ? null
          : DashboardSchoolModel.fromJson(schoolJson),
      schoolUsersCount: _readInt(counts, const [
        'school_users',
        'total_teachers',
      ]),
      studentsCount: _readInt(counts, const ['students', 'total_students']),
      activeStudentsCount: _readInt(counts, const ['active_students']),
      enrollmentsCount: _readInt(counts, const [
        'enrollments',
        'active_classes',
      ]),
      attendancePresent: _readInt(attendance, const ['present']),
      attendanceLate: _readInt(attendance, const ['late']),
      attendanceAbsent: _readInt(attendance, const ['absent']),
      attendanceExcused: _readInt(attendance, const ['excused']),
      attendanceTotal: _readInt(attendance, const ['total']),
      attendanceRate: _readDouble(attendance, const ['rate']),
      subscriptionPlanName: _readString(subscription, const [
        'plan_name',
        'subscription_plan',
      ], defaultValue: 'Free'),
      subscriptionStatus: _readString(subscription, const [
        'status',
      ], defaultValue: ''),
      subscriptionCycle: _readString(subscription, const [
        'cycle',
      ], defaultValue: ''),
      subscriptionPrice: _readNullableDouble(subscription, const ['price']),
      subscriptionEndsAt: _readNullableString(subscription, const ['ends_at']),
      totalStudents: _readInt(counts, const ['students', 'total_students']),
      totalTeachers: _readInt(counts, const ['school_users', 'total_teachers']),
      activeClasses: _readInt(counts, const ['enrollments', 'active_classes']),
      subscriptionPlan: _readString(subscription, const [
        'plan_name',
        'subscription_plan',
      ], defaultValue: 'Free'),
      weeklyAttendance: _parseWeeklyAttendance(json),
      recentActivities: _parseRecentActivities(json),
      activeExams: _parseActiveExams(json),
    );
  }

  static ExamStatus _examStatus(String s) => switch (s) {
    'ongoing' => ExamStatus.ongoing,
    'scheduled' => ExamStatus.scheduled,
    'finished' => ExamStatus.finished,
    _ => ExamStatus.scheduled,
  };

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, dynamic value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  static int _readInt(
    Map<String, dynamic> json,
    List<String> keys, {
    int defaultValue = 0,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return defaultValue;
  }

  static double _readDouble(
    Map<String, dynamic> json,
    List<String> keys, {
    double defaultValue = 0,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value is double) return value;
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return defaultValue;
  }

  static double? _readNullableDouble(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      if (value is double) return value;
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static String _readString(
    Map<String, dynamic> json,
    List<String> keys, {
    required String defaultValue,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) return value;
      if (value != null) return value.toString();
    }
    return defaultValue;
  }

  static String? _readNullableString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) return value;
      if (value != null) return value.toString();
    }
    return null;
  }

  static List<DailyAttendance> _parseWeeklyAttendance(
    Map<String, dynamic> json,
  ) {
    final raw = json['weekly_attendance'];
    if (raw is! List) return const [];

    return raw.whereType<Map>().map((entry) {
      final data = _map(entry);
      return DailyAttendance(
        day: data['day']?.toString() ?? '',
        present: _readInt(data, const ['present']),
        absent: _readInt(data, const ['absent']),
        late: _readInt(data, const ['late']),
      );
    }).toList();
  }

  static List<RecentActivity> _parseRecentActivities(
    Map<String, dynamic> json,
  ) {
    final raw = json['recent_activities'];
    if (raw is! List) return const [];

    return raw.whereType<Map>().map((entry) {
      final data = _map(entry);
      return RecentActivity(
        title: data['title']?.toString() ?? '',
        subtitle: data['subtitle']?.toString() ?? '',
        time: data['time']?.toString() ?? '',
        type: ActivityType.general,
      );
    }).toList();
  }

  static List<ActiveExam> _parseActiveExams(Map<String, dynamic> json) {
    final raw = json['active_exams'];
    if (raw is! List) return const [];

    return raw.whereType<Map>().map((entry) {
      final data = _map(entry);
      return ActiveExam(
        id: data['id']?.toString() ?? '',
        title: data['title']?.toString() ?? '',
        subject: data['subject']?.toString() ?? '',
        className: data['class_name']?.toString() ?? '',
        duration: data['duration']?.toString() ?? '',
        status: _examStatus(data['status']?.toString() ?? ''),
      );
    }).toList();
  }

  /// Fallback mock data when API endpoint is not ready.
  static DashboardStatsModel mock() => const DashboardStatsModel(
    school: null,
    schoolUsersCount: 64,
    studentsCount: 1248,
    activeStudentsCount: 1204,
    enrollmentsCount: 32,
    attendancePresent: 180,
    attendanceLate: 8,
    attendanceAbsent: 12,
    attendanceExcused: 4,
    attendanceTotal: 204,
    attendanceRate: 88.2,
    subscriptionPlanName: 'Pro',
    subscriptionStatus: 'active',
    subscriptionCycle: 'monthly',
    subscriptionPrice: 149000.0,
    subscriptionEndsAt: '2024-12-31',
    totalStudents: 1248,
    totalTeachers: 64,
    activeClasses: 32,
    subscriptionPlan: 'Pro',
    weeklyAttendance: [
      DailyAttendance(day: 'Sen', present: 180, absent: 12, late: 8),
      DailyAttendance(day: 'Sel', present: 175, absent: 15, late: 10),
      DailyAttendance(day: 'Rab', present: 185, absent: 8, late: 7),
      DailyAttendance(day: 'Kam', present: 172, absent: 18, late: 10),
      DailyAttendance(day: 'Jum', present: 168, absent: 20, late: 12),
    ],
    recentActivities: [
      RecentActivity(
        title: 'Siswa baru didaftarkan',
        subtitle: 'Ahmad Fauzi — Kelas 10A',
        time: '5 menit lalu',
        type: ActivityType.student,
      ),
      RecentActivity(
        title: 'Absensi dikonfirmasi',
        subtitle: 'Kelas 11B — Hari ini',
        time: '20 menit lalu',
        type: ActivityType.attendance,
      ),
      RecentActivity(
        title: 'Ujian Matematika selesai',
        subtitle: 'Kelas 12A — 45 peserta',
        time: '1 jam lalu',
        type: ActivityType.exam,
      ),
      RecentActivity(
        title: 'Guru baru bergabung',
        subtitle: 'Siti Rahayu — Bahasa Indonesia',
        time: '2 jam lalu',
        type: ActivityType.staff,
      ),
    ],
    activeExams: [
      ActiveExam(
        id: '1',
        title: 'UTS Matematika',
        subject: 'Matematika',
        className: 'Kelas 10A',
        duration: '90 menit',
        status: ExamStatus.ongoing,
      ),
      ActiveExam(
        id: '2',
        title: 'Quiz Fisika',
        subject: 'Fisika',
        className: 'Kelas 11B',
        duration: '45 menit',
        status: ExamStatus.scheduled,
      ),
      ActiveExam(
        id: '3',
        title: 'UTS Bahasa Indonesia',
        subject: 'Bahasa Indonesia',
        className: 'Kelas 12A',
        duration: '60 menit',
        status: ExamStatus.finished,
      ),
    ],
  );
}
