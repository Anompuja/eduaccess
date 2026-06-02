enum SchoolStatus { active, nonactive }

class SchoolProfile {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String description;
  final String imagePath;
  final String timeZone;
  final SchoolStatus status;

  const SchoolProfile({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.description,
    required this.imagePath,
    required this.timeZone,
    required this.status,
  });

  SchoolProfile copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    String? description,
    String? imagePath,
    String? timeZone,
    SchoolStatus? status,
  }) {
    return SchoolProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      timeZone: timeZone ?? this.timeZone,
      status: status ?? this.status,
    );
  }
}

class SchoolRule {
  final String id;
  final String label;
  final String key;
  final String value;
  final String description;

  const SchoolRule({
    required this.id,
    required this.label,
    required this.key,
    required this.value,
    required this.description,
  });

  SchoolRule copyWith({
    String? id,
    String? label,
    String? key,
    String? value,
    String? description,
  }) {
    return SchoolRule(
      id: id ?? this.id,
      label: label ?? this.label,
      key: key ?? this.key,
      value: value ?? this.value,
      description: description ?? this.description,
    );
  }
}
