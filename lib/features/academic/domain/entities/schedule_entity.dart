class ScheduleEntity {
  final String id;
  final String schoolId;
  final String dayOfWeek;
  final int periodNumber;
  final String label;
  final String startTime;
  final String endTime;
  final bool isBreak;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScheduleEntity({
    required this.id,
    required this.schoolId,
    required this.dayOfWeek,
    required this.periodNumber,
    required this.label,
    required this.startTime,
    required this.endTime,
    required this.isBreak,
    required this.createdAt,
    required this.updatedAt,
  });
}
