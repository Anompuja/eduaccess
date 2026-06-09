import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/token_storage.dart';
import 'cache_policies.dart';

// ── Environment config ────────────────────────────────────────────────────────
// Set EDUACCESS_BASE_URL via --dart-define at build time.
// Default falls back based on runtime platform for local development.
const _kBaseUrl = String.fromEnvironment(
  'EDUACCESS_BASE_URL',
  defaultValue: '',
);

String _resolveBaseUrl() {
  if (_kBaseUrl.isNotEmpty) return _kBaseUrl;
  return 'http://localhost:8080/api/v1';
}

// ── Providers ─────────────────────────────────────────────────────────────────
/// In-memory HTTP cache store. Honors the backend's Cache-Control/ETag so native
/// platforms (Android/iOS) get the same revalidation the browser does for free.
/// Kept as a singleton provider so the auth layer can clear it on login/logout,
/// preventing one user's cached data from leaking to the next on a shared device.
final cacheStoreProvider = Provider<CacheStore>((ref) => MemCacheStore());

final httpCacheOptionsProvider = Provider<CacheOptions>((ref) {
  final cacheStore = ref.read(cacheStoreProvider);
  return EduAccessCachePolicies.interceptor(cacheStore);
});

final staffListCacheOptionsProvider = Provider<CacheOptions>((ref) {
  final cacheStore = ref.read(cacheStoreProvider);
  return EduAccessCachePolicies.staffList(store: cacheStore);
});

final teacherListCacheOptionsProvider = Provider<CacheOptions>((ref) {
  final cacheStore = ref.read(cacheStoreProvider);
  return EduAccessCachePolicies.teacherList(store: cacheStore);
});

final adminListCacheOptionsProvider = Provider<CacheOptions>((ref) {
  final cacheStore = ref.read(cacheStoreProvider);
  return EduAccessCachePolicies.adminList(store: cacheStore);
});

final studentListCacheOptionsProvider = Provider<CacheOptions>((ref) {
  final cacheStore = ref.read(cacheStoreProvider);
  return EduAccessCachePolicies.studentList(store: cacheStore);
});

final headmasterListCacheOptionsProvider = Provider<CacheOptions>((ref) {
  final cacheStore = ref.read(cacheStoreProvider);
  return EduAccessCachePolicies.headmasterList(store: cacheStore);
});

final dashboardStatsCacheOptionsProvider = Provider<CacheOptions>((ref) {
  final cacheStore = ref.read(cacheStoreProvider);
  return EduAccessCachePolicies.dashboardStats(store: cacheStore);
});

final academicListCacheOptionsProvider = Provider<CacheOptions>((ref) {
  final cacheStore = ref.read(cacheStoreProvider);
  return EduAccessCachePolicies.academicList(store: cacheStore);
});

final nonCacheableRequestOptionsProvider = Provider<CacheOptions>((ref) {
  return EduAccessCachePolicies.bypass();
});

final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.read(tokenStorageProvider);
  final cacheOptions = ref.read(httpCacheOptionsProvider);
  return _buildDio(tokenStorage, cacheOptions);
});

// ── Factory ───────────────────────────────────────────────────────────────────
Dio _buildDio(TokenStorage tokenStorage, CacheOptions cacheOptions) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _resolveBaseUrl(),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // The interceptor is kept global for consistent request handling, but the
  // default policy is no-cache. Features must opt in explicitly per request,
  // which lets staff list caching roll out without changing the behaviour of
  // every other endpoint.

  dio.interceptors.addAll([
    // Auth runs first so the Authorization header is attached before the cache
    // interceptor issues its (possibly conditional) request.
    _AuthInterceptor(dio, tokenStorage),
    DioCacheInterceptor(options: cacheOptions),
    _LogInterceptor(),
  ]);

  return dio;
}

// ── Auth Interceptor ─────────────────────────────────────────────────────────
/// Attaches the Bearer token to every request.
/// On 401: attempts a silent token refresh, then retries the original request.
/// On refresh failure: clears tokens and signals the app to redirect to /login.
class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _storage;
  bool _isRefreshing = false;

  _AuthInterceptor(this._dio, this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for auth endpoints (login, register, refresh)
    final isAuthPath =
        options.path.startsWith('/auth/login') ||
        options.path.startsWith('/auth/register') ||
        options.path.startsWith('/auth/refresh');

    if (!isAuthPath) {
      final token = await _storage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken == null) {
          await _handleLogout();
          handler.next(err);
          return;
        }

        // Attempt silent refresh using a clean Dio (no interceptors to avoid loops)
        final refreshDio = Dio(BaseOptions(baseUrl: _resolveBaseUrl()));
        final refreshResp = await refreshDio.post(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
        );

        final newAccessToken =
            refreshResp.data['data']?['access_token'] as String?;
        final newRefreshToken =
            refreshResp.data['data']?['refresh_token'] as String?;
        if (newAccessToken == null) {
          await _handleLogout();
          handler.next(err);
          return;
        }

        // Persist new access token
        await _storage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken ?? refreshToken,
        );

        // Retry original request with new token
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResp = await _dio.fetch(opts);
        handler.resolve(retryResp);
        return;
      } catch (_) {
        await _handleLogout();
        handler.next(err);
      } finally {
        _isRefreshing = false;
      }
      return;
    }

    handler.next(err);
  }

  Future<void> _handleLogout() async {
    await _storage.clearAll();
    // Auth state will react to cleared storage on next build cycle.
    // The GoRouter redirect guard will push /login.
  }
}

// ── Log Interceptor (dev only) ────────────────────────────────────────────────
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    assert(() {
      // ignore: avoid_print
      print('[API] → ${options.method} ${options.uri}');
      return true;
    }());
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    assert(() {
      // ignore: avoid_print
      print('[API] ← ${response.statusCode} ${response.requestOptions.uri}');
      return true;
    }());
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    assert(() {
      // ignore: avoid_print
      print(
        '[API] ✗ ${err.response?.statusCode} ${err.requestOptions.uri} — ${err.message}',
      );
      return true;
    }());
    handler.next(err);
  }
}
