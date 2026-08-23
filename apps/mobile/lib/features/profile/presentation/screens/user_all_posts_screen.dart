import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../common/services/post_service.dart';
import '../../../../common/services/auth_service.dart';
import '../../../../common/services/follow_service.dart';
import '../../../feed/presentation/screens/home_feed_screen.dart';
import '../../../feed/presentation/screens/post_detail_screen.dart';
import 'about_account_screen.dart';
import '../services/profile_manager.dart';
import '../../../../shared/widgets/skeleton/feed_skeleton.dart';

class UserAllPostsScreen extends StatefulWidget {
  final String userName;
  final String userBio;
  final String userAvatar;
  final String? userId;
  final bool isOwnProfile;
  final List<Map<String, dynamic>>? initialPosts;

  const UserAllPostsScreen({
    super.key,
    required this.userName,
    required this.userBio,
    required this.userAvatar,
    this.userId,
    this.isOwnProfile = false,
    this.initialPosts,
  });

  @override
  State<UserAllPostsScreen> createState() => _UserAllPostsScreenState();
}

class _UserAllPostsScreenState extends State<UserAllPostsScreen> {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  final Map<String, bool> _likedPosts = {};
  final Map<String, int> _likesCountOverride = {};
  final Map<String, bool> _bookmarkedPosts = {};
  final Map<String, bool> _expandedContent = {};
  final Map<String, bool> _commentsExpanded = {};
  final Map<String, List<Map<String, dynamic>>> _customComments = {};
  final TextEditingController _commentInputController = TextEditingController();
  String? _activeCommentPostId;

  @override
  void initState() {
    super.initState();
    _loadUserPosts();
  }

  @override
  void dispose() {
    _commentInputController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPosts() async {
    setState(() => _isLoading = true);

    try {
      if (widget.initialPosts != null && widget.initialPosts!.isNotEmpty) {
        _posts = List<Map<String, dynamic>>.from(widget.initialPosts!);
      } else if (widget.isOwnProfile) {
        final allFeedPosts = await PostService.getFeedPosts();
        final currentUserId = AuthService.currentUser?.id;
        final currentUsername = ProfileManager.username.replaceAll('@', '').toLowerCase();
        final currentName = ProfileManager.name.trim().toLowerCase();

        _posts = allFeedPosts.where((p) {
          final pAuthorId = p['author']?['id']?.toString() ?? p['authorId']?.toString();
          final pAuthorUsername = (p['author']?['username'] ?? p['authorHandle'] ?? '').toString().replaceAll('@', '').toLowerCase();
          final pAuthorName = (p['authorName'] ?? p['author']?['fullName'] ?? '').toString().trim().toLowerCase();

          return (currentUserId != null && pAuthorId == currentUserId) ||
              (currentUsername.isNotEmpty && pAuthorUsername == currentUsername) ||
              (currentName.isNotEmpty && pAuthorName == currentName);
        }).toList();
      } else {
        final allFeedPosts = await PostService.getFeedPosts();
        final targetName = widget.userName.trim().toLowerCase();
        final targetId = widget.userId;

        _posts = allFeedPosts.where((p) {
          final pAuthorId = p['author']?['id']?.toString() ?? p['authorId']?.toString();
          final pAuthorName = (p['authorName'] ?? p['author']?['fullName'] ?? '').toString().trim().toLowerCase();

          return (targetId != null && pAuthorId == targetId) ||
              (targetName.isNotEmpty && pAuthorName == targetName);
        }).toList();
      }
    } catch (_) {
      _posts = widget.initialPosts ?? [];
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF000000) : const Color(0xFFF3F2EE);
    final cardBg = isDark ? const Color(0xFF000000) : Colors.white;
    final textMain = isDark ? Colors.white : const Color(0xFF191919);
    final textSub = isDark ? const Color(0xFF8B949E) : const Color(0xFF666666);
    final iconColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF666666);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF000000) : Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textMain),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isOwnProfile ? 'Your Posts' : "${widget.userName}'s Posts",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: textMain,
              ),
            ),
            if (!_isLoading)
              Text(
                '${_posts.length} ${_posts.length == 1 ? 'post' : 'posts'}',
                style: TextStyle(fontSize: 12, color: textSub),
              ),
          ],
        ),
      ),
      body: _isLoading
          ? const SingleChildScrollView(child: FeedSkeleton(itemCount: 4))
          : _posts.isEmpty
              ? _buildEmptyState(isDark, textMain, textSub)
              : RefreshIndicator(
                  onRefresh: _loadUserPosts,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 24),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      return _buildPostCard(
                        _posts[index],
                        isDark: isDark,
                        cardBg: cardBg,
                        textMain: textMain,
                        textSub: textSub,
                        iconColor: iconColor,
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color textMain, Color textSub) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.article_outlined, size: 48, color: Color(0xFF0A66C2)),
            ),
            const SizedBox(height: 16),
            Text(
              widget.isOwnProfile ? 'No posts yet' : 'No posts from ${widget.userName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textMain),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isOwnProfile
                  ? 'Posts you create will appear here on your profile.'
                  : 'When ${widget.userName} posts updates, they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: textSub),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(
    Map<String, dynamic> post, {
    required bool isDark,
    required Color cardBg,
    required Color textMain,
    required Color textSub,
    required Color iconColor,
  }) {
    final String postId = post['id']?.toString() ?? 'post_${post.hashCode}';
    final String authorName = post['authorName']?.toString() ?? post['author']?['fullName']?.toString() ?? widget.userName;
    final String authorSubtitle = post['authorSubtitle']?.toString() ?? '';
    final String authorInitials = post['authorInitials']?.toString() ?? (authorName.isNotEmpty ? authorName[0].toUpperCase() : 'U');
    final int authorBgColor = (post['authorBgColor'] as num?)?.toInt() ?? 0xFF0F4C81;
    final bool isVerified = post['isVerified'] == true;
    final String timeAgo = post['timeAgo']?.toString() ?? 'Just now';
    final String content = post['content']?.toString() ?? post['text']?.toString() ?? '';
    final int likes = (post['likes'] as num?)?.toInt() ?? 0;
    final int comments = (post['comments'] as num?)?.toInt() ?? 0;
    final bool isCollab = post['isCollab'] == true;
    final String collabName = post['collabAuthorName']?.toString() ?? '';

    final bool isMITSOfficial = authorName.startsWith('MITS');
    final String mainAvatarAsset = post['authorAvatar'] ?? (isMITSOfficial ? 'assets/images/mits_logo.png' : widget.userAvatar);
    final String? postImageUrl = post['imageUrl'] ?? post['image'] ?? post['gifUrl'];
    final dynamic imageBytes = post['imageBytes'];
    final String? milestone = post['milestone']?.toString();
    final String? location = post['location']?.toString();
    final List<dynamic>? taggedPeople = post['taggedPeople'] as List<dynamic>?;

    final currentUserId = AuthService.currentUser?.id;
    final currentUsername = AuthService.currentUser?.username?.replaceAll('@', '').toLowerCase();
    final currentProfileName = ProfileManager.name.trim().toLowerCase();
    final postAuthorId = post['author']?['id']?.toString() ?? post['authorId']?.toString();
    final postAuthorUsername = (post['author']?['username'] ?? post['authorHandle'] ?? '').toString().replaceAll('@', '').toLowerCase();
    final postAuthorName = authorName.trim().toLowerCase();

    final bool isAuthor = widget.isOwnProfile ||
        (currentUserId != null && postAuthorId != null && currentUserId == postAuthorId) ||
        (currentUsername != null && currentUsername.isNotEmpty && postAuthorUsername == currentUsername) ||
        (currentProfileName.isNotEmpty && postAuthorName == currentProfileName);

    final isLiked = _likedPosts[postId] ?? (post['isLiked'] == true);
    final likesCount = _likesCountOverride[postId] ?? likes;
    final isBookmarked = _bookmarkedPosts[postId] ?? false;

    String likesStr = likesCount.toString();
    if (likesCount >= 1000) {
      final str = likesCount.toString();
      likesStr = '${str.substring(0, str.length - 3)},${str.substring(str.length - 3)}';
    }

    final isCommentsExpanded = _commentsExpanded[postId] ?? false;
    final commentsList = _customComments[postId];
    final commentsCount = commentsList != null ? commentsList.length : comments;

    return Container(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Milestone banner if present
          if (milestone != null && milestone.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFDBEAFE))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, size: 16, color: Color(0xFF1D9BF0)),
                  const SizedBox(width: 6),
                  Text(
                    milestone,
                    style: const TextStyle(
                      color: Color(0xFF1D9BF0),
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),

          // Author Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatar(
                  initials: authorInitials,
                  bgColor: Color(authorBgColor),
                  size: 36,
                  isMITS: isMITSOfficial,
                  avatarAsset: mainAvatarAsset,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCollab ? '$authorName × $collabName' : authorName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: textMain,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (timeAgo.isNotEmpty)
                        Text(
                          timeAgo,
                          style: TextStyle(color: textSub, fontSize: 11),
                        ),
                    ],
                  ),
                ),
                if (!isAuthor)
                  _buildFollowButton(
                    postAuthorId ?? authorName,
                    authorName: authorName,
                    authorId: postAuthorId,
                    textSub: textSub,
                  ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _showPostOptions(
                    postId: postId,
                    authorName: authorName,
                    authorHeadline: authorSubtitle,
                    mainAvatarAsset: mainAvatarAsset,
                    content: content,
                    postImageUrl: postImageUrl,
                    isAuthor: isAuthor,
                  ),
                  child: Icon(Icons.more_vert, color: textSub, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Post Content
          if (content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: _buildExpandableContent(postId, content, textMain),
            ),
          if (content.isNotEmpty) const SizedBox(height: 10),

          // Media Image if present
          if (imageBytes != null || (postImageUrl != null && postImageUrl.isNotEmpty)) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: GestureDetector(
                onTap: () => _openPostDetail(post, authorName, timeAgo, content),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildPostMediaWidget(postImageUrl, imageBytes),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Location and tagged people
          if ((location != null && location.isNotEmpty) || (taggedPeople != null && taggedPeople.isNotEmpty)) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  if (location != null && location.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.location_solid, size: 13, color: Color(0xFF1D9BF0)),
                        const SizedBox(width: 4),
                        Text(location, style: const TextStyle(fontSize: 12, color: Color(0xFF1D9BF0), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  if (taggedPeople != null && taggedPeople.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.person_2_fill, size: 13, color: Color(0xFF1D9BF0)),
                        const SizedBox(width: 4),
                        Text('with ${taggedPeople.join(', ')}', style: const TextStyle(fontSize: 12, color: Color(0xFF1D9BF0), fontWeight: FontWeight.w600)),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Action Row (Likes, Comments, Bookmark)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Heart icon
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isLiked) {
                            _likedPosts[postId] = false;
                            _likesCountOverride[postId] = likesCount - 1;
                          } else {
                            _likedPosts[postId] = true;
                            _likesCountOverride[postId] = likesCount + 1;
                          }
                        });
                        PostService.toggleLike(postId, isLiked);
                      },
                      child: Icon(
                        isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                        size: 24,
                        color: isLiked ? Colors.red : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      likesStr,
                      style: TextStyle(
                        color: iconColor,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Comment icon
                    GestureDetector(
                      onTap: () async {
                        final willExpand = !isCommentsExpanded;
                        setState(() {
                          _commentsExpanded[postId] = willExpand;
                          _activeCommentPostId = willExpand ? postId : null;
                        });
                        if (willExpand && (!_customComments.containsKey(postId) || _customComments[postId]!.isEmpty)) {
                          final fetched = await PostService.getComments(postId);
                          if (mounted) {
                            setState(() {
                              _customComments[postId] = fetched.map((c) => {
                                'id': c['id'],
                                'name': c['authorName'] ?? 'Acadyk Member',
                                'headline': c['authorHeadline'] ?? '',
                                'avatar': c['authorAvatar'] ?? '',
                                'timeText': c['timeAgo'] ?? 'Just now',
                                'body': c['content'] ?? '',
                                'likes': c['likes'] ?? 0,
                                'hasLiked': c['isLiked'] ?? false,
                              }).toList();
                            });
                          }
                        }
                      },
                      child: Icon(
                        isCommentsExpanded ? CupertinoIcons.chat_bubble_fill : CupertinoIcons.chat_bubble,
                        size: 24,
                        color: isCommentsExpanded ? const Color(0xFF0A66C2) : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      commentsCount.toString(),
                      style: TextStyle(
                        color: iconColor,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _bookmarkedPosts[postId] = !isBookmarked;
                    });
                    PostService.toggleBookmark(postId, isBookmarked);
                  },
                  child: Icon(
                    isBookmarked ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
                    size: 24,
                    color: isBookmarked ? const Color(0xFF1E88E5) : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ],
            ),
          ),

          // Inline Comments accordion
          if (isCommentsExpanded) _buildInlineComments(postId, isDark, textMain, textSub),
        ],
      ),
    );
  }

  Widget _buildPostMediaWidget(String? postImageUrl, dynamic imageBytes) {
    if (imageBytes != null && imageBytes is Uint8List) {
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    }
    if (postImageUrl != null && postImageUrl.isNotEmpty) {
      if (postImageUrl.startsWith('data:image/') || postImageUrl.contains(';base64,')) {
        try {
          final base64String = postImageUrl.split(';base64,').last;
          final bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          );
        } catch (_) {}
      }
      if (postImageUrl.startsWith('http://') || postImageUrl.startsWith('https://')) {
        return Image.network(
          postImageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        );
      }
      if (postImageUrl.startsWith('assets/')) {
        return Image.asset(
          postImageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        );
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildAvatar({
    required String initials,
    required Color bgColor,
    required double size,
    required bool isMITS,
    String? avatarAsset,
  }) {
    if (avatarAsset != null && avatarAsset.isNotEmpty) {
      final ImageProvider? imageProvider = avatarAsset.startsWith('http')
          ? NetworkImage(avatarAsset)
          : (avatarAsset.startsWith('assets/') ? AssetImage(avatarAsset) as ImageProvider : null);
      if (imageProvider != null) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    }
    if (isMITS) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage('assets/images/mits_logo.png'),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials.length > 2 ? initials.substring(0, 2) : initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.35,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildExpandableContent(String postId, String content, Color textMain) {
    final isExpanded = _expandedContent[postId] ?? false;
    const int maxLength = 200;
    final bool needsTruncation = content.length > maxLength;

    if (!needsTruncation || isExpanded) {
      return Text(
        content,
        style: TextStyle(
          color: textMain,
          fontSize: 14,
          height: 1.4,
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedContent[postId] = true;
        });
      },
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: textMain,
            fontSize: 14,
            height: 1.4,
          ),
          children: [
            TextSpan(text: content.substring(0, maxLength)),
            const TextSpan(
              text: '... see more',
              style: TextStyle(
                color: Color(0xFF0A66C2),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowButton(String id, {required String authorName, String? authorId, required Color textSub}) {
    final bool isFollowing = FollowService.getFollowState(authorId ?? id);
    if (isFollowing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: textSub.withValues(alpha: 0.4)),
        ),
        child: Text(
          'Following',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSub),
        ),
      );
    }
    return GestureDetector(
      onTap: () async {
        await FollowService.toggleFollow(authorId ?? id, isFollowing);
        if (mounted) setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0A66C2).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 14, color: Color(0xFF0A66C2)),
            SizedBox(width: 2),
            Text(
              'Follow',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0A66C2)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineComments(String postId, bool isDark, Color textMain, Color textSub) {
    final comments = _customComments[postId] ?? [];
    return Container(
      color: isDark ? const Color(0xFF111317) : const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (comments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  'No comments yet. Be the first to comment!',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                ),
              ),
            )
          else
            for (final c in comments)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFF0F4C81),
                      child: Text(
                        (c['name'] as String? ?? 'U').isNotEmpty ? (c['name'] as String)[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c['name']?.toString() ?? 'Acadyk Member',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: textMain),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              c['body']?.toString() ?? '',
                              style: TextStyle(fontSize: 13, color: textMain),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

          // Comment input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentInputController,
                  style: TextStyle(fontSize: 13, color: textMain),
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: TextStyle(color: textSub, fontSize: 13),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF0A66C2), size: 20),
                onPressed: () {
                  final text = _commentInputController.text.trim();
                  if (text.isEmpty) return;
                  final currentUserName = ProfileManager.name.isNotEmpty ? ProfileManager.name : 'Developer';
                  setState(() {
                    _customComments.putIfAbsent(postId, () => []).add({
                      'id': UniqueKey().toString(),
                      'name': currentUserName,
                      'body': text,
                      'timeText': 'Just now',
                    });
                    _commentInputController.clear();
                  });
                  PostService.addComment(postId, text);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openPostDetail(Map<String, dynamic> post, String authorName, String timeAgo, String content) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(
          authorName: authorName,
          authorHeadline: widget.userBio,
          authorAvatar: widget.userAvatar,
          timeAgo: timeAgo,
          postText: content,
          post: post,
        ),
      ),
    );
  }

  void _showPostOptions({
    required String postId,
    required String authorName,
    required String authorHeadline,
    required String mainAvatarAsset,
    required String content,
    required String? postImageUrl,
    required bool isAuthor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF000000) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final handleColor = isDark ? const Color(0xFF333639) : const Color(0xFFE2E8F0);

    if (isAuthor) {
      showModalBottomSheet(
        context: context,
        backgroundColor: sheetBg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(color: handleColor, borderRadius: BorderRadius.circular(2)),
                  ),
                  _buildOptionTile('Pin to profile', textColor, () {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pinned to your profile'), behavior: SnackBarBehavior.floating));
                  }),
                  _buildOptionTile('Content disclosure', textColor, () {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content disclosure settings updated'), behavior: SnackBarBehavior.floating));
                  }),
                  _buildOptionTile('Delete post', textColor, () {
                    Navigator.pop(sheetContext);
                    _confirmDelete(postId);
                  }),
                  _buildOptionTile('Change who can reply', textColor, () {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reply permissions set to Everyone'), behavior: SnackBarBehavior.floating));
                  }),
                  _buildOptionTile('Request Community Note', textColor, () {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Community Note request submitted'), behavior: SnackBarBehavior.floating));
                  }),
                  _buildOptionTile('View Hidden Replies', textColor, () {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hidden replies on this post'), behavior: SnackBarBehavior.floating));
                  }),
                ],
              ),
            ),
          );
        },
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: handleColor, borderRadius: BorderRadius.circular(2)),
                ),
                _buildOptionTile('Repost', textColor, () {
                  Navigator.pop(sheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post reposted to your feed'), behavior: SnackBarBehavior.floating));
                }),
                _buildOptionTile('Share', textColor, () {
                  Navigator.pop(sheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied to clipboard'), behavior: SnackBarBehavior.floating));
                }),
                _buildOptionTile('About this account', textColor, () {
                  Navigator.pop(sheetContext);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AboutAccountScreen(
                        accountData: {
                          'name': authorName,
                          'avatarUrl': mainAvatarAsset,
                          'dateJoined': 'August 2024',
                          'location': 'Gwalior, India',
                          'sharedFollowers': 12,
                        },
                      ),
                    ),
                  );
                }),
                _buildOptionTile('Report', const Color(0xFFED4956), () {
                  Navigator.pop(sheetContext);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportPostScreen()));
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(String title, Color textColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
        child: Text(
          title,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: textColor, letterSpacing: -0.2),
        ),
      ),
    );
  }

  void _confirmDelete(String postId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF16181C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete post?', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        content: const Text('This can’t be undone and it will be removed from your profile and search results.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() {
                _posts.removeWhere((p) => p['id']?.toString() == postId);
              });
              await PostService.deletePost(postId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your post was deleted'), behavior: SnackBarBehavior.floating));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
