import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/async_state.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/profile_usecases.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSourceImpl();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(remoteDataSource: ref.watch(profileRemoteDataSourceProvider));
});

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.watch(profileRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(profileRepositoryProvider));
});

final profileStateProvider = StateNotifierProvider.family<ProfileNotifier, AsyncState<ProfileEntity?>, String>((ref, userId) {
  return ProfileNotifier(
    userId: userId,
    getProfileUseCase: ref.watch(getProfileUseCaseProvider),
    updateProfileUseCase: ref.watch(updateProfileUseCaseProvider),
  );
});

class ProfileNotifier extends StateNotifier<AsyncState<ProfileEntity?>> {
  final String userId;
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileNotifier({
    required this.userId,
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(const AsyncState()) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    state = state.copyWith(status: Status.loading);
    try {
      final profile = await getProfileUseCase(userId);
      if (profile != null) {
        state = AsyncState(status: Status.success, data: profile);
      } else {
        state = const AsyncState(status: Status.empty, data: null);
      }
    } catch (e) {
      state = AsyncState(status: Status.error, errorMessage: e.toString(), data: null);
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    state = state.copyWith(isRefreshing: true);
    try {
      final updated = await updateProfileUseCase(UpdateProfileParams(userId: userId, updates: updates));
      state = AsyncState(status: Status.success, data: updated);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isRefreshing: false);
      return false;
    }
  }
}
