enum PromotionDecision {
  promote,
  retain,
}

class PromotionStudent {
  final String id;
  final String name;
  final String nis;
  final String sourceClass;

  const PromotionStudent({
    required this.id,
    required this.name,
    required this.nis,
    required this.sourceClass,
  });
}

class PromotionClassOption {
  final String id;
  final String label;
  final String level;
  final String nextClassId;

  const PromotionClassOption({
    required this.id,
    required this.label,
    required this.level,
    required this.nextClassId,
  });
}
