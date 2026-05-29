/// Result of a bulk promotion request.
class PromotionResult {
  final int success;
  final int failed;

  const PromotionResult({required this.success, required this.failed});
}

abstract class ClassPromotionRepository {
  /// Promotes the given students into [toClassroomId] with the given [status]
  /// (promoted | retained | transferred). Returns success/failed counts.
  Future<PromotionResult> promote({
    required List<String> studentIds,
    required String toClassroomId,
    required String status,
    String? notes,
    String? schoolId,
  });
}
