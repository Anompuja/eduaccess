import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/route_names.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';
import 'app_sidebar.dart';
import 'app_topbar.dart';

/// Shell widget wrapping all protected screens.
///
/// Desktop (≥1024px):
///   Row [ AppSidebar(240px fixed) | Column [ AppTopbar(72px) + content ] ]
///
/// Tablet (768–1023px):
///   Scaffold + Drawer(AppSidebar) + AppTopbar as AppBar + content
///
/// Mobile (<768px):
///   Scaffold + Drawer(AppSidebar) + AppTopbar as AppBar + content + BottomNav
class AppLayout extends ConsumerWidget {
  final Widget child;
  const AppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = Responsive.of(context);

    if (screen.isDesktop) return _DesktopLayout(child: child);
    return _MobileLayout(showBottomNav: screen.isMobile, child: child);
  }
}

// ── Desktop ───────────────────────────────────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  final Widget child;
  const _DesktopLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Row(
        children: [
          const AppSidebar(),
          Expanded(
            child: Column(
              children: [
                const AppTopbar(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mobile / Tablet ────────────────────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  final Widget child;
  final bool showBottomNav;
  const _MobileLayout({required this.child, required this.showBottomNav});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Builder(
          builder: (ctx) => AppTopbar(
            onMenuPressed: () => Scaffold.of(ctx).openDrawer(),
            isMobile: true,
          ),
        ),
      ),
      drawer: Drawer(
        width: 240,
        backgroundColor: AppColors.primary900,
        child: SafeArea(child: const AppSidebar()),
      ),
      body: child,
      bottomNavigationBar:
          showBottomNav ? _BottomNav(currentLocation: location) : null,
    );
  }
}

// ── Bottom navigation (mobile only) ───────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final String currentLocation;
  const _BottomNav({required this.currentLocation});

  static const _items = [
    _NavItem(
      label: 'Dashboard',
      icon: Icons.space_dashboard_outlined,
      activeIcon: Icons.space_dashboard_rounded,
      route: RouteNames.dashboard,
    ),
    _NavItem(
      label: 'Siswa',
      icon: Icons.school_outlined,
      activeIcon: Icons.school_rounded,
      route: RouteNames.students,
    ),
    _NavItem(
      label: 'Absensi',
      icon: Icons.fact_check_outlined,
      activeIcon: Icons.fact_check_rounded,
      route: RouteNames.attendance,
    ),
    _NavItem(
      label: 'Pengaturan',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      route: RouteNames.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = () {
      final i = _items.indexWhere((n) => currentLocation.startsWith(n.route));
      return i < 0 ? 0 : i;
    }();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: _items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final isActive = i == currentIndex;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.go(item.route),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: isActive
                            ? AppColors.primary700
                            : AppColors.neutral500,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: AppTextStyles.caption.copyWith(
                          color: isActive
                              ? AppColors.primary700
                              : AppColors.neutral500,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}
