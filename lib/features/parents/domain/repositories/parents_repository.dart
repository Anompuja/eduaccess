import '../../../../core/api/paginated.dart';
import '../entities/parent_entity.dart';

abstract interface class ParentsRepository {
  /// Fetch paginated list of parents.
  /// Backend scopes by JWT role:
  ///   - admin_sekolah & scoped: filtered by JWT school_id (schoolId param ignored)
  ///   - superadmin: filtered by [schoolId] if provided, else all schools
  Future<Paginated<ParentEntity>> getParents({
    required int page,
    int perPage,
    String? query,
    String? schoolId,
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
