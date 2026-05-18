import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/parent_entity.dart';
import '../providers/parents_provider.dart';

Future<void> showParentDeleteModal(
  BuildContext context, {
  required ParentEntity data,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => ParentDeleteModal(data: data),
  );
}

class ParentDeleteModal extends ConsumerStatefulWidget {
  final ParentEntity data;

  const ParentDeleteModal({super.key, required this.data});

  @override
  ConsumerState<ParentDeleteModal> createState() => _ParentDeleteModalState();
}

class _ParentDeleteModalState extends ConsumerState<ParentDeleteModal> {
  bool _isLoading = false;

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
                          'Hapus Data Orang Tua?',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Tindakan ini akan menghapus data orang tua secara permanen dan tidak dapat dibatalkan.',
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
                      'Orang tua yang dipilih',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.neutral500,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      widget.data.name,
                      style: AppTextStyles.bodyLgSemiBold.copyWith(
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.data.phoneNumber.isEmpty
                          ? widget.data.email
                          : 'No. HP: ${widget.data.phoneNumber}',
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
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppButton.danger(
                    label: _isLoading ? 'Menghapus...' : 'Hapus',
                    onPressed: _isLoading ? null : _deleteParent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteParent() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(deleteParentProvider(widget.data.parentId).future);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data orang tua berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
