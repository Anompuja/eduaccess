import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/teacher_row_data.dart';

Future<void> showTeacherDeleteModal(
  BuildContext context, {
  required TeacherRowData data,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => TeacherDeleteModal(data: data),
  );
}

class TeacherDeleteModal extends StatelessWidget {
  final TeacherRowData data;

  const TeacherDeleteModal({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: AppRadius.pillAll,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      size: 30,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hapus Data Guru?',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Aksi ini hanya tampilan UI. Data belum benar-benar dihapus.',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppColors.neutral700,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: AppRadius.lgAll,
                  border: Border.all(color: AppColors.neutral100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Guru yang dipilih',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.neutral500,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      data.name,
                      style: AppTextStyles.bodyLgSemiBold.copyWith(
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'NIP: ${data.nip} • Mapel: ${data.subject}',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.neutral700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton.secondary(
                    label: 'Batal',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppButton.danger(
                    label: 'Hapus',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
