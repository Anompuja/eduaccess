import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/class_schedule_entity.dart';
import '../../domain/repositories/class_schedule_repository.dart';
import '../datasources/class_schedule_remote_datasource.dart';

class ClassScheduleRepositoryImpl implements ClassScheduleRepository {
  final ClassScheduleRemoteDataSource remoteDataSource;

  ClassScheduleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ClassScheduleEntity>> getClassSchedules({String? schoolId, String? classroomId, String? teacherId, String? subjectId, String? date, String? status}) =>
      remoteDataSource.getClassSchedules(schoolId: schoolId, classroomId: classroomId, teacherId: teacherId, subjectId: subjectId, date: date, status: status);

  @override
  Future<ClassScheduleEntity> getClassSchedule(String id) =>
      remoteDataSource.getClassSchedule(id);

  @override
  Future<ClassScheduleEntity> createClassSchedule({required String classroomId, required String subjectId, required String teacherId, required String date, required String startTime, required String endTime, String? startPeriodId, String? endPeriodId, String? schoolId}) =>
      remoteDataSource.createClassSchedule(classroomId: classroomId, subjectId: subjectId, teacherId: teacherId, date: date, startTime: startTime, endTime: endTime, startPeriodId: startPeriodId, endPeriodId: endPeriodId, schoolId: schoolId);

  @override
  Future<ClassScheduleEntity> updateClassSchedule(String id, {required String classroomId, required String subjectId, required String teacherId, required String date, required String startTime, required String endTime, String? startPeriodId, String? endPeriodId}) =>
      remoteDataSource.updateClassSchedule(id, classroomId: classroomId, subjectId: subjectId, teacherId: teacherId, date: date, startTime: startTime, endTime: endTime, startPeriodId: startPeriodId, endPeriodId: endPeriodId);

  @override
  Future<void> deleteClassSchedule(String id) =>
      remoteDataSource.deleteClassSchedule(id);

  @override
  Future<void> startClassSchedule(String id) =>
      remoteDataSource.startClassSchedule(id);

  @override
  Future<void> completeClassSchedule(String id) =>
      remoteDataSource.completeClassSchedule(id);

  @override
  Future<void> cancelClassSchedule(String id) =>
      remoteDataSource.cancelClassSchedule(id);

  @override
  Future<List<AttendanceEntity>> getAttendances(String scheduleId) =>
      remoteDataSource.getAttendances(scheduleId);

  @override
  Future<AttendanceEntity> updateAttendance(String scheduleId, String studentId, {required String status, String? note, String? photoPath}) =>
      remoteDataSource.updateAttendance(scheduleId, studentId, status: status, note: note, photoPath: photoPath);
}
