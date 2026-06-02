import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../academic/presentation/providers/academic_providers.dart';
import '../../../student_tracking/presentation/providers/student_tracking_providers.dart';
import '../providers/class_promotion_providers.dart';

class ClassPromotionScreen extends ConsumerStatefulWidget {
  const ClassPromotionScreen({super.key});

  @override
  ConsumerState<ClassPromotionScreen> createState() => _ClassPromotionScreenState();
}

class _ClassPromotionScreenState extends ConsumerState<ClassPromotionScreen> {
  String? _sourceClassroomId;
  String? _targetClassroomId;
  String _status = 'promoted';
  final Set<String> _selected = {};
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final isCompact = Responsive.isMobile(context) || Responsive.isTablet(context);
    final classroomsAsync = ref.watch(classroomsProvider);

    return SingleChildScrollView(
      padding: isCompact ? const EdgeInsets.all(AppSpacing.lg) : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Naik Kelas', style: AppTextStyles.h2.copyWith(color: AppColors.neutral900)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pindahkan siswa dari kelas sumber ke kelas tujuan. Siswa yang tidak dipilih tetap tinggal kelas.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.lg),
          classroomsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => AppCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: AppEmptyState(message: e.toString().replaceFirst('Exception: ', '')),
              ),
            ),
            data: (classrooms) {
              if (classrooms.isEmpty) {
                return const AppCard(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                    child: AppEmptyState(message: 'Belum ada data ruang kelas.'),
                  ),
                );
              }
              final classroomItems = classrooms
                  .map((c) => AppDropdownItem<String>(value: c.id, label: c.name))
                  .toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterCard(isCompact, classroomItems),
                  const SizedBox(height: AppSpacing.lg),
                  if (_sourceClassroomId != null) _buildStudentsSection(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard(bool isMobile, List<AppDropdownItem<String>> classroomItems) {
    final sourceDropdown = AppDropdown<String>(
      label: 'Kelas Sumber',
      hint: 'Pilih kelas sumber',
      value: _sourceClassroomId,
      items: classroomItems,
      onChanged: (value) => setState(() {
        _sourceClassroomId = value;
        _selected.clear();
      }),
    );
    final targetDropdown = AppDropdown<String>(
      label: 'Kelas Tujuan',
      hint: 'Pilih kelas tujuan',
      value: _targetClassroomId,
      items: classroomItems.where((i) => i.value != _sourceClassroomId).toList(),
      onChanged: (value) => setState(() => _targetClassroomId = value),
    );
    final statusDropdown = AppDropdown<String>(
      label: 'Jenis',
      value: _status,
      items: const [
        AppDropdownItem<String>(value: 'promoted', label: 'Naik Kelas'),
        AppDropdownItem<String>(value: 'transferred', label: 'Pindah'),
      ],
      onChanged: (value) => setState(() => _status = value ?? 'promoted'),
    );

    return AppCard(
      child: isMobile
          ? Column(children: [
              sourceDropdown,
              const SizedBox(height: AppSpacing.md),
              targetDropdown,
              const SizedBox(height: AppSpacing.md),
              statusDropdown,
            ])
          : Row(children: [
              Expanded(child: sourceDropdown),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: targetDropdown),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: statusDropdown),
            ]),
    );
  }

  Widget _buildStudentsSection() {
    final asyncStudents = ref.watch(classroomStudentsProvider(_sourceClassroomId!));
    return asyncStudents.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AppCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: AppEmptyState(message: e.toString().replaceFirst('Exception: ', '')),
        ),
      ),
      data: (students) {
        if (students.isEmpty) {
          return const AppCard(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: AppEmptyState(message: 'Tidak ada siswa aktif pada kelas sumber ini.'),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(students.length),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Daftar Siswa', style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
                      const Spacer(),
                      AppButton.ghost(
                        label: _selected.length == students.length ? 'Batal Semua' : 'Pilih Semua',
                        onPressed: () => setState(() {
                          if (_selected.length == students.length) {
                            _selected.clear();
                          } else {
                            _selected
                              ..clear()
                              ..addAll(students.map((s) => s.studentId));
                          }
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...students.map((s) => CheckboxListTile(
                        value: _selected.contains(s.studentId),
                        onChanged: (checked) => setState(() {
                          if (checked == true) {
                            _selected.add(s.studentId);
                          } else {
                            _selected.remove(s.studentId);
                          }
                        }),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primary700,
                        title: Text(s.studentName, style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral900, fontWeight: FontWeight.w500)),
                        subtitle: Text('NIS: ${s.nis.isEmpty ? '-' : s.nis} · ${s.fullClassName}',
                            style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500)),
                      )),
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButton.primary(
                      label: 'Proses Kenaikan',
                      onPressed: (_selected.isEmpty || _targetClassroomId == null || _isSubmitting)
                          ? null
                          : () => _openConfirmDialog(students.length),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(int total) {
    return AppCard(
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        children: [
          _summaryItem('Total Siswa', '$total', AppColors.primary700),
          _summaryItem(_status == 'transferred' ? 'Dipindah' : 'Naik Kelas', '${_selected.length}', AppColors.success),
          _summaryItem('Tinggal Kelas', '${total - _selected.length}', AppColors.warning),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: AppRadius.lgAll),
      ),
    );
  }

  Future<void> _openConfirmDialog(int total) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AppDialog(
        title: 'Konfirmasi Kenaikan',
