/// A student's enrollment in one classroom for one academic year.
class StudentStudyEntity {
  final String id;
  final String studentId;
  final String studentName;
  final String nis;
  final String classroomId;
  final String classroomName;
  final String className;
  final String subClassName;
  final String academicYearId;
  final String academicYearName;
  final String status; // active, inactive, graduated, transferred
  final String enrollmentDate;

  const StudentStudyEntity({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.nis,
    required this.classroomId,
    required this.classroomName,
    required this.className,
    required this.subClassName,
    required this.academicYearId,
    required this.academicYearName,
    required this.status,
    required this.enrollmentDate,
  });

  /// Combined "Kelas X - A" label, falling back gracefully when parts are blank.
  String get fullClassName {
    if (className.isEmpty) return classroomName;
    if (subClassName.isEmpty) return className;
    return '$className - $subClassName';
  }
}
