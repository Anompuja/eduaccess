import '../entities/parent_entity.dart';

abstract interface class ParentsRepository {
  /// Fetch paginated list of parents
  /// [page] - page number (1-indexed)
  /// [query] - optional search query, handled by backend
  /// [schoolId] - optional school ID for superadmin to scope results
  Future<List<ParentEntity>> getParents({
    required int page,
    String? query,
    String? schoolId,
  });

  /// Create a new parent
  /// [data] - map containing name, email, phone, childrenCount
  Future<ParentEntity> createParent(Map<String, dynamic> data);

  /// Update an existing parent
  /// [id] - parent ID
  /// [data] - map with fields to update
  Future<ParentEntity> updateParent(String id, Map<String, dynamic> data);

  /// Delete a parent
  /// [id] - parent ID
  Future<void> deleteParent(String id);
}
