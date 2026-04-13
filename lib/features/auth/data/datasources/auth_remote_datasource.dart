import 'package:dio/dio.dart';

import '../../../../core/api/api_endpoints.dart';
import '../models/user_model.dart';

/// Raw Dio calls only — no business logic.
/// Throws DioException or Exception on failure;
/// the repository impl converts these to Failure types.
class AuthRemoteDatasource {
  final Dio _dio;
  AuthRemoteDatasource(this._dio);

  /// POST /auth/login → returns tokens + user.
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final resp = await _dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    final data = resp.data['data'] as Map<String, dynamic>;
    return LoginResult(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  /// POST /auth/register → returns created user.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final resp = await _dio.post(
      ApiEndpoints.register,
      data: {'name': name, 'email': email, 'password': password, 'role': role},
    );
    final data = resp.data['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  /// POST /auth/logout → no meaningful response body.
  Future<void> logout() async {
    await _dio.post(ApiEndpoints.logout);
  }

  /// GET /auth/me → current user profile.
  Future<UserModel> getProfile() async {
    final resp = await _dio.get(ApiEndpoints.me);
    final data = resp.data['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  /// POST /auth/refresh → new access token.
  Future<String> refreshToken(String refreshToken) async {
    // Uses a fresh Dio to avoid interceptor loops
    final freshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
    final resp = await freshDio.post(
      ApiEndpoints.refresh,
      data: {'refresh_token': refreshToken},
    );
    final data = resp.data['data'] as Map<String, dynamic>;
    return data['access_token'] as String;
  }
}

/// DTO for the login response (tokens + user).
class LoginResult {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  LoginResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}
