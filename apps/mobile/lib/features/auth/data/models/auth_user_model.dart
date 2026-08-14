import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUserEntity {
  const AuthUserModel({
    required super.id,
    required super.email,
    super.fullName,
    super.token,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json, [String? token]) {
    final user = json['user'] is Map<String, dynamic> ? json['user'] : json;
    return AuthUserModel(
      id: user['id']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      fullName: user['fullName'] ?? user['full_name'],
      token: token ?? json['token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'token': token,
    };
  }
}
