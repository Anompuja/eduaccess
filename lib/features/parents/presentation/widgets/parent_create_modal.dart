import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/providers/active_school_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/parents_provider.dart';

Future<void> showParentCreateModal(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const ParentCreateModal(),
  );
}

class ParentCreateModal extends ConsumerStatefulWidget {
  const ParentCreateModal({super.key});

  @override
  ConsumerState<ParentCreateModal> createState() => _ParentCreateModalState();
}

class _ParentCreateModalState extends ConsumerState<ParentCreateModal> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveParent() async {
    final user = ref.read(currentUserProvider);
    final activeSchool = ref.read(activeSchoolProvider);

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

    if (user?.role == UserRole.superadmin && activeSchool == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih sekolah aktif terlebih dahulu'),
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = {
        'name': _nameCtrl.text,
        'email': _emailCtrl.text,
        'phone_number': _phoneCtrl.text,
      };

      if (user?.role == UserRole.superadmin && activeSchool != null) {
        data['school_id'] = activeSchool.id;
      }

      await ref.read(createParentProvider(data).future);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Orang tua berhasil ditambahkan${user?.role == UserRole.superadmin && activeSchool != null ? ' untuk ${activeSchool.name}' : ''}',
            ),
          ),
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
    final user = ref.watch(currentUserProvider);
    final activeSchool = ref.watch(activeSchoolProvider);

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
                          'Tambah Orang Tua Baru',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          user?.role == UserRole.superadmin && activeSchool != null
                              ? 'Tambahkan orang tua untuk ${activeSchool.name}'
                              : 'Isi form berikut untuk menambah orang tua baru ke dalam sistem.',
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
                  AppButton.accent(
                    label: _isLoading ? 'Menyimpan...' : 'Simpan Orang Tua',
                    onPressed: _isLoading ||
                            (user?.role == UserRole.superadmin &&
                                activeSchool == null)
                        ? null
                        : _saveParent,
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
