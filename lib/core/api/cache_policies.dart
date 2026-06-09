import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

/// Centralized cache policies so each feature can opt in intentionally.
///
/// Phase 1 only enables server-driven HTTP caching for the staff list flow.
/// The interceptor itself stays mounted globally, but its default behaviour is
/// `noCache` so new endpoints do not start caching accidentally.
abstract final class EduAccessCachePolicies {
  static CacheOptions interceptor(CacheStore store) {
    return CacheOptions(
      store: store,
      policy: CachePolicy.noCache,
      priority: CachePriority.normal,
      allowPostMethod: false,
    );
  }

  static CacheOptions staffList({CacheStore? store}) {
    return CacheOptions(
      store: store,
      policy: CachePolicy.request,
      priority: CachePriority.normal,
      allowPostMethod: false,
    );
  }

  static CacheOptions teacherList({CacheStore? store}) {
    return CacheOptions(
      store: store,
      policy: CachePolicy.request,
      priority: CachePriority.normal,
      allowPostMethod: false,
    );
  }

  static CacheOptions adminList({CacheStore? store}) {
    return CacheOptions(
      store: store,
      policy: CachePolicy.request,
      priority: CachePriority.normal,
      allowPostMethod: false,
    );
  }

  static CacheOptions studentList({CacheStore? store}) {
    return CacheOptions(
      store: store,
      policy: CachePolicy.request,
      priority: CachePriority.normal,
      allowPostMethod: false,
    );
  }

  static CacheOptions headmasterList({CacheStore? store}) {
    return CacheOptions(
      store: store,
      policy: CachePolicy.request,
      priority: CachePriority.normal,
      allowPostMethod: false,
    );
  }

  static CacheOptions dashboardStats({CacheStore? store}) {
    return CacheOptions(
      store: store,
      policy: CachePolicy.request,
      priority: CachePriority.normal,
      allowPostMethod: false,
    );
  }

  /// Academic module GET list/detail requests.
  /// Honors the backend's Cache-Control / ETag headers so repeat navigations
  /// return cached data instantly while the server can still push invalidation
  /// via 200 + new ETag when data changes.
  static CacheOptions academicList({CacheStore? store}) {
    return CacheOptions(
      store: store,
      policy: CachePolicy.request,
      priority: CachePriority.normal,
      allowPostMethod: false,
    );
  }

  static CacheOptions bypass({CacheStore? store}) {
    return CacheOptions(
      store: store,
      policy: CachePolicy.noCache,
      priority: CachePriority.normal,
      allowPostMethod: false,
    );
  }
}
