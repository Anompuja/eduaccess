import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/api/paginated.dart';
import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/providers/active_school_provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/external_url_launcher.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_pagination.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/school_filter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../dashboard/domain/entities/dashboard_school.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../payment/data/models/payment_entities.dart';
import '../../../payment/presentation/providers/payment_provider.dart';
import '../../data/models/subscription_entities.dart';
import '../providers/subscription_provider.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  final Map<String, BillingCycle> _selectedCycles = {};
  String? _processingPlanId;
  String? _updatingSchoolId;

  @override
  Widget build(BuildContext context) {
    final isCompact =
        Responsive.isMobile(context) || Responsive.isTablet(context);
    final user = ref.watch(currentUserProvider);
    final isSuperadmin = user?.role == UserRole.superadmin;

    return SingleChildScrollView(
      padding: isCompact
          ? const EdgeInsets.all(AppSpacing.lg)
          : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paket Sekolah',
            style: AppTextStyles.h2.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isSuperadmin
                ? 'Kelola paket langganan seluruh sekolah dari daftar tenant yang tersedia.'
                : 'Kelola paket sekolah dan pantau kuota siswa sesuai paket yang sedang aktif.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isSuperadmin)
            _buildSuperadminContent(context, isCompact)
          else
            _buildSchoolAdminContent(context, isCompact),
        ],
      ),
    );
  }

  Widget _buildSuperadminContent(BuildContext context, bool isCompact) {
    final activeSchool = ref.watch(activeSchoolProvider);
    final plansAsync = ref.watch(schoolPlansProvider);
    final recordsAsync = ref.watch(schoolSubscriptionRecordsProvider);

    ref.listen(activeSchoolProvider, (_, _) {
      ref.read(subscriptionSchoolsCurrentPageProvider.notifier).state = 1;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSuperadminScopeSection(
          context: context,
          activeSchoolName: activeSchool?.name,
          isCompact: isCompact,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (activeSchool == null) ...[
          _buildSuperadminToolbar(isCompact),
          const SizedBox(height: AppSpacing.lg),
        ],
        recordsAsync.when(
          loading: () => const AppCard(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: AppLoadingIndicator(
                message: 'Memuat daftar subscription sekolah...',
              ),
            ),
          ),
          error: (error, _) => AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: AppErrorState(
                message: error.toString(),
                onRetry: () =>
                    ref.invalidate(schoolSubscriptionRecordsProvider),
              ),
            ),
          ),
          data: (result) => _buildSuperadminTable(
            context: context,
            result: result,
            plansAsync: plansAsync,
            isCompact: isCompact,
          ),
        ),
      ],
    );
  }

  Widget _buildSuperadminScopeSection({
    required BuildContext context,
    required String? activeSchoolName,
    required bool isCompact,
  }) {
    final scopeText = activeSchoolName == null
        ? 'Menampilkan subscription dari semua sekolah'
        : 'Subscription untuk: $activeSchoolName';
    final dashboardButton = AppButton.secondary(
      label: 'Dashboard',
      onPressed: () => context.go(RouteNames.dashboard),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCompact) ...[
          Text(
            scopeText,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.md),
          dashboardButton,
        ] else
          Row(
            children: [
              Expanded(
                child: Text(
                  scopeText,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              dashboardButton,
            ],
          ),
        const SizedBox(height: AppSpacing.md),
        const SchoolFilter(
          label: 'Sekolah Subscription',
          allLabel: 'Semua Sekolah',
        ),
      ],
    );
  }

  Widget _buildSuperadminToolbar(bool isCompact) {
    final status = ref.watch(subscriptionSchoolsStatusFilterProvider);
    final dropdown = AppDropdown<SchoolDirectoryStatus?>(
      label: 'Status Sekolah',
      value: status,
      hint: 'Semua Status',
      items: const [
        AppDropdownItem<SchoolDirectoryStatus?>(
          value: null,
          label: 'Semua Status',
        ),
        AppDropdownItem<SchoolDirectoryStatus?>(
          value: SchoolDirectoryStatus.active,
          label: 'Active',
        ),
        AppDropdownItem<SchoolDirectoryStatus?>(
          value: SchoolDirectoryStatus.nonactive,
          label: 'Nonactive',
        ),
      ],
      onChanged: (value) {
        ref.read(subscriptionSchoolsStatusFilterProvider.notifier).state =
            value;
        ref.read(subscriptionSchoolsCurrentPageProvider.notifier).state = 1;
      },
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSearchBar(
            hint: 'Cari nama sekolah...',
            width: double.infinity,
            onSearch: (value) {
              ref.read(subscriptionSchoolsSearchQueryProvider.notifier).state =
                  value.trim().toLowerCase();
              ref.read(subscriptionSchoolsCurrentPageProvider.notifier).state =
                  1;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          dropdown,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 320,
          child: AppSearchBar(
            hint: 'Cari nama sekolah...',
            width: 320,
            onSearch: (value) {
              ref.read(subscriptionSchoolsSearchQueryProvider.notifier).state =
                  value.trim().toLowerCase();
              ref.read(subscriptionSchoolsCurrentPageProvider.notifier).state =
                  1;
            },
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: dropdown),
      ],
    );
  }

  Widget _buildSuperadminTable({
    required BuildContext context,
    required Paginated<SchoolSubscriptionRecord> result,
    required AsyncValue<List<SubscriptionPlan>> plansAsync,
    required bool isCompact,
  }) {
    if (result.items.isEmpty) {
      final search = ref.read(subscriptionSchoolsSearchQueryProvider);
      final status = ref.read(subscriptionSchoolsStatusFilterProvider);
      final hasFilter = search.isNotEmpty || status != null;

      return AppCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: AppEmptyState(
            icon: Icons.apartment_outlined,
            message: hasFilter
                ? 'Tidak ada sekolah yang sesuai filter'
                : 'Belum ada data subscription sekolah',
            subtitle: hasFilter
                ? 'Ubah kata kunci pencarian atau status sekolah.'
                : 'Data sekolah dengan subscription akan tampil di halaman ini.',
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
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: AppColors.neutral100),
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
                        DataColumn(label: _tableHeader('Sekolah', width: 220)),
                        DataColumn(label: _tableHeader('Status', width: 120)),
                        DataColumn(label: _tableHeader('Paket', width: 180)),
                        DataColumn(label: _tableHeader('Siklus', width: 120)),
                        DataColumn(
                          label: _tableHeader('Aktif Hingga', width: 150),
                        ),
                        DataColumn(
                          label: _tableHeader('Maks. Siswa', width: 120),
                        ),
                        DataColumn(label: _tableHeader('Aksi', width: 140)),
                      ],
                      rows: result.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final record = entry.value;
                        final subscription = record.subscription;

                        return DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: 64,
                                child: Text(
                                  '${(result.page - 1) * subscriptionSchoolsPerPage + index + 1}',
                                  style: AppTextStyles.bodyMdSemiBold.copyWith(
                                    color: AppColors.neutral700,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 220,
                                child: Text(
                                  record.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 120,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: _schoolStatusBadge(record.status),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 180,
                                child: Text(
                                  subscription?.plan.displayName ?? '-',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 120,
                                child: Text(subscription?.cycle.label ?? '-'),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 150,
                                child: Text(_formatDate(subscription?.endDate)),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 120,
                                child: Text(
                                  subscription == null
                                      ? '-'
                                      : subscription.plan.maxStudents <= 0
                                      ? 'Tidak diketahui'
                                      : '${subscription.plan.maxStudents}',
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 140,
                                child: Row(
                                  children: [
                                    _actionIconButton(
                                      icon: Icons.visibility_outlined,
                                      backgroundColor: AppColors.info,
                                      onTap: () =>
                                          _showSubscriptionDetailDialog(
                                            context,
                                            record,
                                          ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    _actionIconButton(
                                      icon: Icons.edit_outlined,
                                      backgroundColor: AppColors.warning,
                                      onTap: plansAsync.maybeWhen(
                                        data: (plans) =>
                                            () => _showEditSubscriptionDialog(
                                              context,
                                              record,
                                              plans,
                                            ),
                                        orElse: () => () {
                                          AppToast.show(
                                            context,
                                            message:
                                                'Daftar paket belum siap. Coba lagi sebentar.',
                                            type: ToastType.warning,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    _actionIconButton(
                                      icon: Icons.payments_outlined,
                                      backgroundColor: AppColors.primary700,
                                      onTap: () => _openSchoolPaymentHistory(
                                        context,
                                        record,
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
          if (result.totalPages > 1)
            if (isCompact)
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
                                  subscriptionSchoolsCurrentPageProvider
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
                                subscriptionSchoolsCurrentPageProvider.notifier,
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
  }

  Widget _buildSchoolAdminContent(BuildContext context, bool isCompact) {
    final schoolId = ref.watch(currentSubscriptionSchoolIdProvider);
    final subscriptionAsync = ref.watch(
      currentSchoolSubscriptionOverviewProvider,
    );
    final plansAsync = ref.watch(schoolPlansProvider);
    final trackedPayment = ref.watch(activeSubscriptionPaymentProvider);

    if (schoolId == null || schoolId.isEmpty) {
      return const AppCard(
        child: AppEmptyState(
          icon: Icons.apartment_outlined,
          message: 'Data sekolah belum tersedia',
          subtitle:
              'Akun ini belum memiliki konteks sekolah untuk memuat subscription.',
        ),
      );
    }

    return subscriptionAsync.when(
      loading: () => const AppCard(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: AppLoadingIndicator(message: 'Memuat paket sekolah...'),
        ),
      ),
      error: (error, _) => AppCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: AppErrorState(
            message: error.toString(),
            onRetry: () =>
                ref.invalidate(currentSchoolSubscriptionOverviewProvider),
          ),
        ),
      ),
      data: (overview) => _buildSchoolAdminSubscriptionContent(
        context: context,
        overview: overview,
        plansAsync: plansAsync,
        schoolId: schoolId,
        isCompact: isCompact,
        trackedPayment: trackedPayment,
      ),
    );
  }

  Widget _buildSchoolAdminSubscriptionContent({
    required BuildContext context,
    required SchoolSubscriptionOverview? overview,
    required AsyncValue<List<SubscriptionPlan>> plansAsync,
    required String schoolId,
    required bool isCompact,
    required SubscriptionPayment? trackedPayment,
  }) {
    if (overview == null) {
      return const AppCard(
        child: AppEmptyState(
          message: 'Subscription sekolah belum tersedia',
          subtitle: 'Data paket sekolah belum dapat ditampilkan saat ini.',
        ),
      );
    }

    final schoolPayment = trackedPayment?.schoolId == schoolId
        ? trackedPayment
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (schoolPayment != null && schoolPayment.isPending) ...[
          _buildPendingPaymentBanner(context, schoolPayment),
          const SizedBox(height: AppSpacing.lg),
        ],
        _buildOverviewCard(overview, isCompact),
        const SizedBox(height: AppSpacing.lg),
        if (isCompact)
          Column(
            children: [
              _buildQuotaCard(overview),
              const SizedBox(height: AppSpacing.lg),
              _buildRulesCard(),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildQuotaCard(overview)),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: _buildRulesCard()),
            ],
          ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Katalog Paket',
          style: AppTextStyles.h4.copyWith(color: AppColors.neutral900),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Pilih paket yang sesuai dengan kebutuhan sekolah dan jumlah siswa yang dikelola.',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
        ),
        const SizedBox(height: AppSpacing.md),
        plansAsync.when(
          loading: () => const AppCard(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: AppLoadingIndicator(message: 'Memuat daftar paket...'),
            ),
          ),
          error: (error, _) => AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: AppErrorState(
                message: error.toString(),
                onRetry: () => ref.invalidate(schoolPlansProvider),
              ),
            ),
          ),
          data: (plans) => _buildPlanGrid(
            context: context,
            schoolId: schoolId,
            overview: overview,
            plans: plans,
            isCompact: isCompact,
            trackedPayment: schoolPayment,
          ),
        ),
      ],
    );
  }

  Future<void> _showSubscriptionDetailDialog(
    BuildContext context,
    SchoolSubscriptionRecord record,
  ) async {
    final subscription = record.subscription;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AppDialog(
        title: 'Detail Subscription',
        subtitle: record.displayName,
        content: Column(
          children: [
            _detailRow('Sekolah', record.displayName),
            _detailRow('Status Sekolah', record.status.label),
            _detailRow(
              'Paket',
              subscription?.plan.displayName ?? 'Belum ada subscription',
            ),
            _detailRow('Siklus', subscription?.cycle.label ?? '-'),
            _detailRow(
              'Biaya',
              subscription == null
                  ? '-'
                  : _formatIdr(subscription.currentPrice),
            ),
            _detailRow('Aktif Hingga', _formatDate(subscription?.endDate)),
            _detailRow(
              'Maks. Siswa',
              subscription == null
                  ? '-'
                  : subscription.plan.maxStudents <= 0
                  ? 'Tidak diketahui'
                  : '${subscription.plan.maxStudents}',
            ),
            if (subscription?.plan.description.isNotEmpty == true)
              _detailRow('Deskripsi', subscription!.plan.description),
          ],
        ),
        actions: [
          AppButton.secondary(
            label: 'Tutup',
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          AppButton.primary(
            label: 'Buka Payment',
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _openSchoolPaymentHistory(context, record);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showEditSubscriptionDialog(
    BuildContext context,
    SchoolSubscriptionRecord record,
    List<SubscriptionPlan> plans,
  ) async {
    if (plans.isEmpty) {
      AppToast.show(
        context,
        message: 'Belum ada paket aktif yang bisa dipilih.',
        type: ToastType.warning,
      );
      return;
    }

    final currentPlan = record.subscription?.plan;
    final currentCycle = record.subscription?.cycle;
    SubscriptionPlan selectedPlan = plans.firstWhere(
      (plan) => currentPlan != null && plan.matches(currentPlan),
      orElse: () => plans.first,
    );
    BillingCycle selectedCycle =
        currentCycle != null &&
            currentCycle != BillingCycle.unknown &&
            selectedPlan.supportsCycle(currentCycle)
        ? currentCycle
        : selectedPlan.availableCycles.isNotEmpty
        ? selectedPlan.availableCycles.first
        : BillingCycle.unknown;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AppDialog(
            title: 'Ubah Paket Sekolah',
            subtitle: record.displayName,
            content: Column(
              children: [
                _detailRow(
                  'Paket Saat Ini',
                  record.subscription?.plan.displayName ?? '-',
                ),
                _detailRow(
                  'Siklus Saat Ini',
                  record.subscription?.cycle.label ?? '-',
                ),
                AppDropdown<SubscriptionPlan>(
                  label: 'Paket Baru',
                  value: selectedPlan,
                  items: plans
                      .map(
                        (plan) => AppDropdownItem<SubscriptionPlan>(
                          value: plan,
                          label: plan.displayName,
                        ),
                      )
                      .toList(),
                  onChanged: (plan) {
                    if (plan == null) return;
                    setDialogState(() {
                      selectedPlan = plan;
                      selectedCycle = plan.availableCycles.isNotEmpty
                          ? plan.availableCycles.first
                          : BillingCycle.unknown;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppDropdown<BillingCycle>(
                  label: 'Siklus Billing',
                  value: selectedCycle == BillingCycle.unknown
                      ? null
                      : selectedCycle,
                  items: selectedPlan.availableCycles
                      .map(
                        (cycle) => AppDropdownItem<BillingCycle>(
                          value: cycle,
                          label:
                              '${cycle.label} • ${_formatIdr(selectedPlan.priceForCycle(cycle))}',
                        ),
                      )
                      .toList(),
                  onChanged: (cycle) {
                    if (cycle == null) return;
                    setDialogState(() => selectedCycle = cycle);
                  },
                ),
              ],
            ),
            actions: [
              AppButton.secondary(
                label: 'Batal',
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              AppButton.primary(
                label: 'Simpan',
                isLoading: _updatingSchoolId == record.id,
                onPressed: selectedCycle == BillingCycle.unknown
                    ? null
                    : () => _submitDirectSubscriptionUpdate(
                        context: context,
                        dialogContext: dialogContext,
                        record: record,
                        selectedPlan: selectedPlan,
                        selectedCycle: selectedCycle,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitDirectSubscriptionUpdate({
    required BuildContext context,
    required BuildContext dialogContext,
    required SchoolSubscriptionRecord record,
    required SubscriptionPlan selectedPlan,
    required BillingCycle selectedCycle,
  }) async {
    setState(() => _updatingSchoolId = record.id);
    try {
      await ref.read(
        updateSchoolSubscriptionProvider((
          schoolId: record.id,
          planId: selectedPlan.id,
          cycle: selectedCycle,
        )).future,
      );

      if (!mounted || !dialogContext.mounted) return;
      Navigator.of(dialogContext).pop();
      AppToast.show(
        this.context,
        message:
            'Paket ${record.displayName} berhasil diubah ke ${selectedPlan.displayName}.',
      );
    } catch (e) {
      if (!mounted) return;
      AppToast.show(this.context, message: e.toString(), type: ToastType.error);
    } finally {
      if (mounted) {
        setState(() => _updatingSchoolId = null);
      }
    }
  }

  Future<void> _openSchoolPaymentHistory(
    BuildContext context,
    SchoolSubscriptionRecord record,
  ) async {
    final school = await _resolveDashboardSchool(record);
    if (!context.mounted) return;

    ref.read(activeSchoolProvider.notifier).state = school;
    _resetPaymentHistoryState();
    context.go(RouteNames.payment);
  }

  Future<DashboardSchool> _resolveDashboardSchool(
    SchoolSubscriptionRecord record,
  ) async {
    final currentSchool = ref.read(activeSchoolProvider);
    if (currentSchool != null && currentSchool.id == record.id) {
      return currentSchool;
    }

    final cachedSchools = ref.read(dashboardSchoolsProvider).valueOrNull;
    final cachedMatch = cachedSchools
        ?.where((school) => school.id == record.id)
        .firstOrNull;
    if (cachedMatch != null) {
      return cachedMatch;
    }

    try {
      final schools = await ref.read(dashboardSchoolsProvider.future);
      final match = schools
          .where((school) => school.id == record.id)
          .firstOrNull;
      if (match != null) {
        return match;
      }
    } catch (_) {
      // Keep the flow working even if the school directory is not ready yet.
    }

    return DashboardSchool(
      id: record.id,
      name: record.displayName,
      status: record.status.apiValue,
    );
  }

  void _resetPaymentHistoryState() {
    ref.read(paymentHistoryCurrentPageProvider.notifier).state = 1;
    ref.read(paymentHistorySearchQueryProvider.notifier).state = '';
    ref.read(paymentHistoryStatusFilterProvider.notifier).state = null;
  }

  Widget _buildPendingPaymentBanner(
    BuildContext context,
    SubscriptionPayment payment,
  ) {
    return AppCard(
      color: AppColors.accent100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.75),
              borderRadius: AppRadius.lgAll,
            ),
            child: const Icon(
              Icons.pending_actions_rounded,
              color: AppColors.accent700,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Masih ada pembayaran yang berjalan',
                  style: AppTextStyles.h4.copyWith(color: AppColors.neutral900),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Selesaikan pembayaran yang sedang berjalan sebelum membuat pembayaran baru.',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.neutral700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          AppButton.primary(
            label: 'Lihat Pembayaran',
            onPressed: () => context.push(RouteNames.payment, extra: payment),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
    SchoolSubscriptionOverview overview,
    bool isCompact,
  ) {
    final subscription = overview.subscription;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primary100,
              borderRadius: AppRadius.lgAll,
            ),
            child: isCompact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.plan.displayName,
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _statusBadge(subscription.status),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        subscription.schoolName.isEmpty
                            ? 'Paket aktif sekolah'
                            : subscription.schoolName,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.neutral700,
                        ),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subscription.plan.displayName,
                              style: AppTextStyles.h4.copyWith(
                                color: AppColors.neutral900,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              subscription.schoolName.isEmpty
                                  ? 'Paket aktif sekolah'
                                  : subscription.schoolName,
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.neutral700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _statusBadge(subscription.status),
                    ],
                  ),
          ),
          if (subscription.plan.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              subscription.plan.description,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral700),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _buildOverviewMeta(subscription, isCompact),
        ],
      ),
    );
  }

  Widget _buildOverviewMeta(SchoolSubscription subscription, bool isCompact) {
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.md,
      children: [
        _metaItem(
          'Paket',
          subscription.plan.tier.label,
          width: isCompact ? double.infinity : 150,
        ),
        _metaItem(
          'Siklus',
          subscription.cycle.label,
          width: isCompact ? double.infinity : 150,
        ),
        _metaItem(
          'Biaya',
          _formatIdr(subscription.currentPrice),
          width: isCompact ? double.infinity : 170,
        ),
        _metaItem(
          'Aktif Hingga',
          _formatDate(subscription.endDate),
          width: isCompact ? double.infinity : 170,
        ),
        if (subscription.quantity > 0)
          _metaItem(
            'Jumlah',
            '${subscription.quantity} paket',
            width: isCompact ? double.infinity : 150,
          ),
      ],
    );
  }

  Widget _metaItem(String label, String value, {required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Column(
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
      ),
    );
  }

  Widget _buildQuotaCard(SchoolSubscriptionOverview overview) {
    final accentColor = overview.isAtCapacity
        ? AppColors.error
        : overview.isNearCapacity
        ? AppColors.warning
        : AppColors.primary500;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kuota Siswa',
            style: AppTextStyles.h4.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${overview.studentsUsed}/${overview.studentsLimit} siswa',
                  style: AppTextStyles.bodyLgSemiBold.copyWith(
                    color: AppColors.neutral900,
                  ),
                ),
              ),
              Text(
                'Sisa ${overview.remainingStudents}',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.pillAll,
            child: LinearProgressIndicator(
              minHeight: 10,
              value: overview.progress,
              backgroundColor: AppColors.neutral100,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            overview.isAtCapacity
                ? 'Kuota penuh. Penambahan siswa baru akan ditolak sampai paket di-upgrade.'
                : overview.isNearCapacity
                ? 'Kuota hampir habis. Pertimbangkan upgrade sebelum menambah banyak siswa.'
                : 'Masih ada kapasitas siswa pada paket aktif.',
            style: AppTextStyles.bodySm.copyWith(color: accentColor),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ketentuan Paket',
            style: AppTextStyles.h4.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.md),
          _ruleItem(
            'Pilihan Paket',
            'Pilih paket sesuai jumlah siswa dan kebutuhan sekolah saat ini.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _ruleItem(
            'Perubahan Paket',
            'Perubahan paket dilakukan saat sekolah ingin beralih ke paket yang lebih sesuai.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _ruleItem(
            'Pembayaran',
            'Jika pembayaran sedang berjalan, selesaikan terlebih dahulu sebelum membuat pembayaran baru.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _ruleItem(
            'Kuota Siswa',
            'Batas jumlah siswa mengikuti paket yang sedang aktif.',
          ),
        ],
      ),
    );
  }

  Widget _ruleItem(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.primary700,
            size: 18,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMdSemiBold.copyWith(
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanGrid({
    required BuildContext context,
    required String schoolId,
    required SchoolSubscriptionOverview overview,
    required List<SubscriptionPlan> plans,
    required bool isCompact,
    required SubscriptionPayment? trackedPayment,
  }) {
    if (plans.isEmpty) {
      return const AppCard(
        child: AppEmptyState(
          message: 'Belum ada paket yang tersedia',
          subtitle: 'Pastikan endpoint plan backend sudah mengirim data aktif.',
        ),
      );
    }

    final hasPendingPayment = trackedPayment?.isPending == true;

    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.lg,
      children: plans.map((plan) {
        final selectedCycle = _selectedCycleFor(plan);
        final isCurrentPlan = plan.matches(overview.plan);
        final isDowngrade =
            overview.plan.tier != SubscriptionTier.trial &&
            plan.tier.sortOrder < overview.plan.tier.sortOrder;
        final canFitCurrentStudents =
            plan.maxStudents <= 0 || plan.maxStudents >= overview.studentsUsed;
        final cyclePrice = plan.priceForCycle(selectedCycle);
        final canCheckout =
            !isCurrentPlan &&
            !hasPendingPayment &&
            plan.isSelectable &&
            !isDowngrade &&
            canFitCurrentStudents &&
            selectedCycle != BillingCycle.unknown &&
            cyclePrice > 0;
        final cardWidth = isCompact ? double.infinity : 340.0;

        return SizedBox(
          width: cardWidth,
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isCurrentPlan
                        ? AppColors.primary100
                        : AppColors.neutral50,
                    borderRadius: AppRadius.lgAll,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          plan.displayName,
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                      ),
                      if (isCurrentPlan)
                        const AppBadge(
                          label: 'PAKET AKTIF',
                          status: BadgeStatus.active,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  plan.description.isEmpty
                      ? 'Paket ini menentukan batas kapasitas siswa yang bisa dikelola sekolah.'
                      : plan.description,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: AppRadius.lgAll,
                    border: Border.all(color: AppColors.neutral100),
                  ),
                  child: Column(
                    children: [
                      _planMetric(
                        'Maks. siswa',
                        plan.maxStudents <= 0
                            ? 'Tidak diketahui'
                            : '${plan.maxStudents}',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _planMetric('Bulanan', _formatIdr(plan.monthlyPrice)),
                      const SizedBox(height: AppSpacing.sm),
                      _planMetric('Tahunan', _formatIdr(plan.yearlyPrice)),
                    ],
                  ),
                ),
                if (plan.features.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Keunggulan Paket',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.neutral500,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...plan.features.take(4).map(_featureItem),
                ],
                const SizedBox(height: AppSpacing.lg),
                if (plan.availableCycles.isNotEmpty) ...[
                  Text(
                    'Pilih Periode',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.neutral500,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: plan.availableCycles
                        .map(
                          (cycle) => _cycleChip(
                            cycle: cycle,
                            price: plan.priceForCycle(cycle),
                            isSelected: selectedCycle == cycle,
                            onTap: isCurrentPlan || hasPendingPayment
                                ? null
                                : () => setState(() {
                                    _selectedCycles[plan.id] = cycle;
                                  }),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                SizedBox(
                  width: double.infinity,
                  child: AppButton.primary(
                    label: _planActionLabel(
                      plan: plan,
                      isCurrentPlan: isCurrentPlan,
                      isDowngrade: isDowngrade,
                      canFitCurrentStudents: canFitCurrentStudents,
                      hasPendingPayment: hasPendingPayment,
                    ),
                    isLoading: _processingPlanId == plan.id,
                    onPressed: canCheckout
                        ? () => _startCheckout(
                            context: context,
                            schoolId: schoolId,
                            currentOverview: overview,
                            nextPlan: plan,
                            cycle: selectedCycle,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _featureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, size: 8, color: AppColors.primary500),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              feature,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _planMetric(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMdSemiBold.copyWith(
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }

  Widget _cycleChip({
    required BillingCycle cycle,
    required int price,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    final fgColor = isSelected ? AppColors.primary700 : AppColors.neutral700;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgAll,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary100 : AppColors.neutral50,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: isSelected ? AppColors.primary500 : AppColors.neutral100,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cycle.label,
              style: AppTextStyles.bodySm.copyWith(
                color: fgColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatIdr(price),
              style: AppTextStyles.bodySm.copyWith(color: fgColor),
            ),
          ],
        ),
      ),
    );
  }

  String _planActionLabel({
    required SubscriptionPlan plan,
    required bool isCurrentPlan,
    required bool isDowngrade,
    required bool canFitCurrentStudents,
    required bool hasPendingPayment,
  }) {
    if (isCurrentPlan) return 'Paket Aktif';
    if (hasPendingPayment) return 'Selesaikan Pembayaran Sebelumnya';
    if (!plan.isSelectable) return 'Paket Tidak Tersedia';
    if (isDowngrade) return 'Belum Tersedia';
    if (!canFitCurrentStudents) return 'Jumlah Siswa Melebihi Batas';
    return 'Pilih Paket ${plan.tier.label}';
  }

  BillingCycle _selectedCycleFor(SubscriptionPlan plan) {
    final stored = _selectedCycles[plan.id];
    if (stored != null && plan.supportsCycle(stored)) return stored;
    final first = plan.availableCycles.isNotEmpty
        ? plan.availableCycles.first
        : BillingCycle.unknown;
    _selectedCycles[plan.id] = first;
    return first;
  }

  Future<void> _startCheckout({
    required BuildContext context,
    required String schoolId,
    required SchoolSubscriptionOverview currentOverview,
    required SubscriptionPlan nextPlan,
    required BillingCycle cycle,
  }) async {
    final price = nextPlan.priceForCycle(cycle);
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Konfirmasi Paket',
      message:
          'Lanjutkan pembayaran untuk paket ${nextPlan.displayName} dengan periode ${cycle.label.toLowerCase()} sebesar ${_formatIdr(price)}?',
      confirmLabel: 'Lanjut',
    );

    if (confirmed != true) return;

    setState(() => _processingPlanId = nextPlan.id);
    try {
      final payment = await ref.read(
        createSubscriptionCheckoutProvider((
          schoolId: schoolId,
          planId: nextPlan.id,
          cycle: cycle,
        )).future,
      );

      final opened = await ExternalUrlLauncher.open(
        payment.providerRedirectUrl,
      );

      if (!context.mounted) return;

      final wasUpgrade =
          nextPlan.maxStudents > currentOverview.plan.maxStudents;
      final toastMessage = !opened && payment.providerRedirectUrl.isEmpty
          ? 'Pembayaran berhasil dibuat, tetapi halaman pembayaran belum tersedia saat ini.'
          : opened
          ? wasUpgrade
                ? 'Paket ${nextPlan.displayName} siap diproses. Halaman pembayaran sudah dibuka.'
                : 'Pembayaran berhasil dibuat dan halaman pembayaran sudah dibuka.'
          : 'Pembayaran berhasil dibuat. Silakan buka kembali dari halaman pembayaran.';
      final toastType = !opened ? ToastType.warning : ToastType.info;
      AppToast.show(context, message: toastMessage, type: toastType);

      context.push(RouteNames.payment, extra: payment);
    } catch (e) {
      if (!context.mounted) return;
      AppToast.show(context, message: e.toString(), type: ToastType.error);
    } finally {
      if (mounted) {
        setState(() => _processingPlanId = null);
      }
    }
  }

  Widget _statusBadge(SubscriptionStatus status) {
    return switch (status) {
      SubscriptionStatus.active => const AppBadge(
        label: 'ACTIVE',
        status: BadgeStatus.success,
      ),
      SubscriptionStatus.inactive => const AppBadge(
        label: 'INACTIVE',
        status: BadgeStatus.muted,
      ),
      SubscriptionStatus.trial => const AppBadge(
        label: 'TRIAL',
        status: BadgeStatus.info,
      ),
      SubscriptionStatus.expired => const AppBadge(
        label: 'EXPIRED',
        status: BadgeStatus.warning,
      ),
      SubscriptionStatus.cancelled => const AppBadge(
        label: 'CANCELLED',
        status: BadgeStatus.error,
      ),
      SubscriptionStatus.unknown => const AppBadge(
        label: 'UNKNOWN',
        status: BadgeStatus.muted,
      ),
    };
  }

  Widget _schoolStatusBadge(SchoolDirectoryStatus status) {
    return switch (status) {
      SchoolDirectoryStatus.active => const AppBadge(
        label: 'ACTIVE',
        status: BadgeStatus.success,
      ),
      SchoolDirectoryStatus.nonactive => const AppBadge(
        label: 'NONACTIVE',
        status: BadgeStatus.muted,
      ),
      SchoolDirectoryStatus.unknown => const AppBadge(
        label: 'UNKNOWN',
        status: BadgeStatus.muted,
      ),
    };
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
      width: 34,
      height: 34,
      child: Material(
        color: backgroundColor,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Icon(icon, color: AppColors.white, size: 18),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.neutral900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatIdr(int value) {
    if (value <= 0) return '-';

    final source = value.toString();
    final buffer = StringBuffer();
    var count = 0;
    for (var i = source.length - 1; i >= 0; i--) {
      buffer.write(source[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write('.');
    }
    final reversed = buffer.toString().split('').reversed.join();
    return 'Rp $reversed';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final month = months[date.month - 1];
    return '${date.day} $month ${date.year}';
  }
}
