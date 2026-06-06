import 'package:dio/dio.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/paginated.dart';
import '../models/headmaster_row_data.dart';

class HeadmastersRemoteDataSource {
  final Dio _dio;

  HeadmastersRemoteDataSource(this._dio);

  Future<Paginated<HeadmasterRowData>> getHeadmasters({
    required int page,
    int perPage = 10,
    String? query,
    String? schoolId,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'per_page': perPage};
      if (query != null && query.isNotEmpty) {
        params['search'] = query;
      }
      if (schoolId != null && schoolId.isNotEmpty) {
        params['school_id'] = schoolId;
      }

      final response = await _dio.get(
        ApiEndpoints.headmasters,
        queryParameters: params,
      );

      final data = response.data;
      if (data is! Map) {
        return Paginated.empty<HeadmasterRowData>();
      }

      return Paginated<HeadmasterRowData>.fromResponseBody(
        data.cast<String, dynamic>(),
        HeadmasterRowData.fromJson,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<HeadmasterRowData> createHeadmaster(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiEndpoints.headmasters, data: data);
      final payload = response.data;
      final headmasterJson = payload is Map
          ? (payload['data'] ?? payload)
          : payload;
      return HeadmasterRowData.fromJson(
        Map<String, dynamic>.from(headmasterJson as Map),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<HeadmasterRowData> updateHeadmaster(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.headmasterById(id),
        data: data,
      );
      final payload = response.data;
      final headmasterJson = payload is Map
          ? (payload['data'] ?? payload)
          : payload;
      return HeadmasterRowData.fromJson(
        Map<String, dynamic>.from(headmasterJson as Map),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> deleteHeadmaster(String id) async {
    try {
      await _dio.delete(ApiEndpoints.headmasterById(id));
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
      return e.response?.data?['message'] ?? 'Headmaster not found.';
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
