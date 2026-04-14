import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_notifier.dart';
import '../auth/auth_state.dart';
import '../router/route_names.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

// ── Nav item model ─────────────────────────────────────────────────────────────
class _NavItem {
  final String label;
  final String route;
  final IconData icon;
  final Set<UserRole> allowedRoles;

  const _NavItem({
    required this.label,
    required this.route,
    required this.icon,
    this.allowedRoles = const {},
  });

  bool isVisibleTo(UserRole role) =>
      allowedRoles.isEmpty || allowedRoles.contains(role);
}

// ── Nav definitions ────────────────────────────────────────────────────────────
const _allRoles = <UserRole>{};

const _menuItems = [
  _NavItem(
    label: 'Dashboard',
    route: RouteNames.dashboard,
    icon: Icons.space_dashboard_outlined,
    allowedRoles: _allRoles,
  ),
  _NavItem(
    label: 'User Management',
    route: RouteNames.users,
    icon: Icons.manage_accounts_outlined,
    allowedRoles: {UserRole.superadmin, UserRole.adminSekolah},
  ),
  _NavItem(
    label: 'Manajemen Siswa',
    route: RouteNames.students,
    icon: Icons.school_outlined,
    allowedRoles: {
      UserRole.superadmin,
      UserRole.adminSekolah,
      UserRole.kepalaSekolah,
      UserRole.guru,
    },
  ),
  _NavItem(
    label: 'Manajemen Guru',
    route: RouteNames.teachers,
    icon: Icons.badge_outlined,
    allowedRoles: {
      UserRole.superadmin,
      UserRole.adminSekolah,
      UserRole.kepalaSekolah,
    },
  ),
  _NavItem(
    label: 'Manajemen Staff',
    route: RouteNames.staff,
    icon: Icons.badge_outlined,
    allowedRoles: {UserRole.superadmin, UserRole.adminSekolah},
  ),
  _NavItem(
    label: 'Orang Tua',
    route: RouteNames.parents,
    icon: Icons.family_restroom_outlined,
    allowedRoles: {
      UserRole.superadmin,
      UserRole.adminSekolah,
      UserRole.kepalaSekolah,
    },
  ),
  _NavItem(
    label: 'Struktur Akademik',
    route: RouteNames.academic,
    icon: Icons.account_tree_outlined,
    allowedRoles: {
      UserRole.superadmin,
      UserRole.adminSekolah,
      UserRole.kepalaSekolah,
    },
  ),
  _NavItem(
    label: 'Naik Kelas',
    route: RouteNames.gradePromotion,
    icon: Icons.trending_up_rounded,
    allowedRoles: {
      UserRole.superadmin,
      UserRole.adminSekolah,
      UserRole.kepalaSekolah,
    },
  ),
  _NavItem(
    label: 'CBT / Ujian',
    route: RouteNames.cbt,
    icon: Icons.quiz_outlined,
    allowedRoles: {
      UserRole.superadmin,
      UserRole.adminSekolah,
      UserRole.kepalaSekolah,
      UserRole.guru,
      UserRole.siswa,
      UserRole.orangtua,
    },
  ),
  _NavItem(
    label: 'Absensi',
    route: RouteNames.attendance,
    icon: Icons.fact_check_outlined,
    allowedRoles: {
      UserRole.superadmin,
      UserRole.adminSekolah,
      UserRole.kepalaSekolah,
      UserRole.guru,
      UserRole.siswa,
      UserRole.orangtua,
      UserRole.staff,
    },
  ),
];

const _generalItems = [
  _NavItem(
    label: 'Subscription',
    route: RouteNames.subscription,
    icon: Icons.workspace_premium_outlined,
    allowedRoles: {UserRole.superadmin, UserRole.adminSekolah},
  ),
  _NavItem(
    label: 'Pengaturan',
    route: RouteNames.settings,
    icon: Icons.settings_outlined,
    allowedRoles: _allRoles,
  ),
  _NavItem(
    label: 'Bantuan',
    route: RouteNames.help,
    icon: Icons.help_outline_rounded,
    allowedRoles: _allRoles,
  ),
];

// ── AppSidebar ─────────────────────────────────────────────────────────────────
/// Permanent 240px sidebar for desktop. Extracted as DrawerContent for mobile.
class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final user = ref.watch(currentUserProvider);
    final role = user?.role ?? UserRole.staff;

    return Container(
      width: 240,
      height: double.infinity,
      color: AppColors.primary900,
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Logo area ────────────────────────────────────────────────────
            _LogoArea(),

            // ── Divider ───────────────────────────────────────────────────────
            const Divider(
              color: AppColors.sidebarDivider,
              height: 1,
              thickness: 1,
            ),

            // ── Scrollable nav ────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // MENU section
                    _SectionLabel('MENU'),
                    ..._menuItems
                        .where((i) => i.isVisibleTo(role))
                        .map(
                          (i) => _NavItemTile(
                            item: i,
                            currentLocation: currentLocation,
                          ),
                        ),

                    const SizedBox(height: AppSpacing.md),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Divider(
                        color: AppColors.sidebarDivider,
                        height: 1,
                        thickness: 1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // GENERAL section
                    _SectionLabel('GENERAL'),
                    ..._generalItems
                        .where((i) => i.isVisibleTo(role))
                        .map(
                          (i) => _NavItemTile(
                            item: i,
                            currentLocation: currentLocation,
                          ),
                        ),
                  ],
                ),
              ),
            ),

            // ── Logout + CTA ────────────────────────────────────────────────
            _LogoutTile(ref: ref),
            const SizedBox(height: AppSpacing.md),
            _MobileAppCta(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ), // SafeArea
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _LogoArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary500,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: AppColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'EduAccess',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg + AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        text,
        style: AppTextStyles.sidebarSection.copyWith(
          color: AppColors.sidebarSectionLabel,
        ),
      ),
    );
  }
}

class _NavItemTile extends StatelessWidget {
  final _NavItem item;
  final String currentLocation;

  const _NavItemTile({required this.item, required this.currentLocation});

  bool get isActive => currentLocation.startsWith(item.route);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 2,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.lgAll,
        child: InkWell(
          onTap: () {
            // Close drawer if open (mobile), then navigate
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            context.go(item.route);
          },
          borderRadius: AppRadius.lgAll,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary700 : Colors.transparent,
              borderRadius: AppRadius.lgAll,
            ),
            child: Row(
              children: [
                // Left accent bar (active only)
                if (isActive)
                  Container(
                    width: 3,
                    height: 20,
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    decoration: const BoxDecoration(
                      color: AppColors.accent500,
                      borderRadius: AppRadius.smAll,
                    ),
                  ),
                Icon(
                  item.icon,
                  size: 18,
                  color: isActive ? AppColors.white : AppColors.sidebarNavText,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    item.label,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: isActive
                          ? AppColors.white
                          : AppColors.sidebarNavText,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  final WidgetRef ref;
  const _LogoutTile({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 2,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.lgAll,
        child: InkWell(
          onTap: () async {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            await ref.read(authNotifierProvider.notifier).logout();
          },
          borderRadius: AppRadius.lgAll,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                const Icon(
                  Icons.logout_rounded,
                  size: 18,
                  color: AppColors.sidebarNavText,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Logout',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.sidebarNavText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileAppCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.primary700,
          borderRadius: AppRadius.lgAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Download App',
              style: AppTextStyles.bodyMdSemiBold.copyWith(
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Kelola sekolah dari mana saja',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary300,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.mdAll,
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'Download',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
