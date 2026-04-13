import 'package:equatable/equatable.dart';

// Re-export UserRole from core so domain callers don't need two imports.
export '../../../../core/auth/auth_state.dart' show UserRole;

/// Pure domain entity — no Flutter, no Dio, no JSON.
/// Represents an authenticated EduAccess user.
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role; // raw string; use UserRole.fromString() at boundaries
  final String? schoolId;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.schoolId,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, name, email, role, schoolId, avatarUrl];
}
