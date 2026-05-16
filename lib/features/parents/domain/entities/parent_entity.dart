class ParentEntity {
  final String parentId;
  final String name;
  final String email;
  final String phone;
  final int childrenCount;
  final String createdAt;
  final String updatedAt;

  ParentEntity({
    required this.parentId,
    required this.name,
    required this.email,
    required this.phone,
    required this.childrenCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParentEntity &&
          runtimeType == other.runtimeType &&
          parentId == other.parentId &&
          name == other.name &&
          email == other.email &&
          phone == other.phone &&
          childrenCount == other.childrenCount &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => parentId.hashCode;

  @override
  String toString() => 'ParentEntity(parentId: $parentId, name: $name)';
}
