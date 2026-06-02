class AcademicYearEntity {
  final String id;
  final String schoolId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AcademicYearEntity({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });
}
