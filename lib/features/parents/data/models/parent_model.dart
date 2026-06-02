import '../../domain/entities/parent_entity.dart';

class ParentModel extends ParentEntity {
  ParentModel({
    required super.parentId,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.religion,
    required super.address,
    required super.schoolId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ParentModel.fromJson(Map<String, dynamic> json) {
    return ParentModel(
      parentId: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      religion: json['religion'] as String? ?? '',
      address: json['address'] as String? ?? '',
      schoolId: json['school_id'] as String? ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  factory ParentModel.fromEntity(ParentEntity entity) {
    return ParentModel(
      parentId: entity.parentId,
      name: entity.name,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      religion: entity.religion,
      address: entity.address,
      schoolId: entity.schoolId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
