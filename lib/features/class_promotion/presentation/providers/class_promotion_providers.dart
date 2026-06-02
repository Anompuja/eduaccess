import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduaccess/core/api/api_client.dart';
import '../../data/datasources/class_promotion_remote_datasource.dart';
import '../../data/repositories/class_promotion_repository_impl.dart';
import '../../domain/repositories/class_promotion_repository.dart';

final classPromotionRepositoryProvider = Provider<ClassPromotionRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ClassPromotionRepositoryImpl(
    remoteDataSource: ClassPromotionRemoteDataSourceImpl(dio: dio),
  );
});
