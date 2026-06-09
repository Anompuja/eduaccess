import '../../domain/entities/notification_entity.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl {
  final NotificationsRemoteDataSource _dataSource;

  NotificationsRepositoryImpl(this._dataSource);

  Future<List<NotificationEntity>> getNotifications({bool unreadOnly = false}) async {
    return _dataSource.getNotifications(unreadOnly: unreadOnly);
  }

  Future<void> markRead(String id) => _dataSource.markRead(id);

  Future<void> markAllRead() => _dataSource.markAllRead();
}
