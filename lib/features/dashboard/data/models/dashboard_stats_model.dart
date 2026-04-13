import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.totalStudents,
    required super.totalTeachers,
    required super.activeClasses,
    required super.subscriptionPlan,
    required super.weeklyAttendance,
    required super.recentActivities,
    required super.activeExams,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalStudents: json['total_students'] as int? ?? 0,
      totalTeachers: json['total_teachers'] as int? ?? 0,
      activeClasses: json['active_classes'] as int? ?? 0,
      subscriptionPlan: json['subscription_plan'] as String? ?? 'Free',
      weeklyAttendance: (json['weekly_attendance'] as List<dynamic>? ?? [])
          .map((e) => DailyAttendance(
                day: e['day'] as String? ?? '',
                present: e['present'] as int? ?? 0,
                absent: e['absent'] as int? ?? 0,
                late: e['late'] as int? ?? 0,
              ))
          .toList(),
      recentActivities: (json['recent_activities'] as List<dynamic>? ?? [])
          .map((e) => RecentActivity(
                title: e['title'] as String? ?? '',
                subtitle: e['subtitle'] as String? ?? '',
                time: e['time'] as String? ?? '',
                type: ActivityType.general,
              ))
          .toList(),
      activeExams: (json['active_exams'] as List<dynamic>? ?? [])
          .map((e) => ActiveExam(
                id: e['id'] as String? ?? '',
                title: e['title'] as String? ?? '',
                subject: e['subject'] as String? ?? '',
                className: e['class_name'] as String? ?? '',
                duration: e['duration'] as String? ?? '',
                status: _examStatus(e['status'] as String? ?? ''),
              ))
          .toList(),
    );
  }

  static ExamStatus _examStatus(String s) => switch (s) {
        'ongoing' => ExamStatus.ongoing,
        'scheduled' => ExamStatus.scheduled,
        'finished' => ExamStatus.finished,
        _ => ExamStatus.scheduled,
      };

  /// Fallback mock data when API endpoint is not ready.
  static DashboardStatsModel mock() => const DashboardStatsModel(
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
