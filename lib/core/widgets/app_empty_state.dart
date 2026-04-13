import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// Empty state placeholder — used when a list has no data.
///
/// ```dart
/// AppEmptyState(message: 'Belum ada data siswa')
/// AppEmptyState(
///   message: 'Belum ada ujian aktif',
///   ctaLabel: 'Buat Ujian',
///   onCta: () => context.push('/cbt/create'),
/// )
/// ```
class AppEmptyState extends StatelessWidget {
  final String message;
  final String? subtitle;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final IconData icon;

  const AppEmptyState({
    super.key,
    required this.message,
    this.subtitle,
    this.ctaLabel,
    this.onCta,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.neutral100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.neutral300, size: 36),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: AppTextStyles.h4.copyWith(color: AppColors.neutral700),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style:
                    AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
                textAlign: TextAlign.center,
              ),
            ],
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(label: ctaLabel!, onPressed: onCta),
            ],
          ],
        ),
      ),
    );
  }
}
