import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/paginated.dart';
import '../models/staff_row_data.dart';

class StaffRemoteDataSource {
  final Dio _dio;
  final CacheOptions _staffListCacheOptions;
  final CacheOptions _bypassCacheOptions;

  StaffRemoteDataSource(
    this._dio, {
    required CacheOptions staffListCacheOptions,
    required CacheOptions bypassCacheOptions,
  }) : _staffListCacheOptions = staffListCacheOptions,
       _bypassCacheOptions = bypassCacheOptions;

  Future<Paginated<StaffRowData>> getStaffs({
    required int page,
    int perPage = 10,
    String? query,
    String? schoolId,
    int? refreshTrigger,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'per_page': perPage};
      if (query != null && query.isNotEmpty) {
        params['search'] = query;
      }
      if (schoolId != null && schoolId.isNotEmpty) {
        params['school_id'] = schoolId;
      }
      if (refreshTrigger != null) {
        params['_t'] = refreshTrigger;
      }

      final response = await _dio.get(
        ApiEndpoints.staff,
        queryParameters: params,
        options: _staffListCacheOptions.toOptions(),
      );
      final data = response.data;
      if (data is! Map) {
        return Paginated.empty<StaffRowData>();
      }

      return Paginated<StaffRowData>.fromResponseBody(
        data.cast<String, dynamic>(),
        StaffRowData.fromJson,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<StaffRowData> createStaff(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.staff,
        data: data,
        options: _bypassCacheOptions.toOptions(),
      );
      final payload = response.data;
      final staffJson = payload is Map ? (payload['data'] ?? payload) : payload;
      return StaffRowData.fromJson(Map<String, dynamic>.from(staffJson as Map));
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<StaffRowData> updateStaff(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.staffById(id),
        data: data,
        options: _bypassCacheOptions.toOptions(),
      );
      final payload = response.data;
      final staffJson = payload is Map ? (payload['data'] ?? payload) : payload;
      return StaffRowData.fromJson(Map<String, dynamic>.from(staffJson as Map));
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> deleteStaff(String id) async {
    try {
      await _dio.delete(
        ApiEndpoints.staffById(id),
        options: _bypassCacheOptions.toOptions(),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  String _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet.';
    }
    if (e.type == DioExceptionType.receiveTimeout) {
      return 'Request timeout. Please try again.';
    }
    if (e.response?.statusCode == 400) {
      return e.response?.data?['message'] ??
          'Invalid data. Please check your input.';
    }
    if (e.response?.statusCode == 401) {
      return e.response?.data?['message'] ?? 'Unauthorized.';
    }
    if (e.response?.statusCode == 403) {
      return e.response?.data?['message'] ??
          'You do not have permission to access this resource.';
    }
    if (e.response?.statusCode == 404) {
      return e.response?.data?['message'] ?? 'Staff not found.';
    }
    if (e.response?.statusCode == 409) {
      return e.response?.data?['message'] ?? 'Data conflict.';
    }
    if (e.response?.statusCode == 500) {
      return e.response?.data?['message'] ??
          'Server error. Please try again later.';
    }
    return e.message ?? 'An error occurred. Please try again.';
  }
}
