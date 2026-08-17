import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/state/async_state.dart';
import '../../../../core/usecase/usecase.dart';

class CommunityEntity {
  final String id;
  final String name;
  final String? description;
  final String category;
  final String? avatarUrl;
  final int memberCount;
  final bool isJoined;

  const CommunityEntity({
    required this.id,
    required this.name,
    this.description,
    this.category = 'academic',
    this.avatarUrl,
    this.memberCount = 1,
    this.isJoined = false,
  });

  CommunityEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? avatarUrl,
    int? memberCount,
    bool? isJoined,
  }) {
    return CommunityEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      memberCount: memberCount ?? this.memberCount,
      isJoined: isJoined ?? this.isJoined,
    );
  }
}

class CommunityDto extends CommunityEntity {
  const CommunityDto({
    required super.id,
    required super.name,
    super.description,
    super.category,
    super.avatarUrl,
    super.memberCount,
    super.isJoined,
  });

  factory CommunityDto.fromJson(Map<String, dynamic> json) {
    return CommunityDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Community',
      description: json['description']?.toString(),
      category: json['category']?.toString() ?? 'academic',
      avatarUrl: json['avatarUrl'] ?? json['avatar_url'],
      memberCount: (json['memberCount'] ?? json['member_count'] ?? 1) as int,
      isJoined: json['isJoined'] ?? json['is_joined'] ?? false,
    );
  }
}

abstract class CommunityRepository {
  Future<List<CommunityEntity>> getCommunities();
  Future<bool> joinCommunity(String communityId);
  Future<bool> leaveCommunity(String communityId);
}

class CommunityRepositoryImpl implements CommunityRepository {
  @override
  Future<List<CommunityEntity>> getCommunities() async {
    final response = await ApiClient.get('/communities');
    if (response.data is List) {
      return (response.data as List).map((e) => CommunityDto.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<bool> joinCommunity(String communityId) async {
    final response = await ApiClient.post('/communities/$communityId/join');
    return response.data?['joined'] == true;
  }

  @override
  Future<bool> leaveCommunity(String communityId) async {
    final response = await ApiClient.post('/communities/$communityId/leave');
    return response.data?['left'] == true;
  }
}

class GetCommunitiesUseCase implements UseCase<List<CommunityEntity>, NoParams> {
  final CommunityRepository repository;
  GetCommunitiesUseCase(this.repository);
  @override
  Future<List<CommunityEntity>> call(NoParams params) => repository.getCommunities();
}

class ToggleJoinCommunityUseCase implements UseCase<bool, String> {
  final CommunityRepository repository;
  ToggleJoinCommunityUseCase(this.repository);
  @override
  Future<bool> call(String communityId) => repository.joinCommunity(communityId);
}

final communityRepositoryProvider = Provider<CommunityRepository>((ref) => CommunityRepositoryImpl());
final getCommunitiesUseCaseProvider = Provider<GetCommunitiesUseCase>((ref) => GetCommunitiesUseCase(ref.watch(communityRepositoryProvider)));
final toggleJoinCommunityUseCaseProvider = Provider<ToggleJoinCommunityUseCase>((ref) => ToggleJoinCommunityUseCase(ref.watch(communityRepositoryProvider)));

final communitiesStateProvider = StateNotifierProvider<CommunitiesNotifier, AsyncState<List<CommunityEntity>>>((ref) {
  return CommunitiesNotifier(
    getCommunitiesUseCase: ref.watch(getCommunitiesUseCaseProvider),
    toggleJoinCommunityUseCase: ref.watch(toggleJoinCommunityUseCaseProvider),
  );
});

class CommunitiesNotifier extends StateNotifier<AsyncState<List<CommunityEntity>>> {
  final GetCommunitiesUseCase getCommunitiesUseCase;
  final ToggleJoinCommunityUseCase toggleJoinCommunityUseCase;

  CommunitiesNotifier({
    required this.getCommunitiesUseCase,
    required this.toggleJoinCommunityUseCase,
  }) : super(const AsyncState()) {
    fetchCommunities();
  }

  Future<void> fetchCommunities({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isRefreshing: true);
    } else {
      state = state.copyWith(status: Status.loading);
    }

    try {
      final list = await getCommunitiesUseCase(const NoParams());
      state = AsyncState(
        status: list.isEmpty ? Status.empty : Status.success,
        data: list,
        isRefreshing: false,
      );
    } catch (e) {
      state = AsyncState(status: Status.error, errorMessage: e.toString(), data: []);
    }
  }

  Future<void> toggleJoin(String communityId) async {
    final current = state.data;
    if (current == null) return;
    final updated = current.map((c) {
      if (c.id == communityId) {
        final newJoined = !c.isJoined;
        final newCount = newJoined ? c.memberCount + 1 : maxOf(0, c.memberCount - 1);
        return c.copyWith(isJoined: newJoined, memberCount: newCount);
      }
      return c;
    }).toList();
    state = state.copyWith(data: updated);
    await toggleJoinCommunityUseCase(communityId);
  }

  int maxOf(int a, int b) => a > b ? a : b;
}
