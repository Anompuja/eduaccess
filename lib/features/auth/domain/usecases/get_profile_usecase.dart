import 'package:fpdart/fpdart.dart';

import '../../../../core/api/api_exception.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Fetch the authenticated user's profile from the API.
class GetProfileUseCase {
  final AuthRepository _repo;
  GetProfileUseCase(this._repo);

  Future<Either<Failure, UserEntity>> call() => _repo.getProfile();
}
