class LinkedParentData {
  final String linkId;
  final String parentId;
  final String name;
  final String email;
  final String phoneNumber;
  final String relationship;
  final bool isPrimary;

  const LinkedParentData({
    required this.linkId,
    required this.parentId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.relationship,
    required this.isPrimary,
  });

  factory LinkedParentData.fromJson(Map<String, dynamic> json) {
    final parent = json['parent'] as Map<String, dynamic>?;
    return LinkedParentData(
      linkId: json['id'] as String? ?? '',
      parentId: json['parent_id'] as String? ?? '',
      name: parent?['name'] as String? ?? '',
      email: parent?['email'] as String? ?? '',
      phoneNumber: parent?['phone_number'] as String? ?? '',
      relationship: json['relationship'] as String? ?? '',
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }
}
