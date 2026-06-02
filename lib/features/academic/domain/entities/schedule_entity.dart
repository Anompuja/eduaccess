class ScheduleEntity {
  final String id;
  final String schoolId;
  final String shiftType;
  final String startTime;
  final String endTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScheduleEntity({
    required this.id,
    required this.schoolId,
    required this.shiftType,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.updatedAt,
  });
}
