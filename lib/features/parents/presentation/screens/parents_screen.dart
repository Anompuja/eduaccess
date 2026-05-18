import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/active_school_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/school_filter.dart';
import '../../domain/entities/parent_entity.dart';
import '../widgets/parent_create_modal.dart';
import '../widgets/parent_delete_modal.dart';
import '../widgets/parent_detail_modal.dart';
import '../widgets/parent_edit_modal.dart';
import '../constants/parents_screen_constants.dart';
import '../providers/parents_provider.dart';
import '../../../../core/utils/responsive.dart';

class ParentsScreen extends ConsumerStatefulWidget {
  const ParentsScreen({super.key});

  @override
  ConsumerState<ParentsScreen> createState() => _ParentsScreenState();
}

class _ParentsScreenState extends ConsumerState<ParentsScreen> {
  @override
  Widget build(BuildContext context) {
    final isSmallScreen = Responsive.isMobile(context);
    final currentPage = ref.watch(parentsCurrentPageProvider);
    final parentsAsync = ref.watch(parentsProvider);
    final activeSchool = ref.watch(activeSchoolProvider);

    // Reset to page 1 whenever the school filter changes so pagination
    // stays consistent with what the user is looking at.
    ref.listen(activeSchoolProvider, (_, _) {
      ref.read(parentsCurrentPageProvider.notifier).state = 1;
    });

    return SingleChildScrollView(
      padding: isSmallScreen
          ? const EdgeInsets.all(AppSpacing.lg)
          : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ParentsScreenConstants.title,
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      activeSchool == null
                          ? 'Menampilkan data dari semua sekolah'
                          : 'Data untuk: ${activeSchool.name}',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const SchoolFilter(),
          const SizedBox(height: AppSpacing.sm),
          if (isSmallScreen)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSearchBar(
                  hint: ParentsScreenConstants.searchHint,
                  width: double.infinity,
                  onSearch: (value) {
                    ref.read(parentsSearchQueryProvider.notifier).state = value
                        .toLowerCase()
                        .trim();
                    ref.read(parentsCurrentPageProvider.notifier).state = 1;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton.accent(
                  height: ParentsScreenConstants.addButtonHeight,
                  isFullWidth: true,
                  label: ParentsScreenConstants.addButtonLabel,
                  prefixIcon: const Icon(
                    ParentsScreenConstants.addIcon,
                    size: ParentsScreenConstants.actionIconSize,
                    color: AppColors.white,
                  ),
                  onPressed: _openParentCreateModal,
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
                      width: ParentsScreenConstants.desktopSearchWidth,
                      child: AppSearchBar(
                        hint: ParentsScreenConstants.searchHint,
                        width: ParentsScreenConstants.desktopSearchWidth,
                        onSearch: (value) {
                          ref.read(parentsSearchQueryProvider.notifier).state =
                              value.toLowerCase().trim();
                          ref.read(parentsCurrentPageProvider.notifier).state =
                              1;
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom:
                        ParentsScreenConstants.desktopAddButtonBottomPadding,
                    right: ParentsScreenConstants.desktopAddButtonRightPadding,
                  ),
                  child: AppButton.accent(
                    height: ParentsScreenConstants.addButtonHeight,
                    label: ParentsScreenConstants.addButtonLabel,
                    prefixIcon: const Icon(
                      ParentsScreenConstants.addIcon,
                      size: ParentsScreenConstants.actionIconSize,
                      color: AppColors.white,
                    ),
                    onPressed: _openParentCreateModal,
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.lg),
          parentsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${error.toString()}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton.secondary(
                    label: 'Retry',
                    onPressed: () {
                      final _ = ref.refresh(parentsProvider);
                    },
                  ),
                ],
              ),
            ),
            data: (parents) =>
                _buildParentsTable(parents, isSmallScreen, currentPage),
          ),
        ],
      ),
    );
  }

  Widget _buildParentsTable(
    List<ParentEntity> parents,
    bool isSmallScreen,
    int currentPage,
  ) {
    const rowsPerPage = ParentsScreenConstants.rowsPerPage;
    final startIndex = (currentPage - 1) * rowsPerPage;

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
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: AppColors.neutral100),
                    child: DataTable(
                      columnSpacing: isSmallScreen
                          ? ParentsScreenConstants.tableColumnSpacingMobile
                          : ParentsScreenConstants.tableColumnSpacingDesktop,
                      horizontalMargin: AppSpacing.md,
                      headingRowHeight: isSmallScreen
                          ? ParentsScreenConstants.headingRowHeightMobile
                          : ParentsScreenConstants.headingRowHeightDesktop,
                      dataRowMinHeight: isSmallScreen
                          ? ParentsScreenConstants.dataRowHeightMobile
                          : ParentsScreenConstants.dataRowHeightDesktop,
                      dataRowMaxHeight: isSmallScreen
                          ? ParentsScreenConstants.dataRowHeightMobile
                          : ParentsScreenConstants.dataRowHeightDesktop,
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
                            ParentsScreenConstants.noHeader,
                            width: ParentsScreenConstants.noColumnWidth,
                          ),
                        ),
                        DataColumn(
                          label: _tableHeader(
                            ParentsScreenConstants.nameHeader,
                            width: isSmallScreen
                                ? ParentsScreenConstants.nameColumnWidthMobile
                                : ParentsScreenConstants.nameColumnWidthDesktop,
                          ),
                        ),
                        DataColumn(
                          label: _tableHeader(
                            ParentsScreenConstants.emailHeader,
                            width: isSmallScreen
                                ? ParentsScreenConstants.emailColumnWidthMobile
                                : ParentsScreenConstants
                                      .emailColumnWidthDesktop,
                          ),
                        ),
                        DataColumn(
                          label: _tableHeader(
                            ParentsScreenConstants.phoneHeader,
                            width: isSmallScreen
                                ? ParentsScreenConstants.phoneColumnWidthMobile
                                : ParentsScreenConstants
                                      .phoneColumnWidthDesktop,
                          ),
                        ),
                        DataColumn(
                          label: _tableHeader(
                            ParentsScreenConstants.religionHeader,
                            width: isSmallScreen
                                ? ParentsScreenConstants
                                      .religionColumnWidthMobile
                                : ParentsScreenConstants
                                      .religionColumnWidthDesktop,
                          ),
                        ),
                        DataColumn(
                          label: _tableHeader(
                            ParentsScreenConstants.actionsHeader,
                            width: isSmallScreen
                                ? ParentsScreenConstants
                                      .actionsColumnWidthMobile
                                : ParentsScreenConstants
                                      .actionsColumnWidthDesktop,
                          ),
                        ),
                      ],
                      rows: parents.asMap().entries.map((entry) {
                        final index = entry.key;
                        final e = entry.value;
                        return DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: ParentsScreenConstants.noColumnWidth,
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
                                    ? ParentsScreenConstants
                                          .nameColumnWidthMobile
                                    : ParentsScreenConstants
                                          .nameColumnWidthDesktop,
                                child: Text(
                                  e.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: isSmallScreen
                                    ? ParentsScreenConstants
                                          .emailColumnWidthMobile
                                    : ParentsScreenConstants
                                          .emailColumnWidthDesktop,
                                child: Text(
                                  e.email,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: isSmallScreen
                                    ? ParentsScreenConstants
                                          .phoneColumnWidthMobile
                                    : ParentsScreenConstants
                                          .phoneColumnWidthDesktop,
                                child: Text(
                                  e.phoneNumber.isEmpty ? '-' : e.phoneNumber,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: isSmallScreen
                                    ? ParentsScreenConstants
                                          .religionColumnWidthMobile
                                    : ParentsScreenConstants
                                          .religionColumnWidthDesktop,
                                child: Text(
                                  e.religion.isEmpty ? '-' : e.religion,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: isSmallScreen
                                    ? ParentsScreenConstants
                                          .actionsColumnWidthMobile
                                    : ParentsScreenConstants
                                          .actionsColumnWidthDesktop,
                                child: Row(
                                  children: [
                                    _actionIconButton(
                                      icon: ParentsScreenConstants.viewIcon,
                                      backgroundColor: AppColors.info,
                                      onTap: () => _openParentDetailModal(e),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    _actionIconButton(
                                      icon: ParentsScreenConstants.editIcon,
                                      backgroundColor: AppColors.warning,
                                      onTap: () => _openParentEditModal(e),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    _actionIconButton(
                                      icon: ParentsScreenConstants.deleteIcon,
                                      backgroundColor: AppColors.error,
                                      onTap: () => _openParentDeleteModal(e),
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
                  'Halaman $currentPage',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.neutral700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppButton.secondary(
                        label: 'Previous',
                        onPressed: currentPage > 1
                            ? () {
                                ref
                                    .read(parentsCurrentPageProvider.notifier)
                                    .state--;
                              }
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      AppButton.secondary(
                        label: 'Next',
                        onPressed:
                            parents.length >= ParentsScreenConstants.rowsPerPage
                            ? () {
                                ref
                                    .read(parentsCurrentPageProvider.notifier)
                                    .state++;
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Halaman $currentPage',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.neutral700,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                AppButton.secondary(
                  label: 'Previous',
                  onPressed: currentPage > 1
                      ? () {
                          ref.read(parentsCurrentPageProvider.notifier).state--;
                        }
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                AppButton.secondary(
                  label: 'Next',
                  onPressed:
                      parents.length >= ParentsScreenConstants.rowsPerPage
                      ? () {
                          ref.read(parentsCurrentPageProvider.notifier).state++;
                        }
                      : null,
                ),
              ],
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
      width: ParentsScreenConstants.actionButtonSize,
      height: ParentsScreenConstants.actionButtonSize,
      child: Material(
        color: backgroundColor,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Icon(
            icon,
            color: AppColors.white,
            size: ParentsScreenConstants.actionIconSize,
          ),
        ),
      ),
    );
  }

  void _openParentDetailModal(ParentEntity parent) {
    showParentDetailModal(context, data: parent);
  }

  void _openParentEditModal(ParentEntity parent) {
    showParentEditModal(context, data: parent);
  }

  void _openParentDeleteModal(ParentEntity parent) {
    showParentDeleteModal(context, data: parent);
  }

  void _openParentCreateModal() {
    showParentCreateModal(context);
  }
}
