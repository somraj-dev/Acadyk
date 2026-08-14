import '../../../../core/network/api_client.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/profile_usecases.dart';

class ProfileDto extends ProfileEntity {
  const ProfileDto({
    required super.id,
    required super.username,
    required super.fullName,
    required super.email,
    super.headline,
    super.bio,
    super.location,
    super.profilePhotoUrl,
    super.coverPhotoUrl,
    super.statusEmoji,
    super.statusText,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? 'Acadyk User',
      email: json['email']?.toString() ?? '',
      headline: json['headline']?.toString(),
      bio: json['bio']?.toString(),
      location: json['location']?.toString(),
      profilePhotoUrl: json['profilePhotoUrl'] ?? json['profile_photo_url'],
      coverPhotoUrl: json['coverPhotoUrl'] ?? json['cover_photo_url'],
      statusEmoji: json['statusEmoji'] ?? json['status_emoji'],
      statusText: json['statusText'] ?? json['status_text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'email': email,
      'headline': headline,
      'bio': bio,
      'location': location,
      'profile_photo_url': profilePhotoUrl,
      'cover_photo_url': coverPhotoUrl,
      'status_emoji': statusEmoji,
      'status_text': statusText,
    };
  }
}

abstract class ProfileRemoteDataSource {
  Future<ProfileDto?> getProfile(String userId);
  Future<ProfileDto> updateProfile(String userId, Map<String, dynamic> updates);
  Future<List<ProfileDto>> searchProfiles(String query);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  @override
  Future<ProfileDto?> getProfile(String userId) async {
    final response = await ApiClient.get('/profiles/$userId');
    if (response.data != null) {
      return ProfileDto.fromJson(response.data as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<ProfileDto> updateProfile(String userId, Map<String, dynamic> updates) async {
    final response = await ApiClient.put('/profiles/$userId', data: updates);
    return ProfileDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<ProfileDto>> searchProfiles(String query) async {
    final response = await ApiClient.get('/search/profiles', queryParameters: {'q': query});
    if (response.data is List) {
      return (response.data as List).map((e) => ProfileDto.fromJson(e)).toList();
    }
    return [];
  }
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProfileEntity?> getProfile(String userId) {
    return remoteDataSource.getProfile(userId);
  }

  @override
  Future<ProfileEntity> updateProfile(String userId, Map<String, dynamic> updates) {
    return remoteDataSource.updateProfile(userId, updates);
  }

  @override
  Future<List<ProfileEntity>> searchProfiles(String query) {
    return remoteDataSource.searchProfiles(query);
  }
}
