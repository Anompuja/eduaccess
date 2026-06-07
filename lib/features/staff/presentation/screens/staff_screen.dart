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
import '../constants/staff_screen_constants.dart';
import '../providers/staff_provider.dart';
import '../widgets/staff_create_modal.dart';
import '../widgets/staff_delete_modal.dart';
import '../widgets/staff_detail_modal.dart';
import '../widgets/staff_edit_modal.dart';

class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSmallScreen = Responsive.isMobile(context);
    final activeSchool = ref.watch(activeSchoolProvider);
    final staffAsync = ref.watch(staffProvider);

    ref.listen(activeSchoolProvider, (_, __) {
      ref.read(staffCurrentPageProvider.notifier).state = 1;
      ref.invalidate(staffProvider);
    });

    void setSearch(String value) {
      ref.read(staffSearchQueryProvider.notifier).state = value
          .toLowerCase()
          .trim();
      ref.read(staffCurrentPageProvider.notifier).state = 1;
    }

    return SingleChildScrollView(
      padding: isSmallScreen
          ? const EdgeInsets.all(AppSpacing.lg)
          : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StaffScreenConstants.title,
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
          const SchoolFilter(label: 'Sekolah Staff', allLabel: 'Semua Sekolah'),
          const SizedBox(height: AppSpacing.md),
          if (isSmallScreen)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSearchBar(
                  hint: StaffScreenConstants.searchHint,
                  width: double.infinity,
                  onSearch: setSearch,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton.accent(
                  height: StaffScreenConstants.addButtonHeight,
                  isFullWidth: true,
                  label: StaffScreenConstants.addButtonLabel,
                  prefixIcon: const Icon(
                    StaffScreenConstants.addIcon,
                    size: StaffScreenConstants.actionIconSize,
                    color: AppColors.white,
                  ),
                  onPressed: () => showStaffCreateModal(context),
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
                      width: StaffScreenConstants.desktopSearchWidth,
                      child: AppSearchBar(
                        hint: StaffScreenConstants.searchHint,
                        width: StaffScreenConstants.desktopSearchWidth,
                        onSearch: setSearch,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: StaffScreenConstants.desktopAddButtonBottomPadding,
                    right: StaffScreenConstants.desktopAddButtonRightPadding,
                  ),
                  child: AppButton.accent(
                    height: StaffScreenConstants.addButtonHeight,
                    label: StaffScreenConstants.addButtonLabel,
                    prefixIcon: const Icon(
                      StaffScreenConstants.addIcon,
                      size: StaffScreenConstants.actionIconSize,
                      color: AppColors.white,
                    ),
                    onPressed: () => showStaffCreateModal(context),
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.lg),
          staffAsync.when(
            loading: () => const AppCard(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: AppLoadingIndicator(message: 'Memuat data staff...'),
              ),
            ),
            error: (error, _) => AppCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: AppErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(staffProvider),
                ),
              ),
            ),
            data: (result) {
              final rows = result.items;
              if (rows.isEmpty) {
                final searchQuery = ref.read(staffSearchQueryProvider);
                final hasSearch = searchQuery.isNotEmpty;

                final String message;
                final String? subtitle;
                if (hasSearch) {
                  message = 'Tidak ada hasil pencarian';
                  subtitle =
                      'Tidak ditemukan staff dengan kata kunci "$searchQuery". Coba ubah pencarian.';
                } else if (activeSchool != null) {
                  message = 'Tidak ada data staff yang tersedia di sekolah ini';
                  subtitle =
                      'Belum ada staff terdaftar untuk ${activeSchool.name}. Tambahkan staff baru.';
                } else {
                  message = 'Tidak ada data staff yang tersedia';
                  subtitle = 'Belum ada staff terdaftar di sistem.';
                }

                return AppCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xl,
                    ),
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
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: Theme(
                              data: Theme.of(
                                context,
                              ).copyWith(dividerColor: AppColors.neutral100),
                              child: DataTable(
                                columnSpacing: isSmallScreen
                                    ? StaffScreenConstants
                                          .tableColumnSpacingMobile
                                    : StaffScreenConstants
                                          .tableColumnSpacingDesktop,
                                horizontalMargin: AppSpacing.md,
                                headingRowHeight: isSmallScreen
                                    ? StaffScreenConstants
                                          .headingRowHeightMobile
                                    : StaffScreenConstants
                                          .headingRowHeightDesktop,
                                dataRowMinHeight: isSmallScreen
                                    ? StaffScreenConstants.dataRowHeightMobile
                                    : StaffScreenConstants.dataRowHeightDesktop,
                                dataRowMaxHeight: isSmallScreen
                                    ? StaffScreenConstants.dataRowHeightMobile
                                    : StaffScreenConstants.dataRowHeightDesktop,
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
                                      StaffScreenConstants.noHeader,
                                      width: StaffScreenConstants.noColumnWidth,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      StaffScreenConstants.nameHeader,
                                      width: isSmallScreen
                                          ? StaffScreenConstants
                                                .nameColumnWidthMobile
                                          : StaffScreenConstants
                                                .nameColumnWidthDesktop,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      StaffScreenConstants.emailHeader,
                                      width: isSmallScreen
                                          ? StaffScreenConstants
                                                .emailColumnWidthMobile
                                          : StaffScreenConstants
                                                .emailColumnWidthDesktop,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      StaffScreenConstants.usernameHeader,
                                      width: isSmallScreen
                                          ? StaffScreenConstants
                                                .usernameColumnWidthMobile
                                          : StaffScreenConstants
                                                .usernameColumnWidthDesktop,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      StaffScreenConstants.phoneHeader,
                                      width: isSmallScreen
                                          ? StaffScreenConstants
                                                .phoneColumnWidthMobile
                                          : StaffScreenConstants
                                                .phoneColumnWidthDesktop,
                                    ),
                                  ),
                                  // DataColumn(
                                  //   label: _tableHeader(
                                  //     StaffScreenConstants.statusHeader,
                                  //     width: isSmallScreen
                                  //         ? StaffScreenConstants
                                  //               .statusColumnWidthMobile
                                  //         : StaffScreenConstants
                                  //               .statusColumnWidthDesktop,
                                  //   ),
                                  // ),
                                  DataColumn(
                                    label: _tableHeader(
                                      StaffScreenConstants.actionsHeader,
                                      width: isSmallScreen
                                          ? StaffScreenConstants
                                                .actionsColumnWidthMobile
                                          : StaffScreenConstants
                                                .actionsColumnWidthDesktop,
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
                                          width: StaffScreenConstants
                                              .noColumnWidth,
                                          child: Text(
                                            '${(result.page - 1) * StaffScreenConstants.rowsPerPage + index + 1}',
                                            style: AppTextStyles.bodyMdSemiBold
                                                .copyWith(
                                                  color: AppColors.neutral700,
                                                ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: isSmallScreen
                                              ? StaffScreenConstants
                                                    .nameColumnWidthMobile
                                              : StaffScreenConstants
                                                    .nameColumnWidthDesktop,
                                          child: Row(
                                            children: [
                                              const CircleAvatar(
                                                radius: StaffScreenConstants
                                                    .rowAvatarRadius,
                                                backgroundColor:
                                                    AppColors.primary100,
                                                child: Icon(
                                                  StaffScreenConstants
                                                      .rowAvatarIcon,
                                                  size: StaffScreenConstants
                                                      .rowAvatarIconSize,
                                                  color: AppColors.primary700,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.md,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  row.name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: isSmallScreen
                                              ? StaffScreenConstants
                                                    .emailColumnWidthMobile
                                              : StaffScreenConstants
                                                    .emailColumnWidthDesktop,
                                          child: Text(row.email),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: isSmallScreen
                                              ? StaffScreenConstants
                                                    .usernameColumnWidthMobile
                                              : StaffScreenConstants
                                                    .usernameColumnWidthDesktop,
                                          child: Text(
                                            row.username.isEmpty
                                                ? '-'
                                                : row.username,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: isSmallScreen
                                              ? StaffScreenConstants
                                                    .phoneColumnWidthMobile
                                              : StaffScreenConstants
                                                    .phoneColumnWidthDesktop,
                                          child: Text(
                                            row.phoneNumber.isEmpty
                                                ? '-'
                                                : row.phoneNumber,
                                          ),
                                        ),
                                      ),
                                      // DataCell(
                                      //   SizedBox(
                                      //     width: isSmallScreen
                                      //         ? StaffScreenConstants
                                      //               .statusColumnWidthMobile
                                      //         : StaffScreenConstants
                                      //               .statusColumnWidthDesktop,
                                      //     child: Align(
                                      //       alignment: Alignment.centerLeft,
                                      //       child: AppBadge(
                                      //         label: row.status.toUpperCase(),
                                      //         status:
                                      //             row.status ==
                                      //                 StaffScreenConstants
                                      //                     .activeStatus
                                      //             ? BadgeStatus.info
                                      //             : BadgeStatus.muted,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      DataCell(
                                        SizedBox(
                                          width: isSmallScreen
                                              ? StaffScreenConstants
                                                    .actionsColumnWidthMobile
                                              : StaffScreenConstants
                                                    .actionsColumnWidthDesktop,
                                          child: Row(
                                            children: [
                                              _actionIconButton(
                                                icon: StaffScreenConstants
                                                    .viewIcon,
                                                backgroundColor: AppColors.info,
                                                onTap: () =>
                                                    showStaffDetailModal(
                                                      context,
                                                      data: row,
                                                    ),
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.sm,
                                              ),
                                              _actionIconButton(
                                                icon: StaffScreenConstants
                                                    .editIcon,
                                                backgroundColor:
                                                    AppColors.warning,
                                                onTap: () => showStaffEditModal(
                                                  context,
                                                  ref: ref,
                                                  data: row,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.sm,
                                              ),
                                              _actionIconButton(
                                                icon: StaffScreenConstants
                                                    .deleteIcon,
                                                backgroundColor:
                                                    AppColors.error,
                                                onTap: () =>
                                                    showStaffDeleteModal(
                                                      context,
                                                      ref: ref,
                                                      data: row,
                                                    ),
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
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.neutral700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Center(
                            child: AppPagination(
                              currentPage: result.page,
                              totalPages: result.totalPages,
                              onPageChanged: (page) {
                                ref
                                        .read(staffCurrentPageProvider.notifier)
                                        .state =
                                    page;
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
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.neutral700,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          AppPagination(
                            currentPage: result.page,
                            totalPages: result.totalPages,
                            onPageChanged: (page) {
                              ref
                                      .read(staffCurrentPageProvider.notifier)
                                      .state =
                                  page;
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
      width: StaffScreenConstants.actionButtonSize,
      height: StaffScreenConstants.actionButtonSize,
      child: Material(
        color: backgroundColor,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Icon(
            icon,
            color: AppColors.white,
            size: StaffScreenConstants.actionIconSize,
          ),
        ),
      ),
    );
  }
}
