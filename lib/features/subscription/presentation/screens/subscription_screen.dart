import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/auth/auth_state.dart';
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
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/school_filter.dart';
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
    final trackedPayment = ref.watch(activeSubscriptionPaymentProvider);

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
            'Kelola paket sekolah dan pantau kuota siswa sesuai paket yang sedang aktif.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
          if (user?.role == UserRole.superadmin) ...[
            const SizedBox(height: AppSpacing.md),
            const SchoolFilter(
              label: 'Sekolah Paket',
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
                    'Pilih sekolah aktif untuk melihat paket, kuota siswa, dan pembayaran.',
              ),
            )
          else
            subscriptionAsync.when(
              loading: () => const AppCard(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: AppLoadingIndicator(
                    message: 'Memuat paket sekolah...',
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
                trackedPayment: trackedPayment,
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
