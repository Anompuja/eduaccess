import '../../../../core/api/paginated.dart';
import '../datasources/teachers_remote_data_source.dart';
import '../models/teacher_row_data.dart';

class TeachersRepositoryImpl {
  final TeachersRemoteDataSource _remoteDataSource;

  TeachersRepositoryImpl(this._remoteDataSource);

  Future<Paginated<TeacherRowData>> getTeachers({
    required int page,
    int perPage = 5,
    String? query,
    String? schoolId,
    int? refreshTrigger,
  }) {
    return _remoteDataSource.getTeachers(
      page: page,
      perPage: perPage,
      query: query,
      schoolId: schoolId,
      refreshTrigger: refreshTrigger,
    );
  }

  Future<TeacherRowData> createTeacher(Map<String, dynamic> data) {
    return _remoteDataSource.createTeacher(data);
  }

  Future<TeacherRowData> updateTeacher(String id, Map<String, dynamic> data) {
    return _remoteDataSource.updateTeacher(id, data);
  }

  Future<void> deleteTeacher(String id) {
    return _remoteDataSource.deleteTeacher(id);
  }
}
