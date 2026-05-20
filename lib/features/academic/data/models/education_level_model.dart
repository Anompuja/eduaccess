import '../../domain/entities/education_level_entity.dart';

class EducationLevelModel extends EducationLevelEntity {
  const EducationLevelModel({
    required super.id,
    required super.schoolId,
    required super.name,
    required super.createdAt,
    required super.updatedAt,
  });

  factory EducationLevelModel.fromJson(Map<String, dynamic> json) {
    return EducationLevelModel(
      id: json['id'] as String? ?? '',
      schoolId: json['school_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
