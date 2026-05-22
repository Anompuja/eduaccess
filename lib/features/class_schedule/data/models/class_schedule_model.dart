import '../../domain/entities/class_schedule_entity.dart';

class ClassScheduleModel extends ClassScheduleEntity {
  const ClassScheduleModel({
    required super.id,
    required super.schoolId,
    required super.classroomId,
    required super.subjectId,
    required super.teacherId,
    super.startPeriodId,
    super.endPeriodId,
    required super.date,
    required super.startTime,
    required super.endTime,
    super.teacherAttendanceTime,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ClassScheduleModel.fromJson(Map<String, dynamic> json) {
    return ClassScheduleModel(
      id: json['id'] as String? ?? '',
      schoolId: json['school_id'] as String? ?? '',
      classroomId: json['classroom_id'] as String? ?? '',
      subjectId: json['subject_id'] as String? ?? '',
      teacherId: json['teacher_id'] as String? ?? '',
      startPeriodId: json['start_period_id'] as String?,
      endPeriodId: json['end_period_id'] as String?,
      date: json['date'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      teacherAttendanceTime: json['teacher_attendance_time'] != null
          ? DateTime.tryParse(json['teacher_attendance_time'] as String)
          : null,
      status: json['status'] as String? ?? 'scheduled',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
