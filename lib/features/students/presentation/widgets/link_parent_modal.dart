import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../parents/presentation/providers/parents_provider.dart';
import '../providers/students_provider.dart';

Future<void> showLinkParentModal(
  BuildContext context, {
  required String studentId,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => LinkParentModal(studentId: studentId),
  );
}

class LinkParentModal extends ConsumerStatefulWidget {
  final String studentId;

  const LinkParentModal({super.key, required this.studentId});

  @override
  ConsumerState<LinkParentModal> createState() => _LinkParentModalState();
}

class _LinkParentModalState extends ConsumerState<LinkParentModal> {
  String? _selectedParentId;
  String _relationship = 'father';
  bool _isPrimary = false;
  bool _isSubmitting = false;
  String? _error;

  static const _relationships = [
    ('father', 'Ayah'),
    ('mother', 'Ibu'),
    ('guardian', 'Wali'),
    ('other', 'Lainnya'),
  ];

  @override
  Widget build(BuildContext context) {
    final parentsAsync = ref.watch(parentsProvider);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tambah Orang Tua',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.neutral900,
                      ),
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
              Text(
                'Pilih Orang Tua',
                style: AppTextStyles.label.copyWith(color: AppColors.neutral700),
              ),
              const SizedBox(height: AppSpacing.xs),
              parentsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text(
                  e.toString(),
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.error),
                ),
                data: (paginated) {
                  final parents = paginated.items;
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedParentId,
                    hint: Text(
                      'Cari & pilih orang tua...',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.neutral300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.neutral300),
                      ),
                    ),
                    items: parents
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.parentId,
                            child: Text(
                              '${p.name} — ${p.email}',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.neutral900,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedParentId = value);
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Hubungan',
                style: AppTextStyles.label.copyWith(color: AppColors.neutral700),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                children: _relationships.map((r) {
                  final selected = _relationship == r.$1;
                  return GestureDetector(
                    onTap: () => setState(() => _relationship = r.$1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary700
                            : AppColors.neutral100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        r.$2,
                        style: AppTextStyles.bodySm.copyWith(
                          color: selected
                              ? AppColors.white
                              : AppColors.neutral700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Checkbox(
                    value: _isPrimary,
                    activeColor: AppColors.primary700,
                    onChanged: (v) => setState(() => _isPrimary = v ?? false),
                  ),
                  Text(
                    'Jadikan kontak utama',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.neutral700,
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _error!,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: 'Batal',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton.primary(
                      label: _isSubmitting ? 'Menyimpan...' : 'Tambahkan',
                      onPressed: _selectedParentId == null || _isSubmitting
                          ? null
                          : _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_selectedParentId == null) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await ref.read(linkParentProvider((
        studentId: widget.studentId,
        parentId: _selectedParentId!,
        relationship: _relationship,
        isPrimary: _isPrimary,
      )).future);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _error = e.toString();
      });
    }
  }
}
