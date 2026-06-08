import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduaccess/core/api/api_client.dart';
import '../../data/datasources/attendance_remote_data_source.dart';
import '../../data/repositories/attendance_repository_impl.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepositoryImpl>((ref) {
  return AttendanceRepositoryImpl(AttendanceRemoteDataSource(ref.watch(dioProvider)));
});

/// Fetches the current 30-second QR token for a class session.
/// Invalidate to trigger a refresh.
final qrTokenProvider = FutureProvider.autoDispose.family<String, String>((ref, scheduleId) async {
  return ref.watch(attendanceRepositoryProvider).getQRToken(scheduleId);
});

/// Submits a QR token to mark attendance.
/// Result map contains {status, message} from the backend.
final scanQRProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, token) async {
  return ref.watch(attendanceRepositoryProvider).scanQR(token);
});
