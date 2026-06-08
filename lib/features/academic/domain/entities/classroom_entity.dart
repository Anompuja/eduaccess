class ClassroomEntity {
  final String id;
  final String schoolId;
  final String? classId;
  final String? subClassId;
  final String? academicYearId;
  final String? homeroomTeacherId;
  final String name;
  final int capacity;
  final String floor;
  final String building;
  final String roomType;
  final String status;
  final String facilities;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClassroomEntity({
    required this.id,
    required this.schoolId,
    this.classId,
    this.subClassId,
    this.academicYearId,
    this.homeroomTeacherId,
    required this.name,
    required this.capacity,
    required this.floor,
    required this.building,
    required this.roomType,
    required this.status,
    required this.facilities,
    required this.createdAt,
    required this.updatedAt,
  });
}
