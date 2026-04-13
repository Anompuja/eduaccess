import 'package:fpdart/fpdart.dart';

import '../../../../core/api/api_exception.dart';
import '../entities/user_entity.dart';

/// Abstract contract for authentication operations.
/// Implementations live in the data layer.
/// All methods return `Either<Failure, T>` — never throw.
abstract interface class AuthRepository {
  /// Authenticate with email + password.
  /// Returns the authenticated user on success.
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Register a new account.
  /// Returns the created user; caller should navigate to login.
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  });

  /// Invalidate the session on the server.
  Future<Either<Failure, Unit>> logout();

  /// Fetch the currently authenticated user profile.
  Future<Either<Failure, UserEntity>> getProfile();

  /// Exchange a refresh token for a new access token.
  /// Returns the new access token string.
  Future<Either<Failure, String>> refreshToken(String refreshToken);
}
