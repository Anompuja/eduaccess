import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/paginated.dart';
import '../models/teacher_row_data.dart';

class TeachersRemoteDataSource {
  final Dio _dio;
  final CacheOptions _teacherListCacheOptions;
  final CacheOptions _bypassCacheOptions;

  TeachersRemoteDataSource(
    this._dio, {
    required CacheOptions teacherListCacheOptions,
    required CacheOptions bypassCacheOptions,
  }) : _teacherListCacheOptions = teacherListCacheOptions,
       _bypassCacheOptions = bypassCacheOptions;

  Future<Paginated<TeacherRowData>> getTeachers({
    required int page,
    int perPage = 5,
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
        ApiEndpoints.teachers,
        queryParameters: params,
        options: _teacherListCacheOptions.toOptions(),
      );

      final data = response.data;
      if (data is! Map) {
        return Paginated.empty<TeacherRowData>();
      }

      return Paginated<TeacherRowData>.fromResponseBody(
        data.cast<String, dynamic>(),
        TeacherRowData.fromJson,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<TeacherRowData> createTeacher(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.teachers,
        data: data,
        options: _bypassCacheOptions.toOptions(),
      );
      final payload = response.data;
      final teacherJson = payload is Map
          ? (payload['data'] ?? payload)
          : payload;
      return TeacherRowData.fromJson(
        Map<String, dynamic>.from(teacherJson as Map),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<TeacherRowData> updateTeacher(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.teacherById(id),
        data: data,
        options: _bypassCacheOptions.toOptions(),
      );
      final payload = response.data;
      final teacherJson = payload is Map
          ? (payload['data'] ?? payload)
          : payload;
      return TeacherRowData.fromJson(
        Map<String, dynamic>.from(teacherJson as Map),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> deleteTeacher(String id) async {
    try {
      await _dio.delete(
        ApiEndpoints.teacherById(id),
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
      return e.response?.data?['message'] ?? 'Teacher not found.';
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
