import 'package:flutter/material.dart';

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
import '../../../../core/widgets/app_toast.dart';
import '../../data/datasources/class_promotion_dummy_data.dart';
import '../../data/models/class_promotion_entities.dart';

class ClassPromotionScreen extends StatefulWidget {
  const ClassPromotionScreen({super.key});

  @override
  State<ClassPromotionScreen> createState() => _ClassPromotionScreenState();
}

class _ClassPromotionScreenState extends State<ClassPromotionScreen> {
  String _selectedAcademicYear = classPromotionAcademicYears.first;
  String _selectedSourceClassId = classPromotionClassOptions.first.id;
  String? _selectedTargetClassId;
  final Map<String, PromotionDecision> _decisions = {};

  @override
  void initState() {
    super.initState();
    _syncDefaultTargetClass();
  }

  List<PromotionStudent> get _students =>
      classPromotionStudentsByClass[_selectedSourceClassId] ?? const [];

  PromotionClassOption? get _sourceClassOption {
    final options = classPromotionClassOptions.where((e) => e.id == _selectedSourceClassId);
    return options.isEmpty ? null : options.first;
  }

  List<PromotionClassOption> get _targetClassOptions {
    final source = _sourceClassOption;
    if (source == null) return const [];
    return classPromotionClassOptions
        .where((option) => option.level == source.level && option.id != source.id)
        .toList();
  }

  int get _promoteCount =>
      _decisions.values.where((d) => d == PromotionDecision.promote).length;
  int get _retainCount =>
      _decisions.values.where((d) => d == PromotionDecision.retain).length;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return SingleChildScrollView(
      padding: isMobile ? const EdgeInsets.all(AppSpacing.lg) : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Naik Kelas',
            style: AppTextStyles.h2.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tentukan siswa naik kelas atau tinggal kelas (dummy data, tanpa backend).',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildFilterCard(isMobile),
          const SizedBox(height: AppSpacing.lg),
          _buildSummaryCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildStudentsCard(isMobile),
        ],
      ),
    );
  }

  Widget _buildFilterCard(bool isMobile) {
    return AppCard(
      child: Column(
        children: [
          if (isMobile)
            Column(
              children: [
                AppDropdown<String>(
                  label: 'Tahun Ajaran',
                  value: _selectedAcademicYear,
                  items: classPromotionAcademicYears
                      .map((year) => AppDropdownItem<String>(value: year, label: year))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedAcademicYear = value);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppDropdown<String>(
                  label: 'Kelas Sumber',
                  value: _selectedSourceClassId,
                  items: classPromotionClassOptions
                      .map((item) => AppDropdownItem<String>(value: item.id, label: item.label))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedSourceClassId = value;
                      _decisions.clear();
                      _syncDefaultTargetClass();
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppDropdown<String>(
                  label: 'Kelas Tujuan',
                  value: _selectedTargetClassId,
                  items: _targetClassOptions
                      .map((item) => AppDropdownItem<String>(value: item.id, label: item.label))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedTargetClassId = value),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: AppDropdown<String>(
                    label: 'Tahun Ajaran',
                    value: _selectedAcademicYear,
                    items: classPromotionAcademicYears
                        .map((year) => AppDropdownItem<String>(value: year, label: year))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedAcademicYear = value);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppDropdown<String>(
                    label: 'Kelas Sumber',
                    value: _selectedSourceClassId,
                    items: classPromotionClassOptions
                        .map((item) => AppDropdownItem<String>(value: item.id, label: item.label))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedSourceClassId = value;
                        _decisions.clear();
                        _syncDefaultTargetClass();
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppDropdown<String>(
                    label: 'Kelas Tujuan',
                    value: _selectedTargetClassId,
                    items: _targetClassOptions
                        .map((item) => AppDropdownItem<String>(value: item.id, label: item.label))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedTargetClassId = value),
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.md),
          if (isMobile)
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: AppButton.secondary(
                    label: 'Pilih Semua Naik Kelas',
                    onPressed: _markAllPromote,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: AppButton.ghost(
                    label: 'Reset Pilihan',
                    onPressed: () => setState(_decisions.clear),
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton.secondary(
                  label: 'Pilih Semua Naik Kelas',
                  onPressed: _markAllPromote,
                ),
                const SizedBox(width: AppSpacing.sm),
                AppButton.ghost(
                  label: 'Reset Pilihan',
                  onPressed: () => setState(_decisions.clear),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return AppCard(
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        children: [
          _summaryItem('Total Siswa', '${_students.length}', AppColors.primary700),
          _summaryItem('Naik Kelas', '$_promoteCount', AppColors.success),
          _summaryItem('Tinggal Kelas', '$_retainCount', AppColors.warning),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.h4.copyWith(color: color)),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral700)),
        ],
      ),
    );
  }

  Widget _buildStudentsCard(bool isMobile) {
    if (_students.isEmpty) {
      return const AppCard(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
          child: AppEmptyState(message: 'Tidak ada data siswa pada kelas sumber ini.'),
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile)
            ..._students.map(_buildStudentMobileCard)
          else
            _buildStudentsTable(),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton.primary(
              label: 'Konfirmasi Promosi',
              onPressed: _decisions.isEmpty ? null : _openConfirmDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentMobileCard(PromotionStudent student) {
    final decision = _decisions[student.id];
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(student.name, style: AppTextStyles.bodyMdSemiBold.copyWith(color: AppColors.neutral900)),
          const SizedBox(height: AppSpacing.xs),
          Text('${student.nis} • ${student.sourceClass}',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _decisionChip(student.id, PromotionDecision.promote, 'Naik Kelas'),
              const SizedBox(width: AppSpacing.sm),
              _decisionChip(student.id, PromotionDecision.retain, 'Tinggal Kelas'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (decision != null) _decisionBadge(decision),
        ],
      ),
    );
  }

  Widget _buildStudentsTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: AppColors.neutral100),
              child: DataTable(
                columnSpacing: 24,
                horizontalMargin: AppSpacing.md,
                headingRowHeight: 48,
                dataRowMinHeight: 54,
                dataRowMaxHeight: 54,
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
                  DataColumn(label: _tableHeader('Nama', width: 220)),
                  DataColumn(label: _tableHeader('NIS', width: 120)),
                  DataColumn(label: _tableHeader('Kelas Saat Ini', width: 140)),
                  DataColumn(label: _tableHeader('Keputusan', width: 260)),
                  DataColumn(label: _tableHeader('Status', width: 130)),
                ],
                rows: _students.asMap().entries.map((entry) {
                  final index = entry.key;
                  final student = entry.value;
                  final decision = _decisions[student.id];
                  return DataRow(
                    cells: [
                      DataCell(_cellBox('${index + 1}', width: 64)),
                      DataCell(_cellBox(student.name, width: 220)),
                      DataCell(_cellBox(student.nis, width: 120)),
                      DataCell(_cellBox(student.sourceClass, width: 140)),
                      DataCell(
                        SizedBox(
                          width: 260,
                          child: Row(
                            children: [
                              _decisionChip(student.id, PromotionDecision.promote, 'Naik Kelas'),
                              const SizedBox(width: AppSpacing.sm),
                              _decisionChip(student.id, PromotionDecision.retain, 'Tinggal Kelas'),
                            ],
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 130,
                          child: decision == null ? const SizedBox.shrink() : _decisionBadge(decision),
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

  Widget _decisionChip(String studentId, PromotionDecision decision, String label) {
    final selected = _decisions[studentId] == decision;
    return GestureDetector(
      onTap: () {
        setState(() {
          _decisions[studentId] = decision;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary100 : AppColors.neutral50,
          borderRadius: AppRadius.pillAll,
          border: Border.all(
            color: selected ? AppColors.primary500 : AppColors.neutral300,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: selected ? AppColors.primary700 : AppColors.neutral700,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _decisionBadge(PromotionDecision decision) {
    return switch (decision) {
      PromotionDecision.promote => const AppBadge(label: 'NAIK', status: BadgeStatus.success),
      PromotionDecision.retain => const AppBadge(label: 'TINGGAL', status: BadgeStatus.warning),
    };
  }

  Future<void> _openConfirmDialog() async {
    final promoteStudents = _students
        .where((student) => _decisions[student.id] == PromotionDecision.promote)
        .toList();
    final retainStudents = _students
        .where((student) => _decisions[student.id] == PromotionDecision.retain)
        .toList();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AppDialog(
        title: 'Konfirmasi Promosi',
        subtitle: 'Tahun Ajaran $_selectedAcademicYear',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kelas sumber: ${_sourceClassOption?.label ?? '-'}',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral700),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Kelas tujuan: ${_findClassLabel(_selectedTargetClassId) ?? '-'}',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral700),
            ),
            const SizedBox(height: AppSpacing.md),
            _decisionSummaryLine('Naik Kelas', promoteStudents.length, AppColors.success),
            const SizedBox(height: AppSpacing.xs),
            _decisionSummaryLine('Tinggal Kelas', retainStudents.length, AppColors.warning),
          ],
        ),
        actions: [
          AppButton.secondary(
            label: 'Batal',
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          AppButton.primary(
            label: 'Proses',
            onPressed: () {
              Navigator.of(dialogContext).pop();
              AppToast.show(
                context,
                message: 'Simulasi promosi berhasil diproses (${_decisions.length} siswa).',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _decisionSummaryLine(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: $count siswa',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral700),
        ),
      ],
    );
  }

  void _markAllPromote() {
    setState(() {
      for (final student in _students) {
        _decisions[student.id] = PromotionDecision.promote;
      }
    });
  }

  void _syncDefaultTargetClass() {
    final source = _sourceClassOption;
    if (source == null) {
      _selectedTargetClassId = null;
      return;
    }

    final hasSuggestedTarget = _targetClassOptions.any((opt) => opt.id == source.nextClassId);
    if (hasSuggestedTarget) {
      _selectedTargetClassId = source.nextClassId;
      return;
    }

    _selectedTargetClassId = _targetClassOptions.isEmpty ? null : _targetClassOptions.first.id;
  }

  String? _findClassLabel(String? classId) {
    if (classId == null) return null;
    final matches = classPromotionClassOptions.where((e) => e.id == classId);
    return matches.isEmpty ? null : matches.first.label;
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
}
