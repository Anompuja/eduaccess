import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/staff_row_data.dart';
import '../providers/staff_provider.dart';

Future<void> showStaffDeleteModal(
  BuildContext context, {
  required WidgetRef ref,
  required StaffRowData data,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => StaffDeleteModal(ref: ref, data: data),
  );
}

class StaffDeleteModal extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final StaffRowData data;

  const StaffDeleteModal({super.key, required this.ref, required this.data});

  @override
  ConsumerState<StaffDeleteModal> createState() => _StaffDeleteModalState();
}

class _StaffDeleteModalState extends ConsumerState<StaffDeleteModal> {
  bool _isLoading = false;

  Future<void> _deleteStaff() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(deleteStaffProvider(widget.data.staffId).future);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data staff berhasil dihapus')),
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
                          'Hapus Data Staff?',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Data akan dihapus lewat endpoint backend Staff.',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
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
                      'Staff yang dipilih',
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
                      widget.data.username.isEmpty
                          ? widget.data.email
                          : 'Username: ${widget.data.username} • Email: ${widget.data.email}',
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
                    onPressed: _isLoading ? null : _deleteStaff,
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
