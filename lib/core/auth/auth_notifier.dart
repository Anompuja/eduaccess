import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import 'auth_state.dart';
import 'token_storage.dart';

// ── Provider ──────────────────────────────────────────────────────────────────
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(
    ref.read(tokenStorageProvider),
    ref.read(dioProvider),
    ref.read(cacheStoreProvider),
  );
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
  final CacheStore _cacheStore;

  AuthNotifier(this._storage, this._dio, this._cacheStore)
    : super(const AuthStateLoading()) {
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
    // Drop any cached responses from a previous session before authenticating.
    await _cacheStore.clean();
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
      // Purge cached tenant/user data so it can't be served to the next login.
      await _cacheStore.clean();
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
    // Prefer field-specific backend errors first so the UI can render the
    // exact server source of truth.
    final errors = body['errors'];
    if (errors is List && errors.isNotEmpty) {
      final messages = errors
          .where((error) => error != null)
          .map((error) => error.toString())
          .where((text) => text.trim().isNotEmpty)
          .toList();
      if (messages.isNotEmpty) {
        return messages.join('\n');
      }
    }

    if (errors is Map) {
      final errorMap = errors.cast<String, dynamic>();
      final messages = <String>[];
      for (final entry in errorMap.entries) {
        final value = entry.value;
        if (value is List && value.isNotEmpty) {
          messages.addAll(
            value
                .where((item) => item != null)
                .map((item) => item.toString())
                .where((text) => text.trim().isNotEmpty)
                .map((text) => '${entry.key}: $text'),
          );
        } else if (value != null) {
          final text = value.toString().trim();
          if (text.isNotEmpty) {
            messages.add('${entry.key}: $text');
          }
        }
      }
      if (messages.isNotEmpty) {
        return messages.join('\n');
      }
    }

    final message = body['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }

    return null;
  }

  Future<void> _setLoginFailure(String message) async {
    await _storage.clearAll();
    state = AuthStateError(message);
  }
}
