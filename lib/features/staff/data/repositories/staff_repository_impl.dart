import '../../../../core/api/paginated.dart';
import '../datasources/staff_remote_data_source.dart';
import '../models/staff_row_data.dart';

class StaffRepositoryImpl {
  final StaffRemoteDataSource _remoteDataSource;

  StaffRepositoryImpl(this._remoteDataSource);

  Future<Paginated<StaffRowData>> getStaffs({
    required int page,
    int perPage = 10,
    String? query,
    String? schoolId,
    int? refreshTrigger,
  }) {
    return _remoteDataSource.getStaffs(
      page: page,
      perPage: perPage,
      query: query,
      schoolId: schoolId,
      refreshTrigger: refreshTrigger,
    );
  }

  Future<StaffRowData> createStaff(Map<String, dynamic> data) {
    return _remoteDataSource.createStaff(data);
  }

  Future<StaffRowData> updateStaff(String id, Map<String, dynamic> data) {
    return _remoteDataSource.updateStaff(id, data);
  }

  Future<void> deleteStaff(String id) {
    return _remoteDataSource.deleteStaff(id);
  }
}
