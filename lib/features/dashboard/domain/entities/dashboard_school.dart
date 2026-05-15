import 'package:equatable/equatable.dart';

class DashboardSchool extends Equatable {
  final String id;
  final String name;
  final String status;
  final String? timeZone;

  const DashboardSchool({
    required this.id,
    required this.name,
    required this.status,
    this.timeZone,
  });

  @override
  List<Object?> get props => [id, name, status, timeZone];
}
