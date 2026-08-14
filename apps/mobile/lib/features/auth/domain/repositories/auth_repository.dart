import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUserEntity> login(String email, String password);
  Future<AuthUserEntity> register(String email, String password, String? fullName);
  Future<AuthUserEntity?> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> sendEmailVerification();
  Future<void> logout();
  Future<void> deleteAccount();
  Future<AuthUserEntity?> getCurrentUser();
}
