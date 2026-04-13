import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/route_names.dart';
import '../theme/app_colors.dart';
import 'app_sidebar.dart';
import 'app_topbar.dart';

/// Shell widget wrapping all protected screens.
///
/// Desktop (≥1024px):
///   Row [ AppSidebar(240px) | Column [ AppTopbar(72px) | content ] ]
///
/// Mobile (<768px):
///   Scaffold + Drawer(AppSidebar) + BottomNavigationBar + AppTopbar(AppBar)
class AppLayout extends ConsumerWidget {
  final Widget child;
  const AppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;

    if (isDesktop) {
      return _DesktopLayout(child: child);
    }
    return _MobileLayout(child: child);
  }
}

// ── Desktop layout ────────────────────────────────────────────────────────────
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
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mobile layout ─────────────────────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  final Widget child;
  const _MobileLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Builder(
          builder: (ctx) => AppTopbar(
            onMenuPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: const Drawer(
        width: 240,
        backgroundColor: AppColors.primary900,
        child: AppSidebar(),
      ),
      body: child,
      bottomNavigationBar: _BottomNav(currentLocation: location),
    );
  }
}

// ── Mobile bottom navigation ──────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final String currentLocation;
  const _BottomNav({required this.currentLocation});

  static const _items = [
    _BottomNavItem(
      label: 'Dashboard',
      icon: Icons.space_dashboard_outlined,
      activeIcon: Icons.space_dashboard_rounded,
      route: RouteNames.dashboard,
    ),
    _BottomNavItem(
      label: 'Siswa',
      icon: Icons.school_outlined,
      activeIcon: Icons.school_rounded,
      route: RouteNames.students,
    ),
    _BottomNavItem(
      label: 'Absensi',
      icon: Icons.fact_check_outlined,
      activeIcon: Icons.fact_check_rounded,
      route: RouteNames.attendance,
    ),
    _BottomNavItem(
      label: 'Pengaturan',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      route: RouteNames.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _items.indexWhere(
      (i) => currentLocation.startsWith(i.route),
    );

    return BottomNavigationBar(
      currentIndex: currentIndex < 0 ? 0 : currentIndex,
      onTap: (i) => context.go(_items[i].route),
      items: _items
          .map(
            (i) => BottomNavigationBarItem(
              icon: Icon(i.icon),
              activeIcon: Icon(i.activeIcon),
              label: i.label,
            ),
          )
          .toList(),
    );
  }
}

class _BottomNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}
