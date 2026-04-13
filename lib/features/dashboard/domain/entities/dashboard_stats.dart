import 'package:equatable/equatable.dart';

/// Aggregate stats shown on the dashboard.
class DashboardStats extends Equatable {
  final int totalStudents;
  final int totalTeachers;
  final int activeClasses;
  final String subscriptionPlan;
  final List<DailyAttendance> weeklyAttendance;
  final List<RecentActivity> recentActivities;
  final List<ActiveExam> activeExams;

  const DashboardStats({
    required this.totalStudents,
    required this.totalTeachers,
    required this.activeClasses,
    required this.subscriptionPlan,
    required this.weeklyAttendance,
    required this.recentActivities,
    required this.activeExams,
  });

  @override
  List<Object?> get props => [
        totalStudents,
        totalTeachers,
        activeClasses,
        subscriptionPlan,
      ];
}

/// Attendance data for one day — used in the bar chart.
class DailyAttendance extends Equatable {
  final String day;   // e.g. 'Sen', 'Sel'
  final int present;
  final int absent;
  final int late;

  const DailyAttendance({
    required this.day,
    required this.present,
    required this.absent,
    required this.late,
  });

  int get total => present + absent + late;

  @override
  List<Object?> get props => [day, present, absent, late];
}

/// One item in the recent-activity feed.
class RecentActivity extends Equatable {
  final String title;
  final String subtitle;
  final String time;
  final ActivityType type;

  const RecentActivity({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
  });

  @override
  List<Object?> get props => [title, subtitle, time, type];
}

enum ActivityType { student, attendance, exam, staff, general }

/// One card in the active-exams section.
class ActiveExam extends Equatable {
  final String id;
  final String title;
  final String subject;
  final String className;
  final String duration;
  final ExamStatus status;

  const ActiveExam({
    required this.id,
    required this.title,
    required this.subject,
    required this.className,
    required this.duration,
    required this.status,
  });

  @override
  List<Object?> get props => [id, title, subject, className, status];
}

enum ExamStatus { ongoing, scheduled, finished }
