import '../entities/parent_entity.dart';

abstract interface class ParentsRepository {
  /// Fetch paginated list of parents.
  /// Backend scopes by JWT: admin_sekolah → own school; superadmin → all schools.
  Future<List<ParentEntity>> getParents({
    required int page,
    String? query,
  });

  /// Create a new parent
  /// [data] - map with backend fields: name, email, phone_number, religion, address, school_id (superadmin only)
  Future<ParentEntity> createParent(Map<String, dynamic> data);

  /// Update an existing parent
  /// [id] - parent ID
  /// [data] - map with fields to update
  Future<ParentEntity> updateParent(String id, Map<String, dynamic> data);

  /// Delete a parent
  /// [id] - parent ID
  Future<void> deleteParent(String id);
}
