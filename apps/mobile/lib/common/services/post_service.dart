import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../features/profile/presentation/services/profile_manager.dart';
import 'auth_service.dart';

class PostService {
  static final ValueNotifier<int> feedChangeNotifier = ValueNotifier<int>(0);

  // In-memory created posts for immediate and persistent session state
  static final List<Map<String, dynamic>> _inMemoryPosts = [];
  static final Map<String, List<Map<String, dynamic>>> _postComments = {};
  static final Map<String, bool> _likedPosts = {};
  static final Map<String, int> _likeCounts = {};
  static final Map<String, bool> _bookmarkedPosts = {};

  static void notifyFeedChanged() {
    feedChangeNotifier.value = feedChangeNotifier.value + 1;
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

    final authorName = post['authorName']?.toString() ?? author?['fullName']?.toString() ?? author?['username']?.toString() ?? 'Somraj Lodhi';
    final authorSubtitle = post['authorSubtitle']?.toString() ?? author?['headline']?.toString() ?? 'Student & Developer';
    final authorAvatar = post['authorAvatar']?.toString() ?? author?['profilePhotoUrl']?.toString() ?? 'assets/images/somraj_avatar.jpg';
    final content = post['content']?.toString() ?? '';
    final imageUrl = post['imageUrl']?.toString() ?? (post['mediaUrls'] is List && (post['mediaUrls'] as List).isNotEmpty ? post['mediaUrls'][0]?.toString() : null);

    final rawLikes = _likeCounts[id] ?? post['likesCount'] ?? post['likes'] ?? 0;
    final int likes = (rawLikes is num) ? rawLikes.toInt() : (int.tryParse(rawLikes.toString()) ?? 0);

    final rawComments = _postComments[id]?.length ?? post['commentsCount'] ?? post['comments'] ?? 0;
    final int comments = (rawComments is num) ? rawComments.toInt() : (int.tryParse(rawComments.toString()) ?? 0);

    final isLiked = _likedPosts[id] ?? (post['isLiked'] == true);
    final isBookmarked = _bookmarkedPosts[id] ?? (post['isBookmarked'] == true);

    return {
      'id': id,
      'authorName': authorName,
      'authorSubtitle': authorSubtitle,
      'authorInitials': authorName.isNotEmpty ? authorName.substring(0, authorName.length >= 2 ? 2 : 1).toUpperCase() : 'U',
      'authorBgColor': (post['authorBgColor'] is num) ? (post['authorBgColor'] as num).toInt() : 0xFF0F4C81,
      'authorAvatar': authorAvatar,
      'isVerified': post['isVerified'] == true,
      'badgeType': post['badgeType']?.toString() ?? 'bronze',
      'timeAgo': post['timeAgo']?.toString() ?? 'Just now',
      'content': content,
      'postType': post['postType']?.toString() ?? 'text',
      'imageUrl': imageUrl,
      'likes': likes,
      'comments': comments,
      'isLiked': isLiked,
      'isBookmarked': isBookmarked,
      'createdAt': post['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    };
  }

  /// Create a new post and persist to backend and local session
  static Future<Map<String, dynamic>?> createPost(
    String content, {
    String? postType,
    String? imageUrl,
  }) async {
    final currentUser = AuthService.currentUser;
    final authorName = ProfileManager.name;
    final authorHandle = ProfileManager.username;
    final authorAvatar = ProfileManager.avatarUrl;
    final authorBio = ProfileManager.bio;

    Map<String, dynamic>? createdData;

    try {
      final response = await ApiClient.post('/posts', data: {
        'content': content,
        'postType': postType ?? (imageUrl != null ? 'image' : 'text'),
        'imageUrl': imageUrl,
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

    final fullPost = {
      'id': newId,
      'author': {
        'id': currentUser?.id ?? 'somraj_dev',
        'username': authorHandle,
        'fullName': authorName,
        'headline': authorBio,
        'profilePhotoUrl': authorAvatar,
      },
      'authorName': authorName,
      'authorSubtitle': '$authorBio • Just now',
      'authorInitials': 'SL',
      'authorBgColor': 0xFF0F4C81,
      'authorAvatar': authorAvatar,
      'isVerified': true,
      'badgeType': 'gold',
      'timeAgo': 'Just now',
      'content': content,
      'postType': postType ?? (imageUrl != null ? 'image' : 'text'),
      'imageUrl': imageUrl,
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
