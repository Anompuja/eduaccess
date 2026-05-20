import '../../domain/entities/academic_year_entity.dart';

class AcademicYearModel extends AcademicYearEntity {
  const AcademicYearModel({
    required super.id,
    required super.schoolId,
    required super.name,
    required super.startDate,
    required super.endDate,
    required super.isActive,
    required super.description,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AcademicYearModel.fromJson(Map<String, dynamic> json) {
    return AcademicYearModel(
      id: json['id'] as String? ?? '',
      schoolId: json['school_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] as String? ?? '') ?? DateTime.now(),
      isActive: json['is_active'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
