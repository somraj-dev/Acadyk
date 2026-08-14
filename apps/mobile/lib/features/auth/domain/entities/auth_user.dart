class AuthUserEntity {
  final String id;
  final String email;
  final String? fullName;
  final String? token;

  const AuthUserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.token,
  });
}
