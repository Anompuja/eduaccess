class ClassEntity {
  final String id;
  final String schoolId;
  final String educationLevelId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClassEntity({
    required this.id,
    required this.schoolId,
    required this.educationLevelId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
}
