import '../entities/attendance_entity.dart';
import '../entities/class_schedule_entity.dart';

abstract class ClassScheduleRepository {
  Future<List<ClassScheduleEntity>> getClassSchedules({String? schoolId, String? classroomId, String? teacherId, String? subjectId, String? date, String? status});
  Future<ClassScheduleEntity> getClassSchedule(String id);
  Future<ClassScheduleEntity> createClassSchedule({required String classroomId, required String subjectId, required String teacherId, required String date, required String startTime, required String endTime, String? startPeriodId, String? endPeriodId, String? schoolId});
  Future<ClassScheduleEntity> updateClassSchedule(String id, {required String classroomId, required String subjectId, required String teacherId, required String date, required String startTime, required String endTime, String? startPeriodId, String? endPeriodId});
  Future<void> deleteClassSchedule(String id);
  Future<void> startClassSchedule(String id);
  Future<void> completeClassSchedule(String id);
  Future<void> cancelClassSchedule(String id);
  Future<List<AttendanceEntity>> getAttendances(String scheduleId);
  Future<AttendanceEntity> updateAttendance(String scheduleId, String studentId, {required String status, String? note, String? photoPath});
}
