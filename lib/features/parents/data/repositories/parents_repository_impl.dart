import '../../domain/entities/parent_entity.dart';
import '../../domain/repositories/parents_repository.dart';
import '../datasources/parents_remote_data_source.dart';

class ParentsRepositoryImpl implements ParentsRepository {
  final ParentsRemoteDataSource _remoteDataSource;

  ParentsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ParentEntity>> getParents({
    required int page,
    String? query,
  }) async {
    final models = await _remoteDataSource.getParents(
      page: page,
      query: query,
    );
    return models.cast<ParentEntity>();
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
