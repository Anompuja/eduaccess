import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/paginated.dart';
import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/providers/active_school_provider.dart';
import '../../data/datasources/headmasters_remote_data_source.dart';
import '../../data/models/headmaster_row_data.dart';
import '../../data/repositories/headmasters_repository_impl.dart';
import '../constants/headmasters_screen_constants.dart';

final headmastersRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return HeadmastersRepositoryImpl(HeadmastersRemoteDataSource(dio));
});

final headmastersCurrentPageProvider = StateProvider<int>((ref) => 1);

final headmastersSearchQueryProvider = StateProvider<String>((ref) => '');

final headmastersProvider =
    FutureProvider.autoDispose<Paginated<HeadmasterRowData>>((ref) async {
      final repository = ref.watch(headmastersRepositoryProvider);
      final page = ref.watch(headmastersCurrentPageProvider);
      final query = ref.watch(headmastersSearchQueryProvider);
      final user = ref.watch(currentUserProvider);
      final activeSchool = ref.watch(activeSchoolProvider);

      final schoolId = switch (user?.role) {
        UserRole.superadmin => activeSchool?.id,
        _ => user?.schoolId,
      };

      return repository.getHeadmasters(
        page: page,
        perPage: HeadmastersScreenConstants.rowsPerPage,
        query: query.isNotEmpty ? query : null,
        schoolId: schoolId,
      );
    });

final createHeadmasterProvider = FutureProvider.autoDispose
    .family<HeadmasterRowData, Map<String, dynamic>>((ref, data) async {
      final repository = ref.watch(headmastersRepositoryProvider);
      final headmaster = await repository.createHeadmaster(data);
      ref.invalidate(headmastersProvider);
      return headmaster;
    });

final updateHeadmasterProvider = FutureProvider.autoDispose
    .family<HeadmasterRowData, ({String id, Map<String, dynamic> data})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(headmastersRepositoryProvider);
      final headmaster = await repository.updateHeadmaster(
        params.id,
        params.data,
      );
      ref.invalidate(headmastersProvider);
      return headmaster;
    });

final deleteHeadmasterProvider = FutureProvider.autoDispose
    .family<void, String>((ref, headmasterId) async {
      final repository = ref.watch(headmastersRepositoryProvider);
      await repository.deleteHeadmaster(headmasterId);
      ref.invalidate(headmastersProvider);
    });
