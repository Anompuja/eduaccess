import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduaccess/core/api/api_client.dart';
import 'package:eduaccess/core/auth/auth_notifier.dart';
import 'package:eduaccess/core/auth/auth_state.dart';
import 'package:eduaccess/core/providers/active_school_provider.dart';
import '../../data/datasources/student_tracking_remote_datasource.dart';
import '../../data/repositories/student_tracking_repository_impl.dart';
import '../../domain/entities/student_study_entity.dart';
import '../../domain/repositories/student_tracking_repository.dart';

final studentTrackingRepositoryProvider = Provider<StudentTrackingRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return StudentTrackingRepositoryImpl(
    remoteDataSource: StudentTrackingRemoteDataSourceImpl(dio: dio),
  );
});

String? schoolIdForRequest(Ref ref) {
  final user = ref.watch(currentUserProvider);
  if (user?.role == UserRole.superadmin) {
    return ref.watch(activeSchoolProvider)?.id;
  }
  return null;
}

/// Current (active) enrollments — one row per student in their present class.
final studentStudiesProvider = FutureProvider.autoDispose<List<StudentStudyEntity>>((ref) async {
  return ref.watch(studentTrackingRepositoryProvider).getStudies(
    schoolId: schoolIdForRequest(ref),
    status: 'active',
  );
});

/// Full enrollment history for a single student.
final studentHistoryProvider = FutureProvider.autoDispose.family<List<StudentStudyEntity>, String>((ref, studentId) async {
  return ref.watch(studentTrackingRepositoryProvider).getStudentHistory(
    studentId,
    schoolId: schoolIdForRequest(ref),
  );
});

/// Active students currently enrolled in a given classroom (used by promotion).
final classroomStudentsProvider = FutureProvider.autoDispose.family<List<StudentStudyEntity>, String>((ref, classroomId) async {
  return ref.watch(studentTrackingRepositoryProvider).getStudies(
    schoolId: schoolIdForRequest(ref),
    classroomId: classroomId,
    status: 'active',
  );
});
