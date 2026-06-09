import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_list_item.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    // Keep WS alive while screen is open
    ref.watch(notificationWsProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Notifikasi',
                  style: AppTextStyles.h4.copyWith(color: AppColors.neutral900),
                ),
              ),
              notificationsAsync.when(
                data: (list) {
                  final hasUnread = list.any((n) => !n.isRead);
                  if (!hasUnread) return const SizedBox.shrink();
                  return AppButton.secondary(
                    label: 'Tandai semua dibaca',
                    onPressed: () async {
                      await ref.read(markAllReadProvider.future);
                    },
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: notificationsAsync.when(
              loading: () => const Center(child: AppLoadingIndicator()),
              error: (err, _) => AppErrorState(
                message: err.toString(),
                onRetry: () => ref.invalidate(notificationsProvider),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.notifications_none_rounded,
                    message: 'Belum ada notifikasi',
                    subtitle: 'Notifikasi akan muncul di sini saat ada aktivitas',
                  );
                }
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.neutral100),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) =>
                          NotificationListItem(notification: list[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
