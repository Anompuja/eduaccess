import 'package:fpdart/fpdart.dart';

import '../../../../core/api/api_exception.dart';
import '../repositories/auth_repository.dart';

/// Invalidate the current session server-side.
class LogoutUseCase {
  final AuthRepository _repo;
  LogoutUseCase(this._repo);

  Future<Either<Failure, Unit>> call() => _repo.logout();
}
