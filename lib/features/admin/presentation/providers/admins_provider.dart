import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/paginated.dart';
import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/providers/active_school_provider.dart';
import '../../data/datasources/admins_remote_data_source.dart';
import '../../data/models/admin_row_data.dart';
import '../../data/repositories/admins_repository_impl.dart';
import '../constants/admins_screen_constants.dart';

final adminsRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  final adminListCacheOptions = ref.watch(adminListCacheOptionsProvider);
  final nonCacheableRequestOptions = ref.watch(
    nonCacheableRequestOptionsProvider,
  );
  return AdminsRepositoryImpl(
    AdminsRemoteDataSource(
      dio,
      adminListCacheOptions: adminListCacheOptions,
      bypassCacheOptions: nonCacheableRequestOptions,
    ),
  );
});

final adminsCurrentPageProvider = StateProvider<int>((ref) => 1);

final adminsSearchQueryProvider = StateProvider<String>((ref) => '');

final adminsRefreshTriggerProvider = StateProvider<int>((ref) => 0);

final adminsProvider = FutureProvider.autoDispose<Paginated<AdminRowData>>((
  ref,
) async {
  final repository = ref.watch(adminsRepositoryProvider);
  final page = ref.watch(adminsCurrentPageProvider);
  final query = ref.watch(adminsSearchQueryProvider);
  final user = ref.watch(currentUserProvider);
  final activeSchool = ref.watch(activeSchoolProvider);
  final refreshTrigger = ref.watch(adminsRefreshTriggerProvider);

  final schoolId = switch (user?.role) {
    UserRole.superadmin => activeSchool?.id,
    _ => user?.schoolId,
  };

  return repository.getAdmins(
    page: page,
    perPage: AdminsScreenConstants.rowsPerPage,
    query: query.isNotEmpty ? query : null,
    schoolId: schoolId,
    refreshTrigger: refreshTrigger > 0 ? refreshTrigger : null,
  );
});

final createAdminProvider = FutureProvider.autoDispose
    .family<AdminRowData, Map<String, dynamic>>((ref, data) async {
      final repository = ref.watch(adminsRepositoryProvider);
      final admin = await repository.createAdmin(data);
      await ref.read(cacheStoreProvider).clean();
      ref.read(adminsRefreshTriggerProvider.notifier).state++;
      ref.invalidate(adminsProvider);
      return admin;
    });

final updateAdminProvider = FutureProvider.autoDispose
    .family<AdminRowData, ({String id, Map<String, dynamic> data})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(adminsRepositoryProvider);
      final admin = await repository.updateAdmin(params.id, params.data);
      await ref.read(cacheStoreProvider).clean();
      ref.read(adminsRefreshTriggerProvider.notifier).state++;
      ref.invalidate(adminsProvider);
      return admin;
    });

final deleteAdminProvider = FutureProvider.autoDispose.family<void, String>((
  ref,
  adminId,
) async {
  final repository = ref.watch(adminsRepositoryProvider);
  await repository.deleteAdmin(adminId);
  await ref.read(cacheStoreProvider).clean();
  ref.read(adminsRefreshTriggerProvider.notifier).state++;
  ref.invalidate(adminsProvider);
});
