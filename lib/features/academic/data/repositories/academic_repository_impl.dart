import '../../domain/entities/academic_year_entity.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/entities/classroom_entity.dart';
import '../../domain/entities/education_level_entity.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/entities/sub_class_entity.dart';
import '../../domain/repositories/academic_repository.dart';
import '../datasources/academic_remote_data_source.dart';

class AcademicRepositoryImpl implements AcademicRepository {
  final AcademicRemoteDataSource remoteDataSource;

  AcademicRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<EducationLevelEntity>> getLevels({String? schoolId}) =>
      remoteDataSource.getLevels(schoolId: schoolId);

  @override
  Future<EducationLevelEntity> createLevel(String name, {String? schoolId}) =>
      remoteDataSource.createLevel(name, schoolId: schoolId);

  @override
  Future<EducationLevelEntity> updateLevel(
    String id,
    String name, {
    String? schoolId,
  }) => remoteDataSource.updateLevel(id, name, schoolId: schoolId);

  @override
  Future<void> deleteLevel(String id, {String? schoolId}) =>
      remoteDataSource.deleteLevel(id, schoolId: schoolId);

  @override
  Future<List<ClassEntity>> getClasses({String? schoolId}) =>
      remoteDataSource.getClasses(schoolId: schoolId);

  @override
  Future<ClassEntity> createClass(
    String educationLevelId,
    String name, {
    String? schoolId,
  }) =>
      remoteDataSource.createClass(educationLevelId, name, schoolId: schoolId);

  @override
  Future<ClassEntity> updateClass(
    String id,
    String educationLevelId,
    String name, {
    String? schoolId,
  }) => remoteDataSource.updateClass(
    id,
    educationLevelId,
    name,
    schoolId: schoolId,
  );

  @override
  Future<void> deleteClass(String id, {String? schoolId}) =>
      remoteDataSource.deleteClass(id, schoolId: schoolId);

  @override
  Future<List<SubClassEntity>> getSubClasses({String? schoolId}) =>
      remoteDataSource.getSubClasses(schoolId: schoolId);

  @override
  Future<SubClassEntity> createSubClass(
    String classId,
    String name, {
    String? schoolId,
  }) => remoteDataSource.createSubClass(classId, name, schoolId: schoolId);

  @override
  Future<SubClassEntity> updateSubClass(
    String id,
    String classId,
    String name, {
    String? schoolId,
  }) => remoteDataSource.updateSubClass(id, classId, name, schoolId: schoolId);

  @override
  Future<void> deleteSubClass(String id, {String? schoolId}) =>
      remoteDataSource.deleteSubClass(id, schoolId: schoolId);

  @override
  Future<List<AcademicYearEntity>> getAcademicYears({String? schoolId}) =>
      remoteDataSource.getAcademicYears(schoolId: schoolId);

  @override
  Future<AcademicYearEntity> createAcademicYear(
    String name,
    String startDate,
    String endDate,
    String description, {
    String? schoolId,
  }) => remoteDataSource.createAcademicYear(
    name,
    startDate,
    endDate,
    description,
    schoolId: schoolId,
  );

  @override
  Future<AcademicYearEntity> updateAcademicYear(
    String id,
    String name,
    String startDate,
    String endDate,
    String description, {
    String? schoolId,
  }) => remoteDataSource.updateAcademicYear(
    id,
    name,
    startDate,
    endDate,
    description,
    schoolId: schoolId,
  );

  @override
  Future<void> deleteAcademicYear(String id, {String? schoolId}) =>
      remoteDataSource.deleteAcademicYear(id, schoolId: schoolId);

  @override
  Future<void> activateAcademicYear(String id, {String? schoolId}) =>
      remoteDataSource.activateAcademicYear(id, schoolId: schoolId);

  @override
  Future<List<SubjectEntity>> getSubjects({String? schoolId}) =>
      remoteDataSource.getSubjects(schoolId: schoolId);

  @override
  Future<SubjectEntity> createSubject(
    String name,
    String category, {
    String? schoolId,
  }) => remoteDataSource.createSubject(name, category, schoolId: schoolId);

  @override
  Future<SubjectEntity> updateSubject(
    String id,
    String name,
    String category, {
    String? schoolId,
  }) => remoteDataSource.updateSubject(id, name, category, schoolId: schoolId);

  @override
  Future<void> deleteSubject(String id, {String? schoolId}) =>
      remoteDataSource.deleteSubject(id, schoolId: schoolId);

  @override
  Future<List<ClassroomEntity>> getClassrooms({String? schoolId}) =>
      remoteDataSource.getClassrooms(schoolId: schoolId);

  @override
  Future<ClassroomEntity> createClassroom(
    String name,
    int capacity,
    String floor,
    String building,
    String roomType,
    String facilities, {
    String? classId,
    String? subClassId,
    String? academicYearId,
    String? homeroomTeacherId,
    String? schoolId,
  }) => remoteDataSource.createClassroom(
    name,
    capacity,
    floor,
    building,
    roomType,
    facilities,
    classId: classId,
    subClassId: subClassId,
    academicYearId: academicYearId,
    homeroomTeacherId: homeroomTeacherId,
    schoolId: schoolId,
  );

  @override
  Future<ClassroomEntity> updateClassroom(
    String id,
    String name,
    int capacity,
    String floor,
    String building,
    String roomType,
    String facilities, {
    String status = 'available',
    String? classId,
    String? subClassId,
    String? academicYearId,
    String? homeroomTeacherId,
    String? schoolId,
  }) => remoteDataSource.updateClassroom(
    id,
    name,
    capacity,
    floor,
    building,
    roomType,
    facilities,
    status: status,
    classId: classId,
    subClassId: subClassId,
    academicYearId: academicYearId,
    homeroomTeacherId: homeroomTeacherId,
    schoolId: schoolId,
  );

  @override
  Future<void> deleteClassroom(String id, {String? schoolId}) =>
      remoteDataSource.deleteClassroom(id, schoolId: schoolId);

  @override
  Future<List<ScheduleEntity>> getSchedules({
    String? schoolId,
    String? dayOfWeek,
  }) => remoteDataSource.getSchedules(schoolId: schoolId, dayOfWeek: dayOfWeek);

  @override
  Future<ScheduleEntity> createSchedule({
    required String dayOfWeek,
    required int periodNumber,
    required String label,
    required String startTime,
    required String endTime,
    required bool isBreak,
    String? schoolId,
  }) => remoteDataSource.createSchedule(
    dayOfWeek: dayOfWeek,
    periodNumber: periodNumber,
    label: label,
    startTime: startTime,
    endTime: endTime,
    isBreak: isBreak,
    schoolId: schoolId,
  );

  @override
  Future<ScheduleEntity> updateSchedule(
    String id, {
    required String dayOfWeek,
    required int periodNumber,
    required String label,
    required String startTime,
    required String endTime,
    required bool isBreak,
    String? schoolId,
  }) => remoteDataSource.updateSchedule(
    id,
    dayOfWeek: dayOfWeek,
    periodNumber: periodNumber,
    label: label,
    startTime: startTime,
    endTime: endTime,
    isBreak: isBreak,
    schoolId: schoolId,
  );

  @override
  Future<void> deleteSchedule(String id, {String? schoolId}) =>
      remoteDataSource.deleteSchedule(id, schoolId: schoolId);
}
