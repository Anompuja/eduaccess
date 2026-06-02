import '../../../../core/api/paginated.dart';
import '../../domain/entities/parent_entity.dart';
import '../../domain/repositories/parents_repository.dart';
import '../datasources/parents_remote_data_source.dart';

class ParentsRepositoryImpl implements ParentsRepository {
  final ParentsRemoteDataSource _remoteDataSource;

  ParentsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Paginated<ParentEntity>> getParents({
    required int page,
    int perPage = 20,
    String? query,
    String? schoolId,
  }) async {
    final page$ = await _remoteDataSource.getParents(
      page: page,
      perPage: perPage,
      query: query,
      schoolId: schoolId,
    );
    return Paginated<ParentEntity>(
      items: page$.items.cast<ParentEntity>(),
      page: page$.page,
      perPage: page$.perPage,
      total: page$.total,
      totalPages: page$.totalPages,
    );
  }

  @override
  Future<ParentEntity> createParent(Map<String, dynamic> data) async {
    return await _remoteDataSource.createParent(data);
  }

  @override
  Future<ParentEntity> updateParent(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await _remoteDataSource.updateParent(id, data);
  }

  @override
  Future<void> deleteParent(String id) async {
    return await _remoteDataSource.deleteParent(id);
  }
}
