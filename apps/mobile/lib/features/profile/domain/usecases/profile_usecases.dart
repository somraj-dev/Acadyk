import '../../../../core/usecase/usecase.dart';
import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity?> getProfile(String userId);
  Future<ProfileEntity> updateProfile(String userId, Map<String, dynamic> updates);
  Future<List<ProfileEntity>> searchProfiles(String query);
}

class GetProfileUseCase implements UseCase<ProfileEntity?, String> {
  final ProfileRepository repository;
  GetProfileUseCase(this.repository);

  @override
  Future<ProfileEntity?> call(String userId) {
    return repository.getProfile(userId);
  }
}

class UpdateProfileParams {
  final String userId;
  final Map<String, dynamic> updates;
  UpdateProfileParams({required this.userId, required this.updates});
}

class UpdateProfileUseCase implements UseCase<ProfileEntity, UpdateProfileParams> {
  final ProfileRepository repository;
  UpdateProfileUseCase(this.repository);

  @override
  Future<ProfileEntity> call(UpdateProfileParams params) {
    return repository.updateProfile(params.userId, params.updates);
  }
}
