import '../../domain/entities/schedule_entity.dart';

class ScheduleModel extends ScheduleEntity {
  const ScheduleModel({
    required super.id,
    required super.schoolId,
    required super.dayOfWeek,
    required super.periodNumber,
    required super.label,
    required super.startTime,
    required super.endTime,
    required super.isBreak,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as String? ?? '',
      schoolId: json['school_id'] as String? ?? '',
      dayOfWeek: json['day_of_week'] as String? ?? '',
      periodNumber: json['period_number'] as int? ?? 0,
      label: json['label'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      isBreak: json['is_break'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
