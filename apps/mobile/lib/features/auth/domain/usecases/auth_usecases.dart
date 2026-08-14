import '../../../../core/usecase/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;
  LoginParams({required this.email, required this.password});
}

class LoginUseCase implements UseCase<AuthUserEntity, LoginParams> {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  @override
  Future<AuthUserEntity> call(LoginParams params) {
    return repository.login(params.email, params.password);
  }
}

class RegisterParams {
  final String email;
  final String password;
  final String? fullName;
  RegisterParams({required this.email, required this.password, this.fullName});
}

class RegisterUseCase implements UseCase<AuthUserEntity, RegisterParams> {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  @override
  Future<AuthUserEntity> call(RegisterParams params) {
    return repository.register(params.email, params.password, params.fullName);
  }
}

class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  @override
  Future<void> call(NoParams params) {
    return repository.logout();
  }
}
