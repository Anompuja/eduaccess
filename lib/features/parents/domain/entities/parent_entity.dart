class ParentEntity {
  final String parentId;
  final String name;
  final String email;
  final String phoneNumber;
  final String religion;
  final String address;
  final String schoolId;
  final String createdAt;
  final String updatedAt;

  ParentEntity({
    required this.parentId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.religion,
    required this.address,
    required this.schoolId,
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
          phoneNumber == other.phoneNumber &&
          religion == other.religion &&
          address == other.address &&
          schoolId == other.schoolId &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => parentId.hashCode;

  @override
  String toString() => 'ParentEntity(parentId: $parentId, name: $name)';
}
