class ProfileEntity {
  final String id;
  final String username;
  final String fullName;
  final String email;
  final String? headline;
  final String? bio;
  final String? location;
  final String? profilePhotoUrl;
  final String? coverPhotoUrl;
  final String? statusEmoji;
  final String? statusText;

  const ProfileEntity({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    this.headline,
    this.bio,
    this.location,
    this.profilePhotoUrl,
    this.coverPhotoUrl,
    this.statusEmoji,
    this.statusText,
  });
}
