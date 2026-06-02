import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../data/datasources/school_dummy_data.dart';
import '../../data/models/school_entities.dart';

class SchoolScreen extends ConsumerStatefulWidget {
  const SchoolScreen({super.key});

  @override
  ConsumerState<SchoolScreen> createState() => _SchoolScreenState();
}

class _SchoolScreenState extends ConsumerState<SchoolScreen> {
  static const _timeZones = <String>[
    'Asia/Jakarta',
    'Asia/Makassar',
    'Asia/Jayapura',
  ];

  SchoolProfile _profile = schoolDummyProfile;
  List<SchoolRule> _rules = List.of(schoolDummyRules);
  int _ruleSeq = 100;

  @override
  Widget build(BuildContext context) {
    final isCompact = Responsive.isMobile(context) || Responsive.isTablet(context);
    final canManageStatus = ref.watch(currentUserProvider)?.role == UserRole.superadmin;

    return SingleChildScrollView(
      padding: isCompact ? const EdgeInsets.all(AppSpacing.lg) : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profil Sekolah',
            style: AppTextStyles.h2.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Kelola informasi utama sekolah dan rules operasional (dummy data).',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSchoolInfoCard(isCompact, canManageStatus),
          const SizedBox(height: AppSpacing.lg),
          _buildRulesCard(isCompact),
        ],
      ),
    );
  }

  Widget _buildSchoolInfoCard(bool isMobile, bool canManageStatus) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Informasi Sekolah', style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
                const SizedBox(height: AppSpacing.sm),
                AppButton.primary(
                  label: 'Edit Sekolah',
                  isFullWidth: true,
                  prefixIcon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.white),
                  onPressed: () => _openEditSchoolDialog(canManageStatus),
                ),
              ],
            )
          else
            Row(
              children: [
                Text('Informasi Sekolah', style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
                const Spacer(),
                AppButton.primary(
                  label: 'Edit Sekolah',
                  prefixIcon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.white),
                  onPressed: () => _openEditSchoolDialog(canManageStatus),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: AppRadius.lgAll,
              border: Border.all(color: AppColors.neutral100),
            ),
            child: isMobile ? _buildInfoColumn() : _buildInfoGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoItem('Nama Sekolah', _profile.name),
        const SizedBox(height: AppSpacing.md),
        _infoItem('Alamat', _profile.address),
        const SizedBox(height: AppSpacing.md),
        _infoItem('No. HP', _profile.phone),
        const SizedBox(height: AppSpacing.md),
        _infoItem('Email', _profile.email),
        const SizedBox(height: AppSpacing.md),
        _infoItem('Timezone', _profile.timeZone),
        const SizedBox(height: AppSpacing.md),
        _infoItem('Logo Path', _profile.imagePath),
        const SizedBox(height: AppSpacing.md),
        _infoItem('Deskripsi', _profile.description),
        const SizedBox(height: AppSpacing.md),
        _infoStatusItem(),
      ],
    );
  }

  Widget _buildInfoGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _infoItem('Nama Sekolah', _profile.name)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: _infoItem('No. HP', _profile.phone)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: _infoItem('Email', _profile.email)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: _infoItem('Timezone', _profile.timeZone)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: _infoItem('Alamat', _profile.address)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: _infoItem('Logo Path', _profile.imagePath)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(flex: 3, child: _infoItem('Deskripsi', _profile.description)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: _infoStatusItem()),
          ],
        ),
      ],
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.neutral500,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _infoStatusItem() {
    final isActive = _profile.status == SchoolStatus.active;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.neutral500,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        AppBadge(
          label: isActive ? 'ACTIVE' : 'NONACTIVE',
          status: isActive ? BadgeStatus.success : BadgeStatus.muted,
        ),
      ],
    );
  }

  Widget _buildRulesCard(bool isMobile) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rules Sekolah', style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppButton.accent(
                        label: 'Tambah Rule',
                        prefixIcon: const Icon(Icons.add_rounded, size: 18, color: AppColors.white),
                        onPressed: _openCreateRuleDialog,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton.primary(
                        label: 'Simpan Semua',
                        prefixIcon: const Icon(Icons.save_outlined, size: 18, color: AppColors.white),
                        onPressed: _saveAllRules,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Row(
              children: [
                Text('Rules Sekolah', style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
                const Spacer(),
                AppButton.accent(
                  label: 'Tambah Rule',
                  prefixIcon: const Icon(Icons.add_rounded, size: 18, color: AppColors.white),
                  onPressed: _openCreateRuleDialog,
                ),
                const SizedBox(width: AppSpacing.sm),
                AppButton.primary(
                  label: 'Simpan Semua',
                  prefixIcon: const Icon(Icons.save_outlined, size: 18, color: AppColors.white),
                  onPressed: _saveAllRules,
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.md),
          _buildRulesTable(),
        ],
      ),
    );
  }

  Widget _buildRulesTable() {
    if (_rules.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: AppEmptyState(message: 'Belum ada rules sekolah.'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = Responsive.isMobile(context) || Responsive.isTablet(context);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: AppColors.neutral100),
              child: DataTable(
                columnSpacing: isCompact ? 12 : 24,
                horizontalMargin: AppSpacing.md,
                headingRowHeight: isCompact ? 42 : 48,
                dataRowMinHeight: isCompact ? 60 : 64,
                dataRowMaxHeight: isCompact ? 60 : 64,
                dividerThickness: 1,
                headingTextStyle: AppTextStyles.label.copyWith(
                  color: AppColors.neutral700,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
                dataTextStyle: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.neutral900,
                  fontWeight: FontWeight.w500,
                ),
                columns: [
                  DataColumn(label: _tableHeader('No', width: 64)),
                  DataColumn(label: _tableHeader('Nama Rule', width: 220)),
                  DataColumn(label: _tableHeader('Value', width: 180)),
                  DataColumn(label: _tableHeader('Deskripsi', width: 320)),
                  DataColumn(label: _tableHeader('Aksi', width: 120)),
                ],
                rows: _rules.asMap().entries.map((entry) {
                  final index = entry.key;
                  final rule = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(_cellBox('${index + 1}', width: 64)),
                      DataCell(_ruleLabelCell(rule, width: 220)),
                      DataCell(_cellBox(rule.value, width: 180)),
                      DataCell(_cellBox(rule.description, width: 320)),
                      DataCell(
                        SizedBox(
                          width: 120,
                          child: _rowActions(
                            onEdit: () => _openEditRuleDialog(rule),
                            onDelete: () => _deleteRule(rule),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tableHeader(String label, {double? width}) {
    final header = Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    if (width == null) return header;
    return SizedBox(width: width, child: header);
  }

  Widget _cellBox(String text, {required double width}) {
    return SizedBox(
      width: width,
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }

  Widget _ruleLabelCell(SchoolRule rule, {required double width}) {
    return SizedBox(
      width: width,
      child: Text(rule.label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }

  Widget _rowActions({
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Row(
      children: [
        _actionButton(icon: Icons.edit_outlined, color: AppColors.warning, onTap: onEdit),
        const SizedBox(width: AppSpacing.sm),
        _actionButton(icon: Icons.delete_outline_rounded, color: AppColors.error, onTap: onDelete),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 34,
      height: 34,
      child: Material(
        color: color,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Icon(icon, color: AppColors.white, size: 18),
        ),
      ),
    );
  }

  Future<void> _openEditSchoolDialog(bool canManageStatus) async {
    final nameCtrl = TextEditingController(text: _profile.name);
    final addressCtrl = TextEditingController(text: _profile.address);
    final phoneCtrl = TextEditingController(text: _profile.phone);
    final emailCtrl = TextEditingController(text: _profile.email);
    final descriptionCtrl = TextEditingController(text: _profile.description);
    final imagePathCtrl = TextEditingController(text: _profile.imagePath);
    var selectedTimeZone = _profile.timeZone;
    var selectedStatus = _profile.status;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setDialogState) => AppDialog(
            title: 'Edit Profil Sekolah',
            content: Column(
              children: [
                AppTextField(
                  label: 'Nama Sekolah',
                  controller: nameCtrl,
                  hint: 'Masukkan nama sekolah',
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Alamat',
                  controller: addressCtrl,
                  hint: 'Masukkan alamat sekolah',
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'No. HP',
                  controller: phoneCtrl,
                  hint: 'Masukkan nomor telepon',
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Email',
                  controller: emailCtrl,
                  hint: 'contoh@sekolah.id',
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Deskripsi',
                  controller: descriptionCtrl,
                  hint: 'Masukkan deskripsi sekolah',
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Image Path',
                  controller: imagePathCtrl,
                  hint: 'assets/images/logo/logoandtext.png',
                ),
                const SizedBox(height: AppSpacing.md),
                AppDropdown<String>(
                  label: 'Timezone',
                  value: selectedTimeZone,
                  items: _timeZones
                      .map((item) => AppDropdownItem<String>(value: item, label: item))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setDialogState(() => selectedTimeZone = value);
                  },
                ),
                if (canManageStatus) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppDropdown<SchoolStatus>(
                    label: 'Status Sekolah',
                    value: selectedStatus,
                    items: const [
                      AppDropdownItem<SchoolStatus>(value: SchoolStatus.active, label: 'Active'),
                      AppDropdownItem<SchoolStatus>(value: SchoolStatus.nonactive, label: 'Nonactive'),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => selectedStatus = value);
                    },
                  ),
                ],
              ],
            ),
            actions: [
              AppButton.secondary(
                label: 'Batal',
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              AppButton.primary(
                label: 'Simpan',
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty ||
                      addressCtrl.text.trim().isEmpty ||
                      phoneCtrl.text.trim().isEmpty ||
                      emailCtrl.text.trim().isEmpty) {
                    AppToast.show(
                      context,
                      message: 'Nama, alamat, no. HP, dan email wajib diisi.',
                      type: ToastType.warning,
                    );
                    return;
                  }

                  if (!_isValidEmail(emailCtrl.text.trim())) {
                    AppToast.show(
                      context,
                      message: 'Format email tidak valid.',
                      type: ToastType.warning,
                    );
                    return;
                  }

                  setState(() {
                    _profile = _profile.copyWith(
                      name: nameCtrl.text.trim(),
                      address: addressCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      description: descriptionCtrl.text.trim(),
                      imagePath: imagePathCtrl.text.trim(),
                      timeZone: selectedTimeZone,
                      status: selectedStatus,
                    );
                  });
                  Navigator.of(dialogContext).pop();
                  AppToast.show(context, message: 'Profil sekolah berhasil diperbarui.');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openCreateRuleDialog() async {
    final labelCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();

    await _showRuleDialog(
      title: 'Tambah Rule',
      labelController: labelCtrl,
      valueController: valueCtrl,
      descriptionController: descriptionCtrl,
      onSave: () {
        if (labelCtrl.text.trim().isEmpty || valueCtrl.text.trim().isEmpty) {
          AppToast.show(
            context,
            message: 'Nama Rule dan Value wajib diisi.',
            type: ToastType.warning,
          );
          return false;
        }
        final label = labelCtrl.text.trim();
        final key = _toUniqueRuleKey(label);
        setState(() {
          _rules = [
            ..._rules,
            SchoolRule(
              id: 'rule_${_ruleSeq++}',
              label: label,
              key: key,
              value: valueCtrl.text.trim(),
              description: descriptionCtrl.text.trim(),
            ),
          ];
        });
        return true;
      },
    );
  }

  Future<void> _openEditRuleDialog(SchoolRule rule) async {
    final labelCtrl = TextEditingController(text: rule.label);
    final valueCtrl = TextEditingController(text: rule.value);
    final descriptionCtrl = TextEditingController(text: rule.description);

    await _showRuleDialog(
      title: 'Edit Rule',
      labelController: labelCtrl,
      valueController: valueCtrl,
      descriptionController: descriptionCtrl,
      onSave: () {
        if (labelCtrl.text.trim().isEmpty || valueCtrl.text.trim().isEmpty) {
          AppToast.show(
            context,
            message: 'Nama Rule dan Value wajib diisi.',
            type: ToastType.warning,
          );
          return false;
        }
        final label = labelCtrl.text.trim();
        final key = _toUniqueRuleKey(label, excludeRuleId: rule.id);
        setState(() {
          _rules = _rules
              .map(
                (item) => item.id == rule.id
                    ? item.copyWith(
                        label: label,
                        key: key,
                        value: valueCtrl.text.trim(),
                        description: descriptionCtrl.text.trim(),
                      )
                    : item,
              )
              .toList();
        });
        return true;
      },
    );
  }

  Future<void> _showRuleDialog({
    required String title,
    required TextEditingController labelController,
    required TextEditingController valueController,
    required TextEditingController descriptionController,
    required bool Function() onSave,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AppDialog(
        title: title,
        content: Column(
          children: [
            AppTextField(
              label: 'Nama Rule',
              controller: labelController,
              hint: 'Contoh: Minimal Kehadiran (%)',
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Value',
              controller: valueController,
              hint: 'Contoh: 80',
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Deskripsi',
              controller: descriptionController,
              hint: 'Deskripsi rule',
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(dialogContext).pop()),
          AppButton.primary(
            label: 'Simpan',
            onPressed: () {
              final saved = onSave();
              if (!saved) return;
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRule(SchoolRule rule) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Hapus Rule',
      message: 'Rule "${rule.label}" akan dihapus.',
      confirmLabel: 'Hapus',
      isDanger: true,
    );

    if (confirmed != true) return;

    setState(() {
      _rules = _rules.where((item) => item.id != rule.id).toList();
    });
  }

  void _saveAllRules() {
    if (_rules.isEmpty) {
      AppToast.show(
        context,
        message: 'Belum ada rules untuk disimpan.',
        type: ToastType.warning,
      );
      return;
    }
    AppToast.show(context, message: 'Rules sekolah berhasil disimpan.');
  }

  String _toRuleKey(String input) {
    final lower = input.toLowerCase();
    final replaced = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    final trimmed = replaced.replaceAll(RegExp(r'^_+|_+$'), '');
    if (trimmed.isEmpty) return 'rule';
    return trimmed;
  }

  String _toUniqueRuleKey(String input, {String? excludeRuleId}) {
    final baseKey = _toRuleKey(input);
    var candidate = baseKey;
    var counter = 2;
    final usedKeys = _rules
        .where((rule) => excludeRuleId == null || rule.id != excludeRuleId)
        .map((rule) => rule.key)
        .toSet();

    while (usedKeys.contains(candidate)) {
      candidate = '${baseKey}_$counter';
      counter++;
    }

    return candidate;
  }

  bool _isValidEmail(String email) {
    const pattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
    return RegExp(pattern).hasMatch(email);
  }
}
