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
  return AdminsRepositoryImpl(AdminsRemoteDataSource(dio));
});

final adminsCurrentPageProvider = StateProvider<int>((ref) => 1);

final adminsSearchQueryProvider = StateProvider<String>((ref) => '');

final adminsProvider = FutureProvider.autoDispose<Paginated<AdminRowData>>((
  ref,
) async {
  final repository = ref.watch(adminsRepositoryProvider);
  final page = ref.watch(adminsCurrentPageProvider);
  final query = ref.watch(adminsSearchQueryProvider);
  final user = ref.watch(currentUserProvider);
  final activeSchool = ref.watch(activeSchoolProvider);

  final schoolId = switch (user?.role) {
    UserRole.superadmin => activeSchool?.id,
    _ => user?.schoolId,
  };

  return repository.getAdmins(
    page: page,
    perPage: AdminsScreenConstants.rowsPerPage,
    query: query.isNotEmpty ? query : null,
    schoolId: schoolId,
  );
});

final createAdminProvider = FutureProvider.autoDispose
    .family<AdminRowData, Map<String, dynamic>>((ref, data) async {
      final repository = ref.watch(adminsRepositoryProvider);
      final admin = await repository.createAdmin(data);
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
      ref.invalidate(adminsProvider);
      return admin;
    });

final deleteAdminProvider = FutureProvider.autoDispose.family<void, String>((
  ref,
  adminId,
) async {
  final repository = ref.watch(adminsRepositoryProvider);
  await repository.deleteAdmin(adminId);
  ref.invalidate(adminsProvider);
});
