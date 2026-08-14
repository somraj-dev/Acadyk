class PostEntity {
  final String id;
  final String authorName;
  final String? authorHeadline;
  final String? authorAvatar;
  final String content;
  final String? postType;
  final String? imageUrl;
  final int likeCount;
  final int commentCount;
  final String createdAt;
  final bool isLiked;
  final bool isBookmarked;

  const PostEntity({
    required this.id,
    required this.authorName,
    this.authorHeadline,
    this.authorAvatar,
    required this.content,
    this.postType = 'text',
    this.imageUrl,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.createdAt,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  PostEntity copyWith({
    String? id,
    String? authorName,
    String? authorHeadline,
    String? authorAvatar,
    String? content,
    String? postType,
    String? imageUrl,
    int? likeCount,
    int? commentCount,
    String? createdAt,
    bool? isLiked,
    bool? isBookmarked,
  }) {
    return PostEntity(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorHeadline: authorHeadline ?? this.authorHeadline,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      content: content ?? this.content,
      postType: postType ?? this.postType,
      imageUrl: imageUrl ?? this.imageUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
