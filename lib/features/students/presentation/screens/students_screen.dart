import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/active_school_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_pagination.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/school_filter.dart';
import '../constants/students_screen_constants.dart';
import '../providers/students_provider.dart';
import '../widgets/student_create_modal.dart';
import '../widgets/student_delete_modal.dart';
import '../widgets/student_detail_modal.dart';
import '../widgets/student_edit_modal.dart';
import '../../data/models/student_row_data.dart';
import '../../../../features/academic/presentation/providers/academic_providers.dart';
import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/widgets/app_dropdown.dart';

class StudentsScreen extends ConsumerWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSmallScreen = Responsive.isMobile(context);
    final studentsAsync = ref.watch(studentsProvider);
    final activeSchool = ref.watch(activeSchoolProvider);

    final levelFilter = ref.watch(studentsLevelFilterProvider);
    final classFilter = ref.watch(studentsClassFilterProvider);
    final subClassFilter = ref.watch(studentsSubClassFilterProvider);

    final user = ref.watch(currentUserProvider);
    final schoolId = user?.role == UserRole.superadmin ? activeSchool?.id : user?.schoolId;

    final levels = ref.watch(levelsProvider).valueOrNull ?? [];
    final classes = ref.watch(classesProvider).valueOrNull ?? [];
    final subClasses = ref.watch(subClassesProvider).valueOrNull ?? [];

    ref.listen(activeSchoolProvider, (_, next) {
      ref.read(studentsCurrentPageProvider.notifier).state = 1;
      ref.invalidate(studentsProvider);
      ref.read(studentsLevelFilterProvider.notifier).state = null;
      ref.read(studentsClassFilterProvider.notifier).state = null;
      ref.read(studentsSubClassFilterProvider.notifier).state = null;
    });

    void setSearch(String value) {
      ref.read(studentsSearchQueryProvider.notifier).state = value.toLowerCase().trim();
      ref.read(studentsCurrentPageProvider.notifier).state = 1;
    }

    String getClassName(String classId, String subClassId) {
      if (subClassId.isNotEmpty) {
        final sub = subClasses.where((s) => s.id == subClassId).firstOrNull;
        if (sub != null) return sub.name;
      }
      if (classId.isNotEmpty) {
        final cls = classes.where((c) => c.id == classId).firstOrNull;
        if (cls != null) return cls.name;
      }
      return 'Belum ada kelas';
    }

    return SingleChildScrollView(
      padding: isSmallScreen
          ? const EdgeInsets.all(AppSpacing.lg)
          : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StudentsScreenConstants.title,
            style: AppTextStyles.h2.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            activeSchool == null
                ? 'Menampilkan data dari semua sekolah'
                : 'Data untuk: ${activeSchool.name}',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.md),
          const SchoolFilter(label: 'Sekolah Siswa', allLabel: 'Semua Sekolah'),
          const SizedBox(height: AppSpacing.md),
          if (isSmallScreen)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSearchBar(
                  hint: StudentsScreenConstants.searchHint,
                  width: double.infinity,
                  onSearch: setSearch,
                ),
                const SizedBox(height: AppSpacing.md),
                AppDropdown<String?>(
                  label: StudentsScreenConstants.educationLevelLabel,
                  hint: 'Semua Level',
                  value: levelFilter,
                  items: [
                    const AppDropdownItem(value: null, label: 'Semua Level'),
                    ...levels.map((l) => AppDropdownItem(value: l.id, label: l.name)),
                  ],
                  onChanged: (v) {
                    ref.read(studentsLevelFilterProvider.notifier).state = v;
                    ref.read(studentsCurrentPageProvider.notifier).state = 1;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppDropdown<String?>(
                  label: StudentsScreenConstants.classLabel,
                  hint: 'Semua Kelas',
                  value: classFilter,
                  items: [
                    const AppDropdownItem(value: null, label: 'Semua Kelas'),
                    ...classes
                        .where((c) => levelFilter == null || c.educationLevelId == levelFilter)
                        .map((c) => AppDropdownItem(value: c.id, label: c.name)),
                  ],
                  onChanged: (v) {
                    ref.read(studentsClassFilterProvider.notifier).state = v;
                    ref.read(studentsCurrentPageProvider.notifier).state = 1;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppDropdown<String?>(
                  label: StudentsScreenConstants.subClassLabel,
                  hint: 'Semua Sub-Kelas',
                  value: subClassFilter,
                  items: [
                    const AppDropdownItem(value: null, label: 'Semua Sub-Kelas'),
                    ...subClasses
                        .where((s) => classFilter == null || s.classId == classFilter)
                        .map((s) => AppDropdownItem(value: s.id, label: s.name)),
                  ],
                  onChanged: (v) {
                    ref.read(studentsSubClassFilterProvider.notifier).state = v;
                    ref.read(studentsCurrentPageProvider.notifier).state = 1;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton.accent(
                  height: StudentsScreenConstants.addButtonHeight,
                  isFullWidth: true,
                  label: StudentsScreenConstants.addButtonLabel,
                  prefixIcon: const Icon(
                    StudentsScreenConstants.addIcon,
                    size: StudentsScreenConstants.actionIconSize,
                    color: AppColors.white,
                  ),
                  onPressed: () => _openStudentCreateModal(context),
                ),
              ],
            )
          else
            Wrap(
              runSpacing: AppSpacing.md,
              spacing: AppSpacing.md,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                SizedBox(
                  width: StudentsScreenConstants.desktopSearchWidth,
                  child: AppSearchBar(
                    hint: StudentsScreenConstants.searchHint,
                    width: StudentsScreenConstants.desktopSearchWidth,
                    onSearch: setSearch,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: AppDropdown<String?>(
                    label: StudentsScreenConstants.educationLevelLabel,
                    hint: 'Semua Level',
                    value: levelFilter,
                    items: [
                      const AppDropdownItem(value: null, label: 'Semua Level'),
                      ...levels.map((l) => AppDropdownItem(value: l.id, label: l.name)),
                    ],
                    onChanged: (v) {
                      ref.read(studentsLevelFilterProvider.notifier).state = v;
                      ref.read(studentsCurrentPageProvider.notifier).state = 1;
                    },
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: AppDropdown<String?>(
                    label: StudentsScreenConstants.classLabel,
                    hint: 'Semua Kelas',
                    value: classFilter,
                    items: [
                      const AppDropdownItem(value: null, label: 'Semua Kelas'),
                      ...classes
                          .where((c) => levelFilter == null || c.educationLevelId == levelFilter)
                          .map((c) => AppDropdownItem(value: c.id, label: c.name)),
                    ],
                    onChanged: (v) {
                      ref.read(studentsClassFilterProvider.notifier).state = v;
                      ref.read(studentsCurrentPageProvider.notifier).state = 1;
                    },
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: AppDropdown<String?>(
                    label: StudentsScreenConstants.subClassLabel,
                    hint: 'Semua Sub-Kelas',
                    value: subClassFilter,
                    items: [
                      const AppDropdownItem(value: null, label: 'Semua Sub-Kelas'),
                      ...subClasses
                          .where((s) => classFilter == null || s.classId == classFilter)
                          .map((s) => AppDropdownItem(value: s.id, label: s.name)),
                    ],
                    onChanged: (v) {
                      ref.read(studentsSubClassFilterProvider.notifier).state = v;
                      ref.read(studentsCurrentPageProvider.notifier).state = 1;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: StudentsScreenConstants.desktopAddButtonBottomPadding,
                    left: StudentsScreenConstants.desktopAddButtonLeftPadding,
                  ),
                  child: AppButton.accent(
                    height: StudentsScreenConstants.addButtonHeight,
                    label: StudentsScreenConstants.addButtonLabel,
                    prefixIcon: const Icon(
                      StudentsScreenConstants.addIcon,
                      size: StudentsScreenConstants.actionIconSize,
                      color: AppColors.white,
                    ),
                    onPressed: () => _openStudentCreateModal(context),
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.lg),
          studentsAsync.when(
            loading: () => const AppCard(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: AppLoadingIndicator(message: 'Memuat data siswa...'),
              ),
            ),
            error: (error, _) => AppCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: AppErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(studentsProvider),
                ),
              ),
            ),
            data: (result) {
              final rows = result.items;
              if (rows.isEmpty) {
                final searchQuery = ref.read(studentsSearchQueryProvider);
                final hasSearch = searchQuery.isNotEmpty;

                final String message;
                final String? subtitle;
                if (hasSearch) {
                  message = 'Tidak ada hasil pencarian';
                  subtitle = 'Tidak ditemukan siswa dengan kata kunci "$searchQuery". Coba ubah pencarian.';
                } else if (activeSchool != null) {
                  message = 'Tidak ada data siswa yang tersedia di sekolah ini';
                  subtitle = 'Belum ada siswa terdaftar untuk ${activeSchool.name}. Tambahkan siswa baru.';
                } else {
                  message = 'Tidak ada data siswa yang tersedia';
                  subtitle = 'Belum ada siswa terdaftar di sistem.';
                }

                return AppCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: AppEmptyState(
                      icon: Icons.person_outline,
                      message: message,
                      subtitle: subtitle,
                    ),
                  ),
                );
              }

              return AppCard(
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: AppColors.neutral100),
                              child: DataTable(
                                columnSpacing: isSmallScreen
                                    ? StudentsScreenConstants.tableColumnSpacingMobile
                                    : StudentsScreenConstants.tableColumnSpacingDesktop,
                                horizontalMargin: AppSpacing.md,
                                headingRowHeight: isSmallScreen
                                    ? StudentsScreenConstants.headingRowHeightMobile
                                    : StudentsScreenConstants.headingRowHeightDesktop,
                                dataRowMinHeight: isSmallScreen
                                    ? StudentsScreenConstants.dataRowHeightMobile
                                    : StudentsScreenConstants.dataRowHeightDesktop,
                                dataRowMaxHeight: isSmallScreen
                                    ? StudentsScreenConstants.dataRowHeightMobile
                                    : StudentsScreenConstants.dataRowHeightDesktop,
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
                                  DataColumn(
                                    label: _tableHeader(
                                      StudentsScreenConstants.noHeader,
                                      width: StudentsScreenConstants.noColumnWidth,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      StudentsScreenConstants.nameHeader,
                                      width: isSmallScreen
                                          ? StudentsScreenConstants.nameColumnWidthMobile
                                          : StudentsScreenConstants.nameColumnWidthDesktop,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      StudentsScreenConstants.nisHeader,
                                      width: isSmallScreen
                                          ? StudentsScreenConstants.nisColumnWidthMobile
                                          : StudentsScreenConstants.nisColumnWidthDesktop,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      StudentsScreenConstants.classHeader,
                                      width: isSmallScreen
                                          ? StudentsScreenConstants.classColumnWidthMobile
                                          : StudentsScreenConstants.classColumnWidthDesktop,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      StudentsScreenConstants.statusHeader,
                                      width: isSmallScreen
                                          ? StudentsScreenConstants.statusColumnWidthMobile
                                          : StudentsScreenConstants.statusColumnWidthDesktop,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      StudentsScreenConstants.actionsHeader,
                                      width: isSmallScreen
                                          ? StudentsScreenConstants.actionsColumnWidthMobile
                                          : StudentsScreenConstants.actionsColumnWidthDesktop,
                                    ),
                                  ),
                                ],
                                rows: rows.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final e = entry.value;
                                  final startIndex = (result.page - 1) * result.perPage;
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        SizedBox(
                                          width: StudentsScreenConstants.noColumnWidth,
                                          child: Text(
                                            '${startIndex + index + 1}',
                                            style: AppTextStyles.bodyMdSemiBold.copyWith(
                                              color: AppColors.neutral700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: isSmallScreen
                                              ? StudentsScreenConstants.nameColumnWidthMobile
                                              : StudentsScreenConstants.nameColumnWidthDesktop,
                                          child: Row(
                                            children: [
                                              const CircleAvatar(
                                                radius: StudentsScreenConstants.rowAvatarRadius,
                                                backgroundColor: AppColors.primary100,
                                                child: Icon(
                                                  StudentsScreenConstants.rowAvatarIcon,
                                                  size: StudentsScreenConstants.rowAvatarIconSize,
                                                  color: AppColors.primary700,
                                                ),
                                              ),
                                              const SizedBox(width: AppSpacing.md),
                                              Expanded(
                                                child: Text(
                                                  e.name,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: isSmallScreen
                                              ? StudentsScreenConstants.nisColumnWidthMobile
                                              : StudentsScreenConstants.nisColumnWidthDesktop,
                                          child: Text(e.nis),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: isSmallScreen
                                              ? StudentsScreenConstants.classColumnWidthMobile
                                              : StudentsScreenConstants.classColumnWidthDesktop,
                                          child: Text(getClassName(e.classId, e.subClassId)),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: isSmallScreen
                                              ? StudentsScreenConstants.statusColumnWidthMobile
                                              : StudentsScreenConstants.statusColumnWidthDesktop,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: AppBadge(
                                              label: e.status.toUpperCase(),
                                              status: e.status == StudentsScreenConstants.activeStatus
                                                  ? BadgeStatus.info
                                                  : BadgeStatus.muted,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: isSmallScreen
                                              ? StudentsScreenConstants.actionsColumnWidthMobile
                                              : StudentsScreenConstants.actionsColumnWidthDesktop,
                                          child: Row(
                                            children: [
                                              _actionIconButton(
                                                icon: StudentsScreenConstants.viewIcon,
                                                backgroundColor: AppColors.info,
                                                onTap: () => _openStudentDetailModal(context, e),
                                              ),
                                              const SizedBox(width: AppSpacing.sm),
                                              _actionIconButton(
                                                icon: StudentsScreenConstants.editIcon,
                                                backgroundColor: AppColors.warning,
                                                onTap: () => _openStudentEditModal(context, e),
                                              ),
                                              const SizedBox(width: AppSpacing.sm),
                                              _actionIconButton(
                                                icon: StudentsScreenConstants.deleteIcon,
                                                backgroundColor: AppColors.error,
                                                onTap: () => _openStudentDeleteModal(context, e),
                                              ),
                                            ],
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
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (isSmallScreen)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Halaman ${result.page} dari ${result.totalPages}',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral700),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Center(
                            child: AppPagination(
                              currentPage: result.page,
                              totalPages: result.totalPages,
                              onPageChanged: (page) {
                                ref.read(studentsCurrentPageProvider.notifier).state = page;
                              },
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Halaman ${result.page} dari ${result.totalPages}',
                            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral700),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          AppPagination(
                            currentPage: result.page,
                            totalPages: result.totalPages,
                            onPageChanged: (page) {
                              ref.read(studentsCurrentPageProvider.notifier).state = page;
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String label, {double? width}) {
    final header = Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    if (width == null) return header;
    return SizedBox(width: width, child: header);
  }

  Widget _actionIconButton({
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: StudentsScreenConstants.actionButtonSize,
      height: StudentsScreenConstants.actionButtonSize,
      child: Material(
        color: backgroundColor,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Icon(
            icon,
            color: AppColors.white,
            size: StudentsScreenConstants.actionIconSize,
          ),
        ),
      ),
    );
  }

  void _openStudentDetailModal(BuildContext context, StudentRowData row) {
    showStudentDetailModal(context, data: row);
  }

  void _openStudentDeleteModal(BuildContext context, StudentRowData row) {
    showStudentDeleteModal(context, data: row);
  }

  void _openStudentEditModal(BuildContext context, StudentRowData row) {
    showStudentEditModal(context, data: row);
  }

  void _openStudentCreateModal(BuildContext context) {
    showStudentCreateModal(context);
  }
}
