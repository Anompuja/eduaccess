import 'package:dio/dio.dart';
import 'package:eduaccess/core/api/api_endpoints.dart';
import '../models/attendance_model.dart';
import '../models/class_schedule_model.dart';

abstract class ClassScheduleRemoteDataSource {
  Future<List<ClassScheduleModel>> getClassSchedules({String? schoolId, String? classroomId, String? teacherId, String? subjectId, String? date, String? status});
  Future<ClassScheduleModel> getClassSchedule(String id);
  Future<ClassScheduleModel> createClassSchedule({required String classroomId, required String subjectId, required String teacherId, required String date, required String startTime, required String endTime, String? startPeriodId, String? endPeriodId, String? schoolId});
  Future<ClassScheduleModel> updateClassSchedule(String id, {required String classroomId, required String subjectId, required String teacherId, required String date, required String startTime, required String endTime, String? startPeriodId, String? endPeriodId});
  Future<void> deleteClassSchedule(String id);
  Future<void> startClassSchedule(String id);
  Future<void> completeClassSchedule(String id);
  Future<void> cancelClassSchedule(String id);
  Future<List<AttendanceModel>> getAttendances(String scheduleId);
  Future<AttendanceModel> updateAttendance(String scheduleId, String studentId, {required String status, String? note, String? photoPath});
}

class ClassScheduleRemoteDataSourceImpl implements ClassScheduleRemoteDataSource {
  final Dio dio;

  ClassScheduleRemoteDataSourceImpl({required this.dio});

  List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    final list = data as List<dynamic>? ?? [];
    return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  String _handleError(DioException e, String entity) {
    final msg = e.response?.data?['message'];
    if (e.response?.statusCode == 400) return msg ?? 'Data tidak valid.';
    if (e.response?.statusCode == 403) return 'Akses ditolak.';
    if (e.response?.statusCode == 404) return '$entity tidak ditemukan.';
    if (e.response?.statusCode == 409) return msg ?? 'Data sudah ada.';
    return e.message ?? 'Terjadi kesalahan. Coba lagi.';
  }

  @override
  Future<List<ClassScheduleModel>> getClassSchedules({String? schoolId, String? classroomId, String? teacherId, String? subjectId, String? date, String? status}) async {
    try {
      final params = <String, dynamic>{};
      if (schoolId != null) params['school_id'] = schoolId;
      if (classroomId != null) params['classroom_id'] = classroomId;
      if (teacherId != null) params['teacher_id'] = teacherId;
      if (subjectId != null) params['subject_id'] = subjectId;
      if (date != null) params['date'] = date;
      if (status != null) params['status'] = status;
      final response = await dio.get(ApiEndpoints.classSchedules, queryParameters: params.isNotEmpty ? params : null);
      return _parseList(response.data['data'], ClassScheduleModel.fromJson);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Jadwal kelas'));
    }
  }

  @override
  Future<ClassScheduleModel> getClassSchedule(String id) async {
    try {
      final response = await dio.get(ApiEndpoints.classScheduleById(id));
      return ClassScheduleModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Jadwal kelas'));
    }
  }

  @override
  Future<ClassScheduleModel> createClassSchedule({required String classroomId, required String subjectId, required String teacherId, required String date, required String startTime, required String endTime, String? startPeriodId, String? endPeriodId, String? schoolId}) async {
    try {
      final params = schoolId != null ? {'school_id': schoolId} : <String, dynamic>{};
      final body = <String, dynamic>{
        'classroom_id': classroomId,
        'subject_id': subjectId,
        'teacher_id': teacherId,
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
        if (startPeriodId != null) 'start_period_id': startPeriodId,
        if (endPeriodId != null) 'end_period_id': endPeriodId,
      };
      final response = await dio.post(ApiEndpoints.classSchedules, data: body, queryParameters: params.isNotEmpty ? params : null);
      return ClassScheduleModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Jadwal kelas'));
    }
  }

  @override
  Future<ClassScheduleModel> updateClassSchedule(String id, {required String classroomId, required String subjectId, required String teacherId, required String date, required String startTime, required String endTime, String? startPeriodId, String? endPeriodId}) async {
    try {
      final body = <String, dynamic>{
        'classroom_id': classroomId,
        'subject_id': subjectId,
        'teacher_id': teacherId,
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
        if (startPeriodId != null) 'start_period_id': startPeriodId,
        if (endPeriodId != null) 'end_period_id': endPeriodId,
      };
      final response = await dio.put(ApiEndpoints.classScheduleById(id), data: body);
      return ClassScheduleModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Jadwal kelas'));
    }
  }

  @override
  Future<void> deleteClassSchedule(String id) async {
    try {
      await dio.delete(ApiEndpoints.classScheduleById(id));
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Jadwal kelas'));
    }
  }

  @override
  Future<void> startClassSchedule(String id) async {
    try {
      await dio.post(ApiEndpoints.classScheduleStart(id));
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Jadwal kelas'));
    }
  }

  @override
  Future<void> completeClassSchedule(String id) async {
    try {
      await dio.post(ApiEndpoints.classScheduleComplete(id));
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Jadwal kelas'));
    }
  }

  @override
  Future<void> cancelClassSchedule(String id) async {
    try {
      await dio.post(ApiEndpoints.classScheduleCancel(id));
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Jadwal kelas'));
    }
  }

  @override
  Future<List<AttendanceModel>> getAttendances(String scheduleId) async {
    try {
      final response = await dio.get(ApiEndpoints.classScheduleAttendances(scheduleId));
      return _parseList(response.data['data'], AttendanceModel.fromJson);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Absensi'));
    }
  }

  @override
  Future<AttendanceModel> updateAttendance(String scheduleId, String studentId, {required String status, String? note, String? photoPath}) async {
    try {
      final response = await dio.put(
        ApiEndpoints.classScheduleAttendance(scheduleId, studentId),
        data: {
          'status': status,
          if (note != null) 'note': note,
          if (photoPath != null) 'photo_path': photoPath,
        },
      );
      return AttendanceModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Absensi'));
    }
  }
}
