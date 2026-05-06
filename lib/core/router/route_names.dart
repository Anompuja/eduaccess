/// Named route constants for GoRouter.
/// Always use these constants — never hardcode path strings in widgets.
///
/// Usage: context.go(RouteNames.dashboard)
///        context.push(RouteNames.studentDetail('abc123'))
abstract final class RouteNames {
  // ── Public ────────────────────────────────────────────────────────────────
  static const String login = '/login';
  static const String register = '/register';

  // ── Protected — Dev 1 (foundation) ───────────────────────────────────────
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';

  // ── Protected — Dev 2 (people management) ────────────────────────────────
  static const String users = '/users';
  static const String students = '/students';
  static const String teachers = '/teachers';
  static const String staff = '/staff';
  static const String parents = '/parents';

  // ── Protected — Dev 3 (academic & operations) ────────────────────────────
  static const String academic = '/academic';
  static const String gradePromotion = '/class-promotion';
  static const String studentTracking = '/student-tracking';
  static const String school = '/school';
  static const String cbt = '/cbt';
  static const String attendance = '/attendance';
  static const String subscription = '/subscription';
  static const String payment = '/payment';
  static const String reports = '/reports';
  static const String help = '/help';

  // ── Dynamic path helpers ──────────────────────────────────────────────────
  static String userDetail(String id) => '/users/$id';
  static String studentDetail(String id) => '/students/$id';
  static String teacherDetail(String id) => '/teachers/$id';
  static String staffDetail(String id) => '/staff/$id';
  static String parentDetail(String id) => '/parents/$id';
  static String examDetail(String id) => '/cbt/$id';
}
