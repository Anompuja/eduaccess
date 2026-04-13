import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../data/models/dashboard_stats_model.dart';
import '../../domain/entities/dashboard_stats.dart';

/// Loads dashboard stats from GET /dashboard/stats.
/// Falls back to mock data when the endpoint is not ready (404/any error).
final dashboardStatsProvider =
    AsyncNotifierProvider<DashboardStatsNotifier, DashboardStats>(
  DashboardStatsNotifier.new,
);

class DashboardStatsNotifier extends AsyncNotifier<DashboardStats> {
  @override
  Future<DashboardStats> build() => _fetch();

  Future<DashboardStats> _fetch() async {
    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get(ApiEndpoints.dashboardStats);
      final data = resp.data['data'] as Map<String, dynamic>;
      return DashboardStatsModel.fromJson(data);
    } on DioException {
      // API not ready yet → return mock data so dashboard renders
      return DashboardStatsModel.mock();
    } catch (_) {
      return DashboardStatsModel.mock();
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}
