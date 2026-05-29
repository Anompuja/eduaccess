/// EduAccess API endpoint constants.
/// Base URL is configured via environment — never hardcoded here.
/// Usage: ApiEndpoints.login → '/auth/login'
abstract final class ApiEndpoints {
  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/profile';

  // ── Admins ───────────────────────────────────────────────────────────────
  static const String admins = '/admins';
  static String adminById(String id) => '/admins/$id';

  // ── Dashboard ─────────────────────────────────────────────────────────────
  static const String dashboardStats = '/dashboard/stats';
  static const String schools = '/schools';

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

  // ── Academic Structure ────────────────────────────────────────────────────────
  static const String academicLevels = '/academic/levels';
  static String academicLevelById(String id) => '/academic/levels/$id';
  static const String academicClasses = '/academic/classes';
  static String academicClassById(String id) => '/academic/classes/$id';
  static const String academicSubClasses = '/academic/sub-classes';
  static String academicSubClassById(String id) => '/academic/sub-classes/$id';
  static const String academicYearsList = '/academic/academic-years';
  static String academicYearById(String id) => '/academic/academic-years/$id';
  static String academicYearActivate(String id) => '/academic/academic-years/$id/activate';
  static const String subjectsList = '/academic/subjects';
  static String subjectById(String id) => '/academic/subjects/$id';
  static const String classroomsList = '/academic/classrooms';
  static String classroomById(String id) => '/academic/classrooms/$id';
  static const String schedulesList = '/academic/schedules';
  static String scheduleById(String id) => '/academic/schedules/$id';

  // ── Class Schedules ───────────────────────────────────────────────────────
  static const String classSchedules = '/class-schedules';
  static String classScheduleById(String id) => '/class-schedules/$id';
  static String classScheduleStart(String id) => '/class-schedules/$id/start';
  static String classScheduleComplete(String id) => '/class-schedules/$id/complete';
  static String classScheduleCancel(String id) => '/class-schedules/$id/cancel';
  static String classScheduleSyncStudents(String id) => '/class-schedules/$id/sync-students';
  static String classScheduleAttendances(String id) => '/class-schedules/$id/attendances';
  static String classScheduleAttendance(String scheduleId, String studentId) => '/class-schedules/$scheduleId/attendances/$studentId';

  // ── Student Tracking & Promotion ──────────────────────────────────────────
  static const String studentStudies = '/student-studies';
  static String studentStudyDetail(String studentId) => '/student-studies/$studentId';
  static const String studentPromotions = '/student-promotions';
  static const String studentPromotionPromote = '/student-promotions/promote';

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
