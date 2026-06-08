class AttendanceEntity {
  final String id;
  final String classScheduleId;
  final String studentId;
  final String studentName;
  final String status; // present, sick, permission, absent, scheduled
  final String type;
  final String note;
  final String photoPath;
  final DateTime? studentAttendanceTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AttendanceEntity({
    required this.id,
    required this.classScheduleId,
    required this.studentId,
    required this.studentName,
    required this.status,
    required this.type,
    required this.note,
    required this.photoPath,
    this.studentAttendanceTime,
    required this.createdAt,
    required this.updatedAt,
  });
}
