import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/academic/presentation/screens/academic_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/parents/presentation/screens/parents_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/school/presentation/screens/school_screen.dart';
import '../../features/staff/presentation/screens/staff_screen.dart';
import '../../features/students/presentation/screens/students_screen.dart';
import '../../features/subscription/presentation/screens/subscription_screen.dart';
import '../../features/teachers/presentation/screens/teachers_screen.dart';
import '../../features/users/presentation/screens/users_screen.dart';
import '../auth/auth_notifier.dart';
import '../auth/auth_state.dart';
import '../widgets/app_layout.dart';
import '../widgets/not_found_screen.dart';
import '../widgets/placeholder_screen.dart';
import 'route_names.dart';

const _dev3OpenRoutes = {
  RouteNames.academic,
  RouteNames.gradePromotion,
  RouteNames.studentTracking,
  RouteNames.school,
  RouteNames.subscription,
  RouteNames.payment,
  RouteNames.reports,
};

bool _startsWithAny(String location, Set<String> routes) =>
    routes.any(location.startsWith);

/// Returns a redirect path if [role] is not allowed to access [location],
/// otherwise null.
String? _roleGuard(UserRole role, String location) {
  bool can(Set<String> allowed) => _startsWithAny(location, allowed);

  if (can(_dev3OpenRoutes)) return null;

  const universalRoutes = {
    RouteNames.dashboard,
    RouteNames.profile,
    RouteNames.settings,
    RouteNames.notifications,
    RouteNames.help,
  };

  const guruRoutes = {
    RouteNames.attendance,
    RouteNames.cbt,
  };

  const studentRoutes = {
    RouteNames.attendance,
    RouteNames.cbt,
  };
  const staffRoutes = {
    RouteNames.attendance,
  };

  if (can(universalRoutes)) return null;

  return switch (role) {
    UserRole.superadmin ||
    UserRole.adminSekolah ||
    UserRole.kepalaSekolah =>
      null,
    UserRole.guru => can(guruRoutes) ? null : RouteNames.dashboard,
    UserRole.siswa ||
    UserRole.orangtua =>
      can(studentRoutes) ? null : RouteNames.dashboard,
    UserRole.staff => can(staffRoutes) ? null : RouteNames.dashboard,
  };
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authListenable = _AuthStateListenable(ref);

  return GoRouter(
    initialLocation: RouteNames.dashboard,
    refreshListenable: authListenable,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final location = state.matchedLocation;
      final isPublic = location == RouteNames.login || location == RouteNames.register;
      final isDev3Open = _startsWithAny(location, _dev3OpenRoutes);

      if (authState is AuthStateLoading) return null;

      if (authState is AuthStateUnauthenticated) {
        return (isPublic || isDev3Open) ? null : RouteNames.login;
      }

      if (isPublic) return RouteNames.dashboard;

      if (authState is AuthStateAuthenticated) {
        return _roleGuard(authState.user.role, location);
      }

      return null;
    },
    routes: [
      GoRoute(path: RouteNames.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: RouteNames.register, builder: (_, _) => const RegisterScreen()),
      ShellRoute(
        builder: (_, _, child) => AppLayout(child: child),
        routes: [
          GoRoute(path: RouteNames.dashboard, builder: (_, _) => const DashboardScreen()),
          GoRoute(path: RouteNames.profile, builder: (_, _) => const ProfileScreen()),
          GoRoute(path: RouteNames.settings, builder: (_, _) => const SettingsScreen()),
          GoRoute(path: RouteNames.notifications, builder: (_, _) => const NotificationsScreen()),
          GoRoute(
            path: '/users/:id',
            builder: (_, state) => PlaceholderScreen(
              title: 'Detail User (${state.pathParameters['id']})',
              assignedTo: 'Dev 2',
            ),
          ),
          GoRoute(path: RouteNames.users, builder: (_, _) => const UsersScreen()),
          GoRoute(path: RouteNames.students, builder: (_, _) => const StudentsScreen()),
          GoRoute(path: RouteNames.teachers, builder: (_, _) => const TeachersScreen()),
          GoRoute(path: RouteNames.staff, builder: (_, _) => const StaffScreen()),
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
          GoRoute(path: RouteNames.parents, builder: (_, _) => const ParentsScreen()),
          GoRoute(
            path: '/parents/:id',
            builder: (_, state) => PlaceholderScreen(
              title: 'Detail Orang Tua (${state.pathParameters['id']})',
              assignedTo: 'Dev 2',
            ),
          ),
          GoRoute(path: RouteNames.academic, builder: (_, _) => const AcademicScreen()),
          GoRoute(
            path: RouteNames.gradePromotion,
            builder: (_, _) => const PlaceholderScreen(title: 'Naik Kelas', assignedTo: 'Dev 3'),
          ),
          GoRoute(
            path: RouteNames.studentTracking,
            builder: (_, _) => const PlaceholderScreen(title: 'Tracking Siswa', assignedTo: 'Dev 3'),
          ),
          GoRoute(
            path: RouteNames.school,
            builder: (_, _) => const SchoolScreen(),
          ),
          GoRoute(
            path: RouteNames.cbt,
            builder: (_, _) => const PlaceholderScreen(title: 'CBT / Ujian', assignedTo: 'Dev 3'),
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
            builder: (_, _) => const PlaceholderScreen(title: 'Absensi', assignedTo: 'Dev 3'),
          ),
          GoRoute(
            path: RouteNames.subscription,
            builder: (_, _) => const SubscriptionScreen(),
          ),
          GoRoute(
            path: RouteNames.payment,
            builder: (_, _) => const PlaceholderScreen(title: 'Payment', assignedTo: 'Dev 3'),
          ),
          GoRoute(
            path: RouteNames.reports,
            builder: (_, _) => const PlaceholderScreen(title: 'Reports', assignedTo: 'Dev 3'),
          ),
          GoRoute(
            path: RouteNames.help,
            builder: (_, _) => const PlaceholderScreen(title: 'Bantuan', assignedTo: 'Dev 3'),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => NotFoundScreen(message: state.error?.message),
  );
});

/// Notifies GoRouter to re-evaluate redirect whenever auth state changes.
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen(authNotifierProvider, (_, _) => notifyListeners());
  }
}
