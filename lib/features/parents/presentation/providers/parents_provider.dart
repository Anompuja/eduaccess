import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/paginated.dart';
import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/providers/active_school_provider.dart';
import '../../data/datasources/parents_remote_data_source.dart';
import '../../data/repositories/parents_repository_impl.dart';
import '../../domain/entities/parent_entity.dart';
import '../constants/parents_screen_constants.dart';

// ── Repository Provider ──────────────────────────────────────────────────────
final parentsRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  final remoteDataSource = ParentsRemoteDataSource(dio);
  return ParentsRepositoryImpl(remoteDataSource);
});

// ── State Providers ───────────────────────────────────────────────────────────
final parentsCurrentPageProvider = StateProvider<int>((ref) => 1);

final parentsSearchQueryProvider = StateProvider<String>((ref) => '');

// ── Fetch Parents ────────────────────────────────────────────────────────────
// Backend scoping rules:
//   - admin_sekolah & scoped roles: backend filters by JWT school_id (sending school_id is ignored)
//   - superadmin: backend filters by ?school_id if provided, else returns all schools (aggregate view)
// Frontend reads activeSchoolProvider for superadmin's chosen filter.
final parentsProvider = FutureProvider.autoDispose<Paginated<ParentEntity>>((
  ref,
) async {
  final repository = ref.watch(parentsRepositoryProvider);
  final page = ref.watch(parentsCurrentPageProvider);
  final query = ref.watch(parentsSearchQueryProvider);
  final user = ref.watch(currentUserProvider);
  final activeSchool = ref.watch(activeSchoolProvider);

  String? schoolId;
  if (user?.role == UserRole.superadmin) {
    schoolId = activeSchool?.id; // null = Semua Sekolah
  }

  return await repository.getParents(
    page: page,
    perPage: ParentsScreenConstants.rowsPerPage,
    query: query.isNotEmpty ? query : null,
    schoolId: schoolId,
  );
});

// ── Create Parent ────────────────────────────────────────────────────────────
final createParentProvider = FutureProvider.autoDispose
    .family<ParentEntity, Map<String, dynamic>>((ref, data) async {
      final repository = ref.watch(parentsRepositoryProvider);
      final parent = await repository.createParent(data);
      ref.invalidate(parentsProvider);
      return parent;
    });

// ── Update Parent ────────────────────────────────────────────────────────────
final updateParentProvider = FutureProvider.autoDispose
    .family<ParentEntity, ({String id, Map<String, dynamic> data})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(parentsRepositoryProvider);
      final parent = await repository.updateParent(params.id, params.data);
      ref.invalidate(parentsProvider);
      return parent;
    });

// ── Delete Parent ────────────────────────────────────────────────────────────
final deleteParentProvider = FutureProvider.autoDispose.family<void, String>((
  ref,
  parentId,
) async {
  final repository = ref.watch(parentsRepositoryProvider);
  await repository.deleteParent(parentId);
  ref.invalidate(parentsProvider);
});
