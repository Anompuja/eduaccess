import '../../domain/entities/student_study_entity.dart';
import '../../domain/repositories/student_tracking_repository.dart';
import '../datasources/student_tracking_remote_datasource.dart';

class StudentTrackingRepositoryImpl implements StudentTrackingRepository {
  final StudentTrackingRemoteDataSource remoteDataSource;

  StudentTrackingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<StudentStudyEntity>> getStudies({String? schoolId, String? classroomId, String? academicYearId, String? status}) =>
      remoteDataSource.getStudies(schoolId: schoolId, classroomId: classroomId, academicYearId: academicYearId, status: status);

  @override
  Future<List<StudentStudyEntity>> getStudentHistory(String studentId, {String? schoolId}) =>
      remoteDataSource.getStudentHistory(studentId, schoolId: schoolId);
}
