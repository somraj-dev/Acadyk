import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:acadyk/common/services/post_service.dart';
import 'discover_opportunities_screen.dart';
import 'select_opportunity_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../profile/presentation/screens/edit_status_screen.dart';
import '../../../profile/presentation/screens/about_account_screen.dart';
import '../../../profile/presentation/screens/my_courses_screen.dart';
import 'startup_gallery_screen.dart';
import 'exhibition_screen.dart';
import 'clubs_screen.dart';
import 'create_post_screen.dart';
import '../../../community/presentation/screens/discover_communities_screen.dart';
import '../../../profile/presentation/screens/space_screen.dart';
import '../../../profile/presentation/screens/feedback_form_screen.dart';
import '../../../profile/presentation/screens/student_id_card_screen.dart';
import '../../../profile/presentation/services/profile_manager.dart';
import '../../../../common/services/auth_service.dart';
import '../../../../common/services/follow_service.dart';
import '../../../chat/presentation/screens/message_center_screen.dart';
import '../../../../common/widgets/acadyk_top_header_bar.dart';
import '../../../../shared/widgets/skeleton/skeleton.dart';
class HomeFeedScreen extends StatefulWidget {
  static final GlobalKey<ScaffoldState> mainScaffoldKey = GlobalKey<ScaffoldState>();
  static final ValueNotifier<int> activeTabNotifier = ValueNotifier<int>(0);

  static void openMainDrawer() {
    mainScaffoldKey.currentState?.openDrawer();
  }

  static void switchTab(int tabIndex) {
    activeTabNotifier.value = tabIndex;
  }

  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get scaffoldBg => _isDark ? Color(0xFF000000) : Color(0xFFFFFFFF);
  Color get cardBg => _isDark ? Color(0xFF000000) : Colors.white;
  Color get textMain => _isDark ? Color(0xFFF7F9F9) : Color(0xFF0F1419);
  Color get textSub => _isDark ? Color(0xFF71767B) : Color(0xFF536471);
  Color get iconColor => _isDark ? Colors.white : Colors.black87;
  Color get borderDivider => _isDark ? Color(0xFF2F3336) : Color(0xFFEFF3F4);

  int _activeTab = 0;
  late final PageController _pageController;

  // Dynamic feedback and comment state
  final Map<String, bool> _likedPosts = {};
  final Map<String, int> _likesCountOverride = {};
  final Map<String, bool> _bookmarkedPosts = {};
  final Map<String, bool> _followedAccounts = {};
  final Map<String, bool> _newlyFollowedInSession = {};
  final Map<String, bool> _commentsExpanded = {};
  final Map<String, List<Map<String, dynamic>>> _customComments = {};
  final TextEditingController _commentInputCtrl = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  final List<Map<String, dynamic>> _dynamicReposts = [];

  String? _replyingToPostId;
  Map<String, dynamic>? _replyingToCommentNode;
  String? _replyingToName;

  List<Map<String, dynamic>> _feedPosts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _feedPosts = PostService.getUserCreatedPosts();
    _isLoading = _feedPosts.isEmpty;
    _activeTab = HomeFeedScreen.activeTabNotifier.value;
    _pageController = PageController(initialPage: _activeTab == 4 ? 3 : (_activeTab == 3 ? 2 : _activeTab));
    ProfileManager.profileUpdateNotifier.addListener(_onProfileUpdated);
    PostService.feedChangeNotifier.addListener(_onFeedChanged);
    FollowService.followChangeNotifier.addListener(_onProfileUpdated);
    HomeFeedScreen.activeTabNotifier.addListener(_onTabNotification);
    _loadBackendPosts();
    _setupRealtimeSubscription();
  }

  void _onTabNotification() {
    if (mounted && _activeTab != HomeFeedScreen.activeTabNotifier.value) {
      setState(() {
        _activeTab = HomeFeedScreen.activeTabNotifier.value;
        _newlyFollowedInSession.clear();
      });
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_activeTab);
      }
    }
  }

  void _onFeedChanged() {
    _loadBackendPosts();
  }

  void _onProfileUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    HomeFeedScreen.activeTabNotifier.removeListener(_onTabNotification);
    ProfileManager.profileUpdateNotifier.removeListener(_onProfileUpdated);
    PostService.feedChangeNotifier.removeListener(_onFeedChanged);
    FollowService.followChangeNotifier.removeListener(_onProfileUpdated);
    _pageController.dispose();
    _commentInputCtrl.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _loadBackendPosts() async {
    final posts = await _fetchPostsFromBackend();
    if (mounted) {
      setState(() {
        _feedPosts = posts;
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPostsFromBackend() async {
    try {
      return await PostService.getFeedPosts();
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }

  void _setupRealtimeSubscription() {
    // Realtime posts subscription via WebSocketService
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = theme.scaffoldBackgroundColor;

    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      key: HomeFeedScreen.mainScaffoldKey,
      backgroundColor: scaffoldBg,
      drawer: _buildProfileDrawer(),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: isTablet ? 720 : double.infinity),
            color: scaffoldBg,
            child: Scaffold(
              backgroundColor: scaffoldBg,
              body: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (pageIndex) {
                        setState(() {
                          if (pageIndex == 0) _activeTab = 0;
                          if (pageIndex == 1) _activeTab = 1;
                          if (pageIndex == 2) _activeTab = 3;
                          if (pageIndex == 3) _activeTab = 4;
                        });
                      },
                      children: [
                        // Page 0: Home Feed Screen
                        Column(
                          children: [
                            // 1. Top App Bar (Acadyk)
                            const AcadykTopHeaderBar(title: 'Acadyk'),
                            Divider(height: 1, color: isDark ? const Color(0xFF30363D) : const Color(0xFFE0E0E0)),

                            // 2. Scrollable List of Posts (re-ordered and curated)
                            Expanded(
                              child: Container(
                                color: const Color(0xFFF3F2EF),
                                child: RefreshIndicator(
                                  onRefresh: () async {
                                    final posts = await _fetchPostsFromBackend();
                                    if (mounted) {
                                      setState(() {
                                        _feedPosts = posts;
                                        _isLoading = false;
                                      });
                                    }
                                  },
                                  child: ListView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      // Live Twitter-style Posting Progress Card
                                      _buildPostingProgressCard(),

                                      if (_isLoading)
                                        const FeedSkeleton()
                                      else if (_feedPosts.isEmpty)
                                        _buildEmptyFeedState()
                                      else ...[
                                        ..._feedPosts.map((post) => _buildPostCard(post)),
                                      ],

                                      const SizedBox(height: 16.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Page 1: Opportunities
                        const DiscoverOpportunitiesScreen(),

                        // Page 2: Chat
                        const MessageCenterScreen(),

                        // Page 3: Profile
                        const ProfileScreen(isOwnProfile: true),
                      ],
                    ),
                  ),

                  // 3. Bottom Tab Bar
                  Divider(height: 1, color: isDark ? const Color(0xFF30363D) : const Color(0xFFE0E0E0)),
                  _buildBottomNavBar(),
                ],
              ),
          ),
          ),
        ),
      ),
    );
  }
  // -------------------------------------------------------------
  // REUSABLE FEEDBACK ACTION ROW WITH COMMENTS ACCORDION
  // -------------------------------------------------------------

  Widget _buildPostActionRow({
    required String postId,
    required int defaultLikes,
    required int defaultComments,
  }) {
    final isLiked = _likedPosts[postId] ?? false;
    final likesCount = _likesCountOverride[postId] ?? defaultLikes;
    final isBookmarked = _bookmarkedPosts[postId] ?? false;
    
    // Real comments count calculation
    final commentsList = _customComments[postId];
    final commentsCount = commentsList != null ? _countAllComments(commentsList) : defaultComments;

    final isCommentsExpanded = _commentsExpanded[postId] ?? false;

    String likesStr = likesCount.toString();
    if (likesCount >= 1000) {
      final str = likesCount.toString();
      likesStr = '${str.substring(0, str.length - 3)},${str.substring(str.length - 3)}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Heart icon (like button)
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
                  color: isLiked ? Colors.red : Colors.black87,
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
              // Comment icon button
              GestureDetector(
                onTap: () async {
                  final willExpand = !isCommentsExpanded;
                  setState(() {
                    _commentsExpanded[postId] = willExpand;
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
                          'isAuthor': false,
                          'timeText': c['timeAgo'] ?? 'Just now',
                          'body': c['content'] ?? '',
                          'likes': c['likes'] ?? 0,
                          'hasLiked': c['isLiked'] ?? false,
                          'replies': <Map<String, dynamic>>[],
                        }).toList();
                      });
                    }
                  }
                },
                child: Icon(
                  isCommentsExpanded ? CupertinoIcons.chat_bubble_fill : CupertinoIcons.chat_bubble,
                  size: 24,
                  color: isCommentsExpanded ? const Color(0xFF0A66C2) : Colors.black87,
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
              color: isBookmarked ? const Color(0xFF1E88E5) : Colors.black87,
            ),
          ),
        ],
      ),
    );
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

  Widget _buildCommentsSection(String postId, [String? postAuthorName]) {
    final comments = _customComments[postId] ?? [];
    final bool isEmpty = comments.isEmpty;

    final currentUserName = ProfileManager.name.isNotEmpty
        ? ProfileManager.name
        : (AuthService.currentUser?.fullName?.isNotEmpty == true ? AuthService.currentUser!.fullName! : 'Developer');
    final currentUserHeadline = ProfileManager.summary.isNotEmpty
        ? ProfileManager.summary
        : (ProfileManager.bio.isNotEmpty ? ProfileManager.bio : 'Student @ Acadyk');
    final currentUserAvatar = ProfileManager.avatarUrl.isNotEmpty
        ? ProfileManager.avatarUrl
        : 'assets/images/somraj_avatar.jpg';

    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  'No comments yet.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                ),
              ),
            )
          else ...[
            // Header
            Row(
              children: const [
                Text(
                  'Most relevant',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF374151)),
                ),
                Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF374151)),
              ],
            ),
            const SizedBox(height: 12),

            // Recursive Nested Comments List
            for (int i = 0; i < comments.length; i++)
              _buildCommentTreeNode(
                postId: postId,
                comment: comments[i],
                depth: 0,
                isLast: i == comments.length - 1,
                currentUserName: currentUserName,
                currentUserHeadline: currentUserHeadline,
                currentUserAvatar: currentUserAvatar,
                rootCommentsList: comments,
              ),

            const Divider(height: 1, color: Color(0xFFECECE8)),
            const SizedBox(height: 8),
          ],

          // Replying banner inside feed
          if (_replyingToPostId == postId && _replyingToCommentNode != null)
            Container(
              color: const Color(0xFFF3F2EF),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    'Replying to ${_replyingToName ?? _replyingToCommentNode!['name'] ?? 'comment'}',
                    style: TextStyle(fontSize: 11, color: textSub, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _replyingToPostId = null;
                        _replyingToCommentNode = null;
                        _replyingToName = null;
                      });
                    },
                    child: Icon(Icons.close, size: 14, color: textSub),
                  ),
                ],
              ),
            ),

          // Add a comment box
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF0F4C81),
                backgroundImage: currentUserAvatar.isNotEmpty
                    ? (currentUserAvatar.startsWith('http')
                        ? NetworkImage(currentUserAvatar)
                        : (currentUserAvatar.startsWith('assets/') ? AssetImage(currentUserAvatar) as ImageProvider : null))
                    : null,
                child: (currentUserAvatar.isEmpty || (!currentUserAvatar.startsWith('http') && !currentUserAvatar.startsWith('assets/')))
                    ? Text(
                        currentUserName.isNotEmpty ? currentUserName.substring(0, 1).toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _commentInputCtrl,
                    focusNode: _commentFocusNode,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF191919)),
                    decoration: InputDecoration(
                      hintText: _replyingToName != null ? 'Reply to $_replyingToName...' : 'Add a comment...',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        final text = val.trim();
                        final String pName = (postAuthorName ?? '').trim().toLowerCase();
                        final String cName = currentUserName.trim().toLowerCase();
                        final bool isPostAuthor = pName.isEmpty || pName == cName || pName == 'developer' || pName == 'somraj lodhi';
                        final bool isReplying = _replyingToPostId == postId && _replyingToCommentNode != null;
                        final String? parentId = isReplying ? _replyingToCommentNode!['id']?.toString() : null;
                        final String replyText = (isReplying && _replyingToName != null && _replyingToName != _replyingToCommentNode!['name'])
                            ? '$_replyingToName $text'
                            : text;

                        setState(() {
                          if (isReplying) {
                            if (_replyingToCommentNode!['replies'] == null || _replyingToCommentNode!['replies'] is! List) {
                              _replyingToCommentNode!['replies'] = <Map<String, dynamic>>[];
                            }
                            final reps = (_replyingToCommentNode!['replies'] as List);
                            reps.add({
                              'id': 'reply_${DateTime.now().millisecondsSinceEpoch}',
                              'name': currentUserName,
                              'headline': currentUserHeadline,
                              'avatar': currentUserAvatar,
                              'isAuthor': isPostAuthor,
                              'timeText': 'Just now',
                              'body': replyText,
                              'likes': 0,
                              'hasLiked': false,
                              'replies': <Map<String, dynamic>>[],
                            });
                            _customComments[postId] = comments;
                            _replyingToPostId = null;
                            _replyingToCommentNode = null;
                            _replyingToName = null;
                          } else {
                            final newComment = {
                              'id': 'comment_${DateTime.now().millisecondsSinceEpoch}',
                              'name': currentUserName,
                              'headline': currentUserHeadline,
                              'avatar': currentUserAvatar,
                              'isAuthor': isPostAuthor,
                              'timeText': 'Just now',
                              'body': text,
                              'likes': 0,
                              'hasLiked': false,
                              'replies': <Map<String, dynamic>>[],
                            };
                            final currentComments = List<Map<String, dynamic>>.from(comments);
                            currentComments.add(newComment);
                            _customComments[postId] = currentComments;
                          }
                          _commentInputCtrl.clear();
                        });
                        PostService.addComment(postId, isReplying ? replyText : text, parentId: parentId);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  final val = _commentInputCtrl.text;
                  if (val.trim().isNotEmpty) {
                    final text = val.trim();
                    final String pName = (postAuthorName ?? '').trim().toLowerCase();
                    final String cName = currentUserName.trim().toLowerCase();
                    final bool isPostAuthor = pName.isEmpty || pName == cName || pName == 'developer' || pName == 'somraj lodhi';
                    final bool isReplying = _replyingToPostId == postId && _replyingToCommentNode != null;
                    final String? parentId = isReplying ? _replyingToCommentNode!['id']?.toString() : null;
                    final String replyText = (isReplying && _replyingToName != null && _replyingToName != _replyingToCommentNode!['name'])
                        ? '$_replyingToName $text'
                        : text;

                    setState(() {
                      if (isReplying) {
                        if (_replyingToCommentNode!['replies'] == null || _replyingToCommentNode!['replies'] is! List) {
                          _replyingToCommentNode!['replies'] = <Map<String, dynamic>>[];
                        }
                        final reps = (_replyingToCommentNode!['replies'] as List);
                        reps.add({
                          'id': 'reply_${DateTime.now().millisecondsSinceEpoch}',
                          'name': currentUserName,
                          'headline': currentUserHeadline,
                          'avatar': currentUserAvatar,
                          'isAuthor': isPostAuthor,
                          'timeText': 'Just now',
                          'body': replyText,
                          'likes': 0,
                          'hasLiked': false,
                          'replies': <Map<String, dynamic>>[],
                        });
                        _customComments[postId] = comments;
                        _replyingToPostId = null;
                        _replyingToCommentNode = null;
                        _replyingToName = null;
                      } else {
                        final newComment = {
                          'id': 'comment_${DateTime.now().millisecondsSinceEpoch}',
                          'name': currentUserName,
                          'headline': currentUserHeadline,
                          'avatar': currentUserAvatar,
                          'isAuthor': isPostAuthor,
                          'timeText': 'Just now',
                          'body': text,
                          'likes': 0,
                          'hasLiked': false,
                          'replies': <Map<String, dynamic>>[],
                        };
                        final currentComments = List<Map<String, dynamic>>.from(comments);
                        currentComments.add(newComment);
                        _customComments[postId] = currentComments;
                      }
                      _commentInputCtrl.clear();
                    });
                    PostService.addComment(postId, isReplying ? replyText : text, parentId: parentId);
                  }
                },
                child: const Icon(Icons.send, color: Color(0xFF0A66C2), size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTreeNode({
    required String postId,
    required Map<String, dynamic> comment,
    required int depth,
    required bool isLast,
    required String currentUserName,
    required String currentUserHeadline,
    required String currentUserAvatar,
    required List<Map<String, dynamic>> rootCommentsList,
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
      padding: EdgeInsets.only(
        top: depth == 0 ? 0 : 6,
        bottom: hasReplies ? 0 : (depth == 0 ? 16.0 : (isLast ? 12.0 : 6.0)),
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
                          children: [
                            Text(
                              comment['name'] ?? currentUserName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: depth == 0 ? 13 : 12.5,
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
                            const Spacer(),
                            Text(
                              comment['timeText'] ?? 'Just now',
                              style: const TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                        if ((comment['headline'] ?? '').toString().isNotEmpty)
                          Text(
                            comment['headline'] ?? '',
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
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
                                  _customComments[postId] = rootCommentsList;
                                });
                              },
                              child: Text(
                                'Like',
                                style: TextStyle(
                                  color: comment['hasLiked'] == true ? const Color(0xFF0A66C2) : const Color(0xFF5E5E5E),
                                  fontSize: depth == 0 ? 12 : 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (comment['likes'] != null && (comment['likes'] as int) > 0) ...[
                              const SizedBox(width: 6),
                              Icon(CupertinoIcons.hand_thumbsup_fill, size: depth == 0 ? 12 : 10, color: const Color(0xFF0A66C2)),
                              const SizedBox(width: 2),
                              Text(
                                comment['likes'].toString(),
                                style: TextStyle(color: Colors.grey, fontSize: depth == 0 ? 11 : 10),
                              ),
                            ],
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _replyingToPostId = postId;
                                  _replyingToCommentNode = comment;
                                  _replyingToName = comment['name'];
                                  _commentFocusNode.requestFocus();
                                });
                              },
                              child: Text(
                                'Reply',
                                style: TextStyle(
                                  color: textSub,
                                  fontSize: depth == 0 ? 12 : 11,
                                  fontWeight: FontWeight.w600,
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
                    postId: postId,
                    comment: replies[i] as Map<String, dynamic>,
                    depth: depth + 1,
                    isLast: i == replies.length - 1,
                    currentUserName: currentUserName,
                    currentUserHeadline: currentUserHeadline,
                    currentUserAvatar: currentUserAvatar,
                    rootCommentsList: rootCommentsList,
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

  Widget _buildCommentBodyText(String body) {
    return Text(
      body,
      style: const TextStyle(color: Color(0xFF374151), fontSize: 13, height: 1.4),
    );
  }

  // -------------------------------------------------------------
  // POST OPTIONS BOTTOM SHEET
  // -------------------------------------------------------------

  void _showPostOptionsBottomSheet({
    required BuildContext context,
    required String postId,
    required String authorName,
    required String authorHeadline,
    required String authorAvatar,
    required String postText,
    required String? postImage,
    required Map<String, dynamic> accountData,
  }) {
    final isSaved = _bookmarkedPosts[postId] ?? false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white, // Bright theme matching the app
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 20.0), // Outer padding
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Top row of actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTopActionIcon(
                      isSaved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
                      'Save',
                      color: isSaved ? const Color(0xFF1E88E5) : Colors.black,
                      onTap: () {
                        setState(() {
                          _bookmarkedPosts[postId] = !isSaved;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    _buildTopActionIcon(
                      CupertinoIcons.repeat,
                      'Repost',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RepostScreen(
                              postId: postId,
                              authorName: authorName,
                              authorHeadline: authorHeadline,
                              authorAvatar: authorAvatar,
                              postText: postText,
                              postImage: postImage,
                            ),
                          ),
                        ).then((result) {
                          if (result != null && result is Map<String, dynamic>) {
                            setState(() {
                              _dynamicReposts.insert(0, result);
                            });
                          }
                        });
                      },
                    ),
                    _buildTopActionIcon(
                      CupertinoIcons.paperplane,
                      'Share',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SharePostScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Vertical list actions (left aligned with padding)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      _buildListAction(CupertinoIcons.eye_slash, 'Hide', onTap: () {
                        Navigator.pop(context);
                        _showHidePostOptions(
                          context: context,
                          postId: postId,
                          authorName: authorName,
                          authorId: accountData['id']?.toString() ?? accountData['authorId']?.toString(),
                        );
                      }),
                      const SizedBox(height: 20),
                      _buildListAction(CupertinoIcons.person, 'About this account', onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AboutAccountScreen(accountData: accountData),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      _buildListAction(CupertinoIcons.exclamationmark_bubble, 'Report', color: const Color(0xFFED4956), onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReportPostScreen(),
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

  void _showHidePostOptions({
    required BuildContext context,
    required String postId,
    required String authorName,
    String? authorId,
  }) {
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
                    setState(() {
                      _feedPosts.removeWhere((p) => p['id']?.toString() == postId);
                    });
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
                            _loadBackendPosts();
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
                    if (authorId != null && authorId.isNotEmpty) {
                      PostService.hideAuthor(authorId);
                    }
                    setState(() {
                      _feedPosts.removeWhere((p) => PostService.isPostHidden(p));
                    });
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
                            if (authorId != null && authorId.isNotEmpty) {
                              PostService.unhideAuthor(authorId);
                            }
                            _loadBackendPosts();
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
              color: const Color(0xFFF2F2F2), // Light grey for blocks
              borderRadius: BorderRadius.circular(18), // Slightly less rounded
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
            style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  void _showCreatePostBottomSheet(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      elevation: 0,
      constraints: BoxConstraints(maxWidth: isTablet ? 600 : double.infinity),
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B).withValues(alpha: 0.72)
                    : Colors.white.withValues(alpha: 0.82),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.16)
                      : Colors.white.withValues(alpha: 0.88),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 32.0, left: 16.0, right: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag Handle
                      Container(
                        width: 42,
                        height: 4.5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      // Top Row: Close and Title
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                size: 24,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          Text(
                            'Start creating now',
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      // Horizontal items
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCreateOption(
                            context,
                            icon: Icons.post_add_rounded,
                            label: 'Post',
                            isDark: isDark,
                            onTap: () {
                              Navigator.pop(context); // Close bottom sheet
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const CreatePostScreen()),
                              );
                            },
                          ),
                          _buildCreateOption(
                            context,
                            icon: Icons.calendar_month_rounded,
                            label: 'Event',
                            isDark: isDark,
                            onTap: () {
                              Navigator.pop(context); // Close bottom sheet
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SelectOpportunityScreen(),
                                ),
                              );
                            },
                          ),
                          _buildCreateOption(
                            context,
                            icon: Icons.dashboard_customize_outlined,
                            label: 'Board',
                            isDark: isDark,
                            onTap: () {
                              Navigator.pop(context); // Close bottom sheet
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Board creation coming soon!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreateOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.22)
                    : Colors.white.withValues(alpha: 0.95),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : const Color(0xFF0F172A).withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              size: 32,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Navigation Bar matching active theme (Light / Dark)
  Widget _buildBottomNavBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = Theme.of(context).scaffoldBackgroundColor;
    final activeColor = isDark ? Colors.white : Colors.black;
    final inactiveColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF737373);

    return Container(
      color: navBg,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home
          GestureDetector(
            onTap: () {
              setState(() {
                _activeTab = 0;
                _newlyFollowedInSession.clear();
              });
              _pageController.jumpToPage(0);
            },
            child: Icon(
              CupertinoIcons.house,
              color: _activeTab == 0 ? activeColor : inactiveColor,
              size: 28,
            ),
          ),
          // Search / Discover
          GestureDetector(
            onTap: () {
              setState(() {
                _activeTab = 1;
                _newlyFollowedInSession.clear();
              });
              _pageController.jumpToPage(1);
            },
            child: LayoutGridNavIcon(
              color: _activeTab == 1 ? activeColor : inactiveColor,
              size: 26,
            ),
          ),
          // Add/Plus
          GestureDetector(
            onTap: () {
              _showCreatePostBottomSheet(context);
            },
            child: Icon(
              CupertinoIcons.add,
              color: _activeTab == 2 ? activeColor : inactiveColor,
              size: 32,
            ),
          ),
          // Message/Chat
          GestureDetector(
            onTap: () {
              setState(() {
                _activeTab = 3;
                _newlyFollowedInSession.clear();
              });
              _pageController.jumpToPage(2);
            },
            child: Icon(
              CupertinoIcons.ellipses_bubble,
              color: _activeTab == 3 ? activeColor : inactiveColor,
              size: 28,
            ),
          ),
          // Profile Avatar
          Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _activeTab == 4 ? activeColor : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: StatusAvatar(
              avatarAsset: ProfileManager.avatarUrl.isNotEmpty
                  ? ProfileManager.avatarUrl
                  : 'assets/images/somraj_avatar.jpg',
              radius: 13.5,
              enableTapToViewStory: false,
              onDefaultTap: () {
                setState(() {
                  _activeTab = 4;
                  _newlyFollowedInSession.clear();
                });
                _pageController.jumpToPage(3);
              },
            ),
          ),

        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // CUSTOM PROFILE DRAWER
  // -------------------------------------------------------------

  Widget _buildProfileDrawer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final drawerBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final headerTextColor = isDark ? Colors.white : const Color(0xFF111827);
    final subTextColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280);
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = (screenWidth > 0 && !screenWidth.isNaN && !screenWidth.isInfinite)
        ? min(320.0, screenWidth * 0.85)
        : 300.0;

    return Drawer(
      width: drawerWidth,
      backgroundColor: drawerBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Profile Header with Avatar, Name & Dynamic Unique Enrollment Number
            ValueListenableBuilder<bool>(
              valueListenable: ProfileManager.profileUpdateNotifier,
              builder: (context, _, __) {
                final currentName = (AuthService.currentUser?.fullName != null && AuthService.currentUser!.fullName!.isNotEmpty)
                    ? AuthService.currentUser!.fullName!
                    : (ProfileManager.name.isNotEmpty ? ProfileManager.name : 'Acadyk Member');
                final userEmail = (AuthService.currentUser?.email != null && AuthService.currentUser!.email.isNotEmpty)
                    ? AuthService.currentUser!.email
                    : (ProfileManager.email.isNotEmpty ? ProfileManager.email : '25am1ab4@mitsgwl.ac.in');
                final avatarUrl = ProfileManager.avatarUrl;
                final ImageProvider? drawerAvatarProvider = ProfileManager.avatarBytes != null
                    ? MemoryImage(ProfileManager.avatarBytes!)
                    : (avatarUrl.isNotEmpty
                        ? (avatarUrl.startsWith('http')
                            ? NetworkImage(avatarUrl)
                            : AssetImage(avatarUrl) as ImageProvider)
                        : null);
                final drawerInitials = currentName.isNotEmpty ? currentName.substring(0, 1).toUpperCase() : 'U';

                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 14.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFF0F4C81),
                          backgroundImage: drawerAvatarProvider,
                          onBackgroundImageError: drawerAvatarProvider != null ? (_, __) {} : null,
                          child: drawerAvatarProvider == null
                              ? Text(
                                  drawerInitials,
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(width: 14.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentName,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                  color: headerTextColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                userEmail,
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: subTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Divider(height: 1, color: isDark ? const Color(0xFF30363D) : const Color(0xFFE5E7EB)),

            // Scrollable top content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                children: [
                  _buildDrawerNavItem(
                    'My Courses',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MyCoursesScreen()),
                      );
                    },
                  ),
                  _buildDrawerNavItem(
                    'Startup Gallery',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const StartupGalleryScreen(),
                      ));
                    },
                  ),
                  _buildDrawerNavItem(
                    'Clubs',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ClubsScreen(),
                      ));
                    },
                  ),
                  _buildDrawerNavItem(
                    'Exhibition',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ExhibitionScreen(),
                      ));
                    },
                  ),
                  _buildDrawerNavItem(
                    'Space',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SpaceScreen(),
                      ));
                    },
                  ),
                  _buildDrawerNavItem(
                    'Community',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const DiscoverCommunitiesScreen(),
                      ));
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  Divider(height: 1, color: isDark ? const Color(0xFF30363D) : const Color(0xFFE5E7EB)),
                  const SizedBox(height: 8),


                  _buildDrawerNavItem(
                    'Feedback Form',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const FeedbackFormScreen(),
                      ));
                    },
                  ),
                  _buildDrawerNavItem(
                    'Accessibility',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const StudentIdCardScreen(),
                      ));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerNavItem(
    String title, {
    IconData? icon,
    String? trailingBadge,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final iconColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: navTextColor,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (trailingBadge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: textMain,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trailingBadge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowButton(String accountId, {String? authorName, String? authorId}) {
    final currentUserName = ProfileManager.name.isNotEmpty
        ? ProfileManager.name
        : (AuthService.currentUser?.fullName ?? '');
    final currentUserId = AuthService.currentUser?.id;
    final currentUsername = ProfileManager.username.isNotEmpty
        ? ProfileManager.username
        : (AuthService.currentUser?.username ?? '');

    // Prevent users from following themselves on any of their posts
    final bool isSelf = (authorName != null && currentUserName.isNotEmpty && authorName.trim().toLowerCase() == currentUserName.trim().toLowerCase()) ||
        (authorName != null && currentUsername.isNotEmpty && authorName.trim().toLowerCase() == currentUsername.trim().toLowerCase()) ||
        (authorId != null && currentUserId != null && authorId == currentUserId) ||
        (currentUserId != null && accountId == currentUserId) ||
        (currentUserName.isNotEmpty && accountId == currentUserName) ||
        (currentUsername.isNotEmpty && accountId == currentUsername) ||
        (accountId == 'self');

    if (isSelf) {
      return const SizedBox.shrink();
    }

    final isFollowed = _followedAccounts[accountId] ?? false;
    final isNewlyFollowed = _newlyFollowedInSession[accountId] ?? false;

    if (isFollowed && !isNewlyFollowed) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isFollowed) {
            _followedAccounts[accountId] = false;
            _newlyFollowedInSession[accountId] = false;
          } else {
            _followedAccounts[accountId] = true;
            _newlyFollowedInSession[accountId] = true;
          }
        });
        FollowService.toggleFollow(accountId, isFollowed);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isFollowed ? const Color(0xFFE5E7EB) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
          border: isFollowed ? Border.all(color: const Color(0xFFD1D5DB)) : null,
        ),
        child: Text(
          isFollowed ? 'Following' : 'Follow',
          style: TextStyle(
            color: isFollowed ? Colors.black87 : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _navigateToUserProfile({
    required String name,
    required String headline,
    String? avatar,
    String? initials,
    int? bgColor,
    String? location,
    bool isVerified = false,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          isOwnProfile: false,
          userData: {
            'name': name,
            'headline': headline,
            'avatar': avatar ?? '',
            'initials': initials ?? (name.isNotEmpty ? name.substring(0, min(2, name.length)).toUpperCase() : 'U'),
            'bgColor': bgColor ?? 0xFF1565C0,
            'location': location ?? 'Gwalior, India',
            'isVerified': isVerified,
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // LIVE POSTING PROGRESS CARD (Twitter / X Animated Banner)
  // ------------------------------------------------------------------
  Widget _buildPostingProgressCard() {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: PostService.activePostingNotifier,
      builder: (context, postingState, _) {
        if (postingState == null) return const SizedBox.shrink();

        final status = postingState['status']?.toString() ?? 'posting';
        final isPosting = status == 'posting';
        final isDone = status == 'done';
        final avatar = postingState['avatar']?.toString() ?? ProfileManager.avatarUrl;
        final name = postingState['name']?.toString() ?? ProfileManager.name;
        final initials = name.isNotEmpty ? name.substring(0, min(2, name.length)).toUpperCase() : 'U';

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isDark ? const Color(0xFF16181C) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDone ? const Color(0xFF10B981) : const Color(0xFF1D9BF0).withValues(alpha: 0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDone ? const Color(0xFF10B981) : const Color(0xFF1D9BF0)).withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // User avatar with mini loader
              Stack(
                alignment: Alignment.center,
                children: [
                  _buildAvatar(
                    initials: initials,
                    bgColor: const Color(0xFF0F4C81),
                    size: 38,
                    isMITS: false,
                    avatarAsset: avatar,
                  ),
                  if (isPosting)
                    const Positioned.fill(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D9BF0)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          isDone ? 'Post sent!' : 'Posting to your feed...',
                          style: TextStyle(
                            color: isDone ? const Color(0xFF10B981) : textMain,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                        if (isDone) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isDone ? 'Visible to your connections & feed' : 'Uploading media & synchronizing...',
                      style: TextStyle(
                        color: textSub,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPosting)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D9BF0))),
                ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------------
  // INTERACTIVE POLL CARD BUILDER (Twitter / X Style)
  // ------------------------------------------------------------------
  Widget _buildPollCard(String postId, Map<String, dynamic> poll) {
    final options = (poll['options'] as List<dynamic>?) ?? [];
    final int totalVotes = (poll['totalVotes'] as num?)?.toInt() ?? 0;
    final int userVotedIndex = (poll['userVotedIndex'] as num?)?.toInt() ?? -1;
    final String duration = poll['duration']?.toString() ?? '24 hours';
    final bool hasVoted = userVotedIndex >= 0;

    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < options.length; i++) ...[
            Builder(builder: (context) {
              final opt = options[i] is Map ? options[i] as Map : {'text': options[i].toString(), 'votes': 0};
              final optText = opt['text']?.toString() ?? '';
              final int optVotes = (opt['votes'] as num?)?.toInt() ?? 0;
              final double percent = totalVotes > 0 ? (optVotes / totalVotes) : 0.0;
              final bool isSelected = userVotedIndex == i;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (!hasVoted) {
                        PostService.votePoll(postId, i);
                        setState(() {});
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: _isDark ? const Color(0xFF16181C) : const Color(0xFFF7F9F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1D9BF0)
                              : (_isDark ? const Color(0xFF2F3336) : const Color(0xFFCFD9DE)),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Progress bar fill when voted
                            if (hasVoted && percent > 0)
                              FractionallySizedBox(
                                widthFactor: percent,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  color: isSelected
                                      ? const Color(0xFF1D9BF0).withValues(alpha: 0.28)
                                      : (_isDark ? const Color(0xFF2F3336) : const Color(0xFFE1E8ED)),
                                ),
                              ),

                            // Perfectly centered text and percentage row
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      optText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        color: textMain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    hasVoted ? '${(percent * 100).toStringAsFixed(0)}%' : '0%',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: hasVoted && isSelected ? FontWeight.bold : FontWeight.w600,
                                      color: isSelected ? const Color(0xFF1D9BF0) : textSub,
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
                ),
              );
            }),
          ],
          const SizedBox(height: 4),
          Text(
            '$totalVotes vote${totalVotes == 1 ? '' : 's'} • ${duration.contains('left') ? duration : '$duration left'}',
            style: TextStyle(
              fontSize: 13,
              color: textSub,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // MOCK POST CARD BUILDER
  // ------------------------------------------------------------------
  Widget _buildPostCard(Map<String, dynamic> post) {
    final String postId = post['id']?.toString() ?? 'post_${post.hashCode}';
    final String authorName = post['authorName']?.toString() ?? 'Acadyk Member';
    final String authorSubtitle = post['authorSubtitle']?.toString() ?? '';
    final String authorInitials = post['authorInitials']?.toString() ?? 'U';
    final int authorBgColor = (post['authorBgColor'] as num?)?.toInt() ?? 0xFF0F4C81;
    final bool isVerified = post['isVerified'] == true;
    final String timeAgo = post['timeAgo']?.toString() ?? 'Just now';
    final String content = post['content']?.toString() ?? '';
    final int likes = (post['likes'] as num?)?.toInt() ?? 0;
    final int comments = (post['comments'] as num?)?.toInt() ?? 0;
    final bool isCollab = post['isCollab'] == true;
    final String postType = post['type']?.toString() ?? 'student';

    // Collab author data
    final String collabName = post['collabAuthorName']?.toString() ?? '';
    final String collabInitials = post['collabAuthorInitials']?.toString() ?? '';
    final int collabBgColor = (post['collabAuthorBgColor'] as num?)?.toInt() ?? 0xFF424242;
    final String collabAvatarAsset = post['collabAuthorAvatar']?.toString() ?? (collabName.startsWith('MITS') ? 'assets/images/mits_logo.png' : '');

    // Determine if this is a notification-type post
    final bool isNotification = postType == 'notification';

    // Use MITS logo for MITS official posts
    final bool isMITSOfficial = authorName.startsWith('MITS');

    final String mainAvatarAsset = post['authorAvatar'] ?? (isMITSOfficial ? 'assets/images/mits_logo.png' : '');
    final String? postImageUrl = post['imageUrl'] ?? post['image'] ?? post['gifUrl'];
    final dynamic imageBytes = post['imageBytes'];
    final String? milestone = post['milestone']?.toString();
    final String? location = post['location']?.toString();
    final dynamic pollData = post['poll'];
    final List<dynamic>? taggedPeople = post['taggedPeople'] as List<dynamic>?;

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
                color: _isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                border: Border(bottom: BorderSide(color: _isDark ? const Color(0xFF334155) : const Color(0xFFDBEAFE))),
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
          // Notification banner for notification-type posts
          if (isNotification)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: _isDark ? const Color(0xFF1E1B4B) : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.notifications_active, size: 16, color: _isDark ? const Color(0xFFF59E0B) : const Color(0xFFE65100)),
                  const SizedBox(width: 6),
                  Text(
                    'Official Notification • $timeAgo',
                    style: TextStyle(
                      color: _isDark ? const Color(0xFFF59E0B) : const Color(0xFFE65100),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar section (Tappable to open main author profile or collab author profile)
                if (isCollab) ...[
                  // Overlapping dual avatars for collab posts
                  SizedBox(
                    width: 48,
                    height: 42,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Main author avatar (Top-Left)
                        Positioned(
                          left: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => _navigateToUserProfile(
                              name: authorName,
                              headline: authorSubtitle,
                              avatar: mainAvatarAsset,
                              initials: authorInitials,
                              bgColor: authorBgColor,
                              isVerified: isVerified,
                            ),
                            child: _buildAvatar(
                              initials: authorInitials,
                              bgColor: Color(authorBgColor),
                              size: 34,
                              isMITS: isMITSOfficial,
                              avatarAsset: mainAvatarAsset,
                            ),
                          ),
                        ),
                        // Collab author avatar (Bottom-Right overlay badge)
                        Positioned(
                          left: 20,
                          top: 14,
                          child: GestureDetector(
                            onTap: () => _navigateToUserProfile(
                              name: collabName,
                              headline: post['collabAuthorSubtitle']?.toString() ?? 'Collaborator @ Acadyk',
                              avatar: collabAvatarAsset,
                              initials: collabInitials,
                              bgColor: collabBgColor,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cardBg,
                                border: Border.all(color: cardBg, width: 2.0),
                              ),
                              child: _buildAvatar(
                                initials: collabInitials.isNotEmpty ? collabInitials : 'CO',
                                bgColor: Color(collabBgColor),
                                size: 22,
                                isMITS: collabName.startsWith('MITS') && (collabAvatarAsset == 'assets/images/mits_logo.png' || collabAvatarAsset.isEmpty),
                                avatarAsset: collabAvatarAsset,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Single avatar (Tappable)
                  GestureDetector(
                    onTap: () => _navigateToUserProfile(
                      name: authorName,
                      headline: authorSubtitle,
                      avatar: mainAvatarAsset,
                      initials: authorInitials,
                      bgColor: authorBgColor,
                      isVerified: isVerified,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isNotification
                            ? const Color(0xFFEF4444)
                            : (isMITSOfficial ? const Color(0xFF1565C0) : Colors.transparent),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(isNotification || isMITSOfficial ? 1.5 : 0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isNotification || isMITSOfficial ? Colors.white : Colors.transparent,
                        ),
                        child: _buildAvatar(
                          initials: authorInitials,
                          bgColor: Color(authorBgColor),
                          size: 36,
                          isMITS: isMITSOfficial,
                          avatarAsset: mainAvatarAsset,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                // Author info (Tappable to open author's profile dynamically)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _navigateToUserProfile(
                      name: authorName,
                      headline: authorSubtitle,
                      avatar: mainAvatarAsset,
                      initials: authorInitials,
                      bgColor: authorBgColor,
                      isVerified: isVerified,
                    ),
                    behavior: HitTestBehavior.opaque,
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
                        if (authorSubtitle.isNotEmpty &&
                            authorSubtitle.trim().toLowerCase() != 'just now' &&
                            authorSubtitle.trim().toLowerCase() != timeAgo.trim().toLowerCase())
                          Text(
                            authorSubtitle,
                            style: TextStyle(color: textSub, fontSize: 11.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (!isNotification && timeAgo.isNotEmpty)
                          Text(
                            timeAgo,
                            style: TextStyle(color: textSub, fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                ),
                _buildFollowButton(
                  post['author']?['id']?.toString() ?? post['authorId']?.toString() ?? authorName,
                  authorName: authorName,
                  authorId: post['author']?['id']?.toString() ?? post['authorId']?.toString(),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _showPostOptionsBottomSheet(
                    context: context,
                    postId: postId,
                    authorName: authorName,
                    authorHeadline: authorSubtitle,
                    authorAvatar: mainAvatarAsset,
                    postText: content,
                    postImage: postImageUrl,
                    accountData: {
                      'name': authorName,
                      'avatarUrl': mainAvatarAsset,
                      'dateJoined': 'August 2024',
                      'location': 'Gwalior, India',
                      'sharedFollowers': 12,
                    },
                  ),
                  child: Icon(Icons.more_vert, color: textSub, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Post content with "see more" truncation for long posts
          if (content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: _buildExpandableContent(postId, content),
            ),
          if (content.isNotEmpty) const SizedBox(height: 10),

          // Poll Widget if present
          if (pollData is Map<String, dynamic>) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: _buildPollCard(postId, pollData),
            ),
            const SizedBox(height: 10),
          ],

          if (imageBytes != null || (postImageUrl != null && postImageUrl.isNotEmpty)) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageBytes != null
                    ? (imageBytes is Uint8List
                        ? Image.memory(
                            imageBytes,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          )
                        : const SizedBox.shrink())
                    : (postImageUrl!.startsWith('http')
                        ? Image.network(
                            postImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          )
                        : Image.asset(
                            postImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          )),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Location and tagged people footer
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

          // Engagement row
          _buildPostActionRow(
            postId: postId,
            defaultLikes: likes,
            defaultComments: comments,
          ),
          if (_commentsExpanded[postId] == true) ...[
            _buildCommentsSection(postId, authorName),
          ],
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // REUSABLE FEEDBACK ACTION ROW WITH COMMENTS ACCORDION
  // -------------------------------------------------------------

  // Helper: Build avatar
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

  // Helper: Expandable content with "see more"
  final Map<String, bool> _expandedContent = {};
  Widget _buildExpandableContent(String postId, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bodyTextColor = isDark ? const Color(0xFFE6EDF3) : const Color(0xFF191919);
    final isExpanded = _expandedContent[postId] ?? false;
    const int maxLength = 200;
    final bool needsTruncation = content.length > maxLength;

    if (!needsTruncation || isExpanded) {
      return Text(
        content,
        style: TextStyle(
          color: bodyTextColor,
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
            color: bodyTextColor,
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

  // -------------------------------------------------------------
  // EMPTY FEED STATE
  // -------------------------------------------------------------
  Widget _buildEmptyFeedState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 64.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.dynamic_feed_outlined,
              size: 36,
              color: _isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textMain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share an update, project, or event with your campus community.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: textSub,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CreatePostScreen()),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create Post'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// QUANTAFORZE LOGO CUSTOM PAINTER
// -------------------------------------------------------------

class QuantaforzeLogoPainter extends CustomPainter {
  const QuantaforzeLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    // Draws a stylized circular Q logo shape
    path.addOval(Rect.fromCircle(
      center: Offset(size.width * 0.45, size.height * 0.45),
      radius: size.width * 0.25,
    ));
    path.moveTo(size.width * 0.58, size.height * 0.58);
    path.lineTo(size.width * 0.78, size.height * 0.78);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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



class InstagrammableImage extends StatefulWidget {
  final Widget child;
  final VoidCallback onDoubleTap;

  const InstagrammableImage({
    super.key,
    required this.child,
    required this.onDoubleTap,
  });

  @override
  State<InstagrammableImage> createState() => _InstagrammableImageState();
}

class _InstagrammableImageState extends State<InstagrammableImage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0).chain(CurveTween(curve: Curves.linear)), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 20),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    widget.onDoubleTap();
    setState(() {
      _showHeart = true;
    });
    _controller.reset();
    _controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _showHeart = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          if (_showHeart)
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: const Icon(
                    CupertinoIcons.heart_fill,
                    color: Colors.white,
                    size: 80,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

}

class RepostScreen extends StatefulWidget {
  final String postId;
  final String authorName;
  final String authorHeadline;
  final String authorAvatar;
  final String postText;
  final String? postImage;

  const RepostScreen({
    super.key,
    required this.postId,
    required this.authorName,
    required this.authorHeadline,
    required this.authorAvatar,
    required this.postText,
    this.postImage,
  });

  @override
  State<RepostScreen> createState() => _RepostScreenState();
}

class _RepostScreenState extends State<RepostScreen> {
  // _RepostScreenState_has_getters

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get scaffoldBg => _isDark ? Color(0xFF000000) : Color(0xFFFFFFFF);
  Color get cardBg => _isDark ? Color(0xFF000000) : Colors.white;
  Color get textMain => _isDark ? Color(0xFFF7F9F9) : Color(0xFF0F1419);
  Color get textSub => _isDark ? Color(0xFF71767B) : Color(0xFF536471);
  Color get iconColor => _isDark ? Colors.white : Colors.black87;
  Color get borderDivider => _isDark ? Color(0xFF2F3336) : Color(0xFFEFF3F4);

  final TextEditingController _commentCtrl = TextEditingController();
  bool _showPreview = true;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: isTablet ? 720 : double.infinity),
            color: Colors.white,
            child: Column(
              children: [
                // 1. Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: iconColor, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D8BF2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context, {
                            'postId': widget.postId,
                            'authorName': widget.authorName,
                            'authorHeadline': widget.authorHeadline,
                            'authorAvatar': widget.authorAvatar,
                            'postText': widget.postText,
                            'postImage': widget.postImage,
                            'comment': _commentCtrl.text,
                            'showImage': _showPreview,
                          });
                        },
                        child: const Text(
                          'Repost',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFECECE8)),

                // 2. Content (Input and Preview)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Avatar
                          const CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('assets/images/somraj_avatar.jpg'),
                          ),
                          const SizedBox(width: 12),
                          // Text Input
                          Expanded(
                            child: TextField(
                              controller: _commentCtrl,
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText: 'Add a comment...',
                                hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16.0),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 16.0, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Post Preview Container
                      if (_showPreview)
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE0E0E0), width: 1.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Original author details
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: widget.authorAvatar.startsWith('assets') ? Colors.transparent : const Color(0xFF0A66C2),
                                            shape: BoxShape.circle,
                                            image: widget.authorAvatar.startsWith('assets')
                                                ? DecorationImage(
                                                    image: AssetImage(widget.authorAvatar),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                          alignment: Alignment.center,
                                          child: widget.authorAvatar.startsWith('assets')
                                              ? null
                                              : Text(
                                                  widget.authorAvatar,
                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                                ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.authorName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13.0,
                                                  color: textMain,
                                                ),
                                              ),
                                              Text(
                                                widget.authorHeadline,
                                                style: TextStyle(
                                                  color: textSub,
                                                  fontSize: 11.5,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Original post text
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Text(
                                      widget.postText,
                                      style: TextStyle(color: textMain, fontSize: 13.0, height: 1.4),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Original post image
                                  if (widget.postImage != null)
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(12.0),
                                        bottomRight: Radius.circular(12.0),
                                      ),
                                      child: Image.asset(
                                        widget.postImage!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            
                            // Top-right grey X close button
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showPreview = false;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4.0),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // 3. Bottom controls
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(height: 1, color: Color(0xFFECECE8)),
                    
                    // Reply permission option
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: const [
                          Icon(CupertinoIcons.globe, color: Color(0xFF0D8BF2), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Everyone can reply',
                            style: TextStyle(
                              color: Color(0xFF0D8BF2),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFECECE8)),

                    // Bottom icons row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(CupertinoIcons.photo, color: Color(0xFF0D8BF2), size: 22),
                              SizedBox(width: 20),
                              Icon(Icons.gif_box_outlined, color: Color(0xFF0D8BF2), size: 22),
                              SizedBox(width: 20),
                              Icon(CupertinoIcons.list_bullet, color: Color(0xFF0D8BF2), size: 22),
                              SizedBox(width: 20),
                              Icon(CupertinoIcons.location, color: Color(0xFF0D8BF2), size: 22),
                              SizedBox(width: 20),
                              Icon(CupertinoIcons.flag, color: Color(0xFF0D8BF2), size: 20),
                            ],
                          ),
                          Row(
                            children: const [
                              Icon(CupertinoIcons.circle, color: Color(0xFFE5E7EB), size: 22),
                              SizedBox(width: 16),
                              Icon(CupertinoIcons.add_circled, color: Color(0xFF0D8BF2), size: 22),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class ReportPostScreen extends StatefulWidget {
  const ReportPostScreen({super.key});

  @override
  State<ReportPostScreen> createState() => _ReportPostScreenState();
}

class _ReportPostScreenState extends State<ReportPostScreen> {
  // _ReportPostScreenState_has_getters

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get scaffoldBg => _isDark ? Color(0xFF000000) : Color(0xFFFFFFFF);
  Color get cardBg => _isDark ? Color(0xFF000000) : Colors.white;
  Color get textMain => _isDark ? Color(0xFFF7F9F9) : Color(0xFF0F1419);
  Color get textSub => _isDark ? Color(0xFF71767B) : Color(0xFF536471);
  Color get iconColor => _isDark ? Colors.white : Colors.black87;
  Color get borderDivider => _isDark ? Color(0xFF2F3336) : Color(0xFFEFF3F4);

  int _currentStep = 0; // 0: Select reason, 1: Submit review
  String? _selectedReason;
  bool _receiveUpdates = false;

  final List<String> reasons = const [
    'Harassment',
    'Fraud or scam',
    'Spam',
    'Misinformation',
    'Hateful speech',
    'Threats or violence',
    'Self-harm',
    'Graphic content',
    'Dangerous or extremist organizations',
    'Sexual content',
    'Fake account',
    'Hacked account',
    'Child exploitation',
    'Restricted goods and services',
    'Nonconsensual intimate imagery',
  ];

  final Map<String, String> reasonDescriptions = const {
    'Harassment': 'Content that insults, defames, bullies, or harasses individuals.',
    'Fraud or scam': 'Content that promotes fake financial opportunities, scams, or fraudulent services.',
    'Spam': 'Repetitive, unsolicited, or low-quality commercial content.',
    'Misinformation': 'Inaccurate, false, or misleading claims that cause public harm.',
    'Hateful speech': 'Content that attacks or incites hatred against groups based on protected characteristics.',
    'Threats or violence': 'Direct statements of intent to commit acts of violence against people or property.',
    'Self-harm': 'Encouraging, depicting, or providing instructions on suicide or self-injury.',
    'Graphic content': 'Excessively violent, bloody, or disturbing media.',
    'Dangerous or extremist organizations': 'Promoting terror groups, violent extremism, or hate organizations.',
    'Sexual content': 'Explicit imagery, sexual solicitation, or pornography.',
    'Fake account': 'Accounts pretending to be someone else or using false details.',
    'Hacked account': 'Accounts displaying signs of unauthorized access or takeovers.',
    'Child exploitation': 'Depicting, promoting, or facilitating harm against children.',
    'Restricted goods and services': 'Content that attempts to sell restricted or regulated goods and services, including solicitation of escort services, prostitution and content that depicts and/or promotes sex trafficking or human trafficking',
    'Nonconsensual intimate imagery': 'Sharing intimate photos or videos without the consent of the subject.',
  };

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: isTablet ? 720 : double.infinity),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Row(
                    children: [
                      // Back arrow (only visible on step 1)
                      if (_currentStep == 1)
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: iconColor, size: 28),
                          onPressed: () {
                            setState(() {
                              _currentStep = 0;
                            });
                          },
                        )
                      else
                        const SizedBox(width: 48), // Balances the close icon
                      
                      Expanded(
                        child: Text(
                          'Report this post',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textMain,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: iconColor, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFECECE8)),

                // 2. Content
                Expanded(
                  child: _currentStep == 0 ? _buildReasonSelectionView() : _buildSubmitReviewView(),
                ),

                // 3. Bottom persistent button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D8BF2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: _currentStep == 0
                        ? (_selectedReason != null ? () => setState(() => _currentStep = 1) : null)
                        : _submitReport,
                    child: Text(
                      _currentStep == 0 ? 'Next' : 'Submit report',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReasonSelectionView() {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Text(
          'Select your reporting reason',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textMain,
          ),
        ),
        const SizedBox(height: 20),

        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: reasons.map((reason) {
            final isSelected = _selectedReason == reason;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedReason = reason;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF007A5A) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF007A5A) : const Color(0xFFCCCCCC),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  reason,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF191919),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubmitReviewView() {
    final description = reasonDescriptions[_selectedReason ?? ''] ?? '';

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Text(
          "You're requesting a policy review for this reason",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textMain,
          ),
        ),
        const SizedBox(height: 16),

        // Grey box card
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F2EF),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedReason ?? '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: textSub,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'Want to follow the status of your report?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textMain,
          ),
        ),
        const SizedBox(height: 12),

        // Checkbox row
        Row(
          children: [
            Checkbox(
              value: _receiveUpdates,
              activeColor: const Color(0xFF0D8BF2),
              onChanged: (val) {
                setState(() {
                  _receiveUpdates = val ?? false;
                });
              },
            ),
            Expanded(
              child: Text(
                'Receive updates on this report',
                style: TextStyle(fontSize: 15, color: textMain),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _submitReport() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text('Thank you! We received your report.', style: TextStyle(fontSize: 13))),
          ],
        ),
        backgroundColor: const Color(0xFF262626),
        behavior: SnackBarBehavior.floating,
        width: 280,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class SharePostScreen extends StatefulWidget {
  const SharePostScreen({super.key});

  @override
  State<SharePostScreen> createState() => _SharePostScreenState();
}

class _SharePostScreenState extends State<SharePostScreen> {
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get scaffoldBg => _isDark ? Color(0xFF000000) : Color(0xFFFFFFFF);
  Color get cardBg => _isDark ? Color(0xFF000000) : Colors.white;
  Color get textMain => _isDark ? Color(0xFFF7F9F9) : Color(0xFF0F1419);
  Color get textSub => _isDark ? Color(0xFF71767B) : Color(0xFF536471);
  Color get iconColor => _isDark ? Colors.white : Colors.black87;
  Color get borderDivider => _isDark ? Color(0xFF2F3336) : Color(0xFFEFF3F4);

  final List<Map<String, dynamic>> users = const [
    {'name': 'ਆਯੂਸ਼', 'avatar': 'assets/images/somraj_avatar.jpg', 'isOnline': false},
    {'name': 'ANURAG GURJAR💖', 'avatar': 'assets/images/somraj_avatar.jpg', 'isOnline': false},
    {'name': 'Vandna', 'avatar': 'assets/images/somraj_avatar.jpg', 'isOnline': false},
    {'name': 'ujjwal', 'avatar': 'assets/images/somraj_avatar.jpg', 'isOnline': false},
    {'name': 'The club🔥', 'avatar': 'assets/images/somraj_avatar.jpg', 'isOnline': false},
    {'name': 'Gaurav Rajawat', 'avatar': 'assets/images/somraj_avatar.jpg', 'isOnline': true},
    {'name': 'vishal', 'avatar': 'assets/images/somraj_avatar.jpg', 'isOnline': false},
    {'name': 'Tanishk pal', 'avatar': 'assets/images/somraj_avatar.jpg', 'isOnline': false},
    {'name': 'संकल्प सिंह', 'avatar': 'assets/images/somraj_avatar.jpg', 'isOnline': true},
    {'name': 'm.s.lodhi5', 'avatar': 'assets/images/somraj_avatar.jpg', 'isOnline': false},
    {'name': 'Abhay Gupta', 'avatar': 'assets/images/somraj_avatar.jpg', 'isOnline': false},
    {'name': 'Tannya♠', 'avatar': 'assets/images/somraj_avatar.jpg', 'isOnline': false},
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: isTablet ? 720 : double.infinity),
            color: Colors.white,
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: iconColor, size: 24),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F2EF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          height: 44,
                          alignment: Alignment.center,
                          child: TextField(
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              icon: Icon(Icons.search, color: Colors.grey[600], size: 20),
                              hintText: 'Search',
                              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Grid of users
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final u = users[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Post shared with ${u['name']}!'),
                              backgroundColor: const Color(0xFF262626),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor: const Color(0xFFECECE8),
                                  backgroundImage: AssetImage(u['avatar']),
                                ),
                                if (u['isOnline'] == true)
                                  Positioned(
                                    right: 2,
                                    bottom: 2,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4CAF50),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                u['name'],
                                style: TextStyle(
                                  color: textMain,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom bar
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    border: Border(
                      top: BorderSide(color: Color(0xFFECECE8), width: 1.0),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBottomAction(
                        context,
                        icon: Icons.link,
                        label: 'Copy link',
                        color: const Color(0xFFEBEBEB),
                        iconColor: Color(0xFF191919),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Link copied to clipboard!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      _buildBottomAction(
                        context,
                        label: 'WhatsApp',
                        color: const Color(0xFF25D366),
                        customIcon: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(28, 28),
                              painter: _WhatsAppBubblePainter(),
                            ),
                            Transform.translate(
                              offset: const Offset(0.5, -0.5),
                              child: Transform.rotate(
                                angle: -0.15,
                                child: const Icon(
                                  Icons.phone,
                                  color: Color(0xFF25D366),
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildBottomAction(
                        context,
                        icon: Icons.download,
                        label: 'Download',
                        color: const Color(0xFFEBEBEB),
                        iconColor: Color(0xFF191919),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Saved to gallery!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
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

  Widget _buildBottomAction(BuildContext context, {
    Widget? customIcon,
    IconData? icon,
    required String label,
    required Color color,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: customIcon ?? Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: textSub, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _WhatsAppBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.addOval(Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8));
    path.moveTo(w * 0.28, h * 0.72);
    path.lineTo(w * 0.16, h * 0.86);
    path.lineTo(w * 0.36, h * 0.79);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LayoutGridNavIcon extends StatelessWidget {
  final Color color;
  final double size;

  const LayoutGridNavIcon({
    super.key,
    required this.color,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LayoutGridNavIconPainter(color: color),
      ),
    );
  }
}

class _LayoutGridNavIconPainter extends CustomPainter {
  final Color color;

  _LayoutGridNavIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.095
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;

    final double pad = w * 0.12;
    final double availW = w - (pad * 2);
    final double availH = h - (pad * 2);

    final double gap = availW * 0.20;
    final double colWidth = (availW - gap) / 2;

    // 1. Left Vertical Capsule (Tall rounded rectangle)
    final Rect leftRect = Rect.fromLTWH(pad, pad, colWidth, availH);
    final RRect leftRRect = RRect.fromRectAndRadius(leftRect, Radius.circular(availW * 0.16));
    canvas.drawRRect(leftRRect, paint);

    // 2. Right Top Stacked Square
    final double rightLeft = pad + colWidth + gap;
    final double vertGap = availH * 0.16;
    final double sqHeight = (availH - vertGap) / 2;

    final Rect topRect = Rect.fromLTWH(rightLeft, pad, colWidth, sqHeight);
    final RRect topRRect = RRect.fromRectAndRadius(topRect, Radius.circular(availW * 0.14));
    canvas.drawRRect(topRRect, paint);

    // 3. Right Bottom Stacked Square
    final Rect bottomRect = Rect.fromLTWH(rightLeft, pad + sqHeight + vertGap, colWidth, sqHeight);
    final RRect bottomRRect = RRect.fromRectAndRadius(bottomRect, Radius.circular(availW * 0.14));
    canvas.drawRRect(bottomRRect, paint);
  }

  @override
  bool shouldRepaint(covariant _LayoutGridNavIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

