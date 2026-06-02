class EducationLevelEntity {
  final String id;
  final String schoolId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EducationLevelEntity({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
}
