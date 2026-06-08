import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/providers/active_school_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../features/dashboard/domain/entities/dashboard_school.dart';
import '../../../../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../providers/admins_provider.dart';

Future<void> showAdminCreateModal(BuildContext context, WidgetRef ref) {
  return showDialog<void>(
    context: context,
    builder: (_) => AdminCreateModal(ref: ref),
  );
}

class AdminCreateModal extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const AdminCreateModal({super.key, required this.ref});

  @override
  ConsumerState<AdminCreateModal> createState() => _AdminCreateModalState();
}

class _AdminCreateModalState extends ConsumerState<AdminCreateModal> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _genderCtrl;
  late final TextEditingController _religionCtrl;
  late final TextEditingController _birthPlaceCtrl;
  late final TextEditingController _birthDateCtrl;
  late final TextEditingController _nikCtrl;
  late final TextEditingController _ktpImagePathCtrl;
  bool _isLoading = false;
  String? _selectedSchoolId;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _usernameCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _genderCtrl = TextEditingController();
    _religionCtrl = TextEditingController();
    _birthPlaceCtrl = TextEditingController();
    _birthDateCtrl = TextEditingController();
    _nikCtrl = TextEditingController();
    _ktpImagePathCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _genderCtrl.dispose();
    _religionCtrl.dispose();
    _birthPlaceCtrl.dispose();
    _birthDateCtrl.dispose();
    _nikCtrl.dispose();
    _ktpImagePathCtrl.dispose();
    super.dispose();
  }

  String _requiredLabel(String label) => '$label *';

    static const List<({String label, String value})> _genderOptions = [
    (label: 'Laki-laki', value: 'male'),
    (label: 'Perempuan', value: 'female'),
    (label: 'Lainnya', value: 'other'),
  ];

  Future<void> _pickBirthDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selected == null) return;
    setState(() {
      _birthDateCtrl.text =
          '${selected.year.toString().padLeft(4, '0')}-'
          '${selected.month.toString().padLeft(2, '0')}-'
          '${selected.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _saveAdmin() async {
    final user = ref.read(currentUserProvider);
    final activeSchool = ref.read(activeSchoolProvider);
    final isSuperadmin = user?.role == UserRole.superadmin;
    final effectiveSchoolId = activeSchool?.id ?? _selectedSchoolId;

    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama dan email wajib diisi')),
        );
      }
      return;
    }

    if (isSuperadmin && effectiveSchoolId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih sekolah terlebih dahulu'),
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'username': _usernameCtrl.text.trim().isEmpty
            ? null
            : _usernameCtrl.text.trim(),
        'password': _passwordCtrl.text.isEmpty ? null : _passwordCtrl.text,
        'phone_number': _phoneCtrl.text.trim().isEmpty
            ? null
            : _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim().isEmpty
            ? null
            : _addressCtrl.text.trim(),
        'gender': _selectedGender,
        'religion': _religionCtrl.text.trim().isEmpty
            ? null
            : _religionCtrl.text.trim(),
        'birth_place': _birthPlaceCtrl.text.trim().isEmpty
            ? null
            : _birthPlaceCtrl.text.trim(),
        'birth_date': _birthDateCtrl.text.trim().isEmpty
            ? null
            : _birthDateCtrl.text.trim(),
        'nik': _nikCtrl.text.trim().isEmpty ? null : _nikCtrl.text.trim(),
        'ktp_image_path': _ktpImagePathCtrl.text.trim().isEmpty
            ? null
            : _ktpImagePathCtrl.text.trim(),
      };

      if (isSuperadmin && effectiveSchoolId != null) {
        data['school_id'] = effectiveSchoolId;
      }

      final admin = await ref.read(createAdminProvider(data).future);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${admin.name} berhasil ditambahkan')),
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
    final isSuperadmin = user?.role == UserRole.superadmin;
    final needsSchoolPicker = isSuperadmin && activeSchool == null;
    final schools = needsSchoolPicker
        ? (ref.watch(dashboardSchoolsProvider).valueOrNull ??
              <DashboardSchool>[])
        : <DashboardSchool>[];

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
                          'Tambah Admin Baru',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          isSuperadmin && activeSchool != null
                              ? 'Admin akan dibuat untuk ${activeSchool.name}.'
                              : 'Data akan dikirim langsung ke backend Admin12.',
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
                  borderRadius: AppRadius.xlAll,
                  border: Border.all(color: AppColors.neutral100),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final oneColumn = constraints.maxWidth < 620;
                    final fieldWidth = oneColumn
                        ? constraints.maxWidth
                        : (constraints.maxWidth - AppSpacing.md) / 2;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (needsSchoolPicker) ...[
                          AppDropdown<String?>(
                            label: 'Sekolah *',
                            hint: 'Pilih sekolah untuk admin ini',
                            value: _selectedSchoolId,
                            items: schools
                                .map(
                                  (school) => AppDropdownItem<String?>(
                                    value: school.id,
                                    label: school.name,
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedSchoolId = value),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.md,
                          children: [
                            SizedBox(
                              width: fieldWidth,
                              child: AppTextField(
                                label: _requiredLabel('Nama'),
                                hint: 'Masukkan nama admin',
                                controller: _nameCtrl,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: AppTextField(
                                label: _requiredLabel('Email'),
                                hint: 'Masukkan email',
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: AppTextField(
                                label: _requiredLabel('Username'),
                                hint:
                                    'masukan username',
                                controller: _usernameCtrl,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: AppTextField.password(
                                label: 'Password',
                                controller: _passwordCtrl,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: AppTextField(
                                label: 'Phone Number',
                                hint: 'Masukkan nomor telepon',
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: AppTextField(
                                label: 'Address',
                                hint: 'Masukkan alamat',
                                controller: _addressCtrl,
                                keyboardType: TextInputType.streetAddress,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: AppDropdown<String?>(
                                label: 'Jenis Kelamin',
                                hint: 'Pilih jenis kelamin',
                                value: _selectedGender,
                                items: _genderOptions.map((o) => AppDropdownItem<String?>(value: o.value, label: o.label)).toList(),
                                onChanged: (v) => setState(() => _selectedGender = v),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: AppTextField(
                                label: 'Agama',
                                hint: 'Masukkan agama',
                                controller: _religionCtrl,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: AppTextField(
                                label: 'Tempat Lahir',
                                hint: 'Masukkan tempat lahir',
                                controller: _birthPlaceCtrl,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: AppTextField(
                               label: 'Tanggal Lahir',
                            hint: 'YYYY-MM-DD',
                            controller: _birthDateCtrl,
                            readOnly: true,
                            onTap: _pickBirthDate,
                            suffix: IconButton(onPressed: _pickBirthDate, icon: const Icon(Icons.calendar_month_outlined), color: AppColors.neutral500),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: AppTextField(
                                label: 'NIK',
                                hint: 'Masukkan NIK',
                                controller: _nikCtrl,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: AppTextField(
                                label: 'Foto KTP',
                                hint: 'Unggah foto KTP',
                                controller: _ktpImagePathCtrl,
                              ),
                            ),
                          ],
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
                    label: _isLoading ? 'Menyimpan...' : 'Simpan Admin',
                    onPressed: _isLoading ? null : _saveAdmin,
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
