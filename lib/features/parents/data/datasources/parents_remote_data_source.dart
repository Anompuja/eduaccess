import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/parent_model.dart';

class ParentsRemoteDataSource {
  final Dio _dio;

  ParentsRemoteDataSource(this._dio);

  /// Fetch paginated list of parents from backend.
  /// Backend scopes by JWT role; frontend does not send school_id.
  Future<List<ParentModel>> getParents({
    required int page,
    String? query,
  }) async {
    try {
      final params = <String, dynamic>{'page': page};
      if (query != null && query.isNotEmpty) {
        params['search'] = query;
      }

      final response = await _dio.get(
        ApiEndpoints.parents,
        queryParameters: params,
      );

      final data = response.data;
      if (data == null) {
        return [];
      }

      // Handle response structure: data.data or data['data'] contains list
      final parentsList = data['data'] as List? ?? data as List?;
      if (parentsList == null) {
        return [];
      }

      return parentsList
          .map((p) => ParentModel.fromJson(p as Map<String, dynamic>))
          .toList();
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
