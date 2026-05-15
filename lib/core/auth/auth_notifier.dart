import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import 'auth_state.dart';
import 'token_storage.dart';

// ── Provider ──────────────────────────────────────────────────────────────────
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(ref.read(tokenStorageProvider), ref.read(dioProvider));
});

// ── Convenience selectors ─────────────────────────────────────────────────────
/// True when there is a valid authenticated session.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider) is AuthStateAuthenticated;
});

/// The current user, or null if not authenticated.
final currentUserProvider = Provider<AuthUser?>((ref) {
  final state = ref.watch(authNotifierProvider);
  return state is AuthStateAuthenticated ? state.user : null;
});

// ── AuthNotifier ──────────────────────────────────────────────────────────────
/// Manages the global authentication session.
///
/// Lifecycle:
///   App start → loadFromStorage()
///   Success   → AuthStateAuthenticated
///   No token  → AuthStateUnauthenticated
///
/// Dev 2/3: read current user via ref.watch(currentUserProvider)
/// School tenant: user.schoolId — never pass schoolId via route params.
class AuthNotifier extends StateNotifier<AuthState> {
  final TokenStorage _storage;
  final Dio _dio;

  AuthNotifier(this._storage, this._dio) : super(const AuthStateLoading()) {
    loadFromStorage();
  }

  // ── Boot: check stored tokens ─────────────────────────────────────────────
  Future<void> loadFromStorage() async {
    // Real session: validate stored token via /auth/me
    try {
      final token = await _storage.getAccessToken();
      if (token == null) {
        state = const AuthStateUnauthenticated();
        return;
      }

      final resp = await _dio.get(ApiEndpoints.me);
      final userData = resp.data['data'] as Map<String, dynamic>?;
      if (userData == null) {
        state = const AuthStateUnauthenticated();
        return;
      }

      state = AuthStateAuthenticated(AuthUser.fromJson(userData));
    } catch (_) {
      // Token invalid or network error — treat as unauthenticated
      await _storage.clearAll();
      state = const AuthStateUnauthenticated();
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<void> login(String email, String password) async {
    state = const AuthStateAuthenticating();
    try {
      final resp = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final body = resp.data;
      final bodyMap = body is Map ? body.cast<String, dynamic>() : null;
      if (bodyMap == null) {
        state = const AuthStateError('Format respons login tidak valid.');
        return;
      }

      final success = bodyMap['success'] as bool? ?? false;
      if (!success) {
        await _setLoginFailure(
          _serverMessageFromBody(bodyMap) ?? 'Login gagal. Coba lagi.',
        );
        return;
      }

      final data = bodyMap['data'];
      if (data is! Map) {
        await _setLoginFailure('Data login tidak valid.');
        return;
      }

      final dataMap = data.cast<String, dynamic>();
      final accessToken = dataMap['access_token'] as String?;
      final refreshToken = dataMap['refresh_token'] as String?;
      if (accessToken == null || refreshToken == null) {
        await _setLoginFailure('Token login tidak ditemukan.');
        return;
      }

      await _storage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      final profileResp = await _dio.get(ApiEndpoints.me);
      final userData = profileResp.data['data'] as Map<String, dynamic>?;
      if (userData == null) {
        await _setLoginFailure('Profil pengguna tidak ditemukan.');
        return;
      }

      state = AuthStateAuthenticated(AuthUser.fromJson(userData));
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      await _setLoginFailure(_serverMessage(e) ?? _loginErrorMessage(status));
    } catch (_) {
      await _setLoginFailure('Terjadi kesalahan. Coba lagi.');
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    state = const AuthStateAuthenticating();
    try {
      await _dio.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );
      // After register, redirect to login (don't auto-login).
      state = const AuthStateUnauthenticated();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 409) {
        state = const AuthStateError(
          'Email sudah terdaftar. Gunakan email lain.',
        );
      } else {
        state = AuthStateError(
          _serverMessage(e) ?? 'Registrasi gagal. Coba lagi.',
        );
      }
    } catch (_) {
      state = const AuthStateError('Terjadi kesalahan. Coba lagi.');
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      // Only call revoke endpoint for real sessions
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        try {
          await _dio.post(
            ApiEndpoints.logout,
            data: {'refresh_token': refreshToken},
          );
        } catch (_) {
          // Ignore logout endpoint errors
        }
      }
    } catch (_) {
      // Ignore errors — always clear local state
    } finally {
      await _storage.clearAll();
      state = const AuthStateUnauthenticated();
    }
  }

  // ── Update local user (after profile edit) ────────────────────────────────
  void updateUser(AuthUser updated) {
    if (state is AuthStateAuthenticated) {
      state = AuthStateAuthenticated(updated);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _loginErrorMessage(int? status) => switch (status) {
    401 => 'Email atau password salah.',
    403 => 'Akun Anda tidak aktif. Hubungi administrator.',
    _ => 'Login gagal. Coba lagi.',
  };

  String? _serverMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map) {
        final body = data.cast<String, dynamic>();
        return _serverMessageFromBody(body);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _serverMessageFromBody(Map<String, dynamic> body) {
    // Prefer top-level `message` string
    final message = body['message'];
    if (message is String && message.isNotEmpty) {
      return _userFriendlyMessageFromServer(message);
    }

    // Fall back to first error in `errors` array if present
    final errors = body['errors'];
    if (errors is List && errors.isNotEmpty) {
      return _userFriendlyMessageFromServer(errors.first.toString());
    }

    return null;
  }

  String _userFriendlyMessageFromServer(String raw) {
    final lower = raw.toLowerCase();

    // Common validation pattern from backend: "Key: 'LoginRequest.Email' Error:Field validation for 'Email' failed on the 'email' tag"
    if (lower.contains("failed on the 'email'") ||
        lower.contains("validation for 'email'") ||
        RegExp(r"\bemail\b").hasMatch(lower)) {
      return 'Format email tidak valid. Silakan periksa kembali.';
    }

    if (lower.contains('password') && lower.contains('required')) {
      return 'Password tidak boleh kosong.';
    }

    if (lower.contains('validation') ||
        lower.contains('invalid') ||
        lower.contains('failed')) {
      return 'Data tidak valid. Periksa input Anda.';
    }

    // Default: return raw but keep it concise for users
    return raw;
  }

  Future<void> _setLoginFailure(String message) async {
    await _storage.clearAll();
    state = AuthStateError(message);
  }
}
