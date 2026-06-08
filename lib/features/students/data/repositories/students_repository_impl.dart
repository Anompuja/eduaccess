import '../../../../core/api/paginated.dart';
import '../datasources/students_remote_data_source.dart';
import '../models/student_row_data.dart';

class StudentsRepositoryImpl {
  final StudentsRemoteDataSource _remoteDataSource;

  StudentsRepositoryImpl(this._remoteDataSource);

  Future<Paginated<StudentRowData>> getStudents({
    required int page,
    int perPage = 10,
    String? query,
    String? schoolId,
    String? educationLevelId,
    String? classId,
    String? subClassId,
    int? refreshTrigger,
  }) {
    return _remoteDataSource.getStudents(
      page: page,
      perPage: perPage,
      query: query,
      schoolId: schoolId,
      educationLevelId: educationLevelId,
      classId: classId,
      subClassId: subClassId,
      refreshTrigger: refreshTrigger,
    );
  }

  Future<StudentRowData> createStudent(Map<String, dynamic> data) {
    return _remoteDataSource.createStudent(data);
  }

  Future<StudentRowData> updateStudent(String id, Map<String, dynamic> data) {
    return _remoteDataSource.updateStudent(id, data);
  }

  Future<void> deleteStudent(String id) {
    return _remoteDataSource.deleteStudent(id);
  }
}
