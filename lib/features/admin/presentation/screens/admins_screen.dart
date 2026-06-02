import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/active_school_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_pagination.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/school_filter.dart';
import '../constants/admins_screen_constants.dart';
import '../providers/admins_provider.dart';
import '../widgets/admin_create_modal.dart';
import '../widgets/admin_delete_modal.dart';
import '../widgets/admin_detail_modal.dart';
import '../widgets/admin_edit_modal.dart';
import '../../../dashboard/domain/entities/dashboard_school.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

class AdminsScreen extends ConsumerWidget {
  const AdminsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSmallScreen = Responsive.isMobile(context);
    final adminsAsync = ref.watch(adminsProvider);
    final activeSchool = ref.watch(activeSchoolProvider);
    final schoolsAsync = ref.watch(dashboardSchoolsProvider);
    final schools = schoolsAsync.valueOrNull ?? const <DashboardSchool>[];

    ref.listen(activeSchoolProvider, (_, next) {
      ref.read(adminsCurrentPageProvider.notifier).state = 1;
      ref.invalidate(adminsProvider);
    });

    void setSearch(String value) {
      ref.read(adminsSearchQueryProvider.notifier).state = value
          .toLowerCase()
          .trim();
      ref.read(adminsCurrentPageProvider.notifier).state = 1;
    }

    return SingleChildScrollView(
      padding: isSmallScreen
          ? const EdgeInsets.all(AppSpacing.lg)
          : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AdminsScreenConstants.title,
            style: AppTextStyles.h2.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            activeSchool == null
                ? 'Menampilkan data dari semua sekolah'
                : 'Data untuk: ${activeSchool.name}',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.sm),
          const SchoolFilter(label: 'Sekolah Admin', allLabel: 'Semua Sekolah'),
          const SizedBox(height: AppSpacing.md),
          if (isSmallScreen)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSearchBar(
                  hint: AdminsScreenConstants.searchHint,
                  width: double.infinity,
                  onSearch: setSearch,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton.accent(
                  height: AdminsScreenConstants.addButtonHeight,
                  isFullWidth: true,
                  label: AdminsScreenConstants.addButtonLabel,
                  prefixIcon: const Icon(
                    AdminsScreenConstants.addIcon,
                    size: AdminsScreenConstants.actionIconSize,
                    color: AppColors.white,
                  ),
                  onPressed: () => showAdminCreateModal(context, ref),
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
                      width: AdminsScreenConstants.desktopSearchWidth,
                      child: AppSearchBar(
                        hint: AdminsScreenConstants.searchHint,
                        width: AdminsScreenConstants.desktopSearchWidth,
                        onSearch: setSearch,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: AdminsScreenConstants.desktopAddButtonBottomPadding,
                    right: AdminsScreenConstants.desktopAddButtonRightPadding,
                  ),
                  child: AppButton.accent(
                    height: AdminsScreenConstants.addButtonHeight,
                    label: AdminsScreenConstants.addButtonLabel,
                    prefixIcon: const Icon(
                      AdminsScreenConstants.addIcon,
                      size: AdminsScreenConstants.actionIconSize,
                      color: AppColors.white,
                    ),
                    onPressed: () => showAdminCreateModal(context, ref),
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.lg),
          adminsAsync.when(
            loading: () => const AppCard(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: AppLoadingIndicator(message: 'Memuat data admin...'),
              ),
            ),
            error: (error, _) => AppCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: AppErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(adminsProvider),
                ),
              ),
            ),
            data: (result) {
              final rows = result.items;
              if (rows.isEmpty) {
                final searchQuery = ref.read(adminsSearchQueryProvider);
                final hasSearch = searchQuery.isNotEmpty;

                final String message;
                final String? subtitle;
                if (hasSearch) {
                  message = 'Tidak ada hasil pencarian';
                  subtitle =
                      'Tidak ditemukan admin dengan kata kunci "$searchQuery". Coba ubah pencarian.';
                } else if (activeSchool != null) {
                  message = 'Tidak ada data admin yang tersedia di sekolah ini';
                  subtitle =
                      'Belum ada admin terdaftar untuk ${activeSchool.name}. Tambahkan admin baru.';
                } else {
                  message = 'Tidak ada data admin yang tersedia';
                  subtitle = 'Belum ada admin terdaftar di sistem.';
                }

                return AppCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xl,
                    ),
                    child: AppEmptyState(
                      icon: Icons.admin_panel_settings_outlined,
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
                                    ? AdminsScreenConstants
                                          .tableColumnSpacingMobile
                                    : AdminsScreenConstants
                                          .tableColumnSpacingDesktop,
                                horizontalMargin: AppSpacing.md,
                                headingRowHeight: isSmallScreen
                                    ? AdminsScreenConstants
                                          .headingRowHeightMobile
                                    : AdminsScreenConstants
                                          .headingRowHeightDesktop,
                                dataRowMinHeight: isSmallScreen
                                    ? AdminsScreenConstants.dataRowHeightMobile
                                    : AdminsScreenConstants
                                          .dataRowHeightDesktop,
                                dataRowMaxHeight: isSmallScreen
                                    ? AdminsScreenConstants.dataRowHeightMobile
                                    : AdminsScreenConstants
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
                                      AdminsScreenConstants.noHeader,
                                      width:
                                          AdminsScreenConstants.noColumnWidth,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      AdminsScreenConstants.nameHeader,
                                      width: isSmallScreen
                                          ? AdminsScreenConstants
                                                .nameColumnWidthMobile
                                          : AdminsScreenConstants
                                                .nameColumnWidthDesktop,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      AdminsScreenConstants.schoolHeader,
                                      width: isSmallScreen
                                          ? AdminsScreenConstants
                                                .schoolColumnWidthMobile
                                          : AdminsScreenConstants
                                                .schoolColumnWidthDesktop,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      AdminsScreenConstants.phoneNumberHeader,
                                      width: isSmallScreen
                                          ? AdminsScreenConstants
                                                .phoneNumberColumnWidthMobile
                                          : AdminsScreenConstants
                                                .phoneNumberColumnWidthDesktop,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      AdminsScreenConstants.addressHeader,
                                      width: isSmallScreen
                                          ? AdminsScreenConstants
                                                .addressColumnWidthMobile
                                          : AdminsScreenConstants
                                                .addressColumnWidthDesktop,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      AdminsScreenConstants.nikHeader,
                                      width: isSmallScreen
                                          ? AdminsScreenConstants
                                                .nikColumnWidthMobile
                                          : AdminsScreenConstants
                                                .nikColumnWidthDesktop,
                                    ),
                                  ),
                                  DataColumn(
                                    label: _tableHeader(
                                      AdminsScreenConstants.actionsHeader,
                                      width: isSmallScreen
                                          ? AdminsScreenConstants
                                                .actionsColumnWidthMobile
                                          : AdminsScreenConstants
                                                .actionsColumnWidthDesktop,
                                    ),
                                  ),
                                ],
                                rows: rows.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final row = entry.value;
                                  final schoolName =
                                      schools
                                          .where(
                                            (school) =>
                                                school.id == row.schoolId,
                                          )
                                          .cast<DashboardSchool?>()
                                          .firstWhere(
                                            (school) => school != null,
                                            orElse: () => null,
                                          )
                                          ?.name ??
                                      (row.schoolId.isEmpty
                                          ? '-'
                                          : row.schoolId);
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        SizedBox(
                                          width: AdminsScreenConstants
                                              .noColumnWidth,
                                          child: Text(
                                            '${(result.page - 1) * AdminsScreenConstants.rowsPerPage + index + 1}',
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
                                              ? AdminsScreenConstants
                                                    .nameColumnWidthMobile
                                              : AdminsScreenConstants
                                                    .nameColumnWidthDesktop,
                                          child: Row(
                                            children: [
                                              const CircleAvatar(
                                                radius: AdminsScreenConstants
                                                    .rowAvatarRadius,
                                                backgroundColor:
                                                    AppColors.primary100,
                                                child: Icon(
                                                  AdminsScreenConstants
                                                      .rowAvatarIcon,
                                                  size: AdminsScreenConstants
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
                                              ? AdminsScreenConstants
                                                    .schoolColumnWidthMobile
                                              : AdminsScreenConstants
                                                    .schoolColumnWidthDesktop,
                                          child: Text(
                                            schoolName,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: isSmallScreen
                                              ? AdminsScreenConstants
                                                    .phoneNumberColumnWidthMobile
                                              : AdminsScreenConstants
                                                    .phoneNumberColumnWidthDesktop,
                                          child: Text(
                                            row.phoneNumber.isEmpty
                                                ? '-'
                                                : row.phoneNumber,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: isSmallScreen
                                              ? AdminsScreenConstants
                                                    .addressColumnWidthMobile
                                              : AdminsScreenConstants
                                                    .addressColumnWidthDesktop,
                                          child: Text(
                                            row.address.isEmpty
                                                ? '-'
                                                : row.address,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: isSmallScreen
                                              ? AdminsScreenConstants
                                                    .nikColumnWidthMobile
                                              : AdminsScreenConstants
                                                    .nikColumnWidthDesktop,
                                          child: Text(
                                            row.nik.isEmpty ? '-' : row.nik,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: isSmallScreen
                                              ? AdminsScreenConstants
                                                    .actionsColumnWidthMobile
                                              : AdminsScreenConstants
                                                    .actionsColumnWidthDesktop,
                                          child: Row(
                                            children: [
                                              _actionIconButton(
                                                icon: AdminsScreenConstants
                                                    .viewIcon,
                                                backgroundColor: AppColors.info,
                                                onTap: () =>
                                                    showAdminDetailModal(
                                                      context,
                                                      data: row,
                                                    ),
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.sm,
                                              ),
                                              _actionIconButton(
                                                icon: AdminsScreenConstants
                                                    .editIcon,
                                                backgroundColor:
                                                    AppColors.warning,
                                                onTap: () => showAdminEditModal(
                                                  context,
                                                  ref: ref,
                                                  data: row,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.sm,
                                              ),
                                              _actionIconButton(
                                                icon: AdminsScreenConstants
                                                    .deleteIcon,
                                                backgroundColor:
                                                    AppColors.error,
                                                onTap: () =>
                                                    showAdminDeleteModal(
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
                                          adminsCurrentPageProvider.notifier,
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
                                      .read(adminsCurrentPageProvider.notifier)
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
      width: AdminsScreenConstants.actionButtonSize,
      height: AdminsScreenConstants.actionButtonSize,
      child: Material(
        color: backgroundColor,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Icon(
            icon,
            color: AppColors.white,
            size: AdminsScreenConstants.actionIconSize,
          ),
        ),
      ),
    );
  }
}
