import '../datasources/attendance_remote_data_source.dart';

class AttendanceRepositoryImpl {
  final AttendanceRemoteDataSource _ds;
  AttendanceRepositoryImpl(this._ds);

  Future<String> getQRToken(String scheduleId) => _ds.getQRToken(scheduleId);

  Future<Map<String, dynamic>> scanQR(String token) => _ds.scanQR(token);
}
