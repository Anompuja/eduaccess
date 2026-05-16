import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/parent_entity.dart';
import '../providers/parents_provider.dart';

Future<void> showParentEditModal(
  BuildContext context, {
  required ParentEntity data,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => ParentEditModal(data: data),
  );
}

class ParentEditModal extends ConsumerStatefulWidget {
  final ParentEntity data;

  const ParentEditModal({super.key, required this.data});

  @override
  ConsumerState<ParentEditModal> createState() => _ParentEditModalState();
}

class _ParentEditModalState extends ConsumerState<ParentEditModal> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.data.name);
    _emailCtrl = TextEditingController(text: widget.data.email);
    _phoneCtrl = TextEditingController(text: widget.data.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveParent() async {
    if (_nameCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan isi semua field')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = {
        'name': _nameCtrl.text,
        'email': _emailCtrl.text,
        'phone': _phoneCtrl.text,
      };

      await ref.read(
        updateParentProvider((id: widget.data.parentId, data: data)).future,
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data orang tua berhasil diperbarui')),
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
        constraints: const BoxConstraints(maxWidth: 760),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Data Orang Tua',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Ubah data orang tua di form berikut dan simpan perubahan.',
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
                  borderRadius: AppRadius.xlAll,
                  border: Border.all(color: AppColors.neutral100),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final oneColumn = constraints.maxWidth < 620;
                    final fieldWidth = oneColumn
                        ? constraints.maxWidth
                        : (constraints.maxWidth - AppSpacing.md) / 2;

                    return Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: [
                        SizedBox(
                          width: fieldWidth,
                          child: AppTextField(
                            label: 'Nama Orang Tua',
                            hint: 'Masukkan nama orang tua',
                            controller: _nameCtrl,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: AppTextField(
                            label: 'Email',
                            hint: 'Masukkan email',
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: AppTextField(
                            label: 'No. Telepon',
                            hint: 'Masukkan nomor telepon',
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    );
                  },
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
                  AppButton.primary(
                    label: _isLoading ? 'Menyimpan...' : 'Simpan Perubahan',
                    onPressed: _isLoading ? null : _saveParent,
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
