import '../../domain/entities/user_entity.dart';

/// Data model — extends UserEntity and adds JSON serialization.
/// Never used in domain or presentation — only in data layer.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.schoolId,
    super.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String? ?? '',
        schoolId: json['school_id'] as String?,
        avatarUrl: json['avatar_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'school_id': schoolId,
        'avatar_url': avatarUrl,
      };
}
