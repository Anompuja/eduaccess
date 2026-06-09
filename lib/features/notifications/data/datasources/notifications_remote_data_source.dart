import 'package:dio/dio.dart';

import '../../../../core/api/api_endpoints.dart';
import '../models/notification_model.dart';

class NotificationsRemoteDataSource {
  final Dio _dio;

  NotificationsRemoteDataSource(this._dio);

  Future<List<NotificationModel>> getNotifications({bool unreadOnly = false}) async {
    try {
      final params = <String, dynamic>{};
      if (unreadOnly) params['unread'] = 'true';

      final response = await _dio.get(
        ApiEndpoints.notifications,
        queryParameters: params,
      );

      final payload = response.data;
      final list = payload is Map ? (payload['data'] as List?) : null;
      if (list == null) return [];

      return list
          .whereType<Map<String, dynamic>>()
          .map(NotificationModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _dio.patch(ApiEndpoints.notificationMarkRead(id));
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> markAllRead() async {
    try {
      await _dio.patch(ApiEndpoints.notificationsMarkAllRead);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  String _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet.';
    } else if (e.response?.statusCode == 401) {
      return 'Unauthorized.';
    } else if (e.response?.statusCode == 500) {
      return 'Server error. Please try again later.';
    }
    return e.message ?? 'An error occurred. Please try again.';
  }
}
