import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/staff_row_data.dart';
import '../providers/staff_provider.dart';

Future<void> showStaffEditModal(
  BuildContext context, {
  required WidgetRef ref,
  required StaffRowData data,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => StaffEditModal(ref: ref, data: data),
  );
}

class StaffEditModal extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final StaffRowData data;

  const StaffEditModal({super.key, required this.ref, required this.data});

  @override
  ConsumerState<StaffEditModal> createState() => _StaffEditModalState();
}

class _StaffEditModalState extends ConsumerState<StaffEditModal> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _birthDateCtrl;
  late final TextEditingController _nikCtrl;
  late final TextEditingController _birthPlaceCtrl;
  late final TextEditingController _ktpImagePathCtrl;
  late final TextEditingController _religionCtrl;
  String? _selectedGender;

  static const List<({String label, String value})> _genderOptions = [
    (label: 'Laki-laki', value: 'male'),
    (label: 'Perempuan', value: 'female'),
    (label: 'Lainnya', value: 'other'),
  ];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.data.name);
    _emailCtrl = TextEditingController(text: widget.data.email);
    _usernameCtrl = TextEditingController(text: widget.data.username);
    _phoneCtrl = TextEditingController(text: widget.data.phoneNumber);
    _addressCtrl = TextEditingController(text: widget.data.address);
    _birthDateCtrl = TextEditingController(text: widget.data.birthDate);
    _nikCtrl = TextEditingController(text: widget.data.nik);
    _birthPlaceCtrl = TextEditingController(text: widget.data.birthPlace);
    _ktpImagePathCtrl = TextEditingController(text: widget.data.ktpImagePath);
    _religionCtrl = TextEditingController(text: widget.data.religion);
    _selectedGender = widget.data.gender.isEmpty ? null : widget.data.gender;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _birthDateCtrl.dispose();
    _nikCtrl.dispose();
    _birthPlaceCtrl.dispose();
    _ktpImagePathCtrl.dispose();
    _religionCtrl.dispose();
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

  Future<void> _saveStaff() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _usernameCtrl.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nama, email, dan username wajib diisi'),
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final staff = await ref.read(
        updateStaffProvider((
          id: widget.data.staffId,
          data: {
            'name': _nameCtrl.text.trim(),
            'email': _emailCtrl.text.trim(),
            'username': _usernameCtrl.text.trim(),
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
          },
        )).future,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${staff.name} berhasil diperbarui')),
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
                          'Edit Data Staff',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Perubahan akan dikirim langsung ke backend Staff.',
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

                    return Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: [
                        SizedBox(
                          width: fieldWidth,
                          child: AppTextField(
                            label: _requiredLabel('Nama Staff'),
                            hint: 'Masukkan nama staff',
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
                            label: 'Tempat Lahir',
                            hint: 'Masukkan tempat lahir',
                            controller: _birthPlaceCtrl,
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
                          child: AppDropdown<String?>(
                            label: 'Jenis Kelamin',
                            hint: 'Pilih jenis kelamin',
                            value: _selectedGender,
                            items: _genderOptions
                                .map(
                                  (option) => AppDropdownItem<String?>(
                                    value: option.value,
                                    label: option.label,
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedGender = value);
                            },
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: AppTextField(
                            label: 'Path Foto KTP',
                            hint: 'Masukkan path gambar KTP',
                            controller: _ktpImagePathCtrl,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: AppTextField(
                            label: 'NIK',
                            hint: 'Masukkan NIK',
                            controller: _nikCtrl,
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
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppButton.primary(
                    label: _isLoading ? 'Menyimpan...' : 'Simpan Perubahan',
                    onPressed: _isLoading ? null : _saveStaff,
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
