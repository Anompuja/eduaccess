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
import '../providers/teachers_provider.dart';

Future<void> showTeacherCreateModal(BuildContext context, WidgetRef ref) {
  return showDialog<void>(
    context: context,
    builder: (_) => TeacherCreateModal(ref: ref),
  );
}

class TeacherCreateModal extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const TeacherCreateModal({super.key, required this.ref});

  @override
  ConsumerState<TeacherCreateModal> createState() => _TeacherCreateModalState();
}

class _TeacherCreateModalState extends ConsumerState<TeacherCreateModal> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _nipCtrl;
  late final TextEditingController _nuptkCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _religionCtrl;
  late final TextEditingController _birthPlaceCtrl;
  late final TextEditingController _birthDateCtrl;
  late final TextEditingController _nikCtrl;
  late final TextEditingController _ktpImagePathCtrl;
  late final TextEditingController _kewarganegaraanCtrl;
  late final TextEditingController _golonganDarahCtrl;
  late final TextEditingController _beratBadanCtrl;
  late final TextEditingController _tinggiBadanCtrl;
  late final TextEditingController _penyakitYangSeringKambuhCtrl;
  late final TextEditingController _kelainanJasmaniCtrl;
  late final TextEditingController _penyakitKronisCtrl;
  late final TextEditingController _rtRwCtrl;
  late final TextEditingController _kodePosCtrl;
  late final TextEditingController _pendidikanTerakhirCtrl;
  late final TextEditingController _jurusanCtrl;
  late final TextEditingController _tahunLulusCtrl;
  late final TextEditingController _tahunMasukCtrl;
  late final TextEditingController _addressCtrl;
  String? _selectedSchoolId;
  String? _selectedGender;
  bool _isLoading = false;

  static const List<({String label, String value})> _genderOptions = [
    (label: 'Laki-laki', value: 'male'),
    (label: 'Perempuan', value: 'female'),
    (label: 'Lainnya', value: 'other'),
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _usernameCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _nipCtrl = TextEditingController();
    _nuptkCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _religionCtrl = TextEditingController();
    _birthPlaceCtrl = TextEditingController();
    _birthDateCtrl = TextEditingController();
    _nikCtrl = TextEditingController();
    _ktpImagePathCtrl = TextEditingController();
    _kewarganegaraanCtrl = TextEditingController();
    _golonganDarahCtrl = TextEditingController();
    _beratBadanCtrl = TextEditingController();
    _tinggiBadanCtrl = TextEditingController();
    _penyakitYangSeringKambuhCtrl = TextEditingController();
    _kelainanJasmaniCtrl = TextEditingController();
    _penyakitKronisCtrl = TextEditingController();
    _rtRwCtrl = TextEditingController();
    _kodePosCtrl = TextEditingController();
    _pendidikanTerakhirCtrl = TextEditingController();
    _jurusanCtrl = TextEditingController();
    _tahunLulusCtrl = TextEditingController();
    _tahunMasukCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _nipCtrl.dispose();
    _nuptkCtrl.dispose();
    _phoneCtrl.dispose();
    _religionCtrl.dispose();
    _birthPlaceCtrl.dispose();
    _birthDateCtrl.dispose();
    _nikCtrl.dispose();
    _ktpImagePathCtrl.dispose();
    _kewarganegaraanCtrl.dispose();
    _golonganDarahCtrl.dispose();
    _beratBadanCtrl.dispose();
    _tinggiBadanCtrl.dispose();
    _penyakitYangSeringKambuhCtrl.dispose();
    _kelainanJasmaniCtrl.dispose();
    _penyakitKronisCtrl.dispose();
    _rtRwCtrl.dispose();
    _kodePosCtrl.dispose();
    _pendidikanTerakhirCtrl.dispose();
    _jurusanCtrl.dispose();
    _tahunLulusCtrl.dispose();
    _tahunMasukCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  String _requiredLabel(String label) => '$label *';

  String? _nullIfEmpty(String v) => v.trim().isEmpty ? null : v.trim();

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

  Future<void> _saveTeacher() async {
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
          const SnackBar(content: Text('Nama, email, username, dan password wajib diisi')),
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
        'nip': _nullIfEmpty(_nipCtrl.text),
        'nuptk': _nullIfEmpty(_nuptkCtrl.text),
        'phone_number': _nullIfEmpty(_phoneCtrl.text),
        'address': _nullIfEmpty(_addressCtrl.text),
        'gender': _selectedGender,
        'religion': _nullIfEmpty(_religionCtrl.text),
        'birth_place': _nullIfEmpty(_birthPlaceCtrl.text),
        'birth_date': _nullIfEmpty(_birthDateCtrl.text),
        'nik': _nullIfEmpty(_nikCtrl.text),
        'ktp_image_path': _nullIfEmpty(_ktpImagePathCtrl.text),
        'kewarganegaraan': _nullIfEmpty(_kewarganegaraanCtrl.text),
        'golongan_darah': _nullIfEmpty(_golonganDarahCtrl.text),
        'berat_badan': _nullIfEmpty(_beratBadanCtrl.text),
        'tinggi_badan': _nullIfEmpty(_tinggiBadanCtrl.text),
        'penyakit_yang_sering_kambuh': _nullIfEmpty(_penyakitYangSeringKambuhCtrl.text),
        'kelainan_jasmani': _nullIfEmpty(_kelainanJasmaniCtrl.text),
        'penyakit_kronis_yang_pernah_diderita': _nullIfEmpty(_penyakitKronisCtrl.text),
        'rt_rw': _nullIfEmpty(_rtRwCtrl.text),
        'kode_pos': _nullIfEmpty(_kodePosCtrl.text),
        'pendidikan_terakhir': _nullIfEmpty(_pendidikanTerakhirCtrl.text),
        'jurusan': _nullIfEmpty(_jurusanCtrl.text),
        'tahun_lulus': _nullIfEmpty(_tahunLulusCtrl.text),
        'tahun_masuk': _nullIfEmpty(_tahunMasukCtrl.text),
      };

      if (isSuperadmin && effectiveSchoolId != null) {
        data['school_id'] = effectiveSchoolId;
      }

      final teacher = await ref.read(createTeacherProvider(data).future);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${teacher.name} berhasil ditambahkan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                          'Tambah Guru Baru',
                          style: AppTextStyles.h3.copyWith(color: AppColors.neutral900),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          isSuperadmin && activeSchool != null
                              ? 'Guru akan dibuat untuk ${activeSchool.name}.'
                              : 'Data akan dikirim langsung ke backend Guru.',
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
                    final fw = oneColumn
                        ? constraints.maxWidth
                        : (constraints.maxWidth - AppSpacing.md) / 2;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (needsSchoolPicker) ...[
                          AppDropdown<String?>(
                            label: 'Sekolah *',
                            hint: 'Pilih sekolah untuk guru ini',
                            value: _selectedSchoolId,
                            items: schools
                                .map((s) => AppDropdownItem<String?>(value: s.id, label: s.name))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedSchoolId = v),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        // ── Akun ──────────────────────────────────
                        _sectionLabel('Akun'),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(spacing: AppSpacing.md, runSpacing: AppSpacing.md, children: [
                          _field(fw, AppTextField(label: _requiredLabel('Nama Guru'), hint: 'Masukkan nama guru', controller: _nameCtrl)),
                          _field(fw, AppTextField(label: _requiredLabel('Email'), hint: 'Masukkan email', controller: _emailCtrl, keyboardType: TextInputType.emailAddress)),
                          _field(fw, AppTextField(label: _requiredLabel('Username'), hint: 'Masukkan username', controller: _usernameCtrl)),
                          _field(fw, AppTextField.password(label: _requiredLabel('Password'), controller: _passwordCtrl)),
                        ]),
                        const SizedBox(height: AppSpacing.md),
                        // ── Data Guru ─────────────────────────────
                        _sectionLabel('Data Guru'),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(spacing: AppSpacing.md, runSpacing: AppSpacing.md, children: [
                          _field(fw, AppTextField(label: 'NIP', hint: 'Masukkan NIP', controller: _nipCtrl, keyboardType: TextInputType.number)),
                          _field(fw, AppTextField(label: 'NUPTK', hint: 'Masukkan NUPTK', controller: _nuptkCtrl)),
                          _field(fw, AppTextField(label: 'No. Telepon', hint: 'Masukkan nomor telepon', controller: _phoneCtrl, keyboardType: TextInputType.phone)),
                          _field(fw, AppDropdown<String?>(
                            label: 'Jenis Kelamin',
                            hint: 'Pilih jenis kelamin',
                            value: _selectedGender,
                            items: _genderOptions.map((o) => AppDropdownItem<String?>(value: o.value, label: o.label)).toList(),
                            onChanged: (v) => setState(() => _selectedGender = v),
                          )),
                          _field(fw, AppTextField(label: 'Agama', hint: 'Masukkan agama', controller: _religionCtrl)),
                          _field(fw, AppTextField(label: 'Tempat Lahir', hint: 'Masukkan tempat lahir', controller: _birthPlaceCtrl)),
                          _field(fw, AppTextField(
                            label: 'Tanggal Lahir',
                            hint: 'YYYY-MM-DD',
                            controller: _birthDateCtrl,
                            readOnly: true,
                            onTap: _pickBirthDate,
                            suffix: IconButton(onPressed: _pickBirthDate, icon: const Icon(Icons.calendar_month_outlined), color: AppColors.neutral500),
                          )),
                          _field(fw, AppTextField(label: 'NIK', hint: 'Masukkan NIK', controller: _nikCtrl)),
                          _field(fw, AppTextField(label: 'Path Foto KTP', hint: 'Masukkan path gambar KTP', controller: _ktpImagePathCtrl)),
                          _field(fw, AppTextField(label: 'Kewarganegaraan', hint: 'Masukkan kewarganegaraan', controller: _kewarganegaraanCtrl)),
                          _field(fw, AppTextField(label: 'Golongan Darah', hint: 'Contoh: A, B, O, AB', controller: _golonganDarahCtrl)),
                          _field(fw, AppTextField(label: 'Berat Badan (kg)', hint: 'Masukkan berat badan', controller: _beratBadanCtrl)),
                          _field(fw, AppTextField(label: 'Tinggi Badan (cm)', hint: 'Masukkan tinggi badan', controller: _tinggiBadanCtrl)),
                          _field(fw, AppTextField(label: 'RT/RW', hint: 'Contoh: 001/002', controller: _rtRwCtrl)),
                          _field(fw, AppTextField(label: 'Kode Pos', hint: 'Masukkan kode pos', controller: _kodePosCtrl)),
                          _field(fw, AppTextField(label: 'Penyakit Sering Kambuh', hint: 'Masukkan penyakit yang sering kambuh', controller: _penyakitYangSeringKambuhCtrl)),
                          _field(fw, AppTextField(label: 'Kelainan Jasmani', hint: 'Masukkan kelainan jasmani', controller: _kelainanJasmaniCtrl)),
                          _field(fw, AppTextField(label: 'Penyakit Kronis', hint: 'Penyakit kronis yang pernah diderita', controller: _penyakitKronisCtrl)),
                          SizedBox(width: constraints.maxWidth, child: AppTextField(label: 'Alamat', hint: 'Masukkan alamat', controller: _addressCtrl, maxLines: 3)),
                        ]),
                        const SizedBox(height: AppSpacing.md),
                        // ── Pendidikan ────────────────────────────
                        _sectionLabel('Pendidikan'),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(spacing: AppSpacing.md, runSpacing: AppSpacing.md, children: [
                          _field(fw, AppTextField(label: 'Pendidikan Terakhir', hint: 'Masukkan pendidikan terakhir', controller: _pendidikanTerakhirCtrl)),
                          _field(fw, AppTextField(label: 'Jurusan', hint: 'Masukkan jurusan', controller: _jurusanCtrl)),
                          _field(fw, AppTextField(label: 'Tahun Masuk', hint: 'Contoh: 2010', controller: _tahunMasukCtrl, keyboardType: TextInputType.number)),
                          _field(fw, AppTextField(label: 'Tahun Lulus', hint: 'Contoh: 2014', controller: _tahunLulusCtrl, keyboardType: TextInputType.number)),
                        ]),
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
                    label: _isLoading ? 'Menyimpan...' : 'Simpan Guru',
                    onPressed: _isLoading ? null : _saveTeacher,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String title) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.label.copyWith(
        color: AppColors.neutral500,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _field(double width, Widget child) => SizedBox(width: width, child: child);
}