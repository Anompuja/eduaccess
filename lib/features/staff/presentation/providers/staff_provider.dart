import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/paginated.dart';
import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/providers/active_school_provider.dart';
import '../../data/datasources/staff_remote_data_source.dart';
import '../../data/models/staff_row_data.dart';
import '../../data/repositories/staff_repository_impl.dart';
import '../constants/staff_screen_constants.dart';

final staffRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  final staffListCacheOptions = ref.watch(staffListCacheOptionsProvider);
  final nonCacheableRequestOptions = ref.watch(
    nonCacheableRequestOptionsProvider,
  );
  return StaffRepositoryImpl(
    StaffRemoteDataSource(
      dio,
      staffListCacheOptions: staffListCacheOptions,
      bypassCacheOptions: nonCacheableRequestOptions,
    ),
  );
});

final staffCurrentPageProvider = StateProvider<int>((ref) => 1);

final staffSearchQueryProvider = StateProvider<String>((ref) => '');

final staffRefreshTriggerProvider = StateProvider<int>((ref) => 0);

final staffProvider = FutureProvider.autoDispose<Paginated<StaffRowData>>((
  ref,
) async {
  final repository = ref.watch(staffRepositoryProvider);
  final page = ref.watch(staffCurrentPageProvider);
  final query = ref.watch(staffSearchQueryProvider);
  final user = ref.watch(currentUserProvider);
  final activeSchool = ref.watch(activeSchoolProvider);
  final refreshTrigger = ref.watch(staffRefreshTriggerProvider);

  final schoolId = switch (user?.role) {
    UserRole.superadmin => activeSchool?.id,
    _ => user?.schoolId,
  };

  return repository.getStaffs(
    page: page,
    perPage: StaffScreenConstants.rowsPerPage,
    query: query.isNotEmpty ? query : null,
    schoolId: schoolId,
    refreshTrigger: refreshTrigger > 0 ? refreshTrigger : null,
  );
});

final createStaffProvider = FutureProvider.autoDispose
    .family<StaffRowData, Map<String, dynamic>>((ref, data) async {
      final repository = ref.watch(staffRepositoryProvider);
      final staff = await repository.createStaff(data);
      await ref.read(cacheStoreProvider).clean();
      ref.read(staffRefreshTriggerProvider.notifier).state++;
      ref.invalidate(staffProvider);
      return staff;
    });

final updateStaffProvider = FutureProvider.autoDispose
    .family<StaffRowData, ({String id, Map<String, dynamic> data})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(staffRepositoryProvider);
      final staff = await repository.updateStaff(params.id, params.data);
      await ref.read(cacheStoreProvider).clean();
      ref.read(staffRefreshTriggerProvider.notifier).state++;
      ref.invalidate(staffProvider);
      return staff;
    });

final deleteStaffProvider = FutureProvider.autoDispose.family<void, String>((
  ref,
  staffId,
) async {
  final repository = ref.watch(staffRepositoryProvider);
  await repository.deleteStaff(staffId);
  await ref.read(cacheStoreProvider).clean();
  ref.read(staffRefreshTriggerProvider.notifier).state++;
  ref.invalidate(staffProvider);
});
