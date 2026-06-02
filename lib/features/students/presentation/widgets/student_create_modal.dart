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
import '../../../../features/academic/presentation/providers/academic_providers.dart';
import '../../../../features/academic/domain/entities/education_level_entity.dart';
import '../../../../features/academic/domain/entities/class_entity.dart';
import '../../../../features/academic/domain/entities/sub_class_entity.dart';
import '../providers/students_provider.dart';

Future<void> showStudentCreateModal(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const StudentCreateModal(),
  );
}

class StudentCreateModal extends ConsumerStatefulWidget {
  const StudentCreateModal({super.key});

  @override
  ConsumerState<StudentCreateModal> createState() => _StudentCreateModalState();
}

class _StudentCreateModalState extends ConsumerState<StudentCreateModal> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _nisCtrl;
  late final TextEditingController _nisnCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _birthPlaceCtrl;
  late final TextEditingController _birthDateCtrl;
  late final TextEditingController _tahunMasukCtrl;

  bool _isLoading = false;
  String? _selectedSchoolId;
  String? _selectedEducationLevelId;
  String? _selectedClassId;
  String? _selectedSubClassId;
  
  String? _selectedGender;
  String? _selectedReligion;
  String? _selectedJalurMasuk;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _usernameCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _nisCtrl = TextEditingController();
    _nisnCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _birthPlaceCtrl = TextEditingController();
    _birthDateCtrl = TextEditingController();
    _tahunMasukCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _nisCtrl.dispose();
    _nisnCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _birthPlaceCtrl.dispose();
    _birthDateCtrl.dispose();
    _tahunMasukCtrl.dispose();
    super.dispose();
  }

  String _requiredLabel(String label) => '$label *';

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

  Future<void> _saveStudent() async {
    final user = ref.read(currentUserProvider);
    final activeSchool = ref.read(activeSchoolProvider);
    final isSuperadmin = user?.role == UserRole.superadmin;
    final effectiveSchoolId = activeSchool?.id ?? _selectedSchoolId;

    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _usernameCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nama, email, username, dan password wajib diisi'),
          ),
        );
      }
      return;
    }

    if (isSuperadmin && effectiveSchoolId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih sekolah terlebih dahulu')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'username': _usernameCtrl.text.trim(),
        'password': _passwordCtrl.text,
        'nis': _nisCtrl.text.trim().isEmpty ? null : _nisCtrl.text.trim(),
        'nisn': _nisnCtrl.text.trim().isEmpty ? null : _nisnCtrl.text.trim(),
        'phone_number': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        'birth_place': _birthPlaceCtrl.text.trim().isEmpty ? null : _birthPlaceCtrl.text.trim(),
        'birth_date': _birthDateCtrl.text.trim().isEmpty ? null : _birthDateCtrl.text.trim(),
        'gender': _selectedGender,
        'religion': _selectedReligion,
        'tahun_masuk': _tahunMasukCtrl.text.trim().isEmpty ? null : _tahunMasukCtrl.text.trim(),
        'jalur_masuk_sekolah': _selectedJalurMasuk,
        'education_level_id': _selectedEducationLevelId,
        'class_id': _selectedClassId,
        'sub_class_id': _selectedSubClassId,
      };

      if (isSuperadmin && effectiveSchoolId != null) {
        data['school_id'] = effectiveSchoolId;
      }

      final student = await ref.read(createStudentProvider(data).future);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${student.name} berhasil ditambahkan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
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
        ? (ref.watch(dashboardSchoolsProvider).valueOrNull ?? <DashboardSchool>[])
        : <DashboardSchool>[];


    final levels = ref.watch(levelsProvider).valueOrNull ?? <EducationLevelEntity>[];
    final classes = ref.watch(classesProvider).valueOrNull ?? <ClassEntity>[];
    final subClasses = ref.watch(subClassesProvider).valueOrNull ?? <SubClassEntity>[];

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
                          'Tambah Siswa Baru',
                          style: AppTextStyles.h3.copyWith(color: AppColors.neutral900),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          isSuperadmin && activeSchool != null
                              ? 'Siswa akan dibuat untuk ${activeSchool.name}.'
                              : 'Data akan dikirim ke backend Siswa.',
                          style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
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
                            hint: 'Pilih sekolah untuk siswa ini',
                            value: _selectedSchoolId,
                            items: schools
                                .map(
                                  (school) => AppDropdownItem<String?>(
                                    value: school.id,
                                    label: school.name,
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => setState(() => _selectedSchoolId = value),
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
                                label: _requiredLabel('Nama Siswa'),
                                hint: 'Masukkan nama siswa',
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
                                hint: 'Masukkan username',
                                controller: _usernameCtrl,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: AppTextField.password(
                                label: _requiredLabel('Password'),
                                controller: _passwordCtrl,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: AppTextField(
                                label: 'NIS',
                                hint: 'Masukkan NIS',
                                controller: _nisCtrl,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: AppTextField(
                                label: 'NISN',
                                hint: 'Masukkan NISN',
                                controller: _nisnCtrl,
                                keyboardType: TextInputType.number,
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
                                suffix: IconButton(
                                  onPressed: _pickBirthDate,
                                  icon: const Icon(Icons.calendar_month_outlined),
                                  color: AppColors.neutral500,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: AppDropdown<String?>(
                                label: 'Jenis Kelamin',
                                hint: 'Pilih',
                                value: _selectedGender,
                                items: const [
                                  AppDropdownItem(value: 'L', label: 'Laki-laki (L)'),
                                  AppDropdownItem(value: 'P', label: 'Perempuan (P)'),
                                ],
                                onChanged: (val) => setState(() => _selectedGender = val),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: AppDropdown<String?>(
                                label: 'Agama',
                                hint: 'Pilih Agama',
                                value: _selectedReligion,
                                items: ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu']
                                    .map((r) => AppDropdownItem<String?>(value: r, label: r))
                                    .toList(),
                                onChanged: (val) => setState(() => _selectedReligion = val),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: AppTextField(
                                label: 'Tahun Masuk',
                                hint: 'Contoh: 2023',
                                controller: _tahunMasukCtrl,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: AppDropdown<String?>(
                                label: 'Jalur Masuk',
                                hint: 'Pilih Jalur Masuk',
                                value: _selectedJalurMasuk,
                                items: ['reguler', 'beasiswa', 'mutasi', 'lainnya']
                                    .map((j) => AppDropdownItem<String?>(value: j, label: j))
                                    .toList(),
                                onChanged: (val) => setState(() => _selectedJalurMasuk = val),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: AppDropdown<String?>(
                                label: 'Tingkat Pendidikan',
                                hint: 'Pilih Tingkat',
                                value: _selectedEducationLevelId,
                                items: levels
                                    .map((l) => AppDropdownItem<String?>(value: l.id, label: l.name))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedEducationLevelId = val;
                                    // Reset class and subclass when level changes
                                    _selectedClassId = null;
                                    _selectedSubClassId = null;
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: AppDropdown<String?>(
                                label: 'Kelas',
                                hint: 'Pilih Kelas',
                                value: _selectedClassId,
                                items: classes
                                    .where((c) => c.educationLevelId == _selectedEducationLevelId)
                                    .map((c) => AppDropdownItem<String?>(value: c.id, label: c.name))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedClassId = val;
                                    // Reset subclass when class changes
                                    _selectedSubClassId = null;
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: AppDropdown<String?>(
                                label: 'Sub Kelas',
                                hint: 'Pilih Sub Kelas',
                                value: _selectedSubClassId,
                                items: subClasses
                                    .where((s) => s.classId == _selectedClassId)
                                    .map((s) => AppDropdownItem<String?>(value: s.id, label: s.name))
                                    .toList(),
                                onChanged: (val) => setState(() => _selectedSubClassId = val),
                              ),
                            ),
                            SizedBox(
                              width: constraints.maxWidth,
                              child: AppTextField(
                                label: 'Alamat',
                                hint: 'Masukkan alamat',
                                controller: _addressCtrl,
                                maxLines: 3,
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
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppButton.accent(
                    label: _isLoading ? 'Menyimpan...' : 'Simpan Siswa',
                    onPressed: _isLoading ? null : _saveStudent,
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
