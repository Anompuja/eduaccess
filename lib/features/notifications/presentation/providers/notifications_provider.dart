import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/auth/token_storage.dart';
import '../../data/datasources/notifications_remote_data_source.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/entities/notification_entity.dart';
import '../../data/models/notification_model.dart';

// ── Base URL helper ─────────────────────────────────────────────────────────
const _kWsBaseUrl = String.fromEnvironment('EDUACCESS_WS_BASE', defaultValue: '');

String _resolveWsBase() {
  if (_kWsBaseUrl.isNotEmpty) return _kWsBaseUrl;
  return 'ws://localhost:8080';
}

// ── Repository Provider ─────────────────────────────────────────────────────
final notificationsRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationsRepositoryImpl(NotificationsRemoteDataSource(dio));
});

// ── All notifications ────────────────────────────────────────────────────────
final notificationsProvider =
    FutureProvider.autoDispose<List<NotificationEntity>>((ref) async {
  final repo = ref.watch(notificationsRepositoryProvider);
  return repo.getNotifications();
});

// ── Unread count (used for bell badge) ──────────────────────────────────────
final unreadNotificationsProvider =
    FutureProvider.autoDispose<List<NotificationEntity>>((ref) async {
  final repo = ref.watch(notificationsRepositoryProvider);
  return repo.getNotifications(unreadOnly: true);
});

// ── Mark single notification read ───────────────────────────────────────────
final markReadProvider =
    FutureProvider.autoDispose.family<void, String>((ref, id) async {
  final repo = ref.watch(notificationsRepositoryProvider);
  await repo.markRead(id);
  ref.invalidate(notificationsProvider);
  ref.invalidate(unreadNotificationsProvider);
});

// ── Mark all read ────────────────────────────────────────────────────────────
final markAllReadProvider = FutureProvider.autoDispose<void>((ref) async {
  final repo = ref.watch(notificationsRepositoryProvider);
  await repo.markAllRead();
  ref.invalidate(notificationsProvider);
  ref.invalidate(unreadNotificationsProvider);
});

// ── WebSocket stream ─────────────────────────────────────────────────────────
// Connects to /ws/notifications?token=<JWT> and emits decoded NotificationEntity.
// Automatically invalidates badge count when a new notification arrives.
final notificationWsProvider =
    StreamProvider.autoDispose<NotificationEntity>((ref) async* {
  final tokenStorage = ref.read(tokenStorageProvider);
  final token = await tokenStorage.getAccessToken();
  if (token == null) return;

  final wsUrl = '${_resolveWsBase()}/ws/notifications?token=${Uri.encodeComponent(token)}';

  WebSocketChannel? channel;
  try {
    channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    await channel.ready;

    await for (final message in channel.stream) {
      final text = message is String ? message : String.fromCharCodes(message as List<int>);
      try {
        final json = jsonDecode(text) as Map<String, dynamic>;
        final notification = NotificationModel.fromJson(json);
        // Refresh badge count whenever a new push arrives
        ref.invalidate(unreadNotificationsProvider);
        yield notification;
      } catch (_) {
        // Ignore non-JSON frames (pings etc.)
      }
    }
  } catch (_) {
    // Connection failure is silently ignored — app works offline without WS
  } finally {
    await channel?.sink.close();
  }
});
