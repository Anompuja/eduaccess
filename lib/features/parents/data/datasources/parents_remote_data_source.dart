import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/paginated.dart';
import '../models/parent_model.dart';

class ParentsRemoteDataSource {
  final Dio _dio;

  ParentsRemoteDataSource(this._dio);

  /// Fetch paginated list of parents from backend.
  /// [schoolId] is honored by backend only for superadmin (filter by school).
  /// For other roles, backend uses JWT school and ignores this param.
  /// [perPage] controls page size; defaults to 20 to match backend default.
  Future<Paginated<ParentModel>> getParents({
    required int page,
    int perPage = 20,
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
        ApiEndpoints.parents,
        queryParameters: params,
      );

      final data = response.data;
      if (data is! Map) {
        return Paginated.empty();
      }

      return Paginated<ParentModel>.fromResponseBody(
        data.cast<String, dynamic>(),
        ParentModel.fromJson,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Create a new parent
  Future<ParentModel> createParent(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiEndpoints.parents, data: data);

      final responseData = response.data;
      final parentJson = responseData?['data'] ?? responseData;
      return ParentModel.fromJson(parentJson as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Update an existing parent
  Future<ParentModel> updateParent(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(ApiEndpoints.parentById(id), data: data);

      final responseData = response.data;
      final parentJson = responseData?['data'] ?? responseData;
      return ParentModel.fromJson(parentJson as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Delete a parent
  Future<void> deleteParent(String id) async {
    try {
      await _dio.delete(ApiEndpoints.parentById(id));
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Convert DioException to user-friendly error message
  String _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Request timeout. Please try again.';
    } else if (e.response?.statusCode == 400) {
      return e.response?.data?['message'] ??
          'Invalid data. Please check your input.';
    } else if (e.response?.statusCode == 404) {
      return 'Parent not found.';
    } else if (e.response?.statusCode == 500) {
      return 'Server error. Please try again later.';
    } else {
      return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
