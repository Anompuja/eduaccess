import 'package:dio/dio.dart';
import 'package:eduaccess/core/api/api_endpoints.dart';
import '../models/academic_year_model.dart';
import '../models/class_model.dart';
import '../models/classroom_model.dart';
import '../models/education_level_model.dart';
import '../models/schedule_model.dart';
import '../models/subject_model.dart';
import '../models/sub_class_model.dart';

abstract class AcademicRemoteDataSource {
  Future<List<EducationLevelModel>> getLevels({String? schoolId});
  Future<EducationLevelModel> createLevel(String name, {String? schoolId});
  Future<EducationLevelModel> updateLevel(String id, String name, {String? schoolId});
  Future<void> deleteLevel(String id, {String? schoolId});

  Future<List<ClassModel>> getClasses({String? schoolId});
  Future<ClassModel> createClass(String educationLevelId, String name, {String? schoolId});
  Future<ClassModel> updateClass(String id, String educationLevelId, String name, {String? schoolId});
  Future<void> deleteClass(String id, {String? schoolId});

  Future<List<SubClassModel>> getSubClasses({String? schoolId});
  Future<SubClassModel> createSubClass(String classId, String name, {String? schoolId});
  Future<SubClassModel> updateSubClass(String id, String classId, String name, {String? schoolId});
  Future<void> deleteSubClass(String id, {String? schoolId});

  Future<List<AcademicYearModel>> getAcademicYears({String? schoolId});
  Future<AcademicYearModel> createAcademicYear(String name, String startDate, String endDate, String description, {String? schoolId});
  Future<AcademicYearModel> updateAcademicYear(String id, String name, String startDate, String endDate, String description, {String? schoolId});
  Future<void> deleteAcademicYear(String id, {String? schoolId});
  Future<void> activateAcademicYear(String id, {String? schoolId});

  Future<List<SubjectModel>> getSubjects({String? schoolId});
  Future<SubjectModel> createSubject(String name, String category, {String? schoolId});
  Future<SubjectModel> updateSubject(String id, String name, String category, {String? schoolId});
  Future<void> deleteSubject(String id, {String? schoolId});

  Future<List<ClassroomModel>> getClassrooms({String? schoolId});
  Future<ClassroomModel> createClassroom(String name, int capacity, int floor, String building, String roomType, String facilities, {String? schoolId});
  Future<ClassroomModel> updateClassroom(String id, String name, int capacity, int floor, String building, String roomType, String facilities, {String? schoolId});
  Future<void> deleteClassroom(String id, {String? schoolId});

  Future<List<ScheduleModel>> getSchedules({String? schoolId, String? dayOfWeek});
  Future<ScheduleModel> createSchedule({required String dayOfWeek, required int periodNumber, required String label, required String startTime, required String endTime, required bool isBreak, String? schoolId});
  Future<ScheduleModel> updateSchedule(String id, {required String dayOfWeek, required int periodNumber, required String label, required String startTime, required String endTime, required bool isBreak, String? schoolId});
  Future<void> deleteSchedule(String id, {String? schoolId});
}

class AcademicRemoteDataSourceImpl implements AcademicRemoteDataSource {
  final Dio dio;

  AcademicRemoteDataSourceImpl({required this.dio});

  Map<String, dynamic> _schoolParam({String? schoolId}) {
    final params = <String, dynamic>{};
    if (schoolId != null && schoolId.isNotEmpty) params['school_id'] = schoolId;
    return params;
  }

  List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    final list = data as List<dynamic>? ?? [];
    return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  String _handleError(DioException e, String entity) {
    if (e.response?.statusCode == 400) return e.response?.data?['message'] ?? 'Data tidak valid.';
    if (e.response?.statusCode == 404) return '$entity tidak ditemukan.';
    if (e.response?.statusCode == 409) return e.response?.data?['message'] ?? 'Data sudah ada.';
    if (e.response?.statusCode == 500) return 'Server error. Coba lagi nanti.';
    return e.message ?? 'Terjadi kesalahan. Coba lagi.';
  }

  // ── Education Levels ──────────────────────────────────────────────────────

  @override
  Future<List<EducationLevelModel>> getLevels({String? schoolId}) async {
    try {
      final params = _schoolParam(schoolId: schoolId);
      final response = await dio.get(ApiEndpoints.academicLevels, queryParameters: params.isNotEmpty ? params : null);
      return _parseList(response.data['data'], EducationLevelModel.fromJson);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Level pendidikan'));
    }
  }

  @override
  Future<EducationLevelModel> createLevel(String name, {String? schoolId}) async {
    try {
      final qp = _schoolParam(schoolId: schoolId);
      final response = await dio.post(ApiEndpoints.academicLevels, data: {'name': name}, queryParameters: qp.isNotEmpty ? qp : null);
      return EducationLevelModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Level pendidikan'));
    }
  }

  @override
  Future<EducationLevelModel> updateLevel(String id, String name, {String? schoolId}) async {
    try {
      final response = await dio.put(ApiEndpoints.academicLevelById(id), data: {'name': name});
      return EducationLevelModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Level pendidikan'));
    }
  }

  @override
  Future<void> deleteLevel(String id, {String? schoolId}) async {
    try {
      await dio.delete(ApiEndpoints.academicLevelById(id));
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Level pendidikan'));
    }
  }

  // ── Classes ───────────────────────────────────────────────────────────────

  @override
  Future<List<ClassModel>> getClasses({String? schoolId}) async {
    try {
      final params = _schoolParam(schoolId: schoolId);
      final response = await dio.get(ApiEndpoints.academicClasses, queryParameters: params.isNotEmpty ? params : null);
      return _parseList(response.data['data'], ClassModel.fromJson);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Kelas'));
    }
  }

  @override
  Future<ClassModel> createClass(String educationLevelId, String name, {String? schoolId}) async {
    try {
      final qp = _schoolParam(schoolId: schoolId);
      final response = await dio.post(ApiEndpoints.academicClasses, data: {'level_id': educationLevelId, 'name': name}, queryParameters: qp.isNotEmpty ? qp : null);
      return ClassModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Kelas'));
    }
  }

  @override
  Future<ClassModel> updateClass(String id, String educationLevelId, String name, {String? schoolId}) async {
    try {
      final response = await dio.put(ApiEndpoints.academicClassById(id), data: {'level_id': educationLevelId, 'name': name});
      return ClassModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Kelas'));
    }
  }

  @override
  Future<void> deleteClass(String id, {String? schoolId}) async {
    try {
      await dio.delete(ApiEndpoints.academicClassById(id));
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Kelas'));
    }
  }

  // ── Sub Classes ───────────────────────────────────────────────────────────

  @override
  Future<List<SubClassModel>> getSubClasses({String? schoolId}) async {
    try {
      final params = _schoolParam(schoolId: schoolId);
      final response = await dio.get(ApiEndpoints.academicSubClasses, queryParameters: params.isNotEmpty ? params : null);
      return _parseList(response.data['data'], SubClassModel.fromJson);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Sub-kelas'));
    }
  }

  @override
  Future<SubClassModel> createSubClass(String classId, String name, {String? schoolId}) async {
    try {
      final qp = _schoolParam(schoolId: schoolId);
      final response = await dio.post(ApiEndpoints.academicSubClasses, data: {'class_id': classId, 'name': name}, queryParameters: qp.isNotEmpty ? qp : null);
      return SubClassModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Sub-kelas'));
    }
  }

  @override
  Future<SubClassModel> updateSubClass(String id, String classId, String name, {String? schoolId}) async {
    try {
      final response = await dio.put(ApiEndpoints.academicSubClassById(id), data: {'class_id': classId, 'name': name});
      return SubClassModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Sub-kelas'));
    }
  }

  @override
  Future<void> deleteSubClass(String id, {String? schoolId}) async {
    try {
      await dio.delete(ApiEndpoints.academicSubClassById(id));
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Sub-kelas'));
    }
  }

  // ── Academic Years ────────────────────────────────────────────────────────

  @override
  Future<List<AcademicYearModel>> getAcademicYears({String? schoolId}) async {
    try {
      final params = _schoolParam(schoolId: schoolId);
      final response = await dio.get(ApiEndpoints.academicYearsList, queryParameters: params.isNotEmpty ? params : null);
      return _parseList(response.data['data'], AcademicYearModel.fromJson);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Tahun ajaran'));
    }
  }

  @override
  Future<AcademicYearModel> createAcademicYear(String name, String startDate, String endDate, String description, {String? schoolId}) async {
    try {
      final qp = _schoolParam(schoolId: schoolId);
      final response = await dio.post(ApiEndpoints.academicYearsList, data: {
        'name': name,
        'start_date': startDate,
        'end_date': endDate,
        'description': description,
      }, queryParameters: qp.isNotEmpty ? qp : null);
      return AcademicYearModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Tahun ajaran'));
    }
  }

  @override
  Future<AcademicYearModel> updateAcademicYear(String id, String name, String startDate, String endDate, String description, {String? schoolId}) async {
    try {
      final response = await dio.put(ApiEndpoints.academicYearById(id), data: {
        'name': name,
        'start_date': startDate,
        'end_date': endDate,
        'description': description,
      });
      return AcademicYearModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Tahun ajaran'));
    }
  }

  @override
  Future<void> deleteAcademicYear(String id, {String? schoolId}) async {
    try {
      await dio.delete(ApiEndpoints.academicYearById(id));
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Tahun ajaran'));
    }
  }

  @override
  Future<void> activateAcademicYear(String id, {String? schoolId}) async {
    try {
      await dio.patch(ApiEndpoints.academicYearActivate(id));
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Tahun ajaran'));
    }
  }

  // ── Subjects ──────────────────────────────────────────────────────────────

  @override
  Future<List<SubjectModel>> getSubjects({String? schoolId}) async {
    try {
      final params = _schoolParam(schoolId: schoolId);
      final response = await dio.get(ApiEndpoints.subjectsList, queryParameters: params.isNotEmpty ? params : null);
      return _parseList(response.data['data'], SubjectModel.fromJson);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Mata pelajaran'));
    }
  }

  @override
  Future<SubjectModel> createSubject(String name, String category, {String? schoolId}) async {
    try {
      final qp = _schoolParam(schoolId: schoolId);
      final response = await dio.post(ApiEndpoints.subjectsList, data: {'name': name, 'category': category}, queryParameters: qp.isNotEmpty ? qp : null);
      return SubjectModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Mata pelajaran'));
    }
  }

  @override
  Future<SubjectModel> updateSubject(String id, String name, String category, {String? schoolId}) async {
    try {
      final response = await dio.put(ApiEndpoints.subjectById(id), data: {'name': name, 'category': category});
      return SubjectModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Mata pelajaran'));
    }
  }

  @override
  Future<void> deleteSubject(String id, {String? schoolId}) async {
    try {
      await dio.delete(ApiEndpoints.subjectById(id));
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Mata pelajaran'));
    }
  }

  // ── Classrooms ────────────────────────────────────────────────────────────

  @override
  Future<List<ClassroomModel>> getClassrooms({String? schoolId}) async {
    try {
      final params = _schoolParam(schoolId: schoolId);
      final response = await dio.get(ApiEndpoints.classroomsList, queryParameters: params.isNotEmpty ? params : null);
      return _parseList(response.data['data'], ClassroomModel.fromJson);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Ruang kelas'));
    }
  }

  @override
  Future<ClassroomModel> createClassroom(String name, int capacity, int floor, String building, String roomType, String facilities, {String? schoolId}) async {
    try {
      final qp = _schoolParam(schoolId: schoolId);
      final response = await dio.post(ApiEndpoints.classroomsList, data: {
        'name': name,
        'capacity': capacity,
        'floor': floor,
        'building': building,
        'room_type': roomType,
        'facilities': facilities,
      }, queryParameters: qp.isNotEmpty ? qp : null);
      return ClassroomModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Ruang kelas'));
    }
  }

  @override
  Future<ClassroomModel> updateClassroom(String id, String name, int capacity, int floor, String building, String roomType, String facilities, {String? schoolId}) async {
    try {
      final response = await dio.put(ApiEndpoints.classroomById(id), data: {
        'name': name,
        'capacity': capacity,
        'floor': floor,
        'building': building,
        'room_type': roomType,
        'facilities': facilities,
      });
      return ClassroomModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Ruang kelas'));
    }
  }

  @override
  Future<void> deleteClassroom(String id, {String? schoolId}) async {
    try {
      await dio.delete(ApiEndpoints.classroomById(id));
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Ruang kelas'));
    }
  }

  // ── Schedules ─────────────────────────────────────────────────────────────

  @override
  Future<List<ScheduleModel>> getSchedules({String? schoolId, String? dayOfWeek}) async {
    try {
      final params = _schoolParam(schoolId: schoolId);
      if (dayOfWeek != null) params['day_of_week'] = dayOfWeek;
      final response = await dio.get(ApiEndpoints.schedulesList, queryParameters: params.isNotEmpty ? params : null);
      return _parseList(response.data['data'], ScheduleModel.fromJson);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Jadwal'));
    }
  }

  @override
  Future<ScheduleModel> createSchedule({required String dayOfWeek, required int periodNumber, required String label, required String startTime, required String endTime, required bool isBreak, String? schoolId}) async {
    try {
      final qp = _schoolParam(schoolId: schoolId);
      final response = await dio.post(ApiEndpoints.schedulesList, data: {
        'day_of_week': dayOfWeek,
        'period_number': periodNumber,
        'label': label,
        'start_time': startTime,
        'end_time': endTime,
        'is_break': isBreak,
      }, queryParameters: qp.isNotEmpty ? qp : null);
      return ScheduleModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Jadwal'));
    }
  }

  @override
  Future<ScheduleModel> updateSchedule(String id, {required String dayOfWeek, required int periodNumber, required String label, required String startTime, required String endTime, required bool isBreak, String? schoolId}) async {
    try {
      final response = await dio.put(ApiEndpoints.scheduleById(id), data: {
        'day_of_week': dayOfWeek,
        'period_number': periodNumber,
        'label': label,
        'start_time': startTime,
        'end_time': endTime,
        'is_break': isBreak,
      });
      return ScheduleModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Jadwal'));
    }
  }

  @override
  Future<void> deleteSchedule(String id, {String? schoolId}) async {
    try {
      await dio.delete(ApiEndpoints.scheduleById(id));
    } on DioException catch (e) {
      throw Exception(_handleError(e, 'Jadwal'));
    }
  }
}
