import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_notifier.dart';
import '../auth/auth_state.dart';
import '../providers/active_school_provider.dart';
import '../theme/app_colors.dart';
import '../../features/dashboard/domain/entities/dashboard_school.dart';
import '../../features/dashboard/presentation/providers/dashboard_provider.dart';
import 'app_dropdown.dart';

/// Universal school filter dropdown.
///
/// Reads/writes [activeSchoolProvider] — single source of truth for school
/// context across the app. Returns an empty widget for non-superadmin roles
/// (their school is fixed via JWT and cannot be switched).
///
/// Includes a "Semua Sekolah" option (value = null) that maps to the
/// aggregate / all-schools view. Backend endpoints handle null as aggregate
/// for parents list and dashboard stats.
class SchoolFilter extends ConsumerWidget {
  final String label;
  final String allLabel;

  const SchoolFilter({
    super.key,
    this.label = 'Sekolah',
    this.allLabel = 'Semua Sekolah',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user?.role != UserRole.superadmin) {
      return const SizedBox.shrink();
    }

    final schoolsAsync = ref.watch(dashboardSchoolsProvider);
    final activeSchool = ref.watch(activeSchoolProvider);

    return schoolsAsync.when(
      loading: () => const SizedBox(
        height: 72,
        child: Center(child: LinearProgressIndicator()),
      ),
      error: (err, _) => _SchoolFilterError(
        message: err.toString(),
        onRetry: () => ref.invalidate(dashboardSchoolsProvider),
      ),
      data: (schools) {
        if (schools.isEmpty) {
          return _SchoolFilterPlaceholder(label: label);
        }
        return AppDropdown<DashboardSchool?>(
          label: label,
          value: activeSchool,
          hint: allLabel,
          items: [
            AppDropdownItem<DashboardSchool?>(
              value: null,
              label: allLabel,
              leading: const Icon(
                Icons.public_rounded,
                size: 18,
                color: AppColors.neutral500,
              ),
            ),
            ...schools.map(
              (school) => AppDropdownItem<DashboardSchool?>(
                value: school,
                label: school.name,
                leading: Icon(
                  school.status == 'active'
                      ? Icons.apartment_rounded
                      : Icons.apartment_outlined,
                  size: 18,
                  color: AppColors.primary700,
                ),
              ),
            ),
          ],
          onChanged: (school) =>
              ref.read(activeSchoolProvider.notifier).state = school,
        );
      },
    );
  }
}

class _SchoolFilterError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SchoolFilterError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Gagal memuat sekolah: $message',
            style: const TextStyle(color: AppColors.error),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

class _SchoolFilterPlaceholder extends StatelessWidget {
  final String label;

  const _SchoolFilterPlaceholder({required this.label});

  @override
  Widget build(BuildContext context) {
    return AppDropdown<DashboardSchool?>(
      label: label,
      value: null,
      hint: 'Belum ada sekolah',
      items: const [],
      enabled: false,
      onChanged: null,
    );
  }
}
