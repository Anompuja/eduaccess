import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/parents/presentation/screens/parents_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/students/presentation/screens/students_screen.dart';
import '../../features/staff/presentation/screens/staff_screen.dart';
import '../../features/teachers/presentation/screens/teachers_screen.dart';
import '../auth/auth_notifier.dart';
import '../auth/auth_state.dart';
import '../widgets/app_layout.dart';
import '../widgets/not_found_screen.dart';
import '../widgets/placeholder_screen.dart';
import 'route_names.dart';

// ── Role-based route guard ────────────────────────────────────────────────────
/// Returns a redirect path if [role] is not allowed to access [location],
/// otherwise null (allow through).
String? _roleGuard(UserRole role, String location) {
  // Everyone can access these
  const universalRoutes = {
    RouteNames.dashboard,
    RouteNames.profile,
    RouteNames.settings,
    RouteNames.notifications,
    RouteNames.help,
  };

  // Guru + admins
  const guruRoutes = {
    RouteNames.attendance,
    RouteNames.cbt,
  };

  // Siswa + orangtua (personal access to attendance & CBT)
  const studentRoutes = {
    RouteNames.attendance,
    RouteNames.cbt,
  };

  bool can(Set<String> allowed) =>
      allowed.any((r) => location.startsWith(r));

  if (can(universalRoutes)) return null;

  return switch (role) {
    UserRole.superadmin ||
    UserRole.adminSekolah ||
    UserRole.kepalaSekolah =>
      null, // full access
    UserRole.guru =>
      can(guruRoutes) ? null : RouteNames.dashboard,
    UserRole.siswa ||
    UserRole.orangtua =>
      can(studentRoutes) ? null : RouteNames.dashboard,
    UserRole.staff =>
      can({RouteNames.attendance}) ? null : RouteNames.dashboard,
  };
}

final appRouterProvider = Provider<GoRouter>((ref) {
  // Listen to auth state changes to refresh the router redirect
  final authListenable = _AuthStateListenable(ref);

  return GoRouter(
    initialLocation: RouteNames.dashboard,
    refreshListenable: authListenable,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final location = state.matchedLocation;
      final isPublic = location == RouteNames.login ||
          location == RouteNames.register;

      // Still loading tokens — don't redirect yet
      if (authState is AuthStateLoading) return null;

      // Unauthenticated: send to login (unless already on a public route)
      if (authState is AuthStateUnauthenticated) {
        return isPublic ? null : RouteNames.login;
      }

      // Authenticated: bounce away from public routes
      if (isPublic) return RouteNames.dashboard;

      // Role-based guard
      if (authState is AuthStateAuthenticated) {
        return _roleGuard(authState.user.role, location);
      }

      return null;
    },
    routes: [
      // ── Public routes ───────────────────────────────────────────────────
      GoRoute(path: RouteNames.login, builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: RouteNames.register,
        builder: (_, _) => const RegisterScreen(),
      ),

      // ── Protected shell (AppLayout wraps all protected screens) ─────────
      ShellRoute(
        builder: (_, _, child) => AppLayout(child: child),
        routes: [
          // Dev 1 — Dashboard & core screens
          GoRoute(
            path: RouteNames.dashboard,
            builder: (_, _) => const DashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.profile,
            builder: (_, _) => const ProfileScreen(),
          ),
          GoRoute(
            path: RouteNames.settings,
            builder: (_, _) => const SettingsScreen(),
          ),
          GoRoute(
            path: RouteNames.notifications,
            builder: (_, _) => const NotificationsScreen(),
          ),

          GoRoute(
            path: '/users/:id',
            builder: (_, state) => PlaceholderScreen(
              title: 'Detail User (${state.pathParameters['id']})',
              assignedTo: 'Dev 2',
            ),
          ),
          GoRoute(
            path: RouteNames.students,
            builder: (_, _) => const StudentsScreen(),
          ),
          GoRoute(
            path: RouteNames.teachers,
            builder: (_, _) => const TeachersScreen(),
          ),
          GoRoute(
            path: RouteNames.staff,
            builder: (_, _) => const StaffScreen(),
          ),
          GoRoute(
            path: '/teachers/:id',
            builder: (_, state) => PlaceholderScreen(
              title: 'Detail Guru (${state.pathParameters['id']})',
              assignedTo: 'Dev 2',
            ),
          ),
          GoRoute(
            path: '/staff/:id',
            builder: (_, state) => PlaceholderScreen(
              title: 'Detail Staff (${state.pathParameters['id']})',
              assignedTo: 'Dev 2',
            ),
          ),
          GoRoute(
            path: RouteNames.parents,
            builder: (_, _) => const ParentsScreen(),
          ),
          GoRoute(
            path: '/parents/:id',
            builder: (_, state) => PlaceholderScreen(
              title: 'Detail Orang Tua (${state.pathParameters['id']})',
              assignedTo: 'Dev 2',
            ),
          ),

          // Dev 3 — Academic & operations (placeholder)
          GoRoute(
            path: RouteNames.academic,
            builder: (_, _) => const PlaceholderScreen(
              title: 'Struktur Akademik',
              assignedTo: 'Dev 3',
            ),
          ),
          GoRoute(
            path: RouteNames.gradePromotion,
            builder: (_, _) => const PlaceholderScreen(
              title: 'Naik Kelas',
              assignedTo: 'Dev 3',
            ),
          ),
          GoRoute(
            path: RouteNames.cbt,
            builder: (_, _) => const PlaceholderScreen(
              title: 'CBT / Ujian',
              assignedTo: 'Dev 3',
            ),
          ),
          GoRoute(
            path: '/cbt/:id',
            builder: (_, state) => PlaceholderScreen(
              title: 'Detail Ujian (${state.pathParameters['id']})',
              assignedTo: 'Dev 3',
            ),
          ),
          GoRoute(
            path: RouteNames.attendance,
            builder: (_, _) =>
                const PlaceholderScreen(title: 'Absensi', assignedTo: 'Dev 3'),
          ),
          GoRoute(
            path: RouteNames.subscription,
            builder: (_, _) => const PlaceholderScreen(
              title: 'Subscription',
              assignedTo: 'Dev 3',
            ),
          ),
          GoRoute(
            path: RouteNames.help,
            builder: (_, _) =>
                const PlaceholderScreen(title: 'Bantuan', assignedTo: 'Dev 3'),
          ),
        ],
      ),
    ],

    // ── 404 error page ───────────────────────────────────────────────────────
    errorBuilder: (context, state) =>
        NotFoundScreen(message: state.error?.message),
  );
});

// ── Auth state listenable for GoRouter refreshListenable ────────────────────
/// Notifies GoRouter to re-evaluate the redirect whenever auth state changes.
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen(authNotifierProvider, (_, _) => notifyListeners());
  }
}
