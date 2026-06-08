import '../../../../core/api/paginated.dart';
import '../datasources/admins_remote_data_source.dart';
import '../models/admin_row_data.dart';

class AdminsRepositoryImpl {
  final AdminsRemoteDataSource _remoteDataSource;

  AdminsRepositoryImpl(this._remoteDataSource);

  Future<Paginated<AdminRowData>> getAdmins({
    required int page,
    int perPage = 10,
    String? query,
    String? schoolId,
    int? refreshTrigger,
  }) {
    return _remoteDataSource.getAdmins(
      page: page,
      perPage: perPage,
      query: query,
      schoolId: schoolId,
      refreshTrigger: refreshTrigger,
    );
  }

  Future<AdminRowData> createAdmin(Map<String, dynamic> data) {
    return _remoteDataSource.createAdmin(data);
  }

  Future<AdminRowData> updateAdmin(String id, Map<String, dynamic> data) {
    return _remoteDataSource.updateAdmin(id, data);
  }

  Future<void> deleteAdmin(String id) {
    return _remoteDataSource.deleteAdmin(id);
  }
}
