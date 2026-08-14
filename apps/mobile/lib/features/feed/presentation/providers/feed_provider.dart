import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/async_state.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/post_usecases.dart';

final postRemoteDataSourceProvider = Provider<PostRemoteDataSource>((ref) {
  return PostRemoteDataSourceImpl();
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(remoteDataSource: ref.watch(postRemoteDataSourceProvider));
});

final getFeedPostsUseCaseProvider = Provider<GetFeedPostsUseCase>((ref) {
  return GetFeedPostsUseCase(ref.watch(postRepositoryProvider));
});

final createPostUseCaseProvider = Provider<CreatePostUseCase>((ref) {
  return CreatePostUseCase(ref.watch(postRepositoryProvider));
});

final toggleLikeUseCaseProvider = Provider<ToggleLikeUseCase>((ref) {
  return ToggleLikeUseCase(ref.watch(postRepositoryProvider));
});

final feedStateProvider = StateNotifierProvider<FeedNotifier, AsyncState<List<PostEntity>>>((ref) {
  return FeedNotifier(
    getFeedPostsUseCase: ref.watch(getFeedPostsUseCaseProvider),
    createPostUseCase: ref.watch(createPostUseCaseProvider),
    toggleLikeUseCase: ref.watch(toggleLikeUseCaseProvider),
  );
});

class FeedNotifier extends StateNotifier<AsyncState<List<PostEntity>>> {
  final GetFeedPostsUseCase getFeedPostsUseCase;
  final CreatePostUseCase createPostUseCase;
  final ToggleLikeUseCase toggleLikeUseCase;

  int _page = 0;
  bool _hasMore = true;

  FeedNotifier({
    required this.getFeedPostsUseCase,
    required this.createPostUseCase,
    required this.toggleLikeUseCase,
  }) : super(const AsyncState()) {
    fetchFeed();
  }

  Future<void> fetchFeed({bool refresh = false}) async {
    if (refresh) {
      _page = 0;
      _hasMore = true;
      state = state.copyWith(isRefreshing: true);
    } else if (state.data == null) {
      state = state.copyWith(status: Status.loading);
    }

    try {
      final posts = await getFeedPostsUseCase(GetFeedPostsParams(page: _page, limit: 20));
      if (refresh || state.data == null) {
        state = AsyncState(
          status: posts.isEmpty ? Status.empty : Status.success,
          data: posts,
          isRefreshing: false,
        );
      } else {
        final current = state.data ?? [];
        state = AsyncState(
          status: Status.success,
          data: [...current, ...posts],
          isRefreshing: false,
        );
      }
      _hasMore = posts.length >= 20;
      if (_hasMore) _page++;
    } catch (e) {
      if (state.data == null || state.data!.isEmpty) {
        state = AsyncState(status: Status.error, errorMessage: e.toString(), isRefreshing: false);
      } else {
        state = state.copyWith(isRefreshing: false, errorMessage: e.toString());
      }
    }
  }

  Future<void> toggleLike(String postId) async {
    final currentList = state.data;
    if (currentList == null) return;

    // Optimistic UI update
    final updatedList = currentList.map((post) {
      if (post.id == postId) {
        final newIsLiked = !post.isLiked;
        final newCount = newIsLiked ? post.likeCount + 1 : (post.likeCount > 0 ? post.likeCount - 1 : 0);
        return post.copyWith(isLiked: newIsLiked, likeCount: newCount);
      }
      return post;
    }).toList();

    state = state.copyWith(data: updatedList);

    try {
      await toggleLikeUseCase(postId);
    } catch (_) {
      // Revert on error
      state = state.copyWith(data: currentList);
    }
  }

  Future<bool> createPost(String content, {String? postType, String? imageUrl}) async {
    try {
      final newPost = await createPostUseCase(CreatePostParams(content: content, postType: postType, imageUrl: imageUrl));
      final current = state.data ?? [];
      state = state.copyWith(
        status: Status.success,
        data: [newPost, ...current],
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
