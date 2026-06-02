import '../../domain/entities/attendance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    required super.id,
    required super.classScheduleId,
    required super.studentId,
    required super.status,
    required super.type,
    required super.note,
    required super.photoPath,
    super.studentAttendanceTime,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String? ?? '',
      classScheduleId: json['class_schedule_id'] as String? ?? '',
      studentId: json['student_id'] as String? ?? '',
      status: json['status'] as String? ?? 'scheduled',
      type: json['type'] as String? ?? '',
      note: json['note'] as String? ?? '',
      photoPath: json['photo_path'] as String? ?? '',
      studentAttendanceTime: json['student_attendance_time'] != null
          ? DateTime.tryParse(json['student_attendance_time'] as String)
          : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
