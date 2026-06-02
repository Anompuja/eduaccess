import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/dashboard/domain/entities/dashboard_school.dart';

/// Global provider untuk school aktif (saat ini dipilih oleh superadmin).
///
/// Null = belum ada school yang dipilih (superadmin only).
/// Non-null = school yang sedang aktif, digunakan oleh semua page school-scoped.
final activeSchoolProvider = StateProvider<DashboardSchool?>((ref) => null);
