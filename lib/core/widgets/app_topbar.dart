import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_notifier.dart';
import '../router/route_names.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Page title and subtitle mapped from route.
typedef _PageInfo = ({String title, String subtitle});

_PageInfo _infoForRoute(String location) => switch (location) {
      String l when l.startsWith(RouteNames.dashboard)     => (title: 'Dashboard',          subtitle: 'Selamat datang di EduAccess'),
      String l when l.startsWith(RouteNames.students)      => (title: 'Manajemen Siswa',    subtitle: 'Kelola data siswa sekolah'),
      String l when l.startsWith(RouteNames.staff)         => (title: 'Guru & Staff',        subtitle: 'Kelola tenaga pendidik dan staf'),
      String l when l.startsWith(RouteNames.parents)       => (title: 'Orang Tua',           subtitle: 'Kelola data wali murid'),
      String l when l.startsWith(RouteNames.academic)      => (title: 'Struktur Akademik',   subtitle: 'Tahun ajaran, kelas & mata pelajaran'),
      String l when l.startsWith(RouteNames.gradePromotion)=> (title: 'Naik Kelas',          subtitle: 'Proses kenaikan kelas siswa'),
      String l when l.startsWith(RouteNames.cbt)           => (title: 'CBT / Ujian',         subtitle: 'Buat dan kelola ujian online'),
      String l when l.startsWith(RouteNames.attendance)    => (title: 'Absensi',             subtitle: 'Rekap kehadiran harian'),
      String l when l.startsWith(RouteNames.subscription)  => (title: 'Subscription',        subtitle: 'Kelola paket langganan sekolah'),
      String l when l.startsWith(RouteNames.settings)      => (title: 'Pengaturan',          subtitle: 'Preferensi aplikasi'),
      String l when l.startsWith(RouteNames.notifications) => (title: 'Notifikasi',          subtitle: 'Pesan dan pemberitahuan sistem'),
      String l when l.startsWith(RouteNames.profile)       => (title: 'Profil',              subtitle: 'Informasi akun Anda'),
      _ => (title: 'EduAccess', subtitle: ''),
    };

// ── AppTopbar ──────────────────────────────────────────────────────────────────
/// 72px topbar — page title, notification bell, avatar.
/// Rendered inside AppLayout for all protected routes.
class AppTopbar extends ConsumerWidget {
  /// Optional: override title/subtitle from layout (mobile uses this).
  final String? titleOverride;
  final VoidCallback? onMenuPressed; // mobile hamburger

  const AppTopbar({super.key, this.titleOverride, this.onMenuPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final info = titleOverride != null
        ? (title: titleOverride!, subtitle: '')
        : _infoForRoute(location);
    final user = ref.watch(currentUserProvider);
    final initials = _initials(user?.name ?? '');

    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: AppShadows.topbar,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          // Hamburger (mobile only)
          if (onMenuPressed != null) ...[
            IconButton(
              onPressed: onMenuPressed,
              icon: const Icon(Icons.menu_rounded,
                  color: AppColors.neutral700),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],

          // Page title + subtitle
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  style: AppTextStyles.h3.copyWith(color: AppColors.neutral900),
                ),
                if (info.subtitle.isNotEmpty)
                  Text(
                    info.subtitle,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
              ],
            ),
          ),

          // Notification bell
          _NotificationBell(),
          const SizedBox(width: AppSpacing.md),

          // User avatar
          GestureDetector(
            onTap: () => context.push(RouteNames.profile),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary500,
              child: Text(
                initials,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

// ── Notification bell with badge ───────────────────────────────────────────────
class _NotificationBell extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO (Session 3): wire to real notification count provider
    const int unreadCount = 0;

    return GestureDetector(
      onTap: () => context.push(RouteNames.notifications),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.neutral100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              size: 20,
              color: AppColors.neutral700,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
