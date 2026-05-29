import '../../domain/entities/student_study_entity.dart';

class StudentStudyModel extends StudentStudyEntity {
  const StudentStudyModel({
    required super.id,
    required super.studentId,
    required super.studentName,
    required super.nis,
    required super.classroomId,
    required super.classroomName,
    required super.className,
    required super.subClassName,
    required super.academicYearId,
    required super.academicYearName,
    required super.status,
    required super.enrollmentDate,
  });

  factory StudentStudyModel.fromJson(Map<String, dynamic> json) {
    String s(dynamic v) => v?.toString() ?? '';
    return StudentStudyModel(
      id: s(json['id']),
      studentId: s(json['student_id']),
      studentName: s(json['student_name']),
      nis: s(json['nis']),
      classroomId: s(json['classroom_id']),
      classroomName: s(json['classroom_name']),
      className: s(json['class_name']),
      subClassName: s(json['sub_class_name']),
      academicYearId: s(json['academic_year_id']),
      academicYearName: s(json['academic_year_name']),
      status: s(json['status']),
      enrollmentDate: s(json['enrollment_date']),
    );
  }
}
