import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:acadyk/common/services/post_service.dart';
import 'package:acadyk/common/services/auth_service.dart';
import 'package:acadyk/common/services/follow_service.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../profile/presentation/screens/about_account_screen.dart';
import '../../../profile/presentation/services/profile_manager.dart';


class PostDetailScreen extends StatefulWidget {
  final String authorName;
  final String authorHeadline;
  final String authorAvatar;
  final String timeAgo;
  final String postText;
  final String? connectionDegree;
  final Map<String, dynamic>? post;

  const PostDetailScreen({
    super.key,
    required this.authorName,
    required this.authorHeadline,
    required this.authorAvatar,
    required this.timeAgo,
    required this.postText,
    this.connectionDegree,
    this.post,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool _isPostLiked = false;
  int _postLikesCount = 0;
  bool _isPostBookmarked = false;

  // Replying state
  Map<String, dynamic>? _replyingToCommentNode;
  String? _replyingToName;

  final TextEditingController _commentInputCtrl = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  late List<Map<String, dynamic>> _comments;

  String get _currentUserName => ProfileManager.name.isNotEmpty
      ? ProfileManager.name
      : (AuthService.currentUser?.fullName?.isNotEmpty == true ? AuthService.currentUser!.fullName! : 'Developer');

  String get _currentUserHeadline => ProfileManager.summary.isNotEmpty
      ? ProfileManager.summary
      : (ProfileManager.bio.isNotEmpty ? ProfileManager.bio : 'Student @ Acadyk');

  String get _currentUserAvatar => ProfileManager.avatarUrl.isNotEmpty
      ? ProfileManager.avatarUrl
      : '';

  @override
  void initState() {
    super.initState();
    _comments = [];
    final rawLikes = widget.post?['likes'] ?? widget.post?['likesCount'] ?? 0;
    _postLikesCount = rawLikes is num ? rawLikes.toInt() : (int.tryParse(rawLikes.toString()) ?? 0);
    _isPostLiked = widget.post?['isLiked'] == true || (widget.post != null && PostService.isLiked(widget.post!['id'].toString()));
    _isPostBookmarked = widget.post?['isBookmarked'] == true || (widget.post != null && PostService.isBookmarked(widget.post!['id'].toString()));
    if (widget.post != null) {
      _loadRealComments();
    }
  }

  void _loadRealComments() async {
    if (widget.post == null) return;
    final dbComments = await PostService.getComments(widget.post!['id'].toString());
    if (mounted) {
      final topLevelList = dbComments.map((c) {
        return {
          'id': c['id']?.toString() ?? '',
          'name': c['authorName'] ?? 'Acadyk Member',
          'isAuthor': (c['authorId'] != null && c['authorId'] == widget.post!['authorId']) ||
              (c['authorName'] != null && c['authorName'] == widget.authorName) ||
              (c['isAuthor'] == true),
          'headline': c['authorHeadline'] ?? '',
          'avatar': c['authorAvatar'] ?? '',
          'timeAgo': c['timeAgo'] ?? 'Just now',
          'connectionDegree': '1st',
          'body': c['content'] ?? '',
          'likes': c['likes'] ?? 0,
          'hasLiked': c['isLiked'] ?? false,
          'replies': <Map<String, dynamic>>[],
        };
      }).toList();

      setState(() {
        _comments = topLevelList;
      });
    }
  }

  int _countAllComments(List<dynamic> list) {
    int total = 0;
    for (final item in list) {
      if (item is Map) {
        total += 1;
        final reps = item['replies'];
        if (reps is List && reps.isNotEmpty) {
          total += _countAllComments(reps);
        }
      }
    }
    return total;
  }

  void _submitComment(String text) async {
    final currentUserName = _currentUserName;
    final currentUserHeadline = _currentUserHeadline;
    final currentUserAvatar = _currentUserAvatar;

    final bool isPostAuthor = (widget.authorName.trim().isNotEmpty && widget.authorName.trim().toLowerCase() == currentUserName.trim().toLowerCase()) ||
        (widget.authorName.toLowerCase() == AuthService.currentUser?.username?.toLowerCase());

    if (widget.post != null) {
      String? parentId;
      if (_replyingToCommentNode != null) {
        parentId = _replyingToCommentNode!['id']?.toString();
      }
      final replyText = (_replyingToName != null && _replyingToCommentNode != null && _replyingToName != _replyingToCommentNode!['name'])
          ? '$_replyingToName $text'
          : text;

      await PostService.addComment(widget.post!['id'].toString(), replyText, parentId: parentId);
      setState(() {
        _replyingToCommentNode = null;
        _replyingToName = null;
      });
      _loadRealComments();
    } else {
      setState(() {
        if (_replyingToCommentNode != null) {
          if (_replyingToCommentNode!['replies'] == null || _replyingToCommentNode!['replies'] is! List) {
            _replyingToCommentNode!['replies'] = <Map<String, dynamic>>[];
          }
          final replies = _replyingToCommentNode!['replies'] as List;
          final replyText = (_replyingToName != null && _replyingToName != _replyingToCommentNode!['name'])
              ? '$_replyingToName $text'
              : text;
          replies.add({
            'id': 'reply_${DateTime.now().millisecondsSinceEpoch}',
            'name': currentUserName,
            'isAuthor': isPostAuthor,
            'headline': currentUserHeadline,
            'avatar': currentUserAvatar,
            'timeAgo': 'Just now',
            'connectionDegree': '1st',
            'body': replyText,
            'likes': 0,
            'hasLiked': false,
            'replies': <Map<String, dynamic>>[],
          });
          _replyingToCommentNode = null;
          _replyingToName = null;
        } else {
          _comments.add({
            'id': 'comment_${DateTime.now().millisecondsSinceEpoch}',
            'name': currentUserName,
            'isAuthor': isPostAuthor,
            'headline': currentUserHeadline,
            'avatar': currentUserAvatar,
            'timeAgo': 'Just now',
            'connectionDegree': '1st',
            'body': text,
            'likes': 0,
            'hasLiked': false,
            'replies': <Map<String, dynamic>>[],
          });
        }
      });
    }
    _commentInputCtrl.clear();
  }

  @override
  void dispose() {
    _commentInputCtrl.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  int get _totalCommentsCount {
    return _countAllComments(_comments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: Colors.white,
            child: Column(
              children: [
                // Top bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF191919)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Color(0xFF5E5E5E), size: 24),
                        onPressed: () => _showPostOptionsBottomSheet(context),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),

                // Scrollable content: Post + Comments
                Expanded(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      // ============================
                      // POST AUTHOR HEADER
                      // ============================
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar
                            GestureDetector(
                              onTap: () {
                                final isOwn = (ProfileManager.name.isNotEmpty && widget.authorName == ProfileManager.name) || 
                                              (AuthService.currentUser?.fullName?.isNotEmpty == true && widget.authorName == AuthService.currentUser!.fullName);
                                Navigator.push(
                                   context,
                                   MaterialPageRoute(
                                     builder: (_) => ProfileScreen(
                                       isOwnProfile: isOwn,
                                     ),
                                   ),
                                 );
                               },
                              child: ClipOval(
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  color: const Color(0xFF3B82F6),
                                  child: widget.authorAvatar.startsWith('http')
                                      ? Image.network(
                                          widget.authorAvatar,
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Center(
                                            child: Text(
                                              widget.authorName.isNotEmpty ? widget.authorName[0] : 'A',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                            ),
                                          ),
                                        )
                                      : Image.asset(
                                          widget.authorAvatar.isNotEmpty ? widget.authorAvatar : 'assets/images/user_avatar.jpg',
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Center(
                                            child: Text(
                                              widget.authorName.isNotEmpty ? widget.authorName[0] : 'A',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: GestureDetector(
                                          onTap: () {
                                            final isOwn = (ProfileManager.name.isNotEmpty && widget.authorName == ProfileManager.name) || 
                                                          (AuthService.currentUser?.fullName?.isNotEmpty == true && widget.authorName == AuthService.currentUser!.fullName);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => ProfileScreen(
                                                  isOwnProfile: isOwn,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            widget.authorName,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF191919),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),

                                      if (widget.connectionDegree != null) ...[
                                        const SizedBox(width: 4),
                                        Text(
                                          '• ${widget.connectionDegree}',
                                          style: const TextStyle(color: Color(0xFF5E5E5E), fontSize: 13),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        widget.timeAgo,
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF5E5E5E)),
                                      ),
                                      const Text(' • ', style: TextStyle(color: Color(0xFF5E5E5E), fontSize: 12)),
                                      const Icon(Icons.public, size: 12, color: Color(0xFF5E5E5E)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Follow button (hidden if user is the author of this post)
                            Builder(
                              builder: (context) {
                                final currentUserId = AuthService.currentUser?.id;
                                final currentUsername = AuthService.currentUser?.username?.replaceAll('@', '').toLowerCase();
                                final currentProfileName = ProfileManager.name.trim().toLowerCase();

                                final postAuthorId = widget.post?['author']?['id']?.toString() ?? widget.post?['authorId']?.toString();
                                final postAuthorUsername = (widget.post?['author']?['username'] ?? widget.post?['authorHandle'] ?? '').toString().replaceAll('@', '').toLowerCase();
                                final postAuthorName = (widget.authorName).trim().toLowerCase();

                                final bool isAuthor = (currentUserId != null && postAuthorId != null && currentUserId == postAuthorId) ||
                                    (currentUsername != null && currentUsername.isNotEmpty && postAuthorUsername == currentUsername) ||
                                    (currentProfileName.isNotEmpty && postAuthorName == currentProfileName);

                                if (isAuthor) {
                                  return const SizedBox.shrink();
                                }

                                final targetAuthorId = postAuthorId ?? (postAuthorUsername.isNotEmpty ? postAuthorUsername : widget.authorName);
                                final bool isFollowing = FollowService.getFollowState(targetAuthorId);

                                return TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      FollowService.toggleFollow(targetAuthorId, isFollowing);
                                    });
                                  },
                                  icon: Icon(
                                    isFollowing ? Icons.check : Icons.add,
                                    size: 16,
                                    color: isFollowing ? const Color(0xFF64748B) : const Color(0xFF0A66C2),
                                  ),
                                  label: Text(
                                    isFollowing ? 'Following' : 'Follow',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isFollowing ? const Color(0xFF64748B) : const Color(0xFF0A66C2),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ============================
                      // FULL POST TEXT
                      // ============================
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: widget.postText.isNotEmpty
                            ? Text(
                                widget.postText,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  color: Color(0xFF191919),
                                  height: 1.55,
                                ),
                              )
                            : RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    color: Color(0xFF191919),
                                    height: 1.55,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'We raised \$4.3M, led by ',
                                    ),
                                    const TextSpan(
                                      text: 'Pantera Capital',
                                      style: TextStyle(
                                        color: Color(0xFF0A66C2),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(text: '.\n\n'),
                                    const TextSpan(
                                      text: 'Soon, there will be more agents than people online. Those agents will book flights, hire contractors, enrich customer data, conduct research, and complete transactions without a human in the loop. But today, agents are stuck with whatever tools they were originally given. The moment they need something new, they fail, hallucinate, or hand the problem back to a human.\n\n',
                                    ),
                                    const TextSpan(
                                      text: 'Orthogonal fixes this. Through a single integration, agents can discover the capabilities they need in the moment, orchestrate them, and pay for them instantly. An agent describes what it wants, and Orthogonal composes the result, calling the right services in the right order.\n\n',
                                    ),
                                    const TextSpan(
                                      text: 'Our goal is simple: when an agent needs a capability it doesn\'t already have, Orthogonal will be the first place it goes.\n\n',
                                    ),
                                    const TextSpan(text: 'Thanks to '),
                                    const TextSpan(
                                      text: 'Pantera Capital',
                                      style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                                    ),
                                    const TextSpan(text: ', '),
                                    const TextSpan(
                                      text: 'Y Combinator',
                                      style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                                    ),
                                    const TextSpan(text: ', '),
                                    const TextSpan(
                                      text: 'Pioneer Fund',
                                      style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                                    ),
                                    const TextSpan(text: ', '),
                                    const TextSpan(
                                      text: 'Decasonic',
                                      style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                                    ),
                                    const TextSpan(text: ', '),
                                    const TextSpan(
                                      text: 'Blast Club',
                                      style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                                    ),
                                    const TextSpan(text: ', '),
                                    const TextSpan(
                                      text: 'Outbound Capital',
                                      style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                                    ),
                                    const TextSpan(text: ', Rice Capital ('),
                                    const TextSpan(
                                      text: 'Taro Fukuyama',
                                      style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                                    ),
                                    const TextSpan(text: '), Surreal by Premise ('),
                                    const TextSpan(
                                      text: 'Mercedes Bent',
                                      style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                                    ),
                                    const TextSpan(text: ' & '),
                                    const TextSpan(
                                      text: 'Vanessa Larco',
                                      style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                                    ),
                                    const TextSpan(text: '), '),
                                    const TextSpan(
                                      text: 'Batch Ventures',
                                      style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                                    ),
                                    const TextSpan(
                                      text: ' (CTO Fund), and our strategic investors for backing us. We\'re building the default front door for the internet.',
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      if (widget.post != null && widget.post!['image_url'] != null && widget.post!['image_url'].toString().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              widget.post!['image_url'],
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Action/Engagement row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    final current = _isPostLiked;
                                    setState(() {
                                      _isPostLiked = !current;
                                      _postLikesCount += _isPostLiked ? 1 : -1;
                                    });
                                    if (widget.post != null) {
                                      PostService.toggleLike(widget.post!['id'].toString(), current);
                                    }
                                  },
                                  child: Icon(
                                    _isPostLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                    size: 24,
                                    color: _isPostLiked ? Colors.red : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _postLikesCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () {
                                    _commentFocusNode.requestFocus();
                                  },
                                  child: const Icon(CupertinoIcons.chat_bubble, size: 24, color: Colors.black87),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _totalCommentsCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                final current = _isPostBookmarked;
                                setState(() {
                                  _isPostBookmarked = !current;
                                });
                                if (widget.post != null) {
                                  PostService.toggleBookmark(widget.post!['id'].toString(), current);
                                }
                              },
                              child: Icon(
                                _isPostBookmarked ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
                                size: 24,
                                color: _isPostBookmarked ? const Color(0xFF1E88E5) : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFE0E0E0)),

                      // ============================
                      // COMMENTS SECTION
                      // ============================
                      const SizedBox(height: 8),

                      // Comments list builder
                      for (int i = 0; i < _comments.length; i++)
                        _buildCommentTreeNode(
                          comment: _comments[i],
                          depth: 0,
                          isLast: i == _comments.length - 1,
                        ),

                      const SizedBox(height: 80), // Space for bottom bar
                    ],
                  ),
                ),

                // ============================
                // FIXED BOTTOM COMMENT INPUT
                // ============================
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_replyingToCommentNode != null)
                        Container(
                          color: const Color(0xFFF3F2EF),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Text(
                                'Replying to ${_replyingToName ?? _replyingToCommentNode!['name'] ?? 'comment'}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF5E5E5E), fontWeight: FontWeight.w500),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _replyingToCommentNode = null;
                                    _replyingToName = null;
                                  });
                                },
                                child: const Icon(Icons.close, size: 16, color: Color(0xFF5E5E5E)),
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            // User avatar
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFF0F4C81),
                              backgroundImage: _currentUserAvatar.isNotEmpty
                                  ? (_currentUserAvatar.startsWith('http')
                                      ? NetworkImage(_currentUserAvatar)
                                      : (_currentUserAvatar.startsWith('assets/') ? AssetImage(_currentUserAvatar) as ImageProvider : null))
                                  : null,
                              child: (_currentUserAvatar.isEmpty || (!_currentUserAvatar.startsWith('http') && !_currentUserAvatar.startsWith('assets/')))
                                  ? Text(
                                      _currentUserName.isNotEmpty ? _currentUserName.substring(0, 1).toUpperCase() : 'U',
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF5E5E5E)),
                            const SizedBox(width: 8),
                            // Comment input
                            Expanded(
                              child: Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F2EF),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                alignment: Alignment.centerLeft,
                                child: TextField(
                                  controller: _commentInputCtrl,
                                  focusNode: _commentFocusNode,
                                  decoration: InputDecoration(
                                    hintText: _replyingToCommentNode != null ? 'Add a reply...' : 'Add a comment...',
                                    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF5E5E5E)),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  style: const TextStyle(fontSize: 14, color: Colors.black),
                                  onSubmitted: (val) {
                                    if (val.trim().isNotEmpty) {
                                      _submitComment(val.trim());
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Send button
                            GestureDetector(
                              onTap: () {
                                final val = _commentInputCtrl.text;
                                if (val.trim().isNotEmpty) {
                                  _submitComment(val.trim());
                                }
                              },
                              child: const Icon(Icons.send, color: Color(0xFF0A66C2), size: 22),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildCommentBodyText(String body) {
    return Text(
      body,
      style: const TextStyle(color: Color(0xFF191919), fontSize: 14, height: 1.45),
    );
  }

  // ============================
  // COMMENT BUILDER
  // ============================
  Widget _buildCommentTreeNode({
    required Map<String, dynamic> comment,
    required int depth,
    required bool isLast,
  }) {
    final replies = (comment['replies'] is List) ? (comment['replies'] as List<dynamic>) : <dynamic>[];
    final hasReplies = replies.isNotEmpty;

    final avatarStr = (comment['avatar'] ?? '') as String;
    final ImageProvider? commentAvatarProvider = avatarStr.isNotEmpty
        ? (avatarStr.startsWith('http')
            ? NetworkImage(avatarStr)
            : (avatarStr.startsWith('assets/') ? AssetImage(avatarStr) as ImageProvider : null))
        : null;
    final commentInitials = (comment['name'] != null && (comment['name'] as String).isNotEmpty)
        ? (comment['name'] as String).substring(0, 1).toUpperCase()
        : 'U';

    final double indent = _NestedReplyThreadPainter.getLeftIndent(depth);
    final double avatarRadius = depth == 0 ? 18.0 : 14.0;
    final double avatarCenterX = _NestedReplyThreadPainter.getAvatarCenterX(depth);

    Widget nodeContent = Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        depth == 0 ? 8 : 6,
        16,
        hasReplies ? 0 : (depth == 0 ? 12.0 : (isLast ? 12.0 : 6.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomPaint(
            painter: _NodeTrunkPainter(
              centerX: avatarCenterX,
              startY: depth == 0 ? 38.0 : 30.0,
              hasReplies: hasReplies,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (depth > 0) SizedBox(width: indent),
                SizedBox(
                  width: depth == 0 ? 46.0 : (avatarRadius * 2 + 8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: const Color(0xFF0F4C81),
                      backgroundImage: commentAvatarProvider,
                      onBackgroundImageError: commentAvatarProvider != null ? (_, __) {} : null,
                      child: commentAvatarProvider == null
                          ? Text(
                              commentInitials,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: depth == 0 ? 13 : 10,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          comment['name'] ?? _currentUserName,
                                          style: TextStyle(
                                            fontSize: depth == 0 ? 13.5 : 12.5,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF191919),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (comment['isAuthor'] == true) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE0F2FE),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: const Color(0xFFBAE6FD), width: 0.8),
                                          ),
                                          child: const Text(
                                            'Author',
                                            style: TextStyle(
                                              color: Color(0xFF0369A1),
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if ((comment['headline'] ?? '').toString().isNotEmpty)
                                    Text(
                                      comment['headline'] ?? '',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF5E5E5E)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              comment['timeAgo'] ?? 'Just now',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF5E5E5E)),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.more_vert, size: 16, color: Color(0xFF5E5E5E)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildCommentBodyText(comment['body'] ?? ''),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (comment['hasLiked'] == true) {
                                    comment['hasLiked'] = false;
                                    comment['likes'] = ((comment['likes'] ?? 1) as int) - 1;
                                  } else {
                                    comment['hasLiked'] = true;
                                    comment['likes'] = ((comment['likes'] ?? 0) as int) + 1;
                                  }
                                });
                              },
                              child: Text(
                                'Like',
                                style: TextStyle(
                                  fontSize: depth == 0 ? 12 : 11,
                                  fontWeight: FontWeight.bold,
                                  color: comment['hasLiked'] == true ? const Color(0xFF0A66C2) : const Color(0xFF5E5E5E),
                                ),
                              ),
                            ),
                            if (comment['likes'] != null && (comment['likes'] as int) > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(color: Color(0xFF0A66C2), shape: BoxShape.circle),
                                child: const Icon(Icons.thumb_up, size: 8, color: Colors.white),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                comment['likes'].toString(),
                                style: TextStyle(fontSize: depth == 0 ? 11 : 10, color: const Color(0xFF5E5E5E)),
                              ),
                            ],
                            const SizedBox(width: 14),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _replyingToCommentNode = comment;
                                  _replyingToName = comment['name'];
                                  _commentFocusNode.requestFocus();
                                });
                              },
                              child: Text(
                                'Reply',
                                style: TextStyle(
                                  fontSize: depth == 0 ? 12 : 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF5E5E5E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Render Nested Child Replies Recursively
          if (hasReplies)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < replies.length; i++)
                  _buildCommentTreeNode(
                    comment: replies[i] as Map<String, dynamic>,
                    depth: depth + 1,
                    isLast: i == replies.length - 1,
                  ),
              ],
            ),
        ],
      ),
    );

    if (depth > 0) {
      return CustomPaint(
        painter: _NestedReplyThreadPainter(depth: depth, isLast: isLast),
        child: nodeContent,
      );
    } else {
      return nodeContent;
    }
  }

  void _showPostOptionsBottomSheet(BuildContext context) {
    final postId = widget.post?['id']?.toString() ?? 'detail_post';
    final isSaved = _isPostBookmarked;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF000000) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final iconColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);
    final handleColor = isDark ? const Color(0xFF333639) : const Color(0xFFE2E8F0);

    final currentUserId = AuthService.currentUser?.id;
    final currentUsername = AuthService.currentUser?.username?.replaceAll('@', '').toLowerCase();
    final currentProfileName = ProfileManager.name.trim().toLowerCase();

    final postAuthorId = widget.post?['author']?['id']?.toString() ?? widget.post?['authorId']?.toString();
    final postAuthorUsername = (widget.post?['author']?['username'] ?? widget.post?['authorHandle'] ?? '').toString().replaceAll('@', '').toLowerCase();
    final postAuthorName = (widget.authorName).trim().toLowerCase();

    final bool isAuthor = (currentUserId != null && postAuthorId != null && currentUserId == postAuthorId) ||
        (currentUsername != null && currentUsername.isNotEmpty && postAuthorUsername == currentUsername) ||
        (currentProfileName.isNotEmpty && postAuthorName == currentProfileName);

    if (isAuthor) {
      showModalBottomSheet(
        context: context,
        backgroundColor: sheetBg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext sheetContext) {
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
                    decoration: BoxDecoration(
                      color: handleColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  _buildAuthorMenuTile(
                    title: 'Pin to profile',
                    textColor: textColor,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pinned to your profile'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _buildAuthorMenuTile(
                    title: 'Content disclosure',
                    textColor: textColor,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Content disclosure settings updated'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _buildAuthorMenuTile(
                    title: 'Delete post',
                    textColor: textColor,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _confirmDeleteFromDetail(context, postId);
                    },
                  ),
                  _buildAuthorMenuTile(
                    title: 'Change who can reply',
                    textColor: textColor,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reply permissions set to Everyone'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _buildAuthorMenuTile(
                    title: 'Request Community Note',
                    textColor: textColor,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Community Note request submitted'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _buildAuthorMenuTile(
                    title: 'View Hidden Replies',
                    textColor: textColor,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No hidden replies on this post'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: handleColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTopActionIcon(
                      isSaved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
                      'Save',
                      color: isSaved ? const Color(0xFF1E88E5) : (isDark ? Colors.white : Colors.black),
                      onTap: () {
                        setState(() {
                          _isPostBookmarked = !_isPostBookmarked;
                        });
                        PostService.toggleBookmark(postId, _isPostBookmarked);
                        Navigator.pop(sheetContext);
                      },
                    ),
                    _buildTopActionIcon(
                      CupertinoIcons.paperplane,
                      'Share',
                      color: isDark ? Colors.white : Colors.black,
                      onTap: () {
                        Navigator.pop(sheetContext);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      _buildListAction(CupertinoIcons.eye_slash, 'Hide', onTap: () {
                        Navigator.pop(sheetContext);
                        _showHidePostOptions(context);
                      }),
                      const SizedBox(height: 20),
                      _buildListAction(CupertinoIcons.person, 'About this account', onTap: () {
                        Navigator.pop(sheetContext);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AboutAccountScreen(
                              accountData: {
                                'name': widget.authorName,
                                'avatarUrl': widget.authorAvatar,
                                'dateJoined': 'August 2024',
                                'location': 'Gwalior, India',
                                'sharedFollowers': 12,
                              },
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuthorMenuTile({
    required String title,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            color: textColor,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  void _confirmDeleteFromDetail(BuildContext context, String postId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF16181C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete post?',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          'This can’t be undone and it will be removed from your profile, the timeline of any accounts that follow you, and from search results.',
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await PostService.deletePost(postId);
              if (context.mounted) {
                Navigator.of(context).pop(); // Exit PostDetailScreen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your post was deleted', style: TextStyle(color: Colors.white)),
                    backgroundColor: Color(0xFF1F2937),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showHidePostOptions(BuildContext context) {
    final postId = widget.post?['id']?.toString() ?? 'detail_post';
    final authorName = widget.authorName;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                  child: Text(
                    'Hide options',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Customize what you see in your feed',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                const SizedBox(height: 8),

                // Option 1: Hide this post
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(CupertinoIcons.eye_slash, color: Color(0xFF374151), size: 22),
                  ),
                  title: const Text(
                    'Hide this post',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                  ),
                  subtitle: const Text(
                    'See fewer posts like this',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    PostService.hidePost(postId);
                    Navigator.of(context).pop(); // Go back to feed
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Post hidden from your feed', style: TextStyle(color: Colors.white, fontSize: 13.5)),
                        backgroundColor: const Color(0xFF1F2937),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        action: SnackBarAction(
                          label: 'Undo',
                          textColor: const Color(0xFF60A5FA),
                          onPressed: () {
                            PostService.unhidePost(postId);
                          },
                        ),
                      ),
                    );
                  },
                ),

                // Option 2: Hide all posts from this account
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(CupertinoIcons.person_crop_circle_badge_minus, color: Color(0xFFDC2626), size: 22),
                  ),
                  title: Text(
                    'Hide all posts from $authorName',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                  ),
                  subtitle: Text(
                    'You won\'t see any posts from this account',
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    PostService.hideAuthor(authorName);
                    Navigator.of(context).pop(); // Go back to feed
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('All posts from $authorName hidden', style: const TextStyle(color: Colors.white, fontSize: 13.5)),
                        backgroundColor: const Color(0xFF1F2937),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        action: SnackBarAction(
                          label: 'Undo',
                          textColor: const Color(0xFF60A5FA),
                          onPressed: () {
                            PostService.unhideAuthor(authorName);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopActionIcon(IconData icon, String label, {Color color = Colors.black, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget _buildListAction(IconData icon, String label, {Color color = Colors.black, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _NodeTrunkPainter extends CustomPainter {
  final double centerX;
  final double startY;
  final bool hasReplies;

  const _NodeTrunkPainter({
    required this.centerX,
    this.startY = 38.0,
    required this.hasReplies,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!hasReplies) return;
    
    final paint = Paint()
      ..color = const Color(0xFFC7C7C7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    if (size.height > startY) {
      canvas.drawLine(
        Offset(centerX, startY),
        Offset(centerX, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NodeTrunkPainter oldDelegate) =>
      oldDelegate.hasReplies != hasReplies ||
      oldDelegate.centerX != centerX ||
      oldDelegate.startY != startY;
}

class _NestedReplyThreadPainter extends CustomPainter {
  final int depth;
  final bool isLast;

  const _NestedReplyThreadPainter({
    required this.depth,
    required this.isLast,
  });

  static double getAvatarCenterX(int d) {
    if (d <= 0) return 18.0;
    return getLeftIndent(d) + 14.0;
  }

  static double getLeftIndent(int d) {
    if (d <= 0) return 0.0;
    if (d == 1) return 46.0;
    return 46.0 + (min(d - 1, 3)) * 32.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC7C7C7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final double parentX = getAvatarCenterX(depth - 1);
    final double targetX = getLeftIndent(depth);
    const double centerY = 20.0;
    final double radius = min(12.0, (targetX - parentX) > 0 ? (targetX - parentX) : 12.0);

    final elbowPath = Path();
    elbowPath.moveTo(parentX, 0);
    elbowPath.lineTo(parentX, centerY - radius);
    elbowPath.arcToPoint(
      Offset(parentX + radius, centerY),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    elbowPath.lineTo(targetX, centerY);

    canvas.drawPath(elbowPath, paint);

    if (!isLast) {
      final linePath = Path();
      linePath.moveTo(parentX, centerY - radius);
      linePath.lineTo(parentX, size.height);
      canvas.drawPath(linePath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NestedReplyThreadPainter oldDelegate) =>
      oldDelegate.isLast != isLast || oldDelegate.depth != depth;
}

