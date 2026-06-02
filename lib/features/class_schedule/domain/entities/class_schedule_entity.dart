class ClassScheduleEntity {
  final String id;
  final String schoolId;
  final String classroomId;
  final String subjectId;
  final String teacherId;
  final String? startPeriodId;
  final String? endPeriodId;
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
    required this.subjectId,
    required this.teacherId,
    this.startPeriodId,
    this.endPeriodId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.teacherAttendanceTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}
