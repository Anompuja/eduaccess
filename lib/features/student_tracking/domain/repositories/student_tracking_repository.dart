import '../entities/student_study_entity.dart';

abstract class StudentTrackingRepository {
  /// Lists enrollment records, optionally scoped/filtered.
  Future<List<StudentStudyEntity>> getStudies({
    String? schoolId,
    String? classroomId,
    String? academicYearId,
    String? status,
  });

  /// Full enrollment history for one student.
  Future<List<StudentStudyEntity>> getStudentHistory(
    String studentId, {
    String? schoolId,
  });
}
