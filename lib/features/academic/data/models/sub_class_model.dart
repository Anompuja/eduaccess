import '../../domain/entities/sub_class_entity.dart';

class SubClassModel extends SubClassEntity {
  const SubClassModel({
    required super.id,
    required super.schoolId,
    required super.classId,
    required super.name,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SubClassModel.fromJson(Map<String, dynamic> json) {
    return SubClassModel(
      id: json['id'] as String? ?? '',
      schoolId: json['school_id'] as String? ?? '',
      classId: json['class_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
