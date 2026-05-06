import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Model ─────────────────────────────────────────────────────────────────────
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String time;
  final bool isRead;
  final NotifCategory category;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    required this.category,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        body: body,
        time: time,
        isRead: isRead ?? this.isRead,
        category: category,
      );
}

enum NotifCategory { exam, attendance, student, system }

// ── Notifier ──────────────────────────────────────────────────────────────────
class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier()
      : super([
          const AppNotification(
            id: '1',
            title: 'Ujian Matematika Dimulai',
            body: 'UTS Matematika Kelas 10A akan dimulai dalam 15 menit.',
            time: '5 menit lalu',
            isRead: false,
            category: NotifCategory.exam,
          ),
          const AppNotification(
            id: '2',
            title: 'Absensi Belum Dikonfirmasi',
            body: 'Kelas 11B belum mengisi absensi hari ini.',
            time: '30 menit lalu',
            isRead: false,
            category: NotifCategory.attendance,
          ),
          const AppNotification(
            id: '3',
            title: 'Siswa Baru Terdaftar',
            body: 'Ahmad Fauzi telah berhasil didaftarkan ke Kelas 10A.',
            time: '1 jam lalu',
            isRead: true,
            category: NotifCategory.student,
          ),
          const AppNotification(
            id: '4',
            title: 'Pembaruan Sistem',
            body: 'EduAccess diperbarui ke versi 1.0.1. Lihat perubahan terbaru.',
            time: '2 jam lalu',
            isRead: true,
            category: NotifCategory.system,
          ),
        ]);

  void markRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  void markAllRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>(
  (ref) => NotificationsNotifier(),
);

/// Unread count — read by AppTopbar bell badge.
final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.isRead).length;
});
