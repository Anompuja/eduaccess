import '../../../../core/api/paginated.dart';
import '../datasources/headmasters_remote_data_source.dart';
import '../models/headmaster_row_data.dart';

class HeadmastersRepositoryImpl {
  final HeadmastersRemoteDataSource _remoteDataSource;

  HeadmastersRepositoryImpl(this._remoteDataSource);

  Future<Paginated<HeadmasterRowData>> getHeadmasters({
    required int page,
    int perPage = 10,
    String? query,
    String? schoolId,
    int? refreshTrigger,
  }) {
    return _remoteDataSource.getHeadmasters(
      page: page,
      perPage: perPage,
      query: query,
      schoolId: schoolId,
      refreshTrigger: refreshTrigger,
    );
  }

  Future<HeadmasterRowData> createHeadmaster(Map<String, dynamic> data) {
    return _remoteDataSource.createHeadmaster(data);
  }

  Future<HeadmasterRowData> updateHeadmaster(
    String id,
    Map<String, dynamic> data,
  ) {
    return _remoteDataSource.updateHeadmaster(id, data);
  }

  Future<void> deleteHeadmaster(String id) {
    return _remoteDataSource.deleteHeadmaster(id);
  }
}
