import 'package:equatable/equatable.dart';

// ── Failure base class ────────────────────────────────────────────────────────
// Used with fpdart Either<Failure, T> throughout the data layer.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => message;
}

// ── Concrete failure types ────────────────────────────────────────────────────

/// 4xx/5xx HTTP errors returned by the EduAccess API
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// 401 — token expired / invalid credentials
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Sesi Anda telah berakhir. Silakan login kembali.']);
}

/// 403 — access denied (inactive account, insufficient role)
class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'Anda tidak memiliki akses ke halaman ini.']);
}

/// 404 — resource not found
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Data tidak ditemukan.']);
}

/// 409 — conflict (e.g. duplicate email)
class ConflictFailure extends Failure {
  const ConflictFailure(super.message);
}

/// Network / connectivity issues
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Tidak ada koneksi internet. Periksa jaringan Anda.']);
}

/// Request timeout
class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Koneksi timeout. Coba lagi.']);
}

/// Unexpected / unknown errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Terjadi kesalahan yang tidak terduga.']);
}

/// Validation error (client-side form validation)
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure(super.message, {this.fieldErrors});

  @override
  List<Object?> get props => [message, fieldErrors];
}

// ── API Response wrapper ──────────────────────────────────────────────────────
/// Wraps the standard EduAccess JSON envelope:
/// { "success": bool, "message": str, "data": T|null, "errors": List|null }
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<String>? errors;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromData != null
          ? fromData(json['data'])
          : null,
      errors: json['errors'] != null
          ? List<String>.from(json['errors'] as List)
          : null,
    );
  }
}
