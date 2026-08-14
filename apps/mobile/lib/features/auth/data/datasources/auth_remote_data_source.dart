import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/auth/firebase_auth_service.dart';
import '../models/auth_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUserModel> login(String email, String password);
  Future<AuthUserModel> register(String email, String password, String? fullName);
  Future<AuthUserModel?> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> sendEmailVerification();
  Future<void> logout();
  Future<void> deleteAccount();
  Future<AuthUserModel?> getSavedUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FlutterSecureStorage storage;
  AuthRemoteDataSourceImpl({FlutterSecureStorage? secureStorage})
      : storage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<AuthUserModel> login(String email, String password) async {
    final data = await FirebaseAuthService.signInWithEmail(email, password);
    final userMap = data['user'] is Map<String, dynamic> ? data['user'] as Map<String, dynamic> : data;
    final model = AuthUserModel.fromJson(userMap, data['token']?.toString());
    await storage.write(key: 'user_profile', value: jsonEncode(model.toJson()));
    return model;
  }

  @override
  Future<AuthUserModel> register(String email, String password, String? fullName) async {
    final data = await FirebaseAuthService.signUpWithEmail(email, password, fullName: fullName);
    final userMap = data['user'] is Map<String, dynamic> ? data['user'] as Map<String, dynamic> : data;
    final model = AuthUserModel.fromJson(userMap, data['token']?.toString());
    await storage.write(key: 'user_profile', value: jsonEncode(model.toJson()));
    return model;
  }

  @override
  Future<AuthUserModel?> signInWithGoogle() async {
    final data = await FirebaseAuthService.signInWithGoogle();
    if (data == null) return null;
    final userMap = data['user'] is Map<String, dynamic> ? data['user'] as Map<String, dynamic> : data;
    final model = AuthUserModel.fromJson(userMap, data['token']?.toString());
    await storage.write(key: 'user_profile', value: jsonEncode(model.toJson()));
    return model;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await FirebaseAuthService.sendPasswordReset(email);
  }

  @override
  Future<void> sendEmailVerification() async {
    await FirebaseAuthService.sendEmailVerification();
  }

  @override
  Future<void> logout() async {
    await FirebaseAuthService.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    await FirebaseAuthService.deleteAccount();
  }

  @override
  Future<AuthUserModel?> getSavedUser() async {
    final userJson = await storage.read(key: 'user_profile');
    if (userJson != null) {
      try {
        final token = await storage.read(key: 'auth_token');
        return AuthUserModel.fromJson(jsonDecode(userJson), token);
      } catch (_) {}
    }
    return null;
  }
}
