import '../../../../core/usecase/usecase.dart';
import '../entities/post_entity.dart';

abstract class PostRepository {
  Future<List<PostEntity>> getFeedPosts({int page = 0, int limit = 20});
  Future<PostEntity> createPost(String content, {String? postType, String? imageUrl});
  Future<bool> toggleLike(String postId);
  Future<bool> toggleBookmark(String postId);
}

class GetFeedPostsParams {
  final int page;
  final int limit;
  GetFeedPostsParams({this.page = 0, this.limit = 20});
}

class GetFeedPostsUseCase implements UseCase<List<PostEntity>, GetFeedPostsParams> {
  final PostRepository repository;
  GetFeedPostsUseCase(this.repository);

  @override
  Future<List<PostEntity>> call(GetFeedPostsParams params) {
    return repository.getFeedPosts(page: params.page, limit: params.limit);
  }
}

class CreatePostParams {
  final String content;
  final String? postType;
  final String? imageUrl;
  CreatePostParams({required this.content, this.postType, this.imageUrl});
}

class CreatePostUseCase implements UseCase<PostEntity, CreatePostParams> {
  final PostRepository repository;
  CreatePostUseCase(this.repository);

  @override
  Future<PostEntity> call(CreatePostParams params) {
    return repository.createPost(params.content, postType: params.postType, imageUrl: params.imageUrl);
  }
}

class ToggleLikeUseCase implements UseCase<bool, String> {
  final PostRepository repository;
  ToggleLikeUseCase(this.repository);

  @override
  Future<bool> call(String postId) {
    return repository.toggleLike(postId);
  }
}
