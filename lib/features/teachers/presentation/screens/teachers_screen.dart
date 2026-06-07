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
import '../constants/teachers_screen_constants.dart';
import '../providers/teachers_provider.dart';
import '../widgets/teacher_create_modal.dart';
import '../widgets/teacher_delete_modal.dart';
import '../widgets/teacher_detail_modal.dart';
import '../widgets/teacher_edit_modal.dart';

class TeachersScreen extends ConsumerWidget {
  const TeachersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSmallScreen = Responsive.isMobile(context);
    final teachersAsync = ref.watch(teachersProvider);
    final activeSchool = ref.watch(activeSchoolProvider);

    ref.listen(activeSchoolProvider, (_, next) {
      ref.read(teachersCurrentPageProvider.notifier).state = 1;
      ref.invalidate(teachersProvider);
    });

    void setSearch(String value) {
      ref.read(teachersSearchQueryProvider.notifier).state = value.toLowerCase().trim();
      ref.read(teachersCurrentPageProvider.notifier).state = 1;
    }

    return SingleChildScrollView(
      padding: isSmallScreen
          ? const EdgeInsets.all(AppSpacing.lg)
          : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TeachersScreenConstants.title,
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
          const SchoolFilter(label: 'Sekolah Guru', allLabel: 'Semua Sekolah'),
          const SizedBox(height: AppSpacing.md),
          if (isSmallScreen)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSearchBar(
                  hint: TeachersScreenConstants.searchHint,
                  width: double.infinity,
                  onSearch: setSearch,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton.accent(
                  height: TeachersScreenConstants.addButtonHeight,
                  isFullWidth: true,
                  label: TeachersScreenConstants.addButtonLabel,
                  prefixIcon: const Icon(
                    TeachersScreenConstants.addIcon,
                    size: TeachersScreenConstants.actionIconSize,
                    color: AppColors.white,
                  ),
                  onPressed: () => showTeacherCreateModal(context, ref),
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: TeachersScreenConstants.desktopSearchWidth,
                      child: AppSearchBar(
                        hint: TeachersScreenConstants.searchHint,
                        width: TeachersScreenConstants.desktopSearchWidth,
                        onSearch: setSearch,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: TeachersScreenConstants.desktopAddButtonBottomPadding,
                    right: TeachersScreenConstants.desktopAddButtonRightPadding,
                  ),
                  child: AppButton.accent(
                    height: TeachersScreenConstants.addButtonHeight,
                    label: TeachersScreenConstants.addButtonLabel,
                    prefixIcon: const Icon(
                      TeachersScreenConstants.addIcon,
                      size: TeachersScreenConstants.actionIconSize,
                      color: AppColors.white,
                    ),
                    onPressed: () => showTeacherCreateModal(context, ref),
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.lg),
          teachersAsync.when(
            loading: () => const AppCard(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: AppLoadingIndicator(message: 'Memuat data guru...'),
              ),
            ),
            error: (error, _) => AppCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: AppErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(teachersProvider),
                ),
              ),
            ),
            data: (result) {
              final rows = result.items;
              if (rows.isEmpty) {
                final searchQuery = ref.read(teachersSearchQueryProvider);
                final hasSearch = searchQuery.isNotEmpty;

                final String message;
                final String? subtitle;
                if (hasSearch) {
                  message = 'Tidak ada hasil pencarian';
                  subtitle =
                      'Tidak ditemukan guru dengan kata kunci "$searchQuery". Coba ubah pencarian.';
                } else if (activeSchool != null) {
                  message = 'Tidak ada data guru yang tersedia di sekolah ini';
                  subtitle =
                      'Belum ada guru terdaftar untuk ${activeSchool.name}. Tambahkan guru baru.';
                } else {
                  message = 'Tidak ada data guru yang tersedia';
                  subtitle = 'Belum ada guru terdaftar di sistem.';
                }

                return AppCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: AppEmptyState(
                      icon: Icons.badge_outlined,
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
                            constraints: BoxConstraints(minWidth: constraints.maxWidth),
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: AppColors.neutral100),
                              child: DataTable(
                                columnSpacing: isSmallScreen
                                    ? TeachersScreenConstants.tableColumnSpacingMobile
                                    : TeachersScreenConstants.tableColumnSpacingDesktop,
                                horizontalMargin: AppSpacing.md,
                                headingRowHeight: isSmallScreen
                                    ? TeachersScreenConstants.headingRowHeightMobile
                                    : TeachersScreenConstants.headingRowHeightDesktop,
                                dataRowMinHeight: isSmallScreen
                                    ? TeachersScreenConstants.dataRowHeightMobile
                                    : TeachersScreenConstants.dataRowHeightDesktop,
                                dataRowMaxHeight: isSmallScreen
                                    ? TeachersScreenConstants.dataRowHeightMobile
                                    : TeachersScreenConstants.dataRowHeightDesktop,
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
                                      TeachersScreenConstants.noHeader,
                                      width: TeachersScreenConstants.noColumnWidth,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      TeachersScreenConstants.nameHeader,
                                      width: isSmallScreen
                                          ? TeachersScreenConstants.nameColumnWidthMobile
                                          : TeachersScreenConstants.nameColumnWidthDesktop,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      TeachersScreenConstants.nipHeader,
                                      width: isSmallScreen
                                          ? TeachersScreenConstants.nipColumnWidthMobile
                                          : TeachersScreenConstants.nipColumnWidthDesktop,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      TeachersScreenConstants.subjectHeader,
                                      width: isSmallScreen
                                          ? TeachersScreenConstants.subjectColumnWidthMobile
                                          : TeachersScreenConstants.subjectColumnWidthDesktop,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      TeachersScreenConstants.actionsHeader,
                                      width: isSmallScreen
                                          ? TeachersScreenConstants.actionsColumnWidthMobile
                                          : TeachersScreenConstants.actionsColumnWidthDesktop,
                                    ),
                                  ),
                                ],
                                rows: rows.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final row = entry.value;
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        SizedBox(
                                          width: TeachersScreenConstants.noColumnWidth,
                                          child: Text(
                                            '${(result.page - 1) * TeachersScreenConstants.rowsPerPage + index + 1}',
                                            style: AppTextStyles.bodyMdSemiBold.copyWith(
                                              color: AppColors.neutral700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: isSmallScreen
                                              ? TeachersScreenConstants.nameColumnWidthMobile
                                              : TeachersScreenConstants.nameColumnWidthDesktop,
                                          child: Row(
                                            children: [
                                              const CircleAvatar(
                                                radius: TeachersScreenConstants.rowAvatarRadius,
                                                backgroundColor: AppColors.primary100,
                                                child: Icon(
                                                  TeachersScreenConstants.rowAvatarIcon,
                                                  size: TeachersScreenConstants.rowAvatarIconSize,
                                                  color: AppColors.primary700,
                                                ),
                                              ),
                                              const SizedBox(width: AppSpacing.md),
                                              Expanded(
                                                child: Text(
                                                  row.name,
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
                                              ? TeachersScreenConstants.nipColumnWidthMobile
                                              : TeachersScreenConstants.nipColumnWidthDesktop,
                                          child: Text(row.nip.isEmpty ? '-' : row.nip),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: isSmallScreen
                                              ? TeachersScreenConstants.subjectColumnWidthMobile
                                              : TeachersScreenConstants.subjectColumnWidthDesktop,
                                          child: Text(row.username.isEmpty ? '-' : row.username),
                                        ),
                                      ),
                                      // DataCell(
                                      //   SizedBox(
                                      //     width: isSmallScreen
                                      //         ? TeachersScreenConstants.statusColumnWidthMobile
                                      //         : TeachersScreenConstants.statusColumnWidthDesktop,
                                      //     child: Align(
                                      //       alignment: Alignment.centerLeft,
                                      //       child: AppBadge(
                                      //         label: row.status.toUpperCase(),
                                      //         status: row.isActive
                                      //             ? BadgeStatus.info
                                      //             : BadgeStatus.muted,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      DataCell(
                                        SizedBox(
                                          width: isSmallScreen
                                              ? TeachersScreenConstants.actionsColumnWidthMobile
                                              : TeachersScreenConstants.actionsColumnWidthDesktop,
                                          child: Row(
                                            children: [
                                              _actionIconButton(
                                                icon: TeachersScreenConstants.viewIcon,
                                                backgroundColor: AppColors.info,
                                                onTap: () => showTeacherDetailModal(context, data: row),
                                              ),
                                              const SizedBox(width: AppSpacing.sm),
                                              _actionIconButton(
                                                icon: TeachersScreenConstants.editIcon,
                                                backgroundColor: AppColors.warning,
                                                onTap: () => showTeacherEditModal(context, ref: ref, data: row),
                                              ),
                                              const SizedBox(width: AppSpacing.sm),
                                              _actionIconButton(
                                                icon: TeachersScreenConstants.deleteIcon,
                                                backgroundColor: AppColors.error,
                                                onTap: () => showTeacherDeleteModal(context, ref: ref, data: row),
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
                                ref.read(teachersCurrentPageProvider.notifier).state = page;
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
                              ref.read(teachersCurrentPageProvider.notifier).state = page;
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
      width: TeachersScreenConstants.actionButtonSize,
      height: TeachersScreenConstants.actionButtonSize,
      child: Material(
        color: backgroundColor,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Icon(
            icon,
            color: AppColors.white,
            size: TeachersScreenConstants.actionIconSize,
          ),
        ),
      ),
    );
  }
}