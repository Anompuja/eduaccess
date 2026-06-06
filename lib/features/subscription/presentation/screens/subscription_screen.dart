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
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/school_filter.dart';
import '../../data/models/subscription_entities.dart';
import '../providers/subscription_provider.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  String? _changingPlanId;

  @override
  Widget build(BuildContext context) {
    final isCompact =
        Responsive.isMobile(context) || Responsive.isTablet(context);
    final user = ref.watch(currentUserProvider);
    final schoolId = ref.watch(currentSubscriptionSchoolIdProvider);
    final subscriptionAsync = ref.watch(
      currentSchoolSubscriptionOverviewProvider,
    );
    final plansAsync = ref.watch(schoolPlansProvider);

    return SingleChildScrollView(
      padding: isCompact
          ? const EdgeInsets.all(AppSpacing.lg)
          : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscription',
            style: AppTextStyles.h2.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Kelola paket sekolah dan pantau kuota jumlah siswa berdasarkan plan aktif.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
          if (user?.role == UserRole.superadmin) ...[
            const SizedBox(height: AppSpacing.md),
            const SchoolFilter(
              label: 'Sekolah Subscription',
              allLabel: 'Pilih Sekolah',
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (schoolId == null || schoolId.isEmpty)
            const AppCard(
              child: AppEmptyState(
                icon: Icons.apartment_outlined,
                message: 'Pilih sekolah terlebih dahulu',
                subtitle:
                    'Subscription dikelola per sekolah. Pilih tenant aktif untuk melihat plan dan kuotanya.',
              ),
            )
          else
            subscriptionAsync.when(
              loading: () => const AppCard(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: AppLoadingIndicator(
                    message: 'Memuat subscription sekolah...',
                  ),
                ),
              ),
              error: (error, _) => AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: AppErrorState(
                    message: error.toString(),
                    onRetry: () {
                      ref.invalidate(currentSchoolSubscriptionOverviewProvider);
                    },
                  ),
                ),
              ),
              data: (overview) => _buildSubscriptionContent(
                context: context,
                overview: overview,
                plansAsync: plansAsync,
                schoolId: schoolId,
                isCompact: isCompact,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionContent({
    required BuildContext context,
    required SchoolSubscriptionOverview? overview,
    required AsyncValue<List<SubscriptionPlan>> plansAsync,
    required String schoolId,
    required bool isCompact,
  }) {
    if (overview == null) {
      return const AppCard(
        child: AppEmptyState(
          message: 'Subscription sekolah belum tersedia',
          subtitle:
              'Pastikan sekolah sudah memiliki subscription aktif atau trial dari backend.',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          'Plan baru akan langsung memengaruhi batas jumlah siswa yang dapat dikelola sekolah.',
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
          ),
        ),
      ],
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
          if (isCompact)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.plan.displayName,
                  style: AppTextStyles.h4.copyWith(color: AppColors.neutral900),
                ),
                const SizedBox(height: AppSpacing.sm),
                _statusBadge(subscription.status),
                const SizedBox(height: AppSpacing.md),
                _buildOverviewMeta(subscription),
              ],
            )
          else
            Row(
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
                            ? 'Subscription aktif sekolah'
                            : subscription.schoolName,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _statusBadge(subscription.status),
              ],
            ),
          if (subscription.plan.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              subscription.plan.description,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral700),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _buildOverviewMeta(subscription),
        ],
      ),
    );
  }

  Widget _buildOverviewMeta(SchoolSubscription subscription) {
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.md,
      children: [
        _metaItem('Paket', subscription.plan.tier.label),
        _metaItem('Siklus', subscription.plan.billingCycle.label),
        _metaItem('Harga', _formatIdr(subscription.plan.price)),
        _metaItem('Aktif Hingga', _formatDate(subscription.endDate)),
      ],
    );
  }

  Widget _metaItem(String label, String value) {
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
            'Basic',
            'Direkomendasikan untuk sekolah dengan kebutuhan sampai 500 siswa.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _ruleItem(
            'Pro',
            'Digunakan ketika kapasitas Basic sudah tidak cukup untuk pertumbuhan siswa.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _ruleItem(
            'Enterprise',
            'Dipakai untuk sekolah besar dengan kapasitas siswa paling tinggi.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _ruleItem(
            'Batas Siswa',
            'Jika jumlah siswa sudah mencapai batas paket, sekolah perlu upgrade paket untuk menambah siswa baru.',
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
  }) {
    if (plans.isEmpty) {
      return const AppCard(
        child: AppEmptyState(
          message: 'Belum ada paket yang tersedia',
          subtitle: 'Pastikan endpoint plan backend sudah mengirim data aktif.',
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.lg,
      children: plans.map((plan) {
        final isCurrentPlan = plan.matches(overview.plan);
        final canDowngrade =
            plan.maxStudents <= 0 || plan.maxStudents >= overview.studentsUsed;
        final canChange = !isCurrentPlan && plan.isSelectable && canDowngrade;
        final cardWidth = isCompact ? double.infinity : 320.0;

        return SizedBox(
          width: cardWidth,
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                const SizedBox(height: AppSpacing.xs),
                Text(
                  plan.description.isEmpty
                      ? 'Batas utama paket ini ada pada kapasitas jumlah siswa.'
                      : plan.description,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _planMetric(
                  'Maks. siswa',
                  plan.maxStudents <= 0
                      ? 'Tidak diketahui'
                      : '${plan.maxStudents}',
                ),
                const SizedBox(height: AppSpacing.sm),
                _planMetric('Harga', _formatIdr(plan.price)),
                const SizedBox(height: AppSpacing.sm),
                _planMetric('Siklus', plan.billingCycle.label),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: AppButton.primary(
                    label: _planActionLabel(
                      plan: plan,
                      overview: overview,
                      isCurrentPlan: isCurrentPlan,
                      canDowngrade: canDowngrade,
                    ),
                    isLoading: _changingPlanId == plan.id,
                    onPressed: canChange
                        ? () => _changePlan(
                            context: context,
                            schoolId: schoolId,
                            currentOverview: overview,
                            nextPlan: plan,
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

  String _planActionLabel({
    required SubscriptionPlan plan,
    required SchoolSubscriptionOverview overview,
    required bool isCurrentPlan,
    required bool canDowngrade,
  }) {
    if (isCurrentPlan) return 'Paket Aktif';
    if (!plan.isSelectable) return 'Tidak Dapat Dipilih';
    if (!canDowngrade) return 'Siswa Melebihi Limit Paket';
    if (plan.maxStudents > overview.plan.maxStudents) {
      return 'Upgrade ke ${plan.tier.label}';
    }
    return 'Aktifkan ${plan.tier.label}';
  }

  Future<void> _changePlan({
    required BuildContext context,
    required String schoolId,
    required SchoolSubscriptionOverview currentOverview,
    required SubscriptionPlan nextPlan,
  }) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Ubah Subscription',
      message:
          'Paket sekolah akan diubah ke ${nextPlan.displayName} dengan limit ${nextPlan.maxStudents} siswa.',
      confirmLabel: 'Ubah Paket',
    );

    if (confirmed != true) return;

    setState(() => _changingPlanId = nextPlan.id);
    try {
      await ref.read(
        changeSchoolSubscriptionProvider((
          schoolId: schoolId,
          plan: nextPlan,
        )).future,
      );

      if (!context.mounted) return;

      final wasUpgrade =
          nextPlan.maxStudents > currentOverview.plan.maxStudents;
      AppToast.show(
        context,
        message: wasUpgrade
            ? 'Paket berhasil di-upgrade ke ${nextPlan.displayName}.'
            : 'Paket sekolah berhasil diubah ke ${nextPlan.displayName}.',
      );
    } catch (e) {
      if (!context.mounted) return;
      AppToast.show(context, message: e.toString(), type: ToastType.error);
    } finally {
      if (mounted) {
        setState(() => _changingPlanId = null);
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

  String _formatIdr(int value) {
    if (value <= 0) return 'Rp 0';

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
