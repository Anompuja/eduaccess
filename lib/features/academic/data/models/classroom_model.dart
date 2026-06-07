import '../../domain/entities/classroom_entity.dart';

class ClassroomModel extends ClassroomEntity {
  const ClassroomModel({
    required super.id,
    required super.schoolId,
    super.classId,
    super.subClassId,
    super.academicYearId,
    super.homeroomTeacherId,
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

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  factory ClassroomModel.fromJson(Map<String, dynamic> json) {
    return ClassroomModel(
      id: json['id'] as String? ?? '',
      schoolId: json['school_id'] as String? ?? '',
      classId: json['class_id'] as String?,
      subClassId: json['sub_class_id'] as String?,
      academicYearId: json['academic_year_id'] as String?,
      homeroomTeacherId: json['homeroom_teacher_id'] as String?,
      name: json['name'] as String? ?? '',
      capacity: _parseInt(json['capacity']),
      floor: json['floor']?.toString() ?? '',
      building: json['building'] as String? ?? '',
      roomType: json['room_type'] as String? ?? '',
      status: json['status'] as String? ?? 'available',
      facilities: json['facilities'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
