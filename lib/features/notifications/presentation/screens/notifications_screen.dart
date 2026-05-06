import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (unreadCount > 0) ...[
                AppBadge(
                  label: '$unreadCount belum dibaca',
                  status: BadgeStatus.active,
                ),
                const Spacer(),
                AppButton.ghost(
                  label: 'Tandai semua dibaca',
                  onPressed: () =>
                      ref.read(notificationsProvider.notifier).markAllRead(),
                ),
              ] else
                const Spacer(),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: notifs.isEmpty
                ? const AppEmptyState(
                    message: 'Tidak ada notifikasi',
                    subtitle: 'Semua notifikasi sistem akan muncul di sini',
                    icon: Icons.notifications_off_outlined,
                  )
                : ListView.separated(
                    itemCount: notifs.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) => _NotifCard(
                      notif: notifs[i],
                      onTap: () => ref
                          .read(notificationsProvider.notifier)
                          .markRead(notifs[i].id),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onTap;

  const _NotifCard({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final iconData = switch (notif.category) {
      NotifCategory.exam       => Icons.quiz_outlined,
      NotifCategory.attendance => Icons.fact_check_outlined,
      NotifCategory.student    => Icons.school_outlined,
      NotifCategory.system     => Icons.info_outline_rounded,
    };
    final iconColor = switch (notif.category) {
      NotifCategory.exam       => AppColors.accent700,
      NotifCategory.attendance => AppColors.success,
      NotifCategory.student    => AppColors.primary700,
      NotifCategory.system     => AppColors.info,
    };
    final iconBg = switch (notif.category) {
      NotifCategory.exam       => AppColors.accent100,
      NotifCategory.attendance => AppColors.success.withValues(alpha: 0.1),
      NotifCategory.student    => AppColors.primary100,
      NotifCategory.system     => AppColors.info.withValues(alpha: 0.1),
    };

    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        color: notif.isRead
            ? AppColors.white
            : AppColors.primary100.withValues(alpha: 0.4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: AppTextStyles.bodyMdSemiBold.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary500,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.neutral700),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    notif.time,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.neutral500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
