import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/auth/token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Bridges the datasource ↔ domain.
/// Converts DioExceptions into typed Failure values.
/// Also manages token persistence after login/refresh.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;
  final TokenStorage _storage;

  AuthRepositoryImpl(this._remote, this._storage);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _remote.login(email: email, password: password);
      await _storage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return Right(result.user);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final user = await _remote.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      return Right(user);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _remote.logout();
      await _storage.clearAll();
      return const Right(unit);
    } on DioException catch (e) {
      // Still clear local tokens even if server call fails
      await _storage.clearAll();
      return Left(_mapDioError(e));
    } catch (_) {
      await _storage.clearAll();
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    try {
      final user = await _remote.getProfile();
      return Right(user);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken(String refreshToken) async {
    try {
      final token = await _remote.refreshToken(refreshToken);
      return Right(token);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  // ── Error mapping ─────────────────────────────────────────────────────────
  Failure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const TimeoutFailure();
    }
    if (e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }

    final status = e.response?.statusCode;
    final message = _extractMessage(e);

    return switch (status) {
      401 => const UnauthorizedFailure('Email atau password salah.'),
      403 => const ForbiddenFailure('Akun tidak aktif. Hubungi administrator.'),
      404 => NotFoundFailure(message ?? 'Data tidak ditemukan.'),
      409 => ConflictFailure(message ?? 'Email sudah terdaftar.'),
      422 => ValidationFailure(message ?? 'Data tidak valid.'),
      500 => ServerFailure(message ?? 'Kesalahan server.', statusCode: 500),
      _ => ServerFailure(message ?? 'Terjadi kesalahan.', statusCode: status),
    };
  }

  String? _extractMessage(DioException e) {
    try {
      return e.response?.data['message'] as String?;
    } catch (_) {
      return null;
    }
  }
}
