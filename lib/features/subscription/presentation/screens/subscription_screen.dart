import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../data/datasources/subscription_dummy_data.dart';
import '../../data/models/subscription_entities.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late SchoolSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = subscriptionDummyData;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return SingleChildScrollView(
      padding: isMobile ? const EdgeInsets.all(AppSpacing.lg) : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscription',
            style: AppTextStyles.h2.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pantau status langganan, fitur paket, dan limit penggunaan sekolah (dummy data).',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildPlanOverview(isMobile),
          const SizedBox(height: AppSpacing.lg),
          if (isMobile)
            Column(
              children: [
                _buildFeaturesCard(),
                const SizedBox(height: AppSpacing.lg),
                _buildLimitsCard(),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildFeaturesCard()),
                const SizedBox(width: AppSpacing.lg),
                Expanded(child: _buildLimitsCard()),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPlanOverview(bool isMobile) {
    final isExpired = _subscription.status == SubscriptionStatus.expired;
    final isInactive = _subscription.status == SubscriptionStatus.inactive;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _subscription.planName,
                  style: AppTextStyles.h4.copyWith(color: AppColors.neutral900),
                ),
                const SizedBox(height: AppSpacing.sm),
                _statusBadge(_subscription.status),
                const SizedBox(height: AppSpacing.md),
                _buildOverviewMeta(),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: _buildPrimaryActionButton(isExpired, isInactive),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _subscription.planName,
                            style: AppTextStyles.h4.copyWith(color: AppColors.neutral900),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _subscription.description,
                            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _statusBadge(_subscription.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _buildOverviewMeta(),
                const SizedBox(height: AppSpacing.lg),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildPrimaryActionButton(isExpired, isInactive),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildOverviewMeta() {
    final cycleLabel = switch (_subscription.billingCycle) {
      BillingCycle.monthly => 'Bulanan',
      BillingCycle.yearly => 'Tahunan',
      BillingCycle.oneTime => 'Sekali Bayar',
    };

    final priceLabel = _formatIdr(_subscription.price);
    final endDateLabel = _formatDate(_subscription.endDate);

    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.md,
      children: [
        _metaItem('Siklus', cycleLabel),
        _metaItem('Harga', priceLabel),
        _metaItem('Berlaku Hingga', endDateLabel),
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

  Widget _statusBadge(SubscriptionStatus status) {
    return switch (status) {
      SubscriptionStatus.active => const AppBadge(label: 'ACTIVE', status: BadgeStatus.success),
      SubscriptionStatus.inactive => const AppBadge(label: 'INACTIVE', status: BadgeStatus.muted),
      SubscriptionStatus.trial => const AppBadge(label: 'TRIAL', status: BadgeStatus.info),
      SubscriptionStatus.expired => const AppBadge(label: 'EXPIRED', status: BadgeStatus.warning),
      SubscriptionStatus.cancelled => const AppBadge(label: 'CANCELLED', status: BadgeStatus.error),
    };
  }

  Widget _buildPrimaryActionButton(bool isExpired, bool isInactive) {
    if (isExpired || isInactive) {
      return AppButton.accent(
        label: 'Perpanjang Paket',
        prefixIcon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.white),
        onPressed: _showUpgradeInfo,
      );
    }

    return AppButton.primary(
      label: 'Upgrade Paket',
      prefixIcon: const Icon(Icons.trending_up_rounded, size: 18, color: AppColors.white),
      onPressed: _showUpgradeInfo,
    );
  }

  Widget _buildFeaturesCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fitur Paket', style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
          const SizedBox(height: AppSpacing.md),
          ..._subscription.features.map((feature) {
            final iconColor = feature.included ? AppColors.success : AppColors.neutral300;
            final textColor = feature.included ? AppColors.neutral900 : AppColors.neutral500;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    feature.included ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded,
                    size: 18,
                    color: iconColor,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      feature.name,
                      style: AppTextStyles.bodyMd.copyWith(color: textColor),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLimitsCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Limit Penggunaan', style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
          const SizedBox(height: AppSpacing.md),
          ..._subscription.limits.map((limit) {
            final percent = (limit.progress * 100).round();
            final isNearLimit = percent >= 85;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          limit.label,
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral900),
                        ),
                      ),
                      Text(
                        '${limit.used}/${limit.total}',
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: AppRadius.pillAll,
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: limit.progress,
                      backgroundColor: AppColors.neutral100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isNearLimit ? AppColors.warning : AppColors.primary500,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$percent% terpakai',
                    style: AppTextStyles.caption.copyWith(
                      color: isNearLimit ? AppColors.warning : AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showUpgradeInfo() {
    AppToast.show(
      context,
      message: 'Fitur upgrade/perpanjang akan dihubungkan ke backend payment.',
      type: ToastType.info,
    );
  }

  String _formatIdr(int value) {
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

  String _formatDate(DateTime date) {
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
