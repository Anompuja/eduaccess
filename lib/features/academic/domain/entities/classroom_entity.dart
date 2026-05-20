class ClassroomEntity {
  final String id;
  final String schoolId;
  final String name;
  final int capacity;
  final int floor;
  final String building;
  final String roomType;
  final String status;
  final String facilities;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClassroomEntity({
    required this.id,
    required this.schoolId,
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
