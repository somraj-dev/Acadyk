import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/state/async_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../../profile/data/repositories/profile_repository_impl.dart';

abstract class ConnectionRepository {
  Future<List<ProfileEntity>> getFollowers(String userId);
  Future<List<ProfileEntity>> getFollowing(String userId);
  Future<bool> toggleFollow(String userId);
}

class GetFollowersUseCase implements UseCase<List<ProfileEntity>, String> {
  final ConnectionRepository repository;
  GetFollowersUseCase(this.repository);
  @override
  Future<List<ProfileEntity>> call(String userId) => repository.getFollowers(userId);
}

class GetFollowingUseCase implements UseCase<List<ProfileEntity>, String> {
  final ConnectionRepository repository;
  GetFollowingUseCase(this.repository);
  @override
  Future<List<ProfileEntity>> call(String userId) => repository.getFollowing(userId);
}

class ToggleFollowUseCase implements UseCase<bool, String> {
  final ConnectionRepository repository;
  ToggleFollowUseCase(this.repository);
  @override
  Future<bool> call(String userId) => repository.toggleFollow(userId);
}

class ConnectionRepositoryImpl implements ConnectionRepository {
  @override
  Future<List<ProfileEntity>> getFollowers(String userId) async {
    final response = await ApiClient.get('/profiles/$userId/followers');
    if (response.data is List) {
      return (response.data as List).map((e) => ProfileDto.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<List<ProfileEntity>> getFollowing(String userId) async {
    final response = await ApiClient.get('/profiles/$userId/following');
    if (response.data is List) {
      return (response.data as List).map((e) => ProfileDto.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<bool> toggleFollow(String userId) async {
    final response = await ApiClient.post('/profiles/$userId/follow');
    return response.data?['isFollowing'] == true;
  }
}

final connectionRepositoryProvider = Provider<ConnectionRepository>((ref) => ConnectionRepositoryImpl());
final getFollowersUseCaseProvider = Provider<GetFollowersUseCase>((ref) => GetFollowersUseCase(ref.watch(connectionRepositoryProvider)));
final getFollowingUseCaseProvider = Provider<GetFollowingUseCase>((ref) => GetFollowingUseCase(ref.watch(connectionRepositoryProvider)));
final toggleFollowUseCaseProvider = Provider<ToggleFollowUseCase>((ref) => ToggleFollowUseCase(ref.watch(connectionRepositoryProvider)));

final followersStateProvider = StateNotifierProvider.family<FollowersNotifier, AsyncState<List<ProfileEntity>>, String>((ref, userId) {
  return FollowersNotifier(userId: userId, getFollowersUseCase: ref.watch(getFollowersUseCaseProvider));
});

class FollowersNotifier extends StateNotifier<AsyncState<List<ProfileEntity>>> {
  final String userId;
  final GetFollowersUseCase getFollowersUseCase;

  FollowersNotifier({required this.userId, required this.getFollowersUseCase}) : super(const AsyncState()) {
    fetch();
  }

  Future<void> fetch() async {
    state = state.copyWith(status: Status.loading);
    try {
      final list = await getFollowersUseCase(userId);
      state = AsyncState(status: list.isEmpty ? Status.empty : Status.success, data: list);
    } catch (e) {
      state = AsyncState(status: Status.error, errorMessage: e.toString(), data: []);
    }
  }
}
