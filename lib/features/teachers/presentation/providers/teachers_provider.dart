import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/paginated.dart';
import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/providers/active_school_provider.dart';
import '../../data/datasources/teachers_remote_data_source.dart';
import '../../data/models/teacher_row_data.dart';
import '../../data/repositories/teachers_repository_impl.dart';
import '../constants/teachers_screen_constants.dart';

final teachersRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  final teacherListCacheOptions = ref.watch(teacherListCacheOptionsProvider);
  final nonCacheableRequestOptions = ref.watch(
    nonCacheableRequestOptionsProvider,
  );
  return TeachersRepositoryImpl(
    TeachersRemoteDataSource(
      dio,
      teacherListCacheOptions: teacherListCacheOptions,
      bypassCacheOptions: nonCacheableRequestOptions,
    ),
  );
});

final teachersCurrentPageProvider = StateProvider<int>((ref) => 1);

final teachersSearchQueryProvider = StateProvider<String>((ref) => '');

final teachersRefreshTriggerProvider = StateProvider<int>((ref) => 0);

final teachersProvider = FutureProvider.autoDispose<Paginated<TeacherRowData>>((
  ref,
) async {
  final repository = ref.watch(teachersRepositoryProvider);
  final page = ref.watch(teachersCurrentPageProvider);
  final query = ref.watch(teachersSearchQueryProvider);
  final user = ref.watch(currentUserProvider);
  final activeSchool = ref.watch(activeSchoolProvider);
  final refreshTrigger = ref.watch(teachersRefreshTriggerProvider);

  final schoolId = switch (user?.role) {
    UserRole.superadmin => activeSchool?.id,
    _ => user?.schoolId,
  };

  return repository.getTeachers(
    page: page,
    perPage: TeachersScreenConstants.rowsPerPage,
    query: query.isNotEmpty ? query : null,
    schoolId: schoolId,
    refreshTrigger: refreshTrigger > 0 ? refreshTrigger : null,
  );
});

final createTeacherProvider = FutureProvider.autoDispose
    .family<TeacherRowData, Map<String, dynamic>>((ref, data) async {
      final repository = ref.watch(teachersRepositoryProvider);
      final teacher = await repository.createTeacher(data);
      await ref.read(cacheStoreProvider).clean();
      ref.read(teachersRefreshTriggerProvider.notifier).state++;
      ref.invalidate(teachersProvider);
      return teacher;
    });

final updateTeacherProvider = FutureProvider.autoDispose
    .family<TeacherRowData, ({String id, Map<String, dynamic> data})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(teachersRepositoryProvider);
      final teacher = await repository.updateTeacher(params.id, params.data);
      await ref.read(cacheStoreProvider).clean();
      ref.read(teachersRefreshTriggerProvider.notifier).state++;
      ref.invalidate(teachersProvider);
      return teacher;
    });

final deleteTeacherProvider = FutureProvider.autoDispose.family<void, String>((
  ref,
  teacherId,
) async {
  final repository = ref.watch(teachersRepositoryProvider);
  await repository.deleteTeacher(teacherId);
  await ref.read(cacheStoreProvider).clean();
  ref.read(teachersRefreshTriggerProvider.notifier).state++;
  ref.invalidate(teachersProvider);
});
