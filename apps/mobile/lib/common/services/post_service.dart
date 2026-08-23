import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../features/profile/presentation/services/profile_manager.dart';
import 'auth_service.dart';
import 'storage_service.dart';

class PostService {
  static final ValueNotifier<int> feedChangeNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<Map<String, dynamic>?> activePostingNotifier = ValueNotifier<Map<String, dynamic>?>(null);

  // In-memory created posts for immediate and persistent session state
  static final List<Map<String, dynamic>> _inMemoryPosts = [];
  static final Map<String, List<Map<String, dynamic>>> _postComments = {};
  static final Map<String, bool> _likedPosts = {};
  static final Map<String, int> _likeCounts = {};
  static final Map<String, bool> _bookmarkedPosts = {};

  static void notifyFeedChanged() {
    feedChangeNotifier.value = feedChangeNotifier.value + 1;
  }

  /// Start posting asynchronously with live progress animation
  static Future<Map<String, dynamic>> startPostingAsync({
    required String content,
    String? postType,
    String? imageUrl,
    Uint8List? imageBytes,
    String? imageName,
    String? gifUrl,
    Map<String, dynamic>? poll,
    String? milestone,
    String? location,
    List<String>? taggedPeople,
    String replyVisibility = 'Everyone can reply',
  }) async {
    final authorName = ProfileManager.name.isNotEmpty
        ? ProfileManager.name
        : (AuthService.currentUser?.fullName ?? 'Acadyk Member');
    final authorAvatar = ProfileManager.avatarUrl.isNotEmpty
        ? ProfileManager.avatarUrl
        : 'assets/images/somraj_avatar.jpg';
    final authorBio = ProfileManager.bio;
    final authorHandle = ProfileManager.username.isNotEmpty
        ? ProfileManager.username
        : (AuthService.currentUser?.username ?? 'user');

    // 1. Notify posting in progress
    activePostingNotifier.value = {
      'status': 'posting',
      'content': content,
      'avatar': authorAvatar,
      'name': authorName,
    };

    String? uploadedImageUrl = imageUrl;
    if (imageBytes != null) {
      try {
        final userId = AuthService.currentUser?.id ?? 'user';
        final ext = (imageName != null && imageName.contains('.')) ? imageName.split('.').last : 'jpg';
        uploadedImageUrl = await StorageService.uploadBytes(
          bucket: 'posts',
          bytes: imageBytes,
          fileName: 'post_${DateTime.now().millisecondsSinceEpoch}.$ext',
          remotePath: 'posts/$userId',
        );
      } catch (e) {
        debugPrint('[PostService] Image upload note: $e');
      }
    }

    final newId = 'post_${DateTime.now().millisecondsSinceEpoch}';
    final authorInitials = authorName.isNotEmpty ? authorName.substring(0, min(2, authorName.length)).toUpperCase() : 'U';

    final fullPost = {
      'id': newId,
      'author': {
        'id': AuthService.currentUser?.id ?? '',
        'username': authorHandle,
        'fullName': authorName,
        'headline': authorBio,
        'profilePhotoUrl': authorAvatar,
      },
      'authorName': authorName,
      'authorSubtitle': authorBio.isNotEmpty ? authorBio : 'Student @ Acadyk',
      'authorInitials': authorInitials,
      'authorBgColor': 0xFF0F4C81,
      'authorAvatar': authorAvatar,
      'isVerified': true,
      'badgeType': 'gold',
      'timeAgo': 'Just now',
      'content': content,
      'postType': postType ?? (poll != null ? 'poll' : (gifUrl != null ? 'gif' : (uploadedImageUrl != null || imageBytes != null ? 'image' : 'text'))),
      'imageUrl': uploadedImageUrl,
      'imageBytes': imageBytes,
      'gifUrl': gifUrl,
      'poll': poll,
      'milestone': milestone,
      'location': location,
      'taggedPeople': taggedPeople,
      'replyVisibility': replyVisibility,
      'likes': 0,
      'comments': 0,
      'isLiked': false,
      'isBookmarked': false,
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Prepend to in-memory list
    _inMemoryPosts.insert(0, fullPost);

    // Call backend API gracefully
    try {
      await ApiClient.post('/posts', data: {
        'content': content,
        'postType': fullPost['postType'],
        if (uploadedImageUrl != null) 'mediaUrls': [uploadedImageUrl],
        if (location != null) 'location': location,
      });
    } catch (e) {
      debugPrint('[PostService] Backend create post note: $e');
    }

    // Notify done and refresh feed
    activePostingNotifier.value = {
      'status': 'done',
      'post': fullPost,
    };
    notifyFeedChanged();

    // Auto-clear posting progress banner after 1.8s
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (activePostingNotifier.value?['status'] == 'done') {
        activePostingNotifier.value = null;
      }
    });

    return fullPost;
  }

  /// Vote on an interactive poll in the feed
  static void votePoll(String postId, int optionIndex) {
    for (int i = 0; i < _inMemoryPosts.length; i++) {
      if (_inMemoryPosts[i]['id']?.toString() == postId) {
        final poll = _inMemoryPosts[i]['poll'] as Map<String, dynamic>?;
        if (poll != null) {
          final options = poll['options'] as List<dynamic>?;
          if (options != null && optionIndex >= 0 && optionIndex < options.length) {
            final currentVotes = (options[optionIndex]['votes'] as num?)?.toInt() ?? 0;
            options[optionIndex]['votes'] = currentVotes + 1;
            final total = (poll['totalVotes'] as num?)?.toInt() ?? 0;
            poll['totalVotes'] = total + 1;
            poll['userVotedIndex'] = optionIndex;
            notifyFeedChanged();
          }
        }
        break;
      }
    }
  }

  /// Get feed posts (fetches from backend and merges with any local created posts)
  static Future<List<Map<String, dynamic>>> getFeedPosts({int limit = 20, int offset = 0}) async {
    List<Map<String, dynamic>> backendPosts = [];
    try {
      final safeLimit = limit > 0 ? limit : 20;
      final safeOffset = offset >= 0 ? offset : 0;
      final int page = (safeOffset / safeLimit).floor();

      final response = await ApiClient.get('/posts', queryParameters: {
        'page': page,
        'size': safeLimit,
      });

      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          final payload = resData['data'];
          if (payload is Map && payload.containsKey('content') && payload['content'] is List) {
            backendPosts = List<Map<String, dynamic>>.from(payload['content']);
          } else if (payload is List) {
            backendPosts = List<Map<String, dynamic>>.from(payload);
          }
        } else if (resData is List) {
          backendPosts = List<Map<String, dynamic>>.from(resData);
        }
      }
    } catch (e) {
      debugPrint('[PostService] Error getting feed posts: $e');
    }

    // Merge: Put local created posts first, followed by backend posts, deduplicating by ID
    final Set<String> seenIds = {};
    final List<Map<String, dynamic>> merged = [];

    for (final p in _inMemoryPosts) {
      final id = p['id']?.toString() ?? '';
      if (id.isNotEmpty && !seenIds.contains(id)) {
        seenIds.add(id);
        merged.add(_normalizePostData(p));
      }
    }

    for (final p in backendPosts) {
      final id = p['id']?.toString() ?? '';
      if (id.isNotEmpty && !seenIds.contains(id)) {
        seenIds.add(id);
        merged.add(_normalizePostData(p));
      }
    }

    return merged;
  }

  /// Normalize post data structure between backend response and UI
  static Map<String, dynamic> _normalizePostData(Map<String, dynamic> post) {
    final author = post['author'] is Map ? post['author'] as Map : null;
    final id = post['id']?.toString() ?? 'post_${DateTime.now().millisecondsSinceEpoch}';

    final authorName = post['authorName']?.toString() ?? author?['fullName']?.toString() ?? author?['username']?.toString() ?? 'Acadyk Member';
    final authorSubtitle = post['authorSubtitle']?.toString() ?? author?['headline']?.toString() ?? '';
    final authorAvatar = post['authorAvatar']?.toString() ?? author?['profilePhotoUrl']?.toString() ?? '';
    final content = post['content']?.toString() ?? '';
    final imageUrl = post['imageUrl']?.toString() ?? (post['mediaUrls'] is List && (post['mediaUrls'] as List).isNotEmpty ? post['mediaUrls'][0]?.toString() : null);

    final imageBytes = post['imageBytes'] as Uint8List?;
    final poll = post['poll'] as Map<String, dynamic>?;
    final milestone = post['milestone']?.toString();
    final location = post['location']?.toString();
    final taggedPeople = post['taggedPeople'] as List<dynamic>?;
    final postType = post['postType']?.toString() ?? post['type']?.toString() ?? (poll != null ? 'poll' : (imageUrl != null || imageBytes != null ? 'image' : 'text'));

    final rawLikes = _likeCounts[id] ?? post['likesCount'] ?? post['likes'] ?? 0;
    final int likes = (rawLikes is num) ? rawLikes.toInt() : (int.tryParse(rawLikes.toString()) ?? 0);

    final rawComments = _postComments[id]?.length ?? post['commentsCount'] ?? post['comments'] ?? 0;
    final int comments = (rawComments is num) ? rawComments.toInt() : (int.tryParse(rawComments.toString()) ?? 0);

    final isLiked = _likedPosts[id] ?? (post['isLiked'] == true);

    return {
      'id': id,
      'authorName': authorName,
      'authorSubtitle': authorSubtitle,
      'authorAvatar': authorAvatar,
      'authorInitials': post['authorInitials'] ?? (authorName.isNotEmpty ? authorName.substring(0, min(2, authorName.length)).toUpperCase() : 'U'),
      'authorBgColor': post['authorBgColor'] ?? 0xFF0F4C81,
      'isVerified': post['isVerified'] ?? true,
      'badgeType': post['badgeType'] ?? 'gold',
      'content': content,
      'imageUrl': imageUrl,
      'imageBytes': imageBytes,
      'poll': poll,
      'milestone': milestone,
      'location': location,
      'taggedPeople': taggedPeople,
      'postType': postType,
      'likes': likes,
      'comments': comments,
      'isLiked': isLiked,
      'timeAgo': post['timeAgo'] ?? post['createdAt'] ?? 'Just now',
      'raw': post,
    };
  }

  /// Create a new post and prepend to local state immediately
  static Future<Map<String, dynamic>?> createPost(
    String content, {
    String? authorName,
    String? authorBio,
    String? authorAvatar,
    String? authorHandle,
    String? postType,
    String? imageUrl,
    File? imageFile,
  }) async {
    final currentUser = AuthService.currentUser;
    final resolvedName = (authorName != null && authorName.isNotEmpty)
        ? authorName
        : (ProfileManager.name.isNotEmpty
            ? ProfileManager.name
            : (currentUser?.fullName ?? 'Acadyk Member'));
    final resolvedBio = authorBio ?? ProfileManager.bio;
    final resolvedAvatar = authorAvatar ?? ProfileManager.avatarUrl;
    final resolvedHandle = (authorHandle != null && authorHandle.isNotEmpty)
        ? authorHandle
        : (ProfileManager.username.isNotEmpty
            ? ProfileManager.username
            : (currentUser?.username ?? 'user'));
    String? uploadedImageUrl = imageUrl;

    // Upload image to backend storage if provided
    if (imageFile != null && currentUser != null) {
      uploadedImageUrl = await StorageService.uploadPostImage(currentUser.id, imageFile);
    }

    // Call REST endpoint
    Map<String, dynamic>? createdData;
    try {
      final response = await ApiClient.post('/posts', data: {
        'content': content,
        'postType': postType ?? (uploadedImageUrl != null ? 'image' : 'text'),
        if (uploadedImageUrl != null) 'mediaUrls': [uploadedImageUrl],
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          createdData = resData['data'] as Map<String, dynamic>?;
        } else if (resData is Map) {
          createdData = resData as Map<String, dynamic>?;
        }
      }
    } catch (e) {
      debugPrint('[PostService] Error calling backend createPost: $e');
    }

    final newId = createdData?['id']?.toString() ?? 'local_post_${DateTime.now().millisecondsSinceEpoch}';
    final authorInitials = resolvedName.isNotEmpty ? resolvedName.substring(0, 1).toUpperCase() : 'U';

    final fullPost = {
      'id': newId,
      'author': {
        'id': currentUser?.id ?? '',
        'username': resolvedHandle,
        'fullName': resolvedName,
        'headline': resolvedBio,
        'profilePhotoUrl': resolvedAvatar,
      },
      'authorName': resolvedName,
      'authorSubtitle': resolvedBio.isNotEmpty ? resolvedBio : 'Student @ Acadyk',
      'authorInitials': authorInitials,
      'authorBgColor': 0xFF0F4C81,
      'authorAvatar': resolvedAvatar,
      'isVerified': true,
      'badgeType': 'gold',
      'timeAgo': 'Just now',
      'content': content,
      'postType': uploadedImageUrl != null ? 'image' : (postType ?? 'text'),
      'imageUrl': uploadedImageUrl,
      'likes': 0,
      'comments': 0,
      'isLiked': false,
      'isBookmarked': false,
      'createdAt': DateTime.now().toIso8601String(),
    };

    _inMemoryPosts.insert(0, fullPost);
    notifyFeedChanged();
    return fullPost;
  }

  /// Delete a post
  static Future<void> deletePost(String postId) async {
    _inMemoryPosts.removeWhere((p) => p['id']?.toString() == postId);
    try {
      await ApiClient.delete('/posts/$postId');
    } catch (e) {
      debugPrint('[PostService] Error deleting post from backend: $e');
    }
    notifyFeedChanged();
  }

  /// Toggle like on a post
  static Future<bool> toggleLike(String postId, bool currentLikeState) async {
    final newState = !currentLikeState;
    _likedPosts[postId] = newState;

    final currentLikes = _likeCounts[postId] ?? 0;
    _likeCounts[postId] = newState ? (currentLikes + 1) : (currentLikes > 0 ? currentLikes - 1 : 0);

    // Update in-memory post if present
    for (int i = 0; i < _inMemoryPosts.length; i++) {
      if (_inMemoryPosts[i]['id']?.toString() == postId) {
        _inMemoryPosts[i]['isLiked'] = newState;
        _inMemoryPosts[i]['likes'] = _likeCounts[postId];
        break;
      }
    }

    try {
      await ApiClient.post('/posts/$postId/like');
    } catch (e) {
      debugPrint('[PostService] Error toggling like on backend: $e');
    }

    notifyFeedChanged();
    return newState;
  }

  /// Get comments for a post
  static Future<List<Map<String, dynamic>>> getComments(String postId) async {
    List<Map<String, dynamic>> backendComments = [];
    try {
      final response = await ApiClient.get('/posts/$postId/comments');
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          final payload = resData['data'];
          if (payload is Map && payload.containsKey('content') && payload['content'] is List) {
            backendComments = List<Map<String, dynamic>>.from(payload['content']);
          } else if (payload is List) {
            backendComments = List<Map<String, dynamic>>.from(payload);
          }
        } else if (resData is List) {
          backendComments = List<Map<String, dynamic>>.from(resData);
        }
      }
    } catch (e) {
      debugPrint('[PostService] Error getting comments from backend: $e');
    }

    final local = _postComments[postId] ?? [];
    return [...local, ...backendComments];
  }

  /// Add comment to a post
  static Future<Map<String, dynamic>?> addComment(
    String postId,
    String content, {
    String? parentId,
  }) async {
    final authorName = ProfileManager.name;
    final authorAvatar = ProfileManager.avatarUrl;

    final newComment = {
      'id': 'comment_${DateTime.now().millisecondsSinceEpoch}',
      'postId': postId,
      'content': content,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'authorHeadline': ProfileManager.bio,
      'timeAgo': 'Just now',
      'likes': 0,
      'isLiked': false,
      'createdAt': DateTime.now().toIso8601String(),
    };

    if (!_postComments.containsKey(postId)) {
      _postComments[postId] = [];
    }
    _postComments[postId]!.insert(0, newComment);

    // Update comment count on post
    for (int i = 0; i < _inMemoryPosts.length; i++) {
      if (_inMemoryPosts[i]['id']?.toString() == postId) {
        final currentCount = _inMemoryPosts[i]['comments'] as int? ?? 0;
        _inMemoryPosts[i]['comments'] = currentCount + 1;
        break;
      }
    }

    try {
      await ApiClient.post('/posts/$postId/comments', data: {
        'content': content,
        'parentId': parentId,
      });
    } catch (e) {
      debugPrint('[PostService] Error adding comment to backend: $e');
    }

    notifyFeedChanged();
    return newComment;
  }

  /// Delete a comment
  static Future<void> deleteComment(String postId, String commentId) async {
    if (_postComments.containsKey(postId)) {
      _postComments[postId]!.removeWhere((c) => c['id']?.toString() == commentId);
    }

    for (int i = 0; i < _inMemoryPosts.length; i++) {
      if (_inMemoryPosts[i]['id']?.toString() == postId) {
        final currentCount = _inMemoryPosts[i]['comments'] as int? ?? 0;
        _inMemoryPosts[i]['comments'] = max(0, currentCount - 1);
        break;
      }
    }

    try {
      await ApiClient.delete('/posts/$postId/comments/$commentId');
    } catch (e) {
      debugPrint('[PostService] Error deleting comment on backend: $e');
    }

    notifyFeedChanged();
  }

  /// Update a post
  static Future<Map<String, dynamic>?> updatePost(
    String postId, {
    String? content,
    String? postType,
    String? imageUrl,
  }) async {
    for (int i = 0; i < _inMemoryPosts.length; i++) {
      if (_inMemoryPosts[i]['id']?.toString() == postId) {
        if (content != null) _inMemoryPosts[i]['content'] = content;
        if (postType != null) _inMemoryPosts[i]['postType'] = postType;
        if (imageUrl != null) _inMemoryPosts[i]['imageUrl'] = imageUrl;
        break;
      }
    }

    try {
      final response = await ApiClient.put('/posts/$postId', data: {
        if (content != null) 'content': content,
        if (postType != null) 'postType': postType,
        if (imageUrl != null) 'imageUrl': imageUrl,
      });

      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          return resData['data'] as Map<String, dynamic>?;
        }
      }
    } catch (e) {
      debugPrint('[PostService] Error updating post on backend: $e');
    }

    notifyFeedChanged();
    return null;
  }

  /// Toggle bookmark on a post
  static Future<bool> toggleBookmark(String postId, bool currentBookmarkState) async {
    final newState = !currentBookmarkState;
    _bookmarkedPosts[postId] = newState;

    for (int i = 0; i < _inMemoryPosts.length; i++) {
      if (_inMemoryPosts[i]['id']?.toString() == postId) {
        _inMemoryPosts[i]['isBookmarked'] = newState;
        break;
      }
    }

    try {
      await ApiClient.post('/posts/$postId/bookmark');
    } catch (e) {
      debugPrint('[PostService] Error toggling bookmark on backend: $e');
    }

    notifyFeedChanged();
    return newState;
  }

  /// Get user's own created posts for Profile "Listed"
  static List<Map<String, dynamic>> getUserCreatedPosts() {
    return List<Map<String, dynamic>>.from(_inMemoryPosts);
  }
}
