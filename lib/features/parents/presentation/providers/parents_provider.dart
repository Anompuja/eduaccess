import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../data/datasources/parents_remote_data_source.dart';
import '../../data/repositories/parents_repository_impl.dart';
import '../../domain/entities/parent_entity.dart';

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
// Backend scopes by JWT role:
//   - admin_sekolah & scoped roles: backend filters by JWT school_id
//   - superadmin: backend returns parents across all schools
// Frontend does not send school_id; backend ignores the query param anyway.
final parentsProvider = FutureProvider.autoDispose<List<ParentEntity>>((
  ref,
) async {
  final repository = ref.watch(parentsRepositoryProvider);
  final page = ref.watch(parentsCurrentPageProvider);
  final query = ref.watch(parentsSearchQueryProvider);

  return await repository.getParents(
    page: page,
    query: query.isNotEmpty ? query : null,
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
