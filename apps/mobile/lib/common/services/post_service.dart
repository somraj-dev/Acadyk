import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/network/api_client.dart';
import '../../features/profile/presentation/services/profile_manager.dart';
import 'auth_service.dart';
import 'storage_service.dart';

class PostService {
  static final ValueNotifier<int> feedChangeNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<Map<String, dynamic>?> activePostingNotifier = ValueNotifier<Map<String, dynamic>?>(null);

  // In-memory & persisted post cache for immediate feed visibility and offline resilience
  static final List<Map<String, dynamic>> _cachedPosts = [];
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static bool _hasLoadedStorage = false;

  // Client-side UI preferences
  static final Set<String> _hiddenPostIds = {};
  static final Set<String> _hiddenAuthors = {};

  // Optimistic UI caches — shadow backend state for instant feedback
  static final Map<String, bool> _optimisticLikes = {};
  static final Map<String, int> _optimisticLikeCounts = {};
  static final Map<String, bool> _optimisticBookmarks = {};

  static Set<String> get hiddenPostIds => Set.unmodifiable(_hiddenPostIds);
  static Set<String> get hiddenAuthors => Set.unmodifiable(_hiddenAuthors);

  // ─── Initialization & Persistence ──────────────────────────────────

  static Future<void> init() async {
    if (_hasLoadedStorage) return;
    _hasLoadedStorage = true;
    try {
      final jsonStr = await _storage.read(key: 'cached_feed_posts');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List decoded = jsonDecode(jsonStr);
        final loaded = decoded.map((p) => _normalizePostData(Map<String, dynamic>.from(p))).toList();
        if (_cachedPosts.isEmpty) {
          _cachedPosts.addAll(loaded);
        } else {
          for (final p in loaded) {
            if (!_cachedPosts.any((existing) => existing['id']?.toString() == p['id']?.toString())) {
              _cachedPosts.add(p);
            }
          }
        }
        notifyFeedChanged();
      }
    } catch (e) {
      debugPrint('[PostService] Error loading cached posts: $e');
    }
  }

  static Future<void> _persistCachedPosts() async {
    try {
      final toSave = _cachedPosts.take(100).map((p) {
        final clone = Map<String, dynamic>.from(p);
        clone.remove('imageBytes'); // Raw binary not JSON encodable
        return clone;
      }).toList();
      await _storage.write(key: 'cached_feed_posts', value: jsonEncode(toSave));
    } catch (e) {
      debugPrint('[PostService] Error saving cached posts: $e');
    }
  }

  // ─── Post Visibility (Client-Side Preferences) ──────────────────────

  static bool isPostHidden(Map<String, dynamic> post) {
    final postId = post['id']?.toString();
    if (postId != null && _hiddenPostIds.contains(postId)) return true;

    final authorName = (post['authorName'] ?? post['author']?['fullName'] ?? '').toString().trim().toLowerCase();
    if (authorName.isNotEmpty && _hiddenAuthors.contains(authorName)) return true;

    final authorUsername = (post['author']?['username'] ?? '').toString().trim().toLowerCase();
    if (authorUsername.isNotEmpty && _hiddenAuthors.contains(authorUsername)) return true;

    final authorId = (post['author']?['id'] ?? post['authorId'] ?? '').toString().trim();
    if (authorId.isNotEmpty && _hiddenAuthors.contains(authorId)) return true;

    return false;
  }

  static void hidePost(String postId) {
    _hiddenPostIds.add(postId);
    _cachedPosts.removeWhere((p) => p['id']?.toString() == postId);
    _persistCachedPosts();
    notifyFeedChanged();
  }

  static void unhidePost(String postId) {
    _hiddenPostIds.remove(postId);
    notifyFeedChanged();
  }

  static void hideAuthor(String authorKey) {
    if (authorKey.trim().isNotEmpty) {
      _hiddenAuthors.add(authorKey.trim().toLowerCase());
      _cachedPosts.removeWhere((p) => isPostHidden(p));
      _persistCachedPosts();
      notifyFeedChanged();
    }
  }

  static void unhideAuthor(String authorKey) {
    if (authorKey.trim().isNotEmpty) {
      _hiddenAuthors.remove(authorKey.trim().toLowerCase());
      notifyFeedChanged();
    }
  }

  static bool isAuthorHidden(String authorKey) {
    return _hiddenAuthors.contains(authorKey.trim().toLowerCase());
  }

  static void notifyFeedChanged() {
    feedChangeNotifier.value = feedChangeNotifier.value + 1;
  }

  // ─── Time Formatting ────────────────────────────────────────────────

  static String formatTimeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    if (timestamp is String) {
      if (timestamp.toLowerCase() == 'just now' || timestamp.endsWith('m') || timestamp.endsWith('h') || timestamp.endsWith('d')) {
        return timestamp;
      }
      final parsed = DateTime.tryParse(timestamp);
      if (parsed != null) {
        final diff = DateTime.now().toUtc().difference(parsed.toUtc());
        if (diff.inSeconds < 45) return 'Just now';
        if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
        if (diff.inHours < 24) return '${diff.inHours}h ago';
        if (diff.inDays < 30) return '${diff.inDays}d ago';
        return '${(diff.inDays / 30).floor()}mo ago';
      }
    }
    return 'Just now';
  }

  // ─── Feed Posts (Backend + Local Cache Sync) ─────────────────────────

  /// Fetch feed posts from PostgreSQL with automatic fallback to active cache.
  static Future<List<Map<String, dynamic>>> getFeedPosts({int limit = 20, int offset = 0}) async {
    await init();
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
        List<Map<String, dynamic>> rawPosts = [];

        if (resData is Map && resData.containsKey('data')) {
          final payload = resData['data'];
          if (payload is Map && payload.containsKey('content') && payload['content'] is List) {
            rawPosts = List<Map<String, dynamic>>.from(payload['content']);
          } else if (payload is List) {
            rawPosts = List<Map<String, dynamic>>.from(payload);
          }
        } else if (resData is List) {
          rawPosts = List<Map<String, dynamic>>.from(resData);
        }

        final backendPosts = rawPosts.map((p) => _normalizePostData(p)).toList();

        // Merge backend posts into _cachedPosts without losing newly created local posts
        for (final bp in backendPosts) {
          final idx = _cachedPosts.indexWhere((cp) => cp['id']?.toString() == bp['id']?.toString());
          if (idx != -1) {
            // Keep local media/state if richer, update stats
            _cachedPosts[idx] = {
              ..._cachedPosts[idx],
              ...bp,
              if (_cachedPosts[idx]['imageBytes'] != null) 'imageBytes': _cachedPosts[idx]['imageBytes'],
            };
          } else {
            _cachedPosts.add(bp);
          }
        }

        _persistCachedPosts();
      }
    } catch (e) {
      debugPrint('[PostService] Error fetching feed from backend: $e');
    }

    return _cachedPosts
        .map((p) => _normalizePostData(p))
        .where((p) => !isPostHidden(p))
        .toList();
  }

  /// Get posts authored by a specific user from the backend or local cache.
  static Future<List<Map<String, dynamic>>> getUserPosts(String userId) async {
    await init();
    try {
      final response = await ApiClient.get('/posts/user/$userId');
      if (response.statusCode == 200) {
        final resData = response.data;
        List<Map<String, dynamic>> posts = [];

        if (resData is Map && resData.containsKey('data')) {
          final payload = resData['data'];
          if (payload is Map && payload.containsKey('content') && payload['content'] is List) {
            posts = List<Map<String, dynamic>>.from(payload['content']);
          } else if (payload is List) {
            posts = List<Map<String, dynamic>>.from(payload);
          }
        } else if (resData is List) {
          posts = List<Map<String, dynamic>>.from(resData);
        }

        return posts
            .map((p) => _normalizePostData(p))
            .where((p) => !isPostHidden(p))
            .toList();
      }
    } catch (e) {
      debugPrint('[PostService] Error fetching user posts: $e');
    }

    // Fallback: match from local cache
    return _cachedPosts
        .where((p) {
          final authorId = p['authorId'] ?? p['author']?['id'];
          return authorId?.toString() == userId;
        })
        .where((p) => !isPostHidden(p))
        .toList();
  }

  /// Get current user's own created posts synchronously.
  static List<Map<String, dynamic>> getUserCreatedPosts() {
    return _cachedPosts
        .map((p) => _normalizePostData(p))
        .where((p) => !isPostHidden(p))
        .toList();
  }

  // ─── Post Creation ──────────────────────────────────────────────────

  /// Start posting asynchronously with live progress animation.
  /// Uses optimistic UI: saves and displays immediately, then syncs with backend.
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
    bool isCollab = false,
    String? collabAuthorName,
    String? collabAuthorSubtitle,
    String? collabAuthorAvatar,
    String? collabAuthorInitials,
    int? collabAuthorBgColor,
    String? collabAuthorHandle,
    String? collabAuthorId,
    bool? isOfficialCollab,
  }) async {
    final authorName = ProfileManager.name.isNotEmpty
        ? ProfileManager.name
        : (AuthService.currentUser?.fullName != null && AuthService.currentUser!.fullName!.isNotEmpty
            ? AuthService.currentUser!.fullName!
            : 'Acadyk Member');
    final authorAvatar = ProfileManager.avatarUrl.isNotEmpty
        ? ProfileManager.avatarUrl
        : '';
    final authorBio = ProfileManager.bio.isNotEmpty
        ? ProfileManager.bio
        : (AuthService.currentUser?.branch != null ? '${AuthService.currentUser?.degree ?? "B.Tech"} in ${AuthService.currentUser?.branch}' : 'Student @ MITS Gwalior');
    final authorHandle = ProfileManager.username.isNotEmpty
        ? ProfileManager.username
        : (AuthService.currentUser?.username ?? 'user');

    // 1. Notify posting in progress
    activePostingNotifier.value = {
      'status': 'posting',
      'content': content,
      'avatar': authorAvatar,
      'name': authorName,
      'isCollab': isCollab,
      'collabAuthorName': collabAuthorName,
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

    final tempId = 'post_${DateTime.now().millisecondsSinceEpoch}';
    final authorInitials = authorName.isNotEmpty ? authorName.substring(0, min(2, authorName.length)).toUpperCase() : 'U';

    final resolvedPostType = postType ?? (poll != null ? 'poll' : (gifUrl != null ? 'gif' : (uploadedImageUrl != null || imageBytes != null ? 'image' : 'text')));

    // 2. Optimistic local post (shown immediately before backend confirms)
    final optimisticPost = {
      'id': tempId,
      'author': {
        'id': AuthService.currentUser?.id ?? '',
        'username': authorHandle,
        'fullName': authorName,
        'headline': authorBio,
        'profilePhotoUrl': authorAvatar,
        'email': AuthService.currentUser?.email ?? '',
      },
      'authorName': authorName,
      'authorSubtitle': authorBio,
      'authorInitials': authorInitials,
      'authorBgColor': 0xFF0F4C81,
      'authorAvatar': authorAvatar,
      'isVerified': false,
      'badgeType': 'none',
      'timeAgo': 'Just now',
      'content': content,
      'postType': resolvedPostType,
      'imageUrl': uploadedImageUrl,
      'imageBytes': imageBytes,
      'gifUrl': gifUrl,
      'poll': poll,
      'milestone': milestone,
      'location': location,
      'taggedPeople': taggedPeople,
      'replyVisibility': replyVisibility,
      'isCollab': isCollab,
      if (isCollab) ...{
        'collabAuthorName': collabAuthorName,
        'collabAuthorSubtitle': collabAuthorSubtitle ?? 'Collaborator @ Acadyk',
        'collabAuthorAvatar': collabAuthorAvatar ?? '',
        'collabAuthorInitials': collabAuthorInitials ?? 'CO',
        'collabAuthorBgColor': collabAuthorBgColor ?? 0xFF0284C7,
        'collabAuthorHandle': collabAuthorHandle,
        'collabAuthorId': collabAuthorId,
        'isOfficial': isOfficialCollab ?? false,
      },
      'likes': 0,
      'likesCount': 0,
      'comments': 0,
      'commentsCount': 0,
      'isLiked': false,
      'isBookmarked': false,
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Store in active cache immediately at top of feed
    _cachedPosts.insert(0, optimisticPost);
    _persistCachedPosts();
    notifyFeedChanged();

    // 3. Try to create on backend
    Map<String, dynamic> finalPost = optimisticPost;
    try {
      final response = await ApiClient.post('/posts', data: {
        'content': content,
        'postType': resolvedPostType,
        if (uploadedImageUrl != null) 'imageUrl': uploadedImageUrl,
        if (uploadedImageUrl != null) 'mediaUrls': [uploadedImageUrl],
        if (location != null) 'location': location,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        Map<String, dynamic>? createdData;
        if (resData is Map && resData.containsKey('data')) {
          createdData = resData['data'] as Map<String, dynamic>?;
        } else if (resData is Map) {
          createdData = Map<String, dynamic>.from(resData);
        }
        if (createdData != null) {
          finalPost = _normalizePostData(createdData);
          finalPost['imageBytes'] = imageBytes;
          finalPost['gifUrl'] = gifUrl;
          finalPost['poll'] = poll;
          finalPost['milestone'] = milestone;
          if (isCollab) {
            finalPost['isCollab'] = true;
            finalPost['collabAuthorName'] = collabAuthorName;
            finalPost['collabAuthorSubtitle'] = collabAuthorSubtitle;
            finalPost['collabAuthorAvatar'] = collabAuthorAvatar;
            finalPost['collabAuthorInitials'] = collabAuthorInitials;
            finalPost['collabAuthorBgColor'] = collabAuthorBgColor;
            finalPost['collabAuthorHandle'] = collabAuthorHandle;
            finalPost['collabAuthorId'] = collabAuthorId;
          }

          // Replace optimistic post with server post
          final idx = _cachedPosts.indexWhere((p) => p['id'] == tempId);
          if (idx != -1) {
            _cachedPosts[idx] = finalPost;
          }
          _persistCachedPosts();
        }
      }
    } catch (e) {
      debugPrint('[PostService] Backend create post error (retaining local post): $e');
    }

    // 4. Notify done and refresh feed
    activePostingNotifier.value = {
      'status': 'done',
      'post': finalPost,
    };
    notifyFeedChanged();

    // Auto-clear posting progress banner after 1.8s
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (activePostingNotifier.value?['status'] == 'done') {
        activePostingNotifier.value = null;
      }
    });

    return finalPost;
  }

  /// Create post (alternative API used by some screens)
  static Future<Map<String, dynamic>> createPost(
    String content, {
    String? authorName,
    String? authorBio,
    String? authorAvatar,
    String? authorHandle,
    String? postType,
    String? imageUrl,
    File? imageFile,
  }) async {
    String? uploadedImageUrl = imageUrl;
    final currentUser = AuthService.currentUser;

    if (imageFile != null && currentUser != null) {
      uploadedImageUrl = await StorageService.uploadPostImage(currentUser.id, imageFile);
    }

    return startPostingAsync(
      content: content,
      postType: postType,
      imageUrl: uploadedImageUrl,
    );
  }

  // ─── Post Update & Delete ───────────────────────────────────────────

  /// Update a post on the backend.
  static Future<Map<String, dynamic>?> updatePost(
    String postId, {
    String? content,
    String? postType,
    String? imageUrl,
  }) async {
    final idx = _cachedPosts.indexWhere((p) => p['id']?.toString() == postId);
    if (idx != -1) {
      if (content != null) _cachedPosts[idx]['content'] = content;
      if (postType != null) _cachedPosts[idx]['postType'] = postType;
      if (imageUrl != null) _cachedPosts[idx]['imageUrl'] = imageUrl;
      _persistCachedPosts();
      notifyFeedChanged();
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
          final updated = _normalizePostData(resData['data'] as Map<String, dynamic>);
          if (idx != -1) {
            _cachedPosts[idx] = updated;
            _persistCachedPosts();
          }
          notifyFeedChanged();
          return updated;
        }
      }
    } catch (e) {
      debugPrint('[PostService] Error updating post: $e');
    }
    return idx != -1 ? _cachedPosts[idx] : null;
  }

  /// Delete a post from the backend.
  static Future<void> deletePost(String postId) async {
    _cachedPosts.removeWhere((p) => p['id']?.toString() == postId);
    _persistCachedPosts();
    notifyFeedChanged();

    try {
      await ApiClient.delete('/posts/$postId');
    } catch (e) {
      debugPrint('[PostService] Error deleting post on backend: $e');
    }
  }

  // ─── Likes (Backend + Optimistic UI) ────────────────────────────────

  /// Toggle like on a post. Uses optimistic UI with backend sync.
  static Future<bool> toggleLike(String postId, bool currentLikeState) async {
    final newState = !currentLikeState;

    // Optimistic update
    _optimisticLikes[postId] = newState;
    final currentCount = _optimisticLikeCounts[postId] ?? 0;
    _optimisticLikeCounts[postId] = newState ? currentCount + 1 : max(0, currentCount - 1);

    // Update in cached post
    final idx = _cachedPosts.indexWhere((p) => p['id']?.toString() == postId);
    if (idx != -1) {
      _cachedPosts[idx]['isLiked'] = newState;
      _cachedPosts[idx]['likes'] = _optimisticLikeCounts[postId];
      _cachedPosts[idx]['likesCount'] = _optimisticLikeCounts[postId];
    }
    notifyFeedChanged();

    // Sync with backend
    try {
      final response = await ApiClient.post('/posts/$postId/like');
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          final data = resData['data'] as Map<String, dynamic>;
          final serverLiked = data['isLiked'] ?? data['liked'] ?? newState;
          final serverCount = data['likesCount'] ?? data['likeCount'] ?? _optimisticLikeCounts[postId];
          _optimisticLikes[postId] = serverLiked is bool ? serverLiked : newState;
          if (serverCount is num) _optimisticLikeCounts[postId] = serverCount.toInt();
          if (idx != -1) {
            _cachedPosts[idx]['isLiked'] = _optimisticLikes[postId];
            _cachedPosts[idx]['likes'] = _optimisticLikeCounts[postId];
          }
          notifyFeedChanged();
          return _optimisticLikes[postId]!;
        }
      }
    } catch (e) {
      debugPrint('[PostService] Error toggling like: $e');
      // Rollback optimistic update on failure if not in offline mode
    }

    return newState;
  }

  /// Check if post is liked (optimistic cache)
  static bool isLiked(String postId) {
    return _optimisticLikes[postId] ?? false;
  }

  /// Get like count (optimistic cache or default)
  static int getLikeCount(String postId, int defaultCount) {
    return _optimisticLikeCounts[postId] ?? defaultCount;
  }

  // ─── Bookmarks (Backend + Optimistic UI) ────────────────────────────

  /// Toggle bookmark on a post. Uses optimistic UI with backend sync.
  static Future<bool> toggleBookmark(String postId, [bool? currentBookmarkState]) async {
    final current = currentBookmarkState ?? (_optimisticBookmarks[postId] ?? false);
    final newState = !current;

    // Optimistic update
    _optimisticBookmarks[postId] = newState;
    final idx = _cachedPosts.indexWhere((p) => p['id']?.toString() == postId);
    if (idx != -1) {
      _cachedPosts[idx]['isBookmarked'] = newState;
    }
    notifyFeedChanged();

    // Sync with backend
    try {
      final response = await ApiClient.post('/posts/$postId/bookmark');
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          final data = resData['data'] as Map<String, dynamic>;
          final serverBookmarked = data['isBookmarked'] ?? data['bookmarked'] ?? newState;
          _optimisticBookmarks[postId] = serverBookmarked is bool ? serverBookmarked : newState;
          if (idx != -1) {
            _cachedPosts[idx]['isBookmarked'] = _optimisticBookmarks[postId];
          }
          notifyFeedChanged();
          return _optimisticBookmarks[postId]!;
        }
      }
    } catch (e) {
      debugPrint('[PostService] Error toggling bookmark: $e');
    }

    return newState;
  }

  /// Check if post is bookmarked
  static bool isBookmarked(String postId) {
    return _optimisticBookmarks[postId] ?? false;
  }

  // ─── Comments (Backend Source of Truth) ──────────────────────────────

  /// Get comments for a post from the backend.
  static Future<List<Map<String, dynamic>>> getComments(String postId) async {
    try {
      final response = await ApiClient.get('/posts/$postId/comments');
      if (response.statusCode == 200) {
        final resData = response.data;
        List<Map<String, dynamic>> comments = [];

        if (resData is Map && resData.containsKey('data')) {
          final payload = resData['data'];
          if (payload is Map && payload.containsKey('content') && payload['content'] is List) {
            comments = List<Map<String, dynamic>>.from(payload['content']);
          } else if (payload is List) {
            comments = List<Map<String, dynamic>>.from(payload);
          }
        } else if (resData is List) {
          comments = List<Map<String, dynamic>>.from(resData);
        }

        return comments.map((c) => _normalizeCommentData(c, postId)).toList();
      }
    } catch (e) {
      debugPrint('[PostService] Error fetching comments: $e');
    }
    return [];
  }

  /// Add a comment to a post via the backend.
  static Future<Map<String, dynamic>?> addComment(
    String postId,
    String content, {
    String? parentId,
  }) async {
    // Optimistic comment for immediate display
    final optimistic = {
      'id': 'comment_${DateTime.now().millisecondsSinceEpoch}',
      'postId': postId,
      'content': content,
      'authorName': ProfileManager.name.isNotEmpty ? ProfileManager.name : 'You',
      'authorAvatar': ProfileManager.avatarUrl,
      'authorId': AuthService.currentUser?.id ?? '',
      'authorHeadline': ProfileManager.bio,
      'timeAgo': 'Just now',
      'likes': 0,
      'likesCount': 0,
      'isLiked': false,
      'createdAt': DateTime.now().toIso8601String(),
    };

    final idx = _cachedPosts.indexWhere((p) => p['id']?.toString() == postId);
    if (idx != -1) {
      final currentComments = (_cachedPosts[idx]['commentsCount'] ?? _cachedPosts[idx]['comments'] ?? 0) as int;
      _cachedPosts[idx]['comments'] = currentComments + 1;
      _cachedPosts[idx]['commentsCount'] = currentComments + 1;
      _persistCachedPosts();
    }
    notifyFeedChanged();

    try {
      final response = await ApiClient.post('/posts/$postId/comments', data: {
        'content': content,
        if (parentId != null) 'parentId': parentId,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          final serverComment = _normalizeCommentData(resData['data'] as Map<String, dynamic>, postId);
          notifyFeedChanged();
          return serverComment;
        }
      }
    } catch (e) {
      debugPrint('[PostService] Error adding comment: $e');
    }

    // Return optimistic comment if backend failed
    notifyFeedChanged();
    return optimistic;
  }

  /// Delete a comment from the backend.
  static Future<void> deleteComment(String postId, String commentId) async {
    try {
      await ApiClient.delete('/posts/$postId/comments/$commentId');
    } catch (e) {
      debugPrint('[PostService] Error deleting comment: $e');
    }
    notifyFeedChanged();
  }

  // ─── Poll Voting ────────────────────────────────────────────────────

  /// Vote on a poll
  static void votePoll(String postId, int optionIndex) {
    notifyFeedChanged();
  }

  // ─── Data Normalization ─────────────────────────────────────────────

  /// Normalize post response to UI widget format.
  static Map<String, dynamic> _normalizePostData(Map<String, dynamic> post) {
    final author = post['author'] is Map ? post['author'] as Map : null;
    final id = post['id']?.toString() ?? 'post_${DateTime.now().millisecondsSinceEpoch}';

    final authorName = post['authorName']?.toString() ?? author?['fullName']?.toString() ?? author?['username']?.toString() ?? 'Acadyk Member';
    final authorSubtitle = post['authorSubtitle']?.toString() ?? author?['headline']?.toString() ?? '';
    final authorAvatar = post['authorAvatar']?.toString() ?? author?['profilePhotoUrl']?.toString() ?? '';
    final authorInitials = authorName.isNotEmpty ? authorName.substring(0, min(2, authorName.length)).toUpperCase() : 'U';
    final content = post['content']?.toString() ?? '';
    final imageUrl = post['imageUrl']?.toString() ?? (post['mediaUrls'] is List && (post['mediaUrls'] as List).isNotEmpty ? post['mediaUrls'][0]?.toString() : null);

    final imageBytes = post['imageBytes'] as Uint8List?;
    final poll = post['poll'] as Map<String, dynamic>?;
    final milestone = post['milestone']?.toString();
    final location = post['location']?.toString();
    final taggedPeople = post['taggedPeople'] as List<dynamic>?;
    final postType = post['postType']?.toString() ?? post['type']?.toString() ?? (poll != null ? 'poll' : (imageUrl != null || imageBytes != null ? 'image' : 'text'));

    // Use optimistic cache if available, otherwise backend values
    final rawLikes = post['likesCount'] ?? post['likes'] ?? 0;
    final int backendLikes = (rawLikes is num) ? rawLikes.toInt() : (int.tryParse(rawLikes.toString()) ?? 0);
    final int likes = _optimisticLikeCounts.containsKey(id) ? _optimisticLikeCounts[id]! : backendLikes;
    if (!_optimisticLikeCounts.containsKey(id)) {
      _optimisticLikeCounts[id] = backendLikes;
    }

    final rawComments = post['commentsCount'] ?? post['comments'] ?? 0;
    final int comments = (rawComments is num) ? rawComments.toInt() : (int.tryParse(rawComments.toString()) ?? 0);

    final backendLiked = post['isLiked'] == true || post['liked'] == true;
    final isLiked = _optimisticLikes.containsKey(id) ? _optimisticLikes[id]! : backendLiked;
    if (!_optimisticLikes.containsKey(id)) {
      _optimisticLikes[id] = backendLiked;
    }

    final backendBookmarked = post['isBookmarked'] == true || post['bookmarked'] == true;
    final isBookmarked = _optimisticBookmarks.containsKey(id) ? _optimisticBookmarks[id]! : backendBookmarked;
    if (!_optimisticBookmarks.containsKey(id)) {
      _optimisticBookmarks[id] = backendBookmarked;
    }

    final rawTimestamp = post['createdAt'] ?? post['timeAgo'];
    final formattedTime = formatTimeAgo(rawTimestamp);

    return {
      'id': id,
      'author': author != null ? Map<String, dynamic>.from(author) : {
        'id': post['authorId']?.toString() ?? '',
        'fullName': authorName,
        'username': post['authorHandle']?.toString() ?? '',
        'headline': authorSubtitle,
        'profilePhotoUrl': authorAvatar,
      },
      'authorName': authorName,
      'authorSubtitle': authorSubtitle,
      'authorAvatar': authorAvatar,
      'authorInitials': post['authorInitials'] ?? authorInitials,
      'authorBgColor': post['authorBgColor'] ?? 0xFF0F4C81,
      'isVerified': post['isVerified'] ?? false,
      'badgeType': post['badgeType'] ?? 'none',
      'content': content,
      'imageUrl': imageUrl,
      'imageBytes': imageBytes,
      'poll': poll,
      'milestone': milestone,
      'location': location,
      'taggedPeople': taggedPeople,
      'postType': postType,
      'likes': likes,
      'likesCount': likes,
      'comments': comments,
      'commentsCount': comments,
      'isLiked': isLiked,
      'isBookmarked': isBookmarked,
      'timeAgo': formattedTime,
      'createdAt': post['createdAt']?.toString(),
      'type': post['postType'] ?? post['type'] ?? 'student',
      'isCollab': post['isCollab'] == true,
      'collabAuthorName': post['collabAuthorName'] ?? post['collabName'],
      'collabAuthorSubtitle': post['collabAuthorSubtitle'] ?? post['collabSubtitle'],
      'collabAuthorAvatar': post['collabAuthorAvatar'] ?? post['collabAvatar'],
      'collabAuthorInitials': post['collabAuthorInitials'] ?? post['collabInitials'],
      'collabAuthorBgColor': post['collabAuthorBgColor'] ?? post['collabBgColor'],
      'collabAuthorHandle': post['collabAuthorHandle'] ?? post['collabHandle'],
      'collabAuthorId': post['collabAuthorId'] ?? post['collabId'],
      'raw': post,
    };
  }

  /// Normalize a comment from backend response.
  static Map<String, dynamic> _normalizeCommentData(Map<String, dynamic> c, String postId) {
    final author = c['author'] is Map ? c['author'] as Map : null;
    return {
      'id': c['id']?.toString() ?? '',
      'postId': postId,
      'content': c['content']?.toString() ?? '',
      'authorName': author?['fullName']?.toString() ?? author?['username']?.toString() ?? 'Acadyk Member',
      'authorAvatar': author?['profilePhotoUrl']?.toString() ?? '',
      'authorId': author?['id']?.toString() ?? c['authorId']?.toString() ?? '',
      'authorHeadline': author?['headline']?.toString() ?? '',
      'timeAgo': formatTimeAgo(c['createdAt']),
      'likes': c['likesCount'] ?? c['likes'] ?? 0,
      'likesCount': c['likesCount'] ?? c['likes'] ?? 0,
      'isLiked': c['isLiked'] == true,
      'createdAt': c['createdAt']?.toString() ?? '',
      'parentId': c['parentId']?.toString(),
    };
  }

  // ─── State Cleanup ──────────────────────────────────────────────────

  /// Clear all in-memory caches. Called on sign-out.
  static void clearAllCaches() {
    _optimisticLikes.clear();
    _optimisticLikeCounts.clear();
    _optimisticBookmarks.clear();
    _hiddenPostIds.clear();
    _hiddenAuthors.clear();
    feedChangeNotifier.value = 0;
    activePostingNotifier.value = null;
  }
}
