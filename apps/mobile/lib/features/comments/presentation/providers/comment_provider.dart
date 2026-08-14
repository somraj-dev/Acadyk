import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/state/async_state.dart';
import '../domain/usecases/comment_usecases.dart';

class CommentDto extends CommentEntity {
  const CommentDto({
    required super.id,
    required super.authorName,
    super.authorAvatar,
    required super.content,
    super.parentId,
    required super.createdAt,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    final author = json['author'] is Map<String, dynamic> ? json['author'] : null;
    return CommentDto(
      id: json['id']?.toString() ?? '',
      authorName: author?['fullName'] ?? author?['full_name'] ?? json['author_name'] ?? 'User',
      authorAvatar: author?['profilePhotoUrl'] ?? author?['profile_photo_url'] ?? json['author_avatar'],
      content: json['content']?.toString() ?? '',
      parentId: json['parentId']?.toString() ?? json['parent_id']?.toString(),
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString() ?? 'Just now',
    );
  }
}

abstract class CommentRemoteDataSource {
  Future<List<CommentDto>> getComments(String postId);
  Future<CommentDto> addComment(String postId, String content, {String? parentId});
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  @override
  Future<List<CommentDto>> getComments(String postId) async {
    final response = await ApiClient.get('/posts/$postId/comments');
    if (response.data is List) {
      return (response.data as List).map((e) => CommentDto.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<CommentDto> addComment(String postId, String content, {String? parentId}) async {
    final response = await ApiClient.post('/posts/$postId/comments', data: {
      'content': content,
      'parentId': parentId,
    });
    return CommentDto.fromJson(response.data as Map<String, dynamic>);
  }
}

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remoteDataSource;
  CommentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CommentEntity>> getComments(String postId) => remoteDataSource.getComments(postId);

  @override
  Future<CommentEntity> addComment(String postId, String content, {String? parentId}) =>
      remoteDataSource.addComment(postId, content, parentId: parentId);
}

final commentRemoteDataSourceProvider = Provider<CommentRemoteDataSource>((ref) => CommentRemoteDataSourceImpl());
final commentRepositoryProvider = Provider<CommentRepository>((ref) =>
    CommentRepositoryImpl(remoteDataSource: ref.watch(commentRemoteDataSourceProvider)));
final getCommentsUseCaseProvider = Provider<GetCommentsUseCase>((ref) =>
    GetCommentsUseCase(ref.watch(commentRepositoryProvider)));
final addCommentUseCaseProvider = Provider<AddCommentUseCase>((ref) =>
    AddCommentUseCase(ref.watch(commentRepositoryProvider)));

final commentsStateProvider = StateNotifierProvider.family<CommentsNotifier, AsyncState<List<CommentEntity>>, String>((ref, postId) {
  return CommentsNotifier(
    postId: postId,
    getCommentsUseCase: ref.watch(getCommentsUseCaseProvider),
    addCommentUseCase: ref.watch(addCommentUseCaseProvider),
  );
});

class CommentsNotifier extends StateNotifier<AsyncState<List<CommentEntity>>> {
  final String postId;
  final GetCommentsUseCase getCommentsUseCase;
  final AddCommentUseCase addCommentUseCase;

  CommentsNotifier({
    required this.postId,
    required this.getCommentsUseCase,
    required this.addCommentUseCase,
  }) : super(const AsyncState()) {
    fetchComments();
  }

  Future<void> fetchComments() async {
    state = state.copyWith(status: Status.loading);
    try {
      final comments = await getCommentsUseCase(postId);
      state = AsyncState(
        status: comments.isEmpty ? Status.empty : Status.success,
        data: comments,
      );
    } catch (e) {
      state = AsyncState(status: Status.error, errorMessage: e.toString(), data: []);
    }
  }

  Future<bool> addComment(String content, {String? parentId}) async {
    try {
      final newComment = await addCommentUseCase(AddCommentParams(postId: postId, content: content, parentId: parentId));
      final current = state.data ?? [];
      state = state.copyWith(
        status: Status.success,
        data: [...current, newComment],
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
