import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../data/datasources/students_remote_data_source.dart';
import '../../data/repositories/students_repository_impl.dart';

final studentsRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return StudentsRepositoryImpl(StudentsRemoteDataSource(dio));
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
