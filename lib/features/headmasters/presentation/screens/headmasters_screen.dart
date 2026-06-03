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
import '../constants/headmasters_screen_constants.dart';
import '../providers/headmasters_provider.dart';
import '../widgets/headmaster_create_modal.dart';
import '../widgets/headmaster_delete_modal.dart';
import '../widgets/headmaster_detail_modal.dart';
import '../widgets/headmaster_edit_modal.dart';

class HeadmastersScreen extends ConsumerWidget {
  const HeadmastersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSmallScreen = Responsive.isMobile(context);
    final activeSchool = ref.watch(activeSchoolProvider);
    final headmastersAsync = ref.watch(headmastersProvider);

    ref.listen(activeSchoolProvider, (_, nextSchool) {
      ref.read(headmastersCurrentPageProvider.notifier).state = 1;
      ref.invalidate(headmastersProvider);
    });

    void setSearch(String value) {
      ref.read(headmastersSearchQueryProvider.notifier).state = value
          .toLowerCase()
          .trim();
      ref.read(headmastersCurrentPageProvider.notifier).state = 1;
    }

    return SingleChildScrollView(
      padding: isSmallScreen
          ? const EdgeInsets.all(AppSpacing.lg)
          : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            HeadmastersScreenConstants.title,
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
          const SchoolFilter(
            label: 'Sekolah Kepala Sekolah',
            allLabel: 'Semua Sekolah',
          ),
          const SizedBox(height: AppSpacing.md),
          if (isSmallScreen)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSearchBar(
                  hint: HeadmastersScreenConstants.searchHint,
                  width: double.infinity,
                  onSearch: setSearch,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton.accent(
                  height: HeadmastersScreenConstants.addButtonHeight,
                  isFullWidth: true,
                  label: HeadmastersScreenConstants.addButtonLabel,
                  prefixIcon: const Icon(
                    HeadmastersScreenConstants.addIcon,
                    size: HeadmastersScreenConstants.actionIconSize,
                    color: AppColors.white,
                  ),
                  onPressed: () => showHeadmasterCreateModal(context),
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
                      width: HeadmastersScreenConstants.desktopSearchWidth,
                      child: AppSearchBar(
                        hint: HeadmastersScreenConstants.searchHint,
                        width: HeadmastersScreenConstants.desktopSearchWidth,
                        onSearch: setSearch,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: HeadmastersScreenConstants
                        .desktopAddButtonBottomPadding,
                    right:
                        HeadmastersScreenConstants.desktopAddButtonRightPadding,
                  ),
                  child: AppButton.accent(
                    height: HeadmastersScreenConstants.addButtonHeight,
                    label: HeadmastersScreenConstants.addButtonLabel,
                    prefixIcon: const Icon(
                      HeadmastersScreenConstants.addIcon,
                      size: HeadmastersScreenConstants.actionIconSize,
                      color: AppColors.white,
                    ),
                    onPressed: () => showHeadmasterCreateModal(context),
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.lg),
          headmastersAsync.when(
            loading: () => const AppCard(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: AppLoadingIndicator(
                  message: 'Memuat data kepala sekolah...',
                ),
              ),
            ),
            error: (error, _) => AppCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: AppErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(headmastersProvider),
                ),
              ),
            ),
            data: (result) {
              final rows = result.items;
              if (rows.isEmpty) {
                final searchQuery = ref.read(headmastersSearchQueryProvider);
                final hasSearch = searchQuery.isNotEmpty;

                final String message;
                final String? subtitle;
                if (hasSearch) {
                  message = 'Tidak ada hasil pencarian';
                  subtitle =
                      'Tidak ditemukan kepala sekolah dengan kata kunci "$searchQuery". Coba ubah pencarian.';
                } else if (activeSchool != null) {
                  message =
                      'Tidak ada data kepala sekolah yang tersedia di sekolah ini';
                  subtitle =
                      'Belum ada kepala sekolah terdaftar untuk ${activeSchool.name}. Tambahkan data baru.';
                } else {
                  message = 'Tidak ada data kepala sekolah yang tersedia';
                  subtitle = 'Belum ada kepala sekolah terdaftar di sistem.';
                }

                return AppCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xl,
                    ),
                    child: AppEmptyState(
                      icon: Icons.account_balance_outlined,
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
                                    ? HeadmastersScreenConstants
                                          .tableColumnSpacingMobile
                                    : HeadmastersScreenConstants
                                          .tableColumnSpacingDesktop,
                                horizontalMargin: AppSpacing.md,
                                headingRowHeight: isSmallScreen
                                    ? HeadmastersScreenConstants
                                          .headingRowHeightMobile
                                    : HeadmastersScreenConstants
                                          .headingRowHeightDesktop,
                                dataRowMinHeight: isSmallScreen
                                    ? HeadmastersScreenConstants
                                          .dataRowHeightMobile
                                    : HeadmastersScreenConstants
                                          .dataRowHeightDesktop,
                                dataRowMaxHeight: isSmallScreen
                                    ? HeadmastersScreenConstants
                                          .dataRowHeightMobile
                                    : HeadmastersScreenConstants
                                          .dataRowHeightDesktop,
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
                                      HeadmastersScreenConstants.noHeader,
                                      width: HeadmastersScreenConstants
                                          .noColumnWidth,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      HeadmastersScreenConstants.nameHeader,
                                      width: isSmallScreen
                                          ? HeadmastersScreenConstants
                                                .nameColumnWidthMobile
                                          : HeadmastersScreenConstants
                                                .nameColumnWidthDesktop,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      HeadmastersScreenConstants.nipHeader,
                                      width: isSmallScreen
                                          ? HeadmastersScreenConstants
                                                .nipColumnWidthMobile
                                          : HeadmastersScreenConstants
                                                .nipColumnWidthDesktop,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      HeadmastersScreenConstants.emailHeader,
                                      width: isSmallScreen
                                          ? HeadmastersScreenConstants
                                                .emailColumnWidthMobile
                                          : HeadmastersScreenConstants
                                                .emailColumnWidthDesktop,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      HeadmastersScreenConstants.statusHeader,
                                      width: isSmallScreen
                                          ? HeadmastersScreenConstants
                                                .statusColumnWidthMobile
                                          : HeadmastersScreenConstants
                                                .statusColumnWidthDesktop,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      HeadmastersScreenConstants.actionsHeader,
                                      width: isSmallScreen
                                          ? HeadmastersScreenConstants
                                                .actionsColumnWidthMobile
                                          : HeadmastersScreenConstants
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
                                          width: HeadmastersScreenConstants
                                              .noColumnWidth,
                                          child: Text(
                                            '${(result.page - 1) * HeadmastersScreenConstants.rowsPerPage + index + 1}',
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
                                              ? HeadmastersScreenConstants
                                                    .nameColumnWidthMobile
                                              : HeadmastersScreenConstants
                                                    .nameColumnWidthDesktop,
                                          child: Row(
                                            children: [
                                              const CircleAvatar(
                                                radius:
                                                    HeadmastersScreenConstants
                                                        .rowAvatarRadius,
                                                backgroundColor:
                                                    AppColors.primary100,
                                                child: Icon(
                                                  HeadmastersScreenConstants
                                                      .rowAvatarIcon,
                                                  size:
                                                      HeadmastersScreenConstants
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
                                              ? HeadmastersScreenConstants
                                                    .nipColumnWidthMobile
                                              : HeadmastersScreenConstants
                                                    .nipColumnWidthDesktop,
                                          child: Text(
                                            row.nip.isEmpty ? '-' : row.nip,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: isSmallScreen
                                              ? HeadmastersScreenConstants
                                                    .emailColumnWidthMobile
                                              : HeadmastersScreenConstants
                                                    .emailColumnWidthDesktop,
                                          child: Text(
                                            row.email.isEmpty ? '-' : row.email,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: isSmallScreen
                                              ? HeadmastersScreenConstants
                                                    .statusColumnWidthMobile
                                              : HeadmastersScreenConstants
                                                    .statusColumnWidthDesktop,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: AppBadge(
                                              label: row.status.toUpperCase(),
                                              status: row.isActive
                                                  ? BadgeStatus.info
                                                  : BadgeStatus.muted,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: isSmallScreen
                                              ? HeadmastersScreenConstants
                                                    .actionsColumnWidthMobile
                                              : HeadmastersScreenConstants
                                                    .actionsColumnWidthDesktop,
                                          child: Row(
                                            children: [
                                              _actionIconButton(
                                                icon: HeadmastersScreenConstants
                                                    .viewIcon,
                                                backgroundColor: AppColors.info,
                                                onTap: () =>
                                                    showHeadmasterDetailModal(
                                                      context,
                                                      data: row,
                                                    ),
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.sm,
                                              ),
                                              _actionIconButton(
                                                icon: HeadmastersScreenConstants
                                                    .editIcon,
                                                backgroundColor:
                                                    AppColors.warning,
                                                onTap: () =>
                                                    showHeadmasterEditModal(
                                                      context,
                                                      ref: ref,
                                                      data: row,
                                                    ),
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.sm,
                                              ),
                                              _actionIconButton(
                                                icon: HeadmastersScreenConstants
                                                    .deleteIcon,
                                                backgroundColor:
                                                    AppColors.error,
                                                onTap: () =>
                                                    showHeadmasterDeleteModal(
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
                                        .read(
                                          headmastersCurrentPageProvider
                                              .notifier,
                                        )
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
                                      .read(
                                        headmastersCurrentPageProvider.notifier,
                                      )
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
      width: HeadmastersScreenConstants.actionButtonSize,
      height: HeadmastersScreenConstants.actionButtonSize,
      child: Material(
        color: backgroundColor,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Icon(
            icon,
            color: AppColors.white,
            size: HeadmastersScreenConstants.actionIconSize,
          ),
        ),
      ),
    );
  }
}
