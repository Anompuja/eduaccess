import '../entities/academic_year_entity.dart';
import '../entities/class_entity.dart';
import '../entities/classroom_entity.dart';
import '../entities/education_level_entity.dart';
import '../entities/schedule_entity.dart';
import '../entities/subject_entity.dart';
import '../entities/sub_class_entity.dart';

abstract class AcademicRepository {
  // Education Levels
  Future<List<EducationLevelEntity>> getLevels({String? schoolId});
  Future<EducationLevelEntity> createLevel(String name, {String? schoolId});
  Future<EducationLevelEntity> updateLevel(String id, String name, {String? schoolId});
  Future<void> deleteLevel(String id, {String? schoolId});

  // Classes
  Future<List<ClassEntity>> getClasses({String? schoolId});
  Future<ClassEntity> createClass(String educationLevelId, String name, {String? schoolId});
  Future<ClassEntity> updateClass(String id, String educationLevelId, String name, {String? schoolId});
  Future<void> deleteClass(String id, {String? schoolId});

  // Sub Classes
  Future<List<SubClassEntity>> getSubClasses({String? schoolId});
  Future<SubClassEntity> createSubClass(String classId, String name, {String? schoolId});
  Future<SubClassEntity> updateSubClass(String id, String classId, String name, {String? schoolId});
  Future<void> deleteSubClass(String id, {String? schoolId});

  // Academic Years
  Future<List<AcademicYearEntity>> getAcademicYears({String? schoolId});
  Future<AcademicYearEntity> createAcademicYear(String name, String startDate, String endDate, String description, {String? schoolId});
  Future<AcademicYearEntity> updateAcademicYear(String id, String name, String startDate, String endDate, String description, {String? schoolId});
  Future<void> deleteAcademicYear(String id, {String? schoolId});
  Future<void> activateAcademicYear(String id, {String? schoolId});

  // Subjects
  Future<List<SubjectEntity>> getSubjects({String? schoolId});
  Future<SubjectEntity> createSubject(String name, String category, {String? schoolId});
  Future<SubjectEntity> updateSubject(String id, String name, String category, {String? schoolId});
  Future<void> deleteSubject(String id, {String? schoolId});

  // Classrooms
  Future<List<ClassroomEntity>> getClassrooms({String? schoolId});
  Future<ClassroomEntity> createClassroom(String name, int capacity, int floor, String building, String roomType, String facilities, {String? schoolId});
  Future<ClassroomEntity> updateClassroom(String id, String name, int capacity, int floor, String building, String roomType, String facilities, {String? schoolId});
  Future<void> deleteClassroom(String id, {String? schoolId});

  // Schedules (lesson periods)
  Future<List<ScheduleEntity>> getSchedules({String? schoolId, String? dayOfWeek});
  Future<ScheduleEntity> createSchedule({required String dayOfWeek, required int periodNumber, required String label, required String startTime, required String endTime, required bool isBreak, String? schoolId});
  Future<ScheduleEntity> updateSchedule(String id, {required String dayOfWeek, required int periodNumber, required String label, required String startTime, required String endTime, required bool isBreak, String? schoolId});
  Future<void> deleteSchedule(String id, {String? schoolId});
}
