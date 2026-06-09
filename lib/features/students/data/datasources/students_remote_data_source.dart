import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/paginated.dart';
import '../models/linked_parent_data.dart';
import '../models/student_row_data.dart';

class StudentsRemoteDataSource {
  final Dio _dio;
  final CacheOptions _studentListCacheOptions;
  final CacheOptions _bypassCacheOptions;

  StudentsRemoteDataSource(
    this._dio, {
    required CacheOptions studentListCacheOptions,
    required CacheOptions bypassCacheOptions,
  }) : _studentListCacheOptions = studentListCacheOptions,
       _bypassCacheOptions = bypassCacheOptions;

  Future<Paginated<StudentRowData>> getStudents({
    required int page,
    int perPage = 10,
    String? query,
    String? schoolId,
    String? educationLevelId,
    String? classId,
    String? subClassId,
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
      if (educationLevelId != null && educationLevelId.isNotEmpty) {
        params['education_level_id'] = educationLevelId;
      }
      if (classId != null && classId.isNotEmpty) {
        params['class_id'] = classId;
      }
      if (subClassId != null && subClassId.isNotEmpty) {
        params['sub_class_id'] = subClassId;
      }
      if (refreshTrigger != null) {
        params['_t'] = refreshTrigger;
      }

      final response = await _dio.get(
        ApiEndpoints.students,
        queryParameters: params,
        options: _studentListCacheOptions.toOptions(),
      );

      final data = response.data;
      if (data is! Map) {
        return Paginated.empty<StudentRowData>();
      }

      return Paginated<StudentRowData>.fromResponseBody(
        data.cast<String, dynamic>(),
        StudentRowData.fromJson,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<StudentRowData> createStudent(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.students,
        data: data,
        options: _bypassCacheOptions.toOptions(),
      );
      final payload = response.data;
      final studentJson = payload is Map
          ? (payload['data'] ?? payload)
          : payload;
      return StudentRowData.fromJson(
        Map<String, dynamic>.from(studentJson as Map),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<StudentRowData> updateStudent(
    String id,

    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.studentById(id),
        data: data,
        options: _bypassCacheOptions.toOptions(),
      );
      final payload = response.data;
      final studentJson = payload is Map
          ? (payload['data'] ?? payload)
          : payload;
      return StudentRowData.fromJson(
        Map<String, dynamic>.from(studentJson as Map),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<int> getStudentCount({required String schoolId}) async {
    try {
      final params = <String, dynamic>{'page': 1, 'per_page': 1};
      if (schoolId.isNotEmpty) {
        params['school_id'] = schoolId;
      }

      final response = await _dio.get(
        ApiEndpoints.students,
        queryParameters: params,
      );

      final data = response.data;
      if (data is! Map) return 0;

      final paginated = Paginated<StudentRowData>.fromResponseBody(
        data.cast<String, dynamic>(),
        StudentRowData.fromJson,
      );
      return paginated.total;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      await _dio.delete(
        ApiEndpoints.studentById(id),
        options: _bypassCacheOptions.toOptions(),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<List<LinkedParentData>> getStudentParents(String studentId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.studentById(studentId),
        options: _bypassCacheOptions.toOptions(),
      );
      final payload = response.data;
      final studentJson = payload is Map
          ? (payload['data'] ?? payload) as Map<String, dynamic>
          : <String, dynamic>{};
      final parentsList = studentJson['parents'] as List? ?? [];
      return parentsList
          .whereType<Map<String, dynamic>>()
          .map(LinkedParentData.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> linkParent(
    String studentId,
    String parentId,
    String relationship,
    bool isPrimary,
  ) async {
    try {
      await _dio.post(
        ApiEndpoints.studentParents(studentId),
        data: {
          'parent_id': parentId,
          'relationship': relationship,
          'is_primary': isPrimary,
        },
        options: _bypassCacheOptions.toOptions(),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> unlinkParent(String studentId, String parentId) async {
    try {
      await _dio.delete(
        ApiEndpoints.studentParentById(studentId, parentId),
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
      return e.response?.data?['message'] ?? 'Student not found.';
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
