class ParentRowData {
  final String parentId;
  final String name;
  final String email;
  final String phone;
  final int childrenCount;
  final String createdAt;
  final String updatedAt;

  const ParentRowData({
    required this.parentId,
    required this.name,
    required this.email,
    required this.phone,
    required this.childrenCount,
    required this.createdAt,
    required this.updatedAt,
  });
}
