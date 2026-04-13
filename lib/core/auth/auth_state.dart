import 'package:equatable/equatable.dart';

/// User roles as defined by the EduAccess backend JWT payload.
enum UserRole {
  superadmin,
  adminSekolah,
  kepalaSekolah,
  guru,
  siswa,
  orangtua,
  staff;

  /// Parse from raw JWT role string (snake_case).
  static UserRole fromString(String raw) => switch (raw) {
        'superadmin'      => UserRole.superadmin,
        'admin_sekolah'   => UserRole.adminSekolah,
        'kepala_sekolah'  => UserRole.kepalaSekolah,
        'guru'            => UserRole.guru,
        'siswa'           => UserRole.siswa,
        'orangtua'        => UserRole.orangtua,
        'staff'           => UserRole.staff,
        _                 => UserRole.staff,
      };

  /// Human-readable Indonesian label for UI display.
  String get displayName => switch (this) {
        UserRole.superadmin     => 'Super Admin',
        UserRole.adminSekolah   => 'Admin Sekolah',
        UserRole.kepalaSekolah  => 'Kepala Sekolah',
        UserRole.guru           => 'Guru',
        UserRole.siswa          => 'Siswa',
        UserRole.orangtua       => 'Orang Tua',
        UserRole.staff          => 'Staff',
      };
}

/// Immutable snapshot of the authenticated user, derived from JWT + /auth/me.
class AuthUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? schoolId;
  final String? avatarUrl;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.schoolId,
    this.avatarUrl,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: UserRole.fromString(json['role'] as String? ?? ''),
        schoolId: json['school_id'] as String?,
        avatarUrl: json['avatar_url'] as String?,
      );

  AuthUser copyWith({
    String? name,
    String? avatarUrl,
  }) =>
      AuthUser(
        id: id,
        name: name ?? this.name,
        email: email,
        role: role,
        schoolId: schoolId,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );

  @override
  List<Object?> get props => [id, name, email, role, schoolId, avatarUrl];
}

/// Top-level auth state held by AuthNotifier.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// App is checking stored tokens (initial boot).
final class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

/// User is authenticated with a valid session.
final class AuthStateAuthenticated extends AuthState {
  final AuthUser user;
  const AuthStateAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// No valid session — user must log in.
final class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

/// Login / register / refresh is in progress.
final class AuthStateAuthenticating extends AuthState {
  const AuthStateAuthenticating();
}

/// An auth operation failed.
final class AuthStateError extends AuthState {
  final String message;
  const AuthStateError(this.message);

  @override
  List<Object?> get props => [message];
}
