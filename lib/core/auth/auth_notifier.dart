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
    // 1. Check for demo/offline session no network needed
    final demo = await _storage.loadDemoSession();
    if (demo != null) {
      state = AuthStateAuthenticated(_buildDemoUser(demo.role, demo.name));
      return;
    }

    // 2. Real session: validate stored token via /auth/me
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

  // ── Demo login (no backend required) ─────────────────────────────────────
  /// Signs in instantly as [role] with a mock user — for offline / demo use.
  Future<void> demoLogin(UserRole role) async {
    final name = _demoDisplayName(role);
    final backendRole = _roleToBackendString(role);
    await _storage.saveDemoSession(backendRole, name);
    state = AuthStateAuthenticated(_buildDemoUser(backendRole, name));
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<void> login(String email, String password) async {
    state = const AuthStateAuthenticating();
    try {
      final resp = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final data = resp.data['data'] as Map<String, dynamic>;
      final accessToken = data['access_token'] as String;
      final refreshToken = data['refresh_token'] as String;

      await _storage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      final profileResp = await _dio.get(ApiEndpoints.me);
      final userData = profileResp.data['data'] as Map<String, dynamic>?;
      if (userData == null) {
        state = const AuthStateError('Profil pengguna tidak ditemukan.');
        return;
      }

      state = AuthStateAuthenticated(AuthUser.fromJson(userData));
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      state = AuthStateError(_loginErrorMessage(status));
    } catch (_) {
      state = const AuthStateError('Terjadi kesalahan. Coba lagi.');
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
      final demo = await _storage.loadDemoSession();
      if (demo == null) {
        // Only call revoke endpoint for real sessions
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken != null) {
          await _dio.post(
            ApiEndpoints.logout,
            data: {'refresh_token': refreshToken},
          );
        }
      }
    } catch (_) {
      // Ignore errors — always clear local state
    } finally {
      await Future.wait([_storage.clearAll(), _storage.clearDemoSession()]);
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
  AuthUser _buildDemoUser(String backendRole, String name) {
    final role = UserRole.fromString(backendRole);
    return AuthUser(
      id: 'demo-$backendRole',
      name: name,
      email: '$backendRole@demo.eduaccess.id',
      role: role,
      schoolId: role == UserRole.superadmin ? null : 'demo-school-001',
    );
  }

  String _demoDisplayName(UserRole role) => switch (role) {
    UserRole.superadmin => 'Super Admin',
    UserRole.adminSekolah => 'Admin Sekolah',
    UserRole.kepalaSekolah => 'Kepala Sekolah',
    UserRole.guru => 'Budi Santoso',
    UserRole.siswa => 'Andi Pratama',
    UserRole.orangtua => 'Siti Rahayu',
    UserRole.staff => 'Staff Sekolah',
  };

  String _roleToBackendString(UserRole role) => switch (role) {
    UserRole.superadmin => 'superadmin',
    UserRole.adminSekolah => 'admin_sekolah',
    UserRole.kepalaSekolah => 'kepala_sekolah',
    UserRole.guru => 'guru',
    UserRole.siswa => 'siswa',
    UserRole.orangtua => 'orangtua',
    UserRole.staff => 'staff',
  };

  String _loginErrorMessage(int? status) => switch (status) {
    401 => 'Email atau password salah.',
    403 => 'Akun Anda tidak aktif. Hubungi administrator.',
    _ => 'Login gagal. Coba lagi.',
  };

  String? _serverMessage(DioException e) {
    try {
      return e.response?.data['message'] as String?;
    } catch (_) {
      return null;
    }
  }
}
