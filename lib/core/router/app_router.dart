import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../auth/auth_notifier.dart';
import '../auth/auth_state.dart';
import '../widgets/app_layout.dart';
import '../widgets/not_found_screen.dart';
import '../widgets/placeholder_screen.dart';
import 'route_names.dart';

// ── Provider ──────────────────────────────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  // Listen to auth state changes to refresh the router redirect
  final authListenable = _AuthStateListenable(ref);

  return GoRouter(
    initialLocation: RouteNames.dashboard,
    refreshListenable: authListenable,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isLoading = authState is AuthStateLoading;
      final isAuthenticated = authState is AuthStateAuthenticated;
      final isPublicRoute = state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.register;

      // While checking storage, show nothing (splash)
      if (isLoading) return null;

      // Unauthenticated → push to login (unless already on public route)
      if (!isAuthenticated && !isPublicRoute) return RouteNames.login;

      // Already authenticated → redirect away from login/register
      if (isAuthenticated && isPublicRoute) return RouteNames.dashboard;

      return null;
    },
    routes: [
      // ── Public routes ───────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.login,
        builder: (_, _) => const LoginScreen(),
      ),
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

          // Dev 2 — People management (placeholder until Session Dev2)
          GoRoute(
            path: RouteNames.students,
            builder: (_, _) => const PlaceholderScreen(
              title: 'Manajemen Siswa',
              assignedTo: 'Dev 2',
            ),
          ),
          GoRoute(
            path: '/students/:id',
            builder: (_, state) => PlaceholderScreen(
              title: 'Detail Siswa (${state.pathParameters['id']})',
              assignedTo: 'Dev 2',
            ),
          ),
          GoRoute(
            path: RouteNames.staff,
            builder: (_, _) => const PlaceholderScreen(
              title: 'Guru & Staff',
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
            builder: (_, _) => const PlaceholderScreen(
              title: 'Orang Tua',
              assignedTo: 'Dev 2',
            ),
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
            builder: (_, _) => const PlaceholderScreen(
              title: 'Absensi',
              assignedTo: 'Dev 3',
            ),
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
            builder: (_, _) => const PlaceholderScreen(
              title: 'Bantuan',
              assignedTo: 'Dev 3',
            ),
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
