import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduaccess/core/api/api_client.dart';
import 'package:eduaccess/core/auth/auth_notifier.dart';
import 'package:eduaccess/core/auth/auth_state.dart';
import 'package:eduaccess/core/providers/active_school_provider.dart';
import '../../data/datasources/academic_remote_data_source.dart';
import '../../data/repositories/academic_repository_impl.dart';
import '../../domain/entities/academic_year_entity.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/entities/classroom_entity.dart';
import '../../domain/entities/education_level_entity.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/entities/sub_class_entity.dart';
import '../../domain/repositories/academic_repository.dart';

final academicRepositoryProvider = Provider<AcademicRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final remoteDataSource = AcademicRemoteDataSourceImpl(dio: dio);
  return AcademicRepositoryImpl(remoteDataSource: remoteDataSource);
});

String? _schoolId(Ref ref) {
  final user = ref.watch(currentUserProvider);
  if (user?.role == UserRole.superadmin) {
    return ref.watch(activeSchoolProvider)?.id;
  }
  return null;
}

final levelsProvider = FutureProvider.autoDispose<List<EducationLevelEntity>>((ref) async {
  return ref.watch(academicRepositoryProvider).getLevels(schoolId: _schoolId(ref));
});

final classesProvider = FutureProvider.autoDispose<List<ClassEntity>>((ref) async {
  return ref.watch(academicRepositoryProvider).getClasses(schoolId: _schoolId(ref));
});

final subClassesProvider = FutureProvider.autoDispose<List<SubClassEntity>>((ref) async {
  return ref.watch(academicRepositoryProvider).getSubClasses(schoolId: _schoolId(ref));
});

final academicYearsProvider = FutureProvider.autoDispose<List<AcademicYearEntity>>((ref) async {
  return ref.watch(academicRepositoryProvider).getAcademicYears(schoolId: _schoolId(ref));
});

final subjectsProvider = FutureProvider.autoDispose<List<SubjectEntity>>((ref) async {
  return ref.watch(academicRepositoryProvider).getSubjects(schoolId: _schoolId(ref));
});

final classroomsProvider = FutureProvider.autoDispose<List<ClassroomEntity>>((ref) async {
  return ref.watch(academicRepositoryProvider).getClassrooms(schoolId: _schoolId(ref));
});

final schedulesProvider = FutureProvider.autoDispose<List<ScheduleEntity>>((ref) async {
  return ref.watch(academicRepositoryProvider).getSchedules(schoolId: _schoolId(ref));
});
