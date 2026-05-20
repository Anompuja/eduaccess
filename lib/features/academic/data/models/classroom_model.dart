import '../../domain/entities/classroom_entity.dart';

class ClassroomModel extends ClassroomEntity {
  const ClassroomModel({
    required super.id,
    required super.schoolId,
    required super.name,
    required super.capacity,
    required super.floor,
    required super.building,
    required super.roomType,
    required super.status,
    required super.facilities,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ClassroomModel.fromJson(Map<String, dynamic> json) {
    return ClassroomModel(
      id: json['id'] as String? ?? '',
      schoolId: json['school_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      floor: (json['floor'] as num?)?.toInt() ?? 0,
      building: json['building'] as String? ?? '',
      roomType: json['room_type'] as String? ?? '',
      status: json['status'] as String? ?? 'available',
      facilities: json['facilities'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
