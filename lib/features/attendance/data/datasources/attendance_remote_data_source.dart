import 'package:dio/dio.dart';
import 'package:eduaccess/core/api/api_endpoints.dart';

class AttendanceRemoteDataSource {
  final Dio _dio;
  AttendanceRemoteDataSource(this._dio);

  Future<String> getQRToken(String scheduleId) async {
    try {
      final response = await _dio.get(ApiEndpoints.classScheduleQRToken(scheduleId));
      final data = response.data;
      if (data is Map) {
        return (data['data']?['token'] ?? data['token']) as String;
      }
      throw Exception('Unexpected QR token response');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> scanQR(String token) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.attendanceScan,
        data: {'token': token},
      );
      final data = response.data;
      if (data is Map) {
        return Map<String, dynamic>.from(data['data'] ?? data);
      }
      return {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    final msg = e.response?.data?['message'];
    if (msg is String && msg.isNotEmpty) return Exception(msg);
    return switch (e.response?.statusCode) {
      401 => Exception('QR code telah kedaluwarsa — minta guru refresh QR'),
      403 => Exception(e.response?.data?['message'] ?? 'Akses ditolak'),
      409 => Exception(e.response?.data?['message'] ?? 'Kehadiran sudah dicatat'),
      _ => Exception(e.message ?? 'Terjadi kesalahan, coba lagi'),
    };
  }
}
