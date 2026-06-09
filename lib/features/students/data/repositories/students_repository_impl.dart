import '../../../../core/api/paginated.dart';
import '../datasources/students_remote_data_source.dart';
import '../models/linked_parent_data.dart';
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

  Future<int> getStudentCount({required String schoolId}) {
    return _remoteDataSource.getStudentCount(schoolId: schoolId);
  }

  Future<void> deleteStudent(String id) {
    return _remoteDataSource.deleteStudent(id);
  }

  Future<List<LinkedParentData>> getStudentParents(String studentId) {
    return _remoteDataSource.getStudentParents(studentId);
  }

  Future<void> linkParent(
    String studentId,
    String parentId,
    String relationship,
    bool isPrimary,
  ) {
    return _remoteDataSource.linkParent(studentId, parentId, relationship, isPrimary);
  }

  Future<void> unlinkParent(String studentId, String parentId) {
    return _remoteDataSource.unlinkParent(studentId, parentId);
  }
}
