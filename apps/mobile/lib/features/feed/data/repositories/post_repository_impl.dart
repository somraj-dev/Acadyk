import '../../../../core/network/api_client.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/post_usecases.dart';

class PostDto extends PostEntity {
  const PostDto({
    required super.id,
    required super.authorName,
    super.authorHeadline,
    super.authorAvatar,
    required super.content,
    super.postType,
    super.imageUrl,
    super.likeCount,
    super.commentCount,
    required super.createdAt,
    super.isLiked,
    super.isBookmarked,
  });

  factory PostDto.fromJson(Map<String, dynamic> json) {
    final author = json['author'] is Map<String, dynamic> ? json['author'] : null;
    return PostDto(
      id: json['id']?.toString() ?? '',
      authorName: author?['fullName'] ?? author?['full_name'] ?? json['author_name'] ?? 'Acadyk Member',
      authorHeadline: author?['headline'] ?? json['author_headline'] ?? 'Acadyk Contributor',
      authorAvatar: author?['profilePhotoUrl'] ?? author?['profile_photo_url'] ?? json['author_avatar'],
      content: json['content']?.toString() ?? '',
      postType: json['postType'] ?? json['post_type'] ?? 'text',
      imageUrl: json['imageUrl'] ?? json['image_url'],
      likeCount: (json['likeCount'] ?? json['like_count'] ?? 0) as int,
      commentCount: (json['commentCount'] ?? json['comment_count'] ?? 0) as int,
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString() ?? 'Just now',
      isLiked: json['isLiked'] ?? json['is_liked'] ?? false,
      isBookmarked: json['isBookmarked'] ?? json['is_bookmarked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'postType': postType,
      'imageUrl': imageUrl,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'createdAt': createdAt,
    };
  }
}

abstract class PostRemoteDataSource {
  Future<List<PostDto>> getFeedPosts({int page = 0, int limit = 20});
  Future<PostDto> createPost(String content, {String? postType, String? imageUrl});
  Future<bool> toggleLike(String postId);
  Future<bool> toggleBookmark(String postId);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  @override
  Future<List<PostDto>> getFeedPosts({int page = 0, int limit = 20}) async {
    final response = await ApiClient.get('/posts', queryParameters: {'page': page, 'limit': limit});
    if (response.data is List) {
      return (response.data as List).map((e) => PostDto.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<PostDto> createPost(String content, {String? postType, String? imageUrl}) async {
    final response = await ApiClient.post('/posts', data: {
      'content': content,
      'postType': postType ?? 'text',
      'imageUrl': imageUrl,
    });
    return PostDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<bool> toggleLike(String postId) async {
    final response = await ApiClient.post('/posts/$postId/like');
    return response.data?['liked'] == true;
  }

  @override
  Future<bool> toggleBookmark(String postId) async {
    final response = await ApiClient.post('/posts/$postId/bookmark');
    return response.data?['bookmarked'] == true;
  }
}

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;
  PostRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PostEntity>> getFeedPosts({int page = 0, int limit = 20}) {
    return remoteDataSource.getFeedPosts(page: page, limit: limit);
  }

  @override
  Future<PostEntity> createPost(String content, {String? postType, String? imageUrl}) {
    return remoteDataSource.createPost(content, postType: postType, imageUrl: imageUrl);
  }

  @override
  Future<bool> toggleLike(String postId) {
    return remoteDataSource.toggleLike(postId);
  }

  @override
  Future<bool> toggleBookmark(String postId) {
    return remoteDataSource.toggleBookmark(postId);
  }
}
