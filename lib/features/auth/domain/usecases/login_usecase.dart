import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/api/api_exception.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Authenticate with email and password.
class LoginUseCase {
  final AuthRepository _repo;
  LoginUseCase(this._repo);

  Future<Either<Failure, UserEntity>> call(LoginParams params) {
    return _repo.login(email: params.email, password: params.password);
  }
}
