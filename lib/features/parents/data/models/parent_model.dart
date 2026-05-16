import '../../domain/entities/parent_entity.dart';

class ParentModel extends ParentEntity {
  ParentModel({
    required super.parentId,
    required super.name,
    required super.email,
    required super.phone,
    required super.childrenCount,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create ParentModel from JSON response
  factory ParentModel.fromJson(Map<String, dynamic> json) {
    return ParentModel(
      parentId: json['parent_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      childrenCount: json['children_count'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  /// Convert ParentModel to JSON for API requests
  /// Note: children_count is read-only from API response, not sent in requests
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  /// Create ParentModel from ParentEntity (for converting responses)
  factory ParentModel.fromEntity(ParentEntity entity) {
    return ParentModel(
      parentId: entity.parentId,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      childrenCount: entity.childrenCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
