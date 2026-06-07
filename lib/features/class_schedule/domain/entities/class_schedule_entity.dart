class ClassScheduleEntity {
  final String id;
  final String schoolId;
  final String classroomId;
  final String classroomName;
  final String subjectId;
  final String subjectName;
  final String teacherId;
  final String teacherName;
  final String? startPeriodId;
  final int? startPeriodNumber;
  final String? startPeriodLabel;
  final String? endPeriodId;
  final int? endPeriodNumber;
  final String date;
  final String startTime;
  final String endTime;
  final DateTime? teacherAttendanceTime;
  final String status; // scheduled, ongoing, completed, cancelled
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClassScheduleEntity({
    required this.id,
    required this.schoolId,
    required this.classroomId,
    required this.classroomName,
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.teacherName,
    this.startPeriodId,
    this.startPeriodNumber,
    this.startPeriodLabel,
    this.endPeriodId,
    this.endPeriodNumber,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.teacherAttendanceTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}
