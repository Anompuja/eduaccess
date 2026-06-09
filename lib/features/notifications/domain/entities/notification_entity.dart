class NotificationEntity {
  final String id;
  final String? schoolId;
  final String userId;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String? readAt;
  final String createdAt;
  final String updatedAt;

  const NotificationEntity({
    required this.id,
    this.schoolId,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isRead => readAt != null && readAt!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
