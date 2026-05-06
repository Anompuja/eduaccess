class AcademicLevel {
  final String id;
  final String name;

  const AcademicLevel({
    required this.id,
    required this.name,
  });

  AcademicLevel copyWith({String? id, String? name}) {
    return AcademicLevel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}

class AcademicClass {
  final String id;
  final String levelId;
  final String name;

  const AcademicClass({
    required this.id,
    required this.levelId,
    required this.name,
  });

  AcademicClass copyWith({String? id, String? levelId, String? name}) {
    return AcademicClass(
      id: id ?? this.id,
      levelId: levelId ?? this.levelId,
      name: name ?? this.name,
    );
  }
}

class AcademicSubClass {
  final String id;
  final String classId;
  final String name;

  const AcademicSubClass({
    required this.id,
    required this.classId,
    required this.name,
  });

  AcademicSubClass copyWith({String? id, String? classId, String? name}) {
    return AcademicSubClass(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      name: name ?? this.name,
    );
  }
}
