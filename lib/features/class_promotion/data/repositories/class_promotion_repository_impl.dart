import '../../domain/repositories/class_promotion_repository.dart';
import '../datasources/class_promotion_remote_datasource.dart';

class ClassPromotionRepositoryImpl implements ClassPromotionRepository {
  final ClassPromotionRemoteDataSource remoteDataSource;

  ClassPromotionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PromotionResult> promote({
    required List<String> studentIds,
    required String toClassroomId,
    required String status,
    String? notes,
    String? schoolId,
  }) =>
      remoteDataSource.promote(
        studentIds: studentIds,
        toClassroomId: toClassroomId,
        status: status,
        notes: notes,
        schoolId: schoolId,
      );
}
