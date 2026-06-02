import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/providers/active_school_provider.dart';
import '../../data/models/dashboard_school_model.dart';
import '../../data/models/dashboard_stats_model.dart';
import '../../domain/entities/dashboard_school.dart';
import '../../domain/entities/dashboard_stats.dart';

final dashboardSchoolsProvider = FutureProvider<List<DashboardSchool>>((
  ref,
) async {
  final dio = ref.read(dioProvider);
  final resp = await dio.get(ApiEndpoints.schools);
  final raw = _readListData(resp.data);

  return raw
      .whereType<Map>()
      .map((entry) => DashboardSchoolModel.fromJson(_map(entry)))
      .toList();
});

/// Loads dashboard stats from GET /dashboard/stats.
/// Superadmin requests include `school_id`; scoped roles do not.
final dashboardStatsProvider =
    AsyncNotifierProvider<DashboardStatsNotifier, DashboardStats>(
      DashboardStatsNotifier.new,
    );

class DashboardStatsNotifier extends AsyncNotifier<DashboardStats> {
  @override
  Future<DashboardStats> build() {
    final user = ref.watch(currentUserProvider);
    final activeSchool = ref.watch(activeSchoolProvider);
    return _fetch(user: user, activeSchool: activeSchool);
  }

  Future<DashboardStats> _fetch({
    required AuthUser? user,
    required DashboardSchool? activeSchool,
  }) async {
    try {
      final dio = ref.read(dioProvider);
      final role = user?.role ?? UserRole.staff;

      // Superadmin: optionally scope by activeSchool. Null = aggregate
      // ("Semua Sekolah") — backend returns combined stats across all schools.
      // Scoped roles: backend uses JWT school_id; we don't send a query param.
      String? schoolId;
      if (role == UserRole.superadmin) {
        schoolId = activeSchool?.id;
      }

      final resp = await dio.get(
        ApiEndpoints.dashboardStats,
        queryParameters: schoolId == null ? null : {'school_id': schoolId},
      );
      final data = _readMapData(resp.data);
      return DashboardStatsModel.fromJson(data);
    } on DioException catch (e) {
      throw DashboardRequestException(_messageFor(e));
    } catch (_) {
      throw const DashboardRequestException('Gagal memuat dashboard.');
    }
  }

  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    final activeSchool = ref.read(activeSchoolProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(user: user, activeSchool: activeSchool),
    );
  }
}

class DashboardRequestException implements Exception {
  final String message;

  const DashboardRequestException(this.message);

  @override
  String toString() => message;
}

String _messageFor(DioException e) {
  final status = e.response?.statusCode;
  return switch (status) {
    400 => 'Pilih sekolah terlebih dahulu.',
    403 => 'Anda tidak memiliki akses ke dashboard sekolah ini.',
    404 => 'Data dashboard tidak ditemukan.',
    _ => _extractServerMessage(e) ?? 'Gagal memuat dashboard.',
  };
}

String? _extractServerMessage(DioException e) {
  try {
    final data = e.response?.data;
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
  } catch (_) {}
  return null;
}

Map<String, dynamic> _readMapData(dynamic data) {
  if (data is Map<String, dynamic>) {
    final inner = data['data'];
    if (inner is Map<String, dynamic>) return inner;
    if (inner is Map) return _map(inner);
    return data;
  }
  if (data is Map) return _map(data);
  return <String, dynamic>{};
}

List<dynamic> _readListData(dynamic data) {
  if (data is Map<String, dynamic>) {
    final inner = data['data'];
    if (inner is List) return inner;
    if (inner is Map && inner['items'] is List) return inner['items'] as List;
  }
  if (data is List) return data;
  return const [];
}

Map<String, dynamic> _map(Map value) =>
    value.map((key, dynamic value) => MapEntry(key.toString(), value));
