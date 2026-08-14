import '../../../../core/usecase/usecase.dart';

class CommentEntity {
  final String id;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final String? parentId;
  final String createdAt;

  const CommentEntity({
    required this.id,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    this.parentId,
    required this.createdAt,
  });
}

abstract class CommentRepository {
  Future<List<CommentEntity>> getComments(String postId);
  Future<CommentEntity> addComment(String postId, String content, {String? parentId});
}

class GetCommentsUseCase implements UseCase<List<CommentEntity>, String> {
  final CommentRepository repository;
  GetCommentsUseCase(this.repository);

  @override
  Future<List<CommentEntity>> call(String postId) {
    return repository.getComments(postId);
  }
}

class AddCommentParams {
  final String postId;
  final String content;
  final String? parentId;
  AddCommentParams({required this.postId, required this.content, this.parentId});
}

class AddCommentUseCase implements UseCase<CommentEntity, AddCommentParams> {
  final CommentRepository repository;
  AddCommentUseCase(this.repository);

  @override
  Future<CommentEntity> call(AddCommentParams params) {
    return repository.addComment(params.postId, params.content, parentId: params.parentId);
  }
}
