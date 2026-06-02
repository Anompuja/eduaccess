class SubjectEntity {
  final String id;
  final String schoolId;
  final String name;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubjectEntity({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });
}
