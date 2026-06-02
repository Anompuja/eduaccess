import '../../domain/entities/dashboard_school.dart';

class DashboardSchoolModel extends DashboardSchool {
  const DashboardSchoolModel({
    required super.id,
    required super.name,
    required super.status,
    super.timeZone,
  });

  factory DashboardSchoolModel.fromJson(Map<String, dynamic> json) {
    return DashboardSchoolModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? '',
      timeZone: (json['time_zone'] ?? json['timeZone']) as String?,
    );
  }
}
