import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduaccess/core/api/api_client.dart';
import 'package:eduaccess/core/auth/auth_notifier.dart';
import 'package:eduaccess/core/auth/auth_state.dart';
import 'package:eduaccess/core/providers/active_school_provider.dart';
import '../../data/datasources/class_schedule_remote_datasource.dart';
import '../../data/repositories/class_schedule_repository_impl.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/class_schedule_entity.dart';
import '../../domain/repositories/class_schedule_repository.dart';

final classScheduleRepositoryProvider = Provider<ClassScheduleRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ClassScheduleRepositoryImpl(
    remoteDataSource: ClassScheduleRemoteDataSourceImpl(dio: dio),
  );
});

String? _schoolId(Ref ref) {
  final user = ref.watch(currentUserProvider);
  if (user?.role == UserRole.superadmin) {
    return ref.watch(activeSchoolProvider)?.id;
  }
  return null;
}

final classSchedulesProvider = FutureProvider.autoDispose.family<List<ClassScheduleEntity>, ClassScheduleFilter>((ref, filter) async {
  return ref.watch(classScheduleRepositoryProvider).getClassSchedules(
    schoolId: _schoolId(ref),
    classroomId: filter.classroomId,
    teacherId: filter.teacherId,
    subjectId: filter.subjectId,
    date: filter.date,
    status: filter.status,
  );
});

final classScheduleDetailProvider = FutureProvider.autoDispose.family<ClassScheduleEntity, String>((ref, id) async {
  return ref.watch(classScheduleRepositoryProvider).getClassSchedule(id);
});

final attendancesProvider = FutureProvider.autoDispose.family<List<AttendanceEntity>, String>((ref, scheduleId) async {
  return ref.watch(classScheduleRepositoryProvider).getAttendances(scheduleId);
});

class ClassScheduleFilter {
  final String? classroomId;
  final String? teacherId;
  final String? subjectId;
  final String? date;
  final String? status;

  const ClassScheduleFilter({this.classroomId, this.teacherId, this.subjectId, this.date, this.status});

  @override
  bool operator ==(Object other) =>
      other is ClassScheduleFilter &&
      classroomId == other.classroomId &&
      teacherId == other.teacherId &&
      subjectId == other.subjectId &&
      date == other.date &&
      status == other.status;

  @override
  int get hashCode => Object.hash(classroomId, teacherId, subjectId, date, status);
}
