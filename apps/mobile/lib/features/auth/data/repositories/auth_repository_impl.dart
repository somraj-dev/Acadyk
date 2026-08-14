import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthUserEntity> login(String email, String password) {
    return remoteDataSource.login(email, password);
  }

  @override
  Future<AuthUserEntity> register(String email, String password, String? fullName) {
    return remoteDataSource.register(email, password, fullName);
  }

  @override
  Future<AuthUserEntity?> signInWithGoogle() {
    return remoteDataSource.signInWithGoogle();
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return remoteDataSource.sendPasswordReset(email);
  }

  @override
  Future<void> sendEmailVerification() {
    return remoteDataSource.sendEmailVerification();
  }

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }

  @override
  Future<void> deleteAccount() {
    return remoteDataSource.deleteAccount();
  }

  @override
  Future<AuthUserEntity?> getCurrentUser() {
    return remoteDataSource.getSavedUser();
  }
}
