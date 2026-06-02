import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/student_row_data.dart';
import '../providers/students_provider.dart';

Future<void> showStudentEditModal(
  BuildContext context, {
  required StudentRowData data,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => StudentEditModal(data: data),
  );
}

class StudentEditModal extends ConsumerStatefulWidget {
  final StudentRowData data;

  const StudentEditModal({super.key, required this.data});

  @override
  ConsumerState<StudentEditModal> createState() => _StudentEditModalState();
}

class _StudentEditModalState extends ConsumerState<StudentEditModal> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _nisCtrl;
  late final TextEditingController _nisnCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _birthPlaceCtrl;
  late final TextEditingController _birthDateCtrl;
  late final TextEditingController _genderCtrl;
  late final TextEditingController _religionCtrl;
  late final TextEditingController _tahunMasukCtrl;
  late final TextEditingController _jalurMasukCtrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _nameCtrl = TextEditingController(text: d.name);
    _emailCtrl = TextEditingController(text: d.email);
    _nisCtrl = TextEditingController(text: d.nis);
    _nisnCtrl = TextEditingController(text: d.nisn);
    _phoneCtrl = TextEditingController(text: d.phone);
    _addressCtrl = TextEditingController(text: d.address);
    _birthPlaceCtrl = TextEditingController(text: d.birthPlace);
    // Remove formatting to get just YYYY-MM-DD if possible, or just let user re-pick
    _birthDateCtrl = TextEditingController(text: ''); 
    _genderCtrl = TextEditingController(text: d.gender);
    _religionCtrl = TextEditingController(text: d.religion);
    _tahunMasukCtrl = TextEditingController(text: d.tahunMasuk);
    _jalurMasukCtrl = TextEditingController(text: d.jalurMasukSekolah);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _nisCtrl.dispose();
    _nisnCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _birthPlaceCtrl.dispose();
    _birthDateCtrl.dispose();
    _genderCtrl.dispose();
    _religionCtrl.dispose();
    _tahunMasukCtrl.dispose();
    _jalurMasukCtrl.dispose();
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

  Future<void> _updateStudent() async {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama dan email wajib diisi')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'nis': _nisCtrl.text.trim().isEmpty ? null : _nisCtrl.text.trim(),
        'nisn': _nisnCtrl.text.trim().isEmpty ? null : _nisnCtrl.text.trim(),
        'phone_number': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        'birth_place': _birthPlaceCtrl.text.trim().isEmpty ? null : _birthPlaceCtrl.text.trim(),
        'birth_date': _birthDateCtrl.text.trim().isEmpty ? null : _birthDateCtrl.text.trim(),
        'gender': _genderCtrl.text.trim().isEmpty ? null : _genderCtrl.text.trim(),
        'religion': _religionCtrl.text.trim().isEmpty ? null : _religionCtrl.text.trim(),
        'tahun_masuk': _tahunMasukCtrl.text.trim().isEmpty ? null : _tahunMasukCtrl.text.trim(),
        'jalur_masuk_sekolah': _jalurMasukCtrl.text.trim().isEmpty ? null : _jalurMasukCtrl.text.trim(),
      };

      await ref.read(
        updateStudentProvider(
          (id: widget.data.studentId, data: data),
        ).future,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.data.name} berhasil diperbarui')),
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
                          'Edit Data Siswa',
                          style: AppTextStyles.h3.copyWith(color: AppColors.neutral900),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Memperbarui data ${widget.data.name}',
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

                    return Wrap(
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
                          child: AppTextField(
                            label: 'Jenis Kelamin',
                            hint: 'L / P',
                            controller: _genderCtrl,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: AppTextField(
                            label: 'Agama',
                            hint: 'Islam, Kristen, dll',
                            controller: _religionCtrl,
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
                          child: AppTextField(
                            label: 'Jalur Masuk',
                            hint: 'Contoh: Zonasi, Prestasi',
                            controller: _jalurMasukCtrl,
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
                  AppButton.primary(
                    label: _isLoading ? 'Menyimpan...' : 'Simpan Perubahan',
                    onPressed: _isLoading ? null : _updateStudent,
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
