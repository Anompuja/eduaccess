import 'package:dio/dio.dart';
import 'package:eduaccess/core/api/api_endpoints.dart';
import '../../domain/repositories/class_promotion_repository.dart';

abstract class ClassPromotionRemoteDataSource {
  Future<PromotionResult> promote({
    required List<String> studentIds,
    required String toClassroomId,
    required String status,
    String? notes,
    String? schoolId,
  });
}

class ClassPromotionRemoteDataSourceImpl implements ClassPromotionRemoteDataSource {
  final Dio dio;

  ClassPromotionRemoteDataSourceImpl({required this.dio});

  @override
  Future<PromotionResult> promote({
    required List<String> studentIds,
    required String toClassroomId,
    required String status,
    String? notes,
    String? schoolId,
  }) async {
    try {
      final params = schoolId != null ? {'school_id': schoolId} : <String, dynamic>{};
      final body = <String, dynamic>{
        'student_ids': studentIds,
        'to_classroom_id': toClassroomId,
        'status': status,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };
      final response = await dio.post(
        ApiEndpoints.studentPromotionPromote,
        data: body,
        queryParameters: params.isNotEmpty ? params : null,
      );
      final data = response.data['data'] as Map<String, dynamic>? ?? const {};
      return PromotionResult(
        success: (data['success'] as num?)?.toInt() ?? 0,
        failed: (data['failed'] as num?)?.toInt() ?? 0,
      );
    } on DioException catch (e) {
      final msg = e.response?.data is Map ? e.response?.data['message'] : null;
      if (e.response?.statusCode == 403) throw Exception('Akses ditolak.');
      throw Exception((msg as String?) ?? e.message ?? 'Promosi gagal. Coba lagi.');
    }
  }
}
