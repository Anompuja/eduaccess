/// EduAccess API endpoint constants.
/// Base URL is configured via environment — never hardcoded here.
/// Usage: ApiEndpoints.login → '/auth/login'
abstract final class ApiEndpoints {
  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login   = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout  = '/auth/logout';
  static const String me      = '/auth/me';

  // ── Dashboard ─────────────────────────────────────────────────────────────
  static const String dashboardStats = '/dashboard/stats';

  // ── Students ──────────────────────────────────────────────────────────────
  static const String students = '/students';
  static String studentById(String id) => '/students/$id';
  static String studentPassword(String id) => '/students/$id/password';

  // ── Staff (Guru & Staff) ──────────────────────────────────────────────────
  static const String staff = '/staff';
  static String staffById(String id) => '/staff/$id';

  // ── Parents (Orang Tua) ───────────────────────────────────────────────────
  static const String parents = '/parents';
  static String parentById(String id) => '/parents/$id';

  // ── Academic ──────────────────────────────────────────────────────────────
  static const String classrooms = '/classrooms';
  static const String academicYears = '/academic-years';
  static const String gradePromotion = '/grade-promotion';

  // ── CBT / Exams ───────────────────────────────────────────────────────────
  static const String exams = '/exams';
  static String examById(String id) => '/exams/$id';

  // ── Attendance ────────────────────────────────────────────────────────────
  static const String attendance = '/attendance';

  // ── Subscription ─────────────────────────────────────────────────────────
  static const String subscription = '/subscription';

  // ── Profile ───────────────────────────────────────────────────────────────
  static const String profile = '/profile';
  static String userPassword(String id) => '/users/$id/password';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String notifications = '/notifications';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const String notificationsReadAll = '/notifications/read-all';
}
