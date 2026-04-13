import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum BadgeStatus { success, error, warning, info, active, muted }

/// EduAccess status pill badge.
///
/// ```dart
/// AppBadge(label: 'Hadir', status: BadgeStatus.success)
/// AppBadge(label: 'Absen', status: BadgeStatus.error)
/// AppBadge(label: 'Berlangsung', status: BadgeStatus.active)
/// AppBadge(label: 'Terlambat', status: BadgeStatus.warning)
/// AppBadge(label: 'Pending', status: BadgeStatus.muted)
/// ```
class AppBadge extends StatelessWidget {
  final String label;
  final BadgeStatus status;

  const AppBadge({
    super.key,
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = _config(status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: cfg.fg,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  ({Color bg, Color fg}) _config(BadgeStatus s) => switch (s) {
        BadgeStatus.success => (
            bg: AppColors.success.withValues(alpha: 0.15),
            fg: AppColors.success
          ),
        BadgeStatus.error => (
            bg: AppColors.error.withValues(alpha: 0.15),
            fg: AppColors.error
          ),
        BadgeStatus.warning => (
            bg: AppColors.warning.withValues(alpha: 0.15),
            fg: AppColors.warning
          ),
        BadgeStatus.info => (
            bg: AppColors.info.withValues(alpha: 0.15),
            fg: AppColors.info
          ),
        BadgeStatus.active => (
            bg: AppColors.primary100,
            fg: AppColors.primary700
          ),
        BadgeStatus.muted => (
            bg: AppColors.neutral100,
            fg: AppColors.neutral500
          ),
      };
}
