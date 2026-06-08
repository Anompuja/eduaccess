import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/paginated.dart';
import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/providers/active_school_provider.dart';
import '../../data/datasources/students_remote_data_source.dart';
import '../../data/models/student_row_data.dart';
import '../../data/repositories/students_repository_impl.dart';
import '../constants/students_screen_constants.dart';

final studentsRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  final studentListCacheOptions = ref.watch(studentListCacheOptionsProvider);
  final nonCacheableRequestOptions = ref.watch(
    nonCacheableRequestOptionsProvider,
  );
  return StudentsRepositoryImpl(
    StudentsRemoteDataSource(
      dio,
      studentListCacheOptions: studentListCacheOptions,
      bypassCacheOptions: nonCacheableRequestOptions,
    ),
  );
});

final studentsCurrentPageProvider = StateProvider<int>((ref) => 1);

final studentsSearchQueryProvider = StateProvider<String>((ref) => '');

final studentsRefreshTriggerProvider = StateProvider<int>((ref) => 0);

// These are for dropdown filters in the UI
final studentsLevelFilterProvider = StateProvider<String?>((ref) => null);
final studentsClassFilterProvider = StateProvider<String?>((ref) => null);
final studentsSubClassFilterProvider = StateProvider<String?>((ref) => null);

final studentsProvider = FutureProvider.autoDispose<Paginated<StudentRowData>>((
  ref,
) async {
  final repository = ref.watch(studentsRepositoryProvider);
  final page = ref.watch(studentsCurrentPageProvider);
  final query = ref.watch(studentsSearchQueryProvider);
  final user = ref.watch(currentUserProvider);
  final activeSchool = ref.watch(activeSchoolProvider);
  final refreshTrigger = ref.watch(studentsRefreshTriggerProvider);

  // Custom API filters
  final levelFilter = ref.watch(studentsLevelFilterProvider);
  final classFilter = ref.watch(studentsClassFilterProvider);
  final subClassFilter = ref.watch(studentsSubClassFilterProvider);

  final schoolId = switch (user?.role) {
    UserRole.superadmin => activeSchool?.id,
    _ => user?.schoolId,
  };

  return repository.getStudents(
    page: page,
    perPage: StudentsScreenConstants.rowsPerPage,
    query: query.isNotEmpty ? query : null,
    schoolId: schoolId,
    educationLevelId: levelFilter,
    classId: classFilter,
    subClassId: subClassFilter,
    refreshTrigger: refreshTrigger > 0 ? refreshTrigger : null,
  );
});

final createStudentProvider = FutureProvider.autoDispose
    .family<StudentRowData, Map<String, dynamic>>((ref, data) async {
      final repository = ref.watch(studentsRepositoryProvider);
      final student = await repository.createStudent(data);
      await ref.read(cacheStoreProvider).clean();
      ref.read(studentsRefreshTriggerProvider.notifier).state++;
      ref.invalidate(studentsProvider);
      return student;
    });

final updateStudentProvider = FutureProvider.autoDispose
    .family<StudentRowData, ({String id, Map<String, dynamic> data})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(studentsRepositoryProvider);
      final student = await repository.updateStudent(params.id, params.data);
      await ref.read(cacheStoreProvider).clean();
      ref.read(studentsRefreshTriggerProvider.notifier).state++;
      ref.invalidate(studentsProvider);
      return student;
    });

final deleteStudentProvider = FutureProvider.autoDispose.family<void, String>((
  ref,
  studentId,
) async {
  final repository = ref.watch(studentsRepositoryProvider);
  await repository.deleteStudent(studentId);
  await ref.read(cacheStoreProvider).clean();
  ref.read(studentsRefreshTriggerProvider.notifier).state++;
  ref.invalidate(studentsProvider);
});
