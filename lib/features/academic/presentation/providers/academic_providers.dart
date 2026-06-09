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
import '../../../teachers/presentation/providers/teachers_provider.dart';
import '../../../teachers/data/models/teacher_row_data.dart';

final academicRepositoryProvider = Provider<AcademicRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final academicListCacheOptions = ref.watch(academicListCacheOptionsProvider);
  final bypassCacheOptions = ref.watch(nonCacheableRequestOptionsProvider);
  final remoteDataSource = AcademicRemoteDataSourceImpl(
    dio: dio,
    academicListCacheOptions: academicListCacheOptions,
    bypassCacheOptions: bypassCacheOptions,
  );
  return AcademicRepositoryImpl(remoteDataSource: remoteDataSource);
});

String? _schoolId(Ref ref) {
  final user = ref.watch(currentUserProvider);
  if (user?.role == UserRole.superadmin) {
    return ref.watch(activeSchoolProvider)?.id;
  }
  return null;
}

final levelsProvider = FutureProvider<List<EducationLevelEntity>>((ref) async {
  return ref
      .watch(academicRepositoryProvider)
      .getLevels(schoolId: _schoolId(ref));
});

final levelsBySchoolProvider =
    FutureProvider.family<List<EducationLevelEntity>, String?>((
      ref,
      schoolId,
    ) async {
      return ref
          .watch(academicRepositoryProvider)
          .getLevels(schoolId: schoolId);
    });

final classesProvider = FutureProvider<List<ClassEntity>>((ref) async {
  return ref
      .watch(academicRepositoryProvider)
      .getClasses(schoolId: _schoolId(ref));
});

final classesBySchoolProvider =
    FutureProvider.family<List<ClassEntity>, String?>((ref, schoolId) async {
      return ref
          .watch(academicRepositoryProvider)
          .getClasses(schoolId: schoolId);
    });

final subClassesProvider = FutureProvider<List<SubClassEntity>>((ref) async {
  return ref
      .watch(academicRepositoryProvider)
      .getSubClasses(schoolId: _schoolId(ref));
});

final subClassesBySchoolProvider =
    FutureProvider.family<List<SubClassEntity>, String?>((ref, schoolId) async {
      return ref
          .watch(academicRepositoryProvider)
          .getSubClasses(schoolId: schoolId);
    });

final academicYearsProvider = FutureProvider<List<AcademicYearEntity>>((
  ref,
) async {
  return ref
      .watch(academicRepositoryProvider)
      .getAcademicYears(schoolId: _schoolId(ref));
});

final subjectsProvider = FutureProvider<List<SubjectEntity>>((ref) async {
  return ref
      .watch(academicRepositoryProvider)
      .getSubjects(schoolId: _schoolId(ref));
});

final classroomsProvider = FutureProvider<List<ClassroomEntity>>((ref) async {
  return ref
      .watch(academicRepositoryProvider)
      .getClassrooms(schoolId: _schoolId(ref));
});

final classroomsBySchoolProvider =
    FutureProvider.family<List<ClassroomEntity>, String?>((ref, schoolId) async {
      return ref
          .watch(academicRepositoryProvider)
          .getClassrooms(schoolId: schoolId);
    });

final schedulesProvider = FutureProvider<List<ScheduleEntity>>((ref) async {
  return ref
      .watch(academicRepositoryProvider)
      .getSchedules(schoolId: _schoolId(ref));
});

// Flat teacher list for classroom form dropdowns.
// Value used as homeroom_teacher_id = TeacherRowData.userId (auth.users UUID).
final teachersForDropdownProvider = FutureProvider<List<TeacherRowData>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final activeSchool = ref.watch(activeSchoolProvider);
  final schoolId = switch (user?.role) {
    UserRole.superadmin => activeSchool?.id,
    _ => user?.schoolId,
  };
  final result = await ref
      .watch(teachersRepositoryProvider)
      .getTeachers(page: 1, perPage: 200, schoolId: schoolId);
  return result.items.where((t) => t.userId.isNotEmpty).toList();
});
