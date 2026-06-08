import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/paginated.dart';
import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/providers/active_school_provider.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../academic/presentation/providers/academic_providers.dart';
import '../../../class_schedule/presentation/providers/class_schedule_providers.dart';
import '../../data/datasources/students_remote_data_source.dart';
import '../../data/models/student_row_data.dart';
import '../../data/repositories/students_repository_impl.dart';
import '../constants/students_screen_constants.dart';

final studentsRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  final studentListCacheOptions = ref.watch(studentListCacheOptionsProvider);
  final nonCacheableRequestOptions = ref.watch(nonCacheableRequestOptionsProvider);
  return StudentsRepositoryImpl(
    StudentsRemoteDataSource(
      dio,
      studentListCacheOptions: studentListCacheOptions,
      bypassCacheOptions: nonCacheableRequestOptions,
    ),
  );
});

final schoolStudentCountProvider = FutureProvider.autoDispose
    .family<int, ({String schoolId, bool includeSchoolIdQuery})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(studentsRepositoryProvider);
      return repository.getStudentCount(
        schoolId: params.includeSchoolIdQuery ? params.schoolId : '',
      );
    });

final studentsCurrentPageProvider = StateProvider<int>((ref) => 1);

final studentsSearchQueryProvider = StateProvider<String>((ref) => '');

final studentsRefreshTriggerProvider = StateProvider<int>((ref) => 0);

// These are for dropdown filters in the UI
final studentsLevelFilterProvider = StateProvider<String?>((ref) => null);
final studentsClassFilterProvider = StateProvider<String?>((ref) => null);
final studentsSubClassFilterProvider = StateProvider<String?>((ref) => null);

/// Returns the sub-class IDs of classrooms this teacher teaches in.
/// Flow: class_schedules(teacher_id) → classroom_ids → school_classrooms.sub_class_id
/// Empty set for non-guru roles or when data is unavailable.
final teacherSubClassIdsProvider = FutureProvider.autoDispose<Set<String>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user?.role != UserRole.guru) return {};

  final schedules = await ref.watch(
    classSchedulesProvider(ClassScheduleFilter(teacherId: user!.id)).future,
  );
  final classroomIds = schedules.map((s) => s.classroomId).toSet();
  if (classroomIds.isEmpty) return {};

  // Cross-reference with classrooms to get sub_class_id
  final classrooms = await ref.watch(
    classroomsBySchoolProvider(user.schoolId).future,
  );
  return classrooms
      .where((c) => classroomIds.contains(c.id) && c.subClassId != null)
      .map((c) => c.subClassId!)
      .toSet();
});

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
    _ => null,
  };

  // For guru: restrict to sub-classes they teach. Auto-select first sub-class
  // when no filter is active, so they never see the full school roster.
  String? effectiveSubClassId = subClassFilter;
  if (user?.role == UserRole.guru) {
    final teacherSubClassIds = await ref.watch(
      teacherSubClassIdsProvider.future,
    );
    if (effectiveSubClassId == null ||
        !teacherSubClassIds.contains(effectiveSubClassId)) {
      effectiveSubClassId = teacherSubClassIds.isNotEmpty
          ? teacherSubClassIds.first
          : null;
    }
  }

  return repository.getStudents(
    page: page,
    perPage: StudentsScreenConstants.rowsPerPage,
    query: query.isNotEmpty ? query : null,
    schoolId: schoolId,
    educationLevelId: levelFilter,
    classId: classFilter,
    subClassId: effectiveSubClassId,
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
      ref.invalidate(currentSchoolSubscriptionOverviewProvider);

      final requestedSchoolId = (data['school_id'] as String?)?.trim() ?? '';
      final targetSchoolId = requestedSchoolId.isNotEmpty
          ? requestedSchoolId
          : student.schoolId.trim();
      if (targetSchoolId.isNotEmpty) {
        ref.invalidate(
          schoolStudentCountProvider((
            schoolId: targetSchoolId,
            includeSchoolIdQuery: requestedSchoolId.isNotEmpty,
          )),
        );
        ref.invalidate(schoolSubscriptionProvider(targetSchoolId));
        ref.invalidate(
          schoolSubscriptionOverviewProvider((
            schoolId: targetSchoolId,
            includeSchoolIdQuery: requestedSchoolId.isNotEmpty,
          )),
        );
      }
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

  final currentSchoolId = ref.read(currentSubscriptionSchoolIdProvider);
  final currentUser = ref.read(currentUserProvider);
  ref.invalidate(currentSchoolSubscriptionOverviewProvider);
  if (currentSchoolId != null && currentSchoolId.isNotEmpty) {
    ref.invalidate(
      schoolStudentCountProvider((
        schoolId: currentSchoolId,
        includeSchoolIdQuery: currentUser?.role == UserRole.superadmin,
      )),
    );
    ref.invalidate(schoolSubscriptionProvider(currentSchoolId));
    ref.invalidate(
      schoolSubscriptionOverviewProvider((
        schoolId: currentSchoolId,
        includeSchoolIdQuery: currentUser?.role == UserRole.superadmin,
      )),
    );
  }
});
