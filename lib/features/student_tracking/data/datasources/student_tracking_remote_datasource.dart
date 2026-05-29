import 'package:dio/dio.dart';
import 'package:eduaccess/core/api/api_endpoints.dart';
import '../models/student_study_model.dart';

abstract class StudentTrackingRemoteDataSource {
  Future<List<StudentStudyModel>> getStudies({String? schoolId, String? classroomId, String? academicYearId, String? status});
  Future<List<StudentStudyModel>> getStudentHistory(String studentId, {String? schoolId});
}

class StudentTrackingRemoteDataSourceImpl implements StudentTrackingRemoteDataSource {
  final Dio dio;

  StudentTrackingRemoteDataSourceImpl({required this.dio});

  List<StudentStudyModel> _parseList(dynamic data) {
    final list = data as List<dynamic>? ?? [];
    return list.map((e) => StudentStudyModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  String _handleError(DioException e) {
    final msg = e.response?.data is Map ? e.response?.data['message'] : null;
    if (e.response?.statusCode == 403) return 'Akses ditolak.';
    if (e.response?.statusCode == 404) return 'Data tidak ditemukan.';
    return (msg as String?) ?? e.message ?? 'Terjadi kesalahan. Coba lagi.';
  }

  @override
  Future<List<StudentStudyModel>> getStudies({String? schoolId, String? classroomId, String? academicYearId, String? status}) async {
    try {
      final params = <String, dynamic>{};
      if (schoolId != null) params['school_id'] = schoolId;
      if (classroomId != null) params['classroom_id'] = classroomId;
      if (academicYearId != null) params['academic_year_id'] = academicYearId;
      if (status != null) params['status'] = status;
      final response = await dio.get(ApiEndpoints.studentStudies, queryParameters: params.isNotEmpty ? params : null);
      return _parseList(response.data['data']);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<List<StudentStudyModel>> getStudentHistory(String studentId, {String? schoolId}) async {
    try {
      final params = schoolId != null ? {'school_id': schoolId} : <String, dynamic>{};
      final response = await dio.get(ApiEndpoints.studentStudyDetail(studentId), queryParameters: params.isNotEmpty ? params : null);
      return _parseList(response.data['data']);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
