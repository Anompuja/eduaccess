enum TrackingStatus {
  onTrack,
  needAttention,
}

class StudentTrackingHistory {
  final String period;
  final String className;
  final double averageScore;
  final double attendancePercent;
  final String notes;

  const StudentTrackingHistory({
    required this.period,
    required this.className,
    required this.averageScore,
    required this.attendancePercent,
    required this.notes,
  });
}

class StudentTrackingRow {
  final String id;
  final String name;
  final String nis;
  final String className;
  final String semester;
  final String academicYear;
  final double averageScore;
  final double attendancePercent;
  final TrackingStatus status;
  final List<StudentTrackingHistory> histories;

  const StudentTrackingRow({
    required this.id,
    required this.name,
    required this.nis,
    required this.className,
    required this.semester,
    required this.academicYear,
    required this.averageScore,
    required this.attendancePercent,
    required this.status,
    required this.histories,
  });
}
