import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'dart:math';
import 'package:acadyk/common/services/post_service.dart';
import 'discover_opportunities_screen.dart';
import 'select_opportunity_screen.dart';
import 'company_profile_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../profile/presentation/screens/edit_status_screen.dart';
import '../../../profile/presentation/screens/story_view_screen.dart';


import '../../../profile/presentation/screens/about_account_screen.dart';
import '../../../profile/presentation/screens/my_courses_screen.dart';
import 'post_detail_screen.dart';
import 'startup_gallery_screen.dart';
import 'exhibition_screen.dart';
import 'clubs_screen.dart';
import 'create_post_screen.dart';
import '../../../notifications/presentation/screens/notification_screen.dart';
import '../../../community/presentation/screens/discover_communities_screen.dart';
import '../../../profile/presentation/screens/space_screen.dart';
import '../../../profile/presentation/screens/settings_activity_screen.dart';
import '../../../chat/presentation/screens/message_center_screen.dart';
import '../data/mock_feed_data.dart';
class HomeFeedScreen extends StatefulWidget {
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final PageController _pageController;

  // Dynamic feedback and comment state
  final Map<String, bool> _likedPosts = {};
  final Map<String, int> _likesCountOverride = {};
  final Map<String, bool> _bookmarkedPosts = {};
  final Map<String, bool> _savedPosts = {};
  final Map<String, bool> _followedAccounts = {};
  final Map<String, bool> _newlyFollowedInSession = {};
  final Map<String, bool> _commentsExpanded = {};
  final Map<String, List<Map<String, dynamic>>> _customComments = {};
  final TextEditingController _commentInputCtrl = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  final List<Map<String, dynamic>> _dynamicReposts = [];

  String? _replyingToPostId;
  int? _replyingToCommentIndex;
  String? _replyingToName;

  List<Map<String, dynamic>> _feedPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _activeTab == 4 ? 3 : (_activeTab == 3 ? 2 : _activeTab));
    _loadBackendPosts();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
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
    final textColor = theme.colorScheme.onSurface;
    final iconColor = isDark ? Colors.white : Colors.black87;
    final searchBgColor = isDark ? const Color(0xFF21262D) : const Color(0xFFF3F4F6);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: scaffoldBg,
      drawer: _buildProfileDrawer(),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 414), // Standard mobile frame width
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
                            // 1. Top App Bar (Dynamic Light/Dark Theme)
                            Container(
                              color: scaffoldBg,
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Left: Avatar and Plus
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            _scaffoldKey.currentState?.openDrawer();
                                          },
                                          child: Container(
                                            width: 34,
                                            height: 34,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: AssetImage('assets/images/alina_avatar.jpg'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Center: Acadyk Text and Down Arrow
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Acadyk',
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 26,
                                          fontFamily: 'Billabong',
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 2), // Small gap between 'k' and arrow
                                      Icon(Icons.keyboard_arrow_down, color: iconColor, size: 20),
                                    ],
                                  ),
                                  
                                  // Right: Search & Heart
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            showSearch(
                                              context: context,
                                              delegate: AcadykSearchDelegate(),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                              color: searchBgColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(CupertinoIcons.search, color: iconColor, size: 16),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(MaterialPageRoute(
                                              builder: (_) => const NotificationScreen(),
                                            ));
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Icon(CupertinoIcons.heart, color: iconColor, size: 24),
                                              Positioned(
                                                top: -1,
                                                right: -2,
                                                child: Container(
                                                  width: 9,
                                                  height: 9,
                                                  decoration: const BoxDecoration(
                                                    color: Colors.redAccent,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
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
                            Divider(height: 1, color: isDark ? const Color(0xFF30363D) : const Color(0xFFE0E0E0)),

                            // 2. Scrollable List of Posts (re-ordered and curated)
                            Expanded(
                              child: Container(
                                color: const Color(0xFFF3F2EF),
                                child: ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    if (_isLoading)
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 40),
                                        alignment: Alignment.center,
                                        child: Column(
                                          children: [
                                            const CircularProgressIndicator(),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Loading feed...',
                                              style: TextStyle(color: textSub),
                                            ),
                                          ],
                                        ),
                                      )
                                    else ...[
                                      if (_feedPosts.isNotEmpty)
                                        ..._feedPosts.map((post) => _buildDatabasePostCard(post)),
                                      // Mock posts from MITS Gwalior
                                      ...MockFeedData.mockPosts.map((post) => _buildMockPostCard(post)),
                                    ],

                                    const SizedBox(height: 16.0),
                                  ],
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
  // CARD BUILDERS
  // -------------------------------------------------------------

  // Post 1: Y Combinator
  Widget _buildYCPostCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
            
    return Container(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                // YC Profile square logo (with red status ring)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StoryViewScreen(
                          name: 'ycombinator',
                          avatarAsset: '',
                          avatarText: 'Y',
                          avatarBgColor: Color(0xFFFF6600),
                          statusEmoji: '🚀',
                          statusText: 'W26 Batch Open',
                          statusSubtitle: 'Y Combinator winter batch applications are officially open. Submit your application today!',
                          dateText: 'September 16th, 2026',
                          isCompany: true,
                          bannerColor: Color(0xFFFF6600),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEF4444), // Solid red ring
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(1.5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6600), // YC Orange
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Y',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const CompanyProfileScreen(companyName: 'Y Combinator'),
                      ));
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Y Combinator',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: textMain,
                              ),
                            ),
                            const SizedBox(width: 4),
                            PremiumBadge(type: 'gold'),
                          ],
                        ),
                        Text(
                          'Startup Supporters',
                          style: TextStyle(color: textSub, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ),
                 _buildFollowButton('ycombinator'),
                 const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showPostOptionsBottomSheet(
                    context: context,
                    postId: 'warp_post',
                    authorName: 'Y Combinator',
                    authorHeadline: 'W26 Batch Open',
                    authorAvatar: 'Y',
                    postText: 'Warp has raised \$60 million in Series B funding to automate payroll, HR, tax compliance, and employee onboarding.',
                    postImage: 'assets/images/warp_team.jpg',
                    accountData: {
                      'name': 'Y Combinator',
                      'avatarText': 'Y',
                      'avatarColor': const Color(0xFFFF6600),
                      'dateJoined': 'March 2005',
                      'location': 'United States',
                      'sharedFollowers': 24,
                    },
                  ),
                  child: Icon(Icons.more_vert, color: textSub),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Content Text (tappable to open detail)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: textMain, fontSize: 13.5, height: 1.45),
                children: [
                  TextSpan(
                    text: 'Warp',
                    style: const TextStyle(
                      color: Color(0xFF0A66C2),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CompanyProfileScreen(companyName: 'Warp'),
                          ),
                        );
                      },
                  ),
                  const TextSpan(
                    text: ' has raised \$60 million in Series B funding to automate payroll, HR, tax compliance, and employee onboarding. ',
                  ),
                  TextSpan(
                    text: '...more',
                    style: TextStyle(
                      color: textMain,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const PostDetailScreen(
                            authorName: 'Christian Pickett',
                            authorHeadline: 'Co-founder @ Orthogonal (YC W26)',
                            authorAvatar: 'assets/images/dharmik_avatar.jpg',
                            timeAgo: '1d',
                            postText: '',
                            connectionDegree: '3rd+',
                          ),
                        ));
                      },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Image (Warp team)
          InstagrammableImage(
            onDoubleTap: () {
              final isLiked = _likedPosts['warp_post'] ?? false;
              final likesCount = _likesCountOverride['warp_post'] ?? 537;
              setState(() {
                if (!isLiked) {
                  _likedPosts['warp_post'] = true;
                  _likesCountOverride['warp_post'] = likesCount + 1;
                }
              });
            },
            child: Image.asset(
              'assets/images/warp_team.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 10),

          // Action/Engagement row
          _buildPostActionRow(
            postId: 'warp_post',
            defaultLikes: 537,
            defaultComments: 51,
          ),
          if (_commentsExpanded['warp_post'] == true) ...[
            _buildCommentsSection('warp_post'),
          ],
        ],
      ),
    );
  }

  // Post 2: TIME
  Widget _buildTIMEPostCard() {
    return Container(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                // TIME red square logo (with red status ring)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StoryViewScreen(
                          name: 'TIME',
                          avatarAsset: '',
                          avatarText: 'TIME',
                          avatarBgColor: Color(0xFFE50914),
                          statusEmoji: '📰',
                          statusText: 'AI Special Issue',
                          statusSubtitle: 'TIME\'s new special report covering the state of Artificial Intelligence is out now.',
                          dateText: 'September 16th, 2026',
                          isCompany: true,
                          bannerColor: Color(0xFFE50914),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEF4444), // Solid red ring
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(1.5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE50914), // TIME Red
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'TIME',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 8.5,
                            fontFamily: 'serif',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const ProfileScreen(isOwnProfile: false),
                      ));
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'TIME',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: textMain,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const PremiumBadge(type: 'silver'),
                          ],
                        ),
                        Text(
                          '2,484,746 followers',
                          style: TextStyle(color: textSub, fontSize: 11.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'News & Media Publisher',
                          style: TextStyle(
                            color: textSub,
                            fontSize: 11.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildFollowButton('time'),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showPostOptionsBottomSheet(
                    context: context,
                    postId: 'time_post',
                    authorName: 'TIME',
                    authorHeadline: '2,484,746 followers',
                    authorAvatar: 'TIME',
                    postText: 'TIME CEO Jessica Sibley sits down with Alisha Moopen, Managing Director & Group CEO of... more',
                    postImage: 'assets/images/time_handshake.jpg',
                    accountData: {
                      'name': 'TIME',
                      'avatarText': 'TIME',
                      'avatarColor': const Color(0xFFE50914),
                      'dateJoined': 'October 2010',
                      'location': 'United States',
                      'sharedFollowers': 12,
                    },
                  ),
                  child: Icon(Icons.more_vert, color: textSub),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Content Text (tappable to open detail)
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const PostDetailScreen(
                  authorName: 'Christian Pickett',
                  authorHeadline: 'Co-founder @ Orthogonal (YC W26)',
                  authorAvatar: 'assets/images/dharmik_avatar.jpg',
                  timeAgo: '1d',
                  postText: '',
                  connectionDegree: '3rd+',
                ),
              ));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'TIME CEO Jessica Sibley sits down with Alisha Moopen, Managing Director & Group CEO of... more',
                style: TextStyle(color: textMain, fontSize: 13.5, height: 1.45),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Image (TIME video frame with play overlays)
          InstagrammableImage(
            onDoubleTap: () {
              final isLiked = _likedPosts['time_post'] ?? false;
              final likesCount = _likesCountOverride['time_post'] ?? 1204;
              setState(() {
                if (!isLiked) {
                  _likedPosts['time_post'] = true;
                  _likesCountOverride['time_post'] = likesCount + 1;
                }
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/time_handshake.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                // Center Play button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(12.0),
                  child: const Icon(Icons.play_arrow, size: 28, color: Colors.white),
                ),
                // Top-right video duration overlay
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
                    child: const Text(
                      '07:35',
                      style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Bottom-right speaker/volume mute overlay
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(5.0),
                    child: const Icon(Icons.volume_mute, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Action/Engagement row
          _buildPostActionRow(
            postId: 'time_post',
            defaultLikes: 1204,
            defaultComments: 89,
          ),
          if (_commentsExpanded['time_post'] == true) ...[
            _buildCommentsSection('time_post'),
          ],
        ],
      ),
    );
  }

  // Post 3: Alina Sprongole
  Widget _buildAlinaPostCard() {
    return Container(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ProfileScreen(isOwnProfile: false),
              ));
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
              children: [
                // Alina image avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/alina_avatar.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Alina Sprongole',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                              color: textMain,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const PremiumBadge(type: 'bronze'),
                          const SizedBox(width: 4),

                          Text('• 1st', style: TextStyle(color: textSub, fontSize: 12)),
                        ],
                      ),
                      const Text(
                        'Visit my website',
                        style: TextStyle(
                          color: Color(0xFF0A66C2),
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                        ),
                      ),
                      Text(
                        'Vibe Skills',
                        style: TextStyle(color: textSub, fontSize: 11.0),
                      ),
                    ],
                  ),
                ),
                _buildFollowButton('alina'),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showPostOptionsBottomSheet(
                    context: context,
                    postId: 'alina_post',
                    authorName: 'Alina Sprongole',
                    authorHeadline: 'Co-founder & CEO of Vibe Skills',
                    authorAvatar: 'assets/images/alina_avatar.jpg',
                    postText: 'A \$24M seed valuation is a death sentence. Carta just released their Q1 2026 data. The...',
                    postImage: 'assets/images/valuation_sentence.jpg',
                    accountData: {
                      'name': 'Alina Sprongole',
                      'avatarUrl': 'assets/images/alina_avatar.jpg',
                      'dateJoined': 'November 2020',
                      'location': 'India',
                      'sharedFollowers': 2,
                    },
                  ),
                  child: Icon(Icons.more_vert, color: textSub),
                ),
              ],
            ),
            ),
          ),
          const SizedBox(height: 10),

          // Post Text (tappable to open detail)
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const PostDetailScreen(
                  authorName: 'Christian Pickett',
                  authorHeadline: 'Co-founder @ Orthogonal (YC W26)',
                  authorAvatar: 'assets/images/dharmik_avatar.jpg',
                  timeAgo: '1d',
                  postText: '',
                  connectionDegree: '3rd+',
                ),
              ));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'A \$24M seed valuation is a death sentence. Carta just released their Q1 2026 data. The... more',
                style: TextStyle(color: textMain, fontSize: 13.5, height: 1.45),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Image (crossed-out valuation poster)
          InstagrammableImage(
            onDoubleTap: () {
              final isLiked = _likedPosts['alina_post'] ?? false;
              final likesCount = _likesCountOverride['alina_post'] ?? 23;
              setState(() {
                if (!isLiked) {
                  _likedPosts['alina_post'] = true;
                  _likesCountOverride['alina_post'] = likesCount + 1;
                }
              });
            },
            child: Image.asset(
              'assets/images/valuation_sentence.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 10),

          // Action/Engagement row
          _buildPostActionRow(
            postId: 'alina_post',
            defaultLikes: 23,
            defaultComments: 15,
          ),
          if (_commentsExpanded['alina_post'] == true) ...[
            _buildCommentsSection('alina_post'),
          ],
        ],
      ),
    );
  }

  // Middle Activity Separator Card
  Widget _buildActivitySeparatorRow() {
    return Container(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFFEEF3F8),
                child: Icon(Icons.person, size: 14, color: textSub),
              ),
              const SizedBox(width: 8),
              Text(
                'Ankit Sharma likes this',
                style: TextStyle(
                  color: textMain,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
          const SizedBox.shrink(),
        ],
      ),
    );
  }

  // Post 4: P Dharmik
  Widget _buildDharmikPostCard() {
    return Container(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ProfileScreen(isOwnProfile: false),
              ));
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
              children: [
                // Collab avatars (Overlapping)
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    children: [
                      // Top-right avatar (Underneath)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: const StatusAvatar(
                          avatarAsset: 'assets/images/somraj_avatar.jpg',
                          radius: 16,
                        ),
                      ),
                      // Bottom-left avatar (On top)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/dharmik_avatar.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'P Dharmik',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: textMain,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'and',
                            style: TextStyle(fontSize: 13.5, color: textMain),
                          ),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'somraj lodhi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: textMain,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Acadyk',
                        style: TextStyle(color: textSub, fontSize: 11.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ),
          ),
          const SizedBox(height: 10),

          // Post Text (tappable to open detail)
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const PostDetailScreen(
                  authorName: 'Christian Pickett',
                  authorHeadline: 'Co-founder @ Orthogonal (YC W26)',
                  authorAvatar: 'assets/images/dharmik_avatar.jpg',
                  timeAgo: '1d',
                  postText: '',
                  connectionDegree: '3rd+',
                ),
              ));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'A 19-year-old left Patna with borrowed money. 50 years later, his company posted \$18.2B in revenue. This is Anil Agarwal - and the story is not... more',
                style: TextStyle(color: textMain, fontSize: 13.5, height: 1.45),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Image (portrait with double badges overlays)
          InstagrammableImage(
            onDoubleTap: () {
              final isLiked = _likedPosts['collab_post'] ?? false;
              final likesCount = _likesCountOverride['collab_post'] ?? 1492;
              setState(() {
                if (!isLiked) {
                  _likedPosts['collab_post'] = true;
                  _likesCountOverride['collab_post'] = likesCount + 1;
                }
              });
            },
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/young_entrepreneur.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                // Bottom-left yellow badge
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    color: const Color(0xFFFFF176), // Bright Yellow
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: const Text(
                      'DAY ONE',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.0,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                // Top-right yellow badge (Money & Power)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    color: const Color(0xFFFFF176), // Bright Yellow
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: const Text(
                      'MONEY &\nPOWER',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.0,
                        height: 1.1,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Action/Engagement row
          _buildPostActionRow(
            postId: 'collab_post',
            defaultLikes: 1492,
            defaultComments: 235,
          ),
          if (_commentsExpanded['collab_post'] == true) ...[
            _buildCommentsSection('collab_post'),
          ],
        ],
      ),
    );
  }

  // Post 5: Repost Card
  Widget _buildRepostCard() {
    return Container(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Outer Header (Reposter)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                // Reposter Avatar
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(isOwnProfile: false),
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/dharmik_avatar.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(isOwnProfile: false),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Gokul Rajaram',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: textMain,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '• Following',
                              style: TextStyle(
                                color: textSub,
                                fontSize: 13.0,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Investor and Company Helper',
                          style: TextStyle(
                            color: textSub,
                            fontSize: 12.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                _buildFollowButton('gokul'),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showPostOptionsBottomSheet(
                    context: context,
                    postId: 'openai_post',
                    authorName: 'Rahul Thathoo',
                    authorHeadline: 'Engineering @ OpenAI',
                    authorAvatar: 'assets/images/alina_avatar.jpg',
                    postText: 'Rahul Thathoo: Engineering @ OpenAI. I enjoyed the podcast featuring Nikesh Arora with Harry Stebbings on 20VC...',
                    postImage: 'assets/images/young_entrepreneur.jpg',
                    accountData: {
                      'name': 'Gokul Rajaram',
                      'avatarUrl': 'assets/images/dharmik_avatar.jpg',
                      'dateJoined': 'Jan 2010',
                      'location': 'United States',
                      'sharedFollowers': 50,
                    },
                  ),
                  child: Icon(Icons.more_vert, color: textSub),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Reposter Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              'This is awesome!!!!',
              style: TextStyle(color: textMain, fontSize: 16.0, height: 1.3),
            ),
          ),
          const SizedBox(height: 12),

          // Inner Card (Original Post)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Inner Header
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(isOwnProfile: false),
                              ),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage('assets/images/alina_avatar.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileScreen(isOwnProfile: false),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rahul Thathoo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                    color: textMain,
                                  ),
                                ),
                                Text(
                                  'Engineering @ OpenAI',
                                  style: TextStyle(
                                    color: textSub,
                                    fontSize: 12.0,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        _buildFollowButton('rahul'),
                      ],
                    ),
                  ),
                  
                  // Inner Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: textMain, fontSize: 13.5, height: 1.45),
                        children: [
                          TextSpan(text: 'I enjoyed the podcast featuring '),
                          TextSpan(
                            text: 'Nikesh Arora',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A66C2)),
                          ),
                          TextSpan(text: ' with '),
                          TextSpan(
                            text: 'Harry Stebbings',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A66C2)),
                          ),
                          TextSpan(text: ' on 20VC. I utilized '),
                          TextSpan(
                            text: 'Gokul Rajaram',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A66C2)),
                          ),
                          TextSpan(text: '\'s Use Transcribe tool to... '),
                          TextSpan(
                            text: 'more',
                            style: TextStyle(color: textSub),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Inner Image
                  InstagrammableImage(
                    onDoubleTap: () {
                      final isLiked = _likedPosts['openai_post'] ?? false;
                      final likesCount = _likesCountOverride['openai_post'] ?? 892;
                      setState(() {
                        if (!isLiked) {
                          _likedPosts['openai_post'] = true;
                          _likesCountOverride['openai_post'] = likesCount + 1;
                        }
                      });
                    },
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                      ),
                      child: Image.asset(
                        'assets/images/young_entrepreneur.jpg',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Action/Engagement row
          _buildPostActionRow(
            postId: 'openai_post',
            defaultLikes: 892,
            defaultComments: 124,
          ),
          if (_commentsExpanded['openai_post'] == true) ...[
            _buildCommentsSection('openai_post'),
          ],
        ],
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
    
    // Dynamic comments count calculation
    final commentsList = _customComments[postId];
    int commentsCount = defaultComments;
    if (commentsList != null) {
      int total = 0;
      for (var c in commentsList) {
        total++;
        final reps = c['replies'] as List?;
        if (reps != null) {
          total += reps.length;
        }
      }
      // Offset by 47 to match the baseline of 51 comments initially
      commentsCount = 47 + total;
    }

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
                onTap: () {
                  setState(() {
                    _commentsExpanded[postId] = !isCommentsExpanded;
                  });
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

  Widget _buildCommentsSection(String postId) {
    final comments = _customComments[postId] ?? [
      {
        'name': 'Christian Pickett',
        'headline': 'Co-founder @ Orthogonal (YC W26)',
        'avatar': 'assets/images/dharmik_avatar.jpg',
        'isAuthor': true,
        'timeText': '1d',
        'body': 'Read more:\nhttps://www.thestreet.com/crypto/newsroom/orthogonal-is-betting-the-agent-economy-needs-better-infrastructure',
        'likes': 10,
        'hasLiked': false,
        'replies': <Map<String, dynamic>>[],
      },
      {
        'name': 'Aryan Gandhi',
        'headline': 'Building the Future with AI 0->1 | Gen ...',
        'avatar': 'assets/images/alina_avatar.jpg',
        'isAuthor': false,
        'timeText': '15h',
        'body': 'Congratulations on the raise! The idea of agents dynamically discovering and orchestrating capabilities feels like a missing layer in today\'s agent stack. Excited to see where Orthogonal goes from here. Christian Pickett 👏',
        'likes': 0,
        'hasLiked': false,
        'replies': <Map<String, dynamic>>[],
      },
      {
        'name': 'Ryan Widgeon',
        'headline': 'Founder | AI/ML | AI Agents |GTM| Forb...',
        'avatar': 'assets/images/somraj_avatar.jpg',
        'isAuthor': false,
        'timeText': '1d',
        'body': 'Congrats! This is a reallyyy interesting layer to build.\n\nMost agents today are only as useful as the tools they were pre-wired with. The moment the task requires a new capability, they either hallucinate a workaround, fail silently, or punt back to a human.\n\nDynamic capability discovery...',
        'likes': 9,
        'hasLiked': false,
        'replies': <Map<String, dynamic>>[
          {
            'name': 'Dr. Xi Zeng',
            'headline': 'Founder and CEO of Chance A...',
            'avatar': 'assets/images/dharmik_avatar.jpg',
            'timeText': '18h',
            'body': 'Ryan Widgeon The safety point is where this gets interesting. Tool discovery is easy to describe as routing, but the agent also needs a reason to stop....',
            'likes': 1,
            'hasLiked': false,
          }
        ],
      }
    ];

    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown
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

          // Comments List
          ...comments.asMap().entries.map((entry) {
            final commentIndex = entry.key;
            final comment = entry.value;
            final replies = comment['replies'] as List<dynamic>;
            final hasReplies = replies.isNotEmpty;

            return Padding(
              padding: EdgeInsets.only(bottom: hasReplies ? 0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 46,
                          child: CustomPaint(
                            painter: _MainCommentThreadPainter(hasReplies: hasReplies),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundImage: AssetImage(comment['avatar']),
                              ),
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
                                      comment['name'],
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                    ),
                                    if (comment['isAuthor'] == true) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0F2FE),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Author',
                                          style: TextStyle(color: Color(0xFF0369A1), fontSize: 9, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                    const Spacer(),
                                    Text(
                                      comment['timeText'],
                                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                                    ),
                                  ],
                                ),
                                Text(
                                  comment['headline'],
                                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                _buildCommentBodyText(comment['body']),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (comment['hasLiked'] == true) {
                                            comment['hasLiked'] = false;
                                            comment['likes'] = (comment['likes'] as int) - 1;
                                          } else {
                                            comment['hasLiked'] = true;
                                            comment['likes'] = (comment['likes'] as int) + 1;
                                          }
                                          _customComments[postId] = comments;
                                        });
                                      },
                                      child: Text(
                                        'Like',
                                        style: TextStyle(
                                          color: comment['hasLiked'] == true ? const Color(0xFF0A66C2) : const Color(0xFF5E5E5E),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (comment['likes'] > 0) ...[
                                      const SizedBox(width: 6),
                                      const Icon(CupertinoIcons.hand_thumbsup_fill, size: 12, color: Color(0xFF0A66C2)),
                                      const SizedBox(width: 2),
                                      Text(
                                        comment['likes'].toString(),
                                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                                      ),
                                    ],
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _replyingToPostId = postId;
                                          _replyingToCommentIndex = commentIndex;
                                          _replyingToName = comment['name'];
                                          _commentFocusNode.requestFocus();
                                        });
                                      },
                                      child: Text(
                                        'Reply',
                                        style: TextStyle(color: textSub, fontSize: 12, fontWeight: FontWeight.w600),
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

                  // Render Replies
                  if (replies.isNotEmpty) ...[
                    ...replies.asMap().entries.map((replyEntry) {
                      final replyIndex = replyEntry.key;
                      final reply = replyEntry.value;
                      final isLastReply = replyIndex == replies.length - 1;

                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: 46,
                              child: CustomPaint(
                                painter: _ReplyThreadPainter(isLast: isLastReply),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(top: 8, bottom: isLastReply ? 12 : 0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundImage: AssetImage(reply['avatar']),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                reply['name'],
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                                              ),
                                              const Spacer(),
                                              Text(
                                                reply['timeText'],
                                                style: const TextStyle(color: Colors.grey, fontSize: 11),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            reply['headline'],
                                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          _buildCommentBodyText(reply['body']),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    if (reply['hasLiked'] == true) {
                                                      reply['hasLiked'] = false;
                                                      reply['likes'] = ((reply['likes'] ?? 0) as int) - 1;
                                                    } else {
                                                      reply['hasLiked'] = true;
                                                      reply['likes'] = ((reply['likes'] ?? 0) as int) + 1;
                                                    }
                                                    _customComments[postId] = comments;
                                                  });
                                                },
                                                child: Text(
                                                  'Like',
                                                  style: TextStyle(
                                                    color: reply['hasLiked'] == true ? const Color(0xFF0A66C2) : const Color(0xFF5E5E5E),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              if (reply['likes'] != null && reply['likes'] > 0) ...[
                                                const SizedBox(width: 4),
                                                const Icon(CupertinoIcons.hand_thumbsup_fill, size: 10, color: Color(0xFF0A66C2)),
                                                const SizedBox(width: 2),
                                                Text(
                                                  reply['likes'].toString(),
                                                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                                                ),
                                              ],
                                              const SizedBox(width: 12),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _replyingToPostId = postId;
                                                    _replyingToCommentIndex = commentIndex;
                                                    _replyingToName = reply['name'];
                                                    _commentFocusNode.requestFocus();
                                                  });
                                                },
                                                child: Text(
                                                  'Reply',
                                                  style: TextStyle(color: textSub, fontSize: 11, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            );
          }).toList(),

          const Divider(height: 1, color: Color(0xFFECECE8)),
          const SizedBox(height: 8),

          // Replying banner inside feed
          if (_replyingToPostId == postId && _replyingToCommentIndex != null)
            Container(
              color: const Color(0xFFF3F2EF),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    'Replying to $_replyingToName',
                    style: TextStyle(fontSize: 11, color: textSub, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _replyingToPostId = null;
                        _replyingToCommentIndex = null;
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
              const StatusAvatar(
                avatarAsset: 'assets/images/somraj_avatar.jpg',
                radius: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: _commentInputCtrl,
                    focusNode: _replyingToPostId == postId ? _commentFocusNode : null,
                    decoration: InputDecoration(
                      hintText: (_replyingToPostId == postId && _replyingToCommentIndex != null) ? 'Add a reply...' : 'Add a comment...',
                      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13.5),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 13.5, color: Colors.black),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        final text = val.trim();
                        setState(() {
                          if (_replyingToPostId == postId && _replyingToCommentIndex != null) {
                            final parentComment = comments[_replyingToCommentIndex!];
                            final reps = parentComment['replies'] as List;
                            final replyText = (_replyingToName != null && _replyingToName != parentComment['name'])
                                ? '$_replyingToName $text'
                                : text;
                            reps.add({
                              'name': 'Somraj lodhi',
                              'headline': 'Founder & Builder @ Acadyk',
                              'avatar': 'assets/images/somraj_avatar.jpg',
                              'timeText': 'Just now',
                              'body': replyText,
                              'likes': 0,
                              'hasLiked': false,
                            });
                            _customComments[postId] = comments;
                            _replyingToPostId = null;
                            _replyingToCommentIndex = null;
                            _replyingToName = null;
                          } else {
                            final newComment = {
                              'name': 'Somraj lodhi',
                              'headline': 'Founder & Builder @ Acadyk',
                              'avatar': 'assets/images/somraj_avatar.jpg',
                              'isAuthor': false,
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
                    setState(() {
                      if (_replyingToPostId == postId && _replyingToCommentIndex != null) {
                        final parentComment = comments[_replyingToCommentIndex!];
                        final reps = parentComment['replies'] as List;
                        final replyText = (_replyingToName != null && _replyingToName != parentComment['name'])
                            ? '$_replyingToName $text'
                            : text;
                        reps.add({
                          'name': 'Somraj lodhi',
                          'headline': 'Founder & Builder @ Acadyk',
                          'avatar': 'assets/images/somraj_avatar.jpg',
                          'timeText': 'Just now',
                          'body': replyText,
                          'likes': 0,
                          'hasLiked': false,
                        });
                        _customComments[postId] = comments;
                        _replyingToPostId = null;
                        _replyingToCommentIndex = null;
                        _replyingToName = null;
                      } else {
                        final newComment = {
                          'name': 'Somraj lodhi',
                          'headline': 'Founder & Builder @ Acadyk',
                          'avatar': 'assets/images/somraj_avatar.jpg',
                          'isAuthor': false,
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

  Widget _buildCommentBodyText(String body) {
    final words = ['Christian Pickett', 'Ryan Widgeon'];
    String? foundWord;
    for (final w in words) {
      if (body.contains(w)) {
        foundWord = w;
        break;
      }
    }

    if (foundWord == null) {
      return Text(
        body,
        style: const TextStyle(color: Color(0xFF374151), fontSize: 13, height: 1.4),
      );
    }

    final parts = body.split(foundWord);
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Color(0xFF374151), fontSize: 13, height: 1.4),
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: foundWord,
            style: const TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ProfileScreen(isOwnProfile: false),
                ));
              },
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF202022),
      constraints: const BoxConstraints(maxWidth: 414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 32.0, left: 16.0, right: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Close and Title
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Text(
                      'Start creating now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Horizontal items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCreateOption(
                      context,
                      icon: Icons.push_pin_outlined,
                      label: 'Post',
                      onTap: () {
                        Navigator.pop(context); // Close bottom sheet
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const CreatePostScreen()),
                        );
                      },
                    ),
                    _buildCreateOption(
                      context,
                      icon: Icons.content_cut_outlined,
                      label: 'Event',
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
                      icon: Icons.splitscreen_outlined,
                      label: 'Board',
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
        );
      },
    );
  }

  Widget _buildCreateOption(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFF2F3033),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
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
              avatarAsset: 'assets/images/somraj_avatar.jpg',
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

    return Drawer(
      width: 300,
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
            // Top Profile Header with Avatar & Name
            InkWell(
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
                      radius: 22,
                      backgroundColor: const Color(0xFF0F4C81),
                      child: const Icon(Icons.person, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Somraj Lodhi',
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
                            '@somraj-dev',
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
                    Icon(
                      Icons.chevron_right_rounded,
                      color: subTextColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: isDark ? const Color(0xFF30363D) : const Color(0xFFE5E7EB)),

            // Scrollable top content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                children: [
                  _buildDrawerNavItem(
                    'Profile',
                    icon: Icons.person_outline_rounded,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                  ),
                  _buildDrawerNavItem(
                    'My Courses',
                    icon: Icons.school_outlined,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MyCoursesScreen()),
                      );
                    },
                  ),
                  _buildDrawerNavItem(
                    'Startup Gallery',
                    icon: Icons.rocket_launch_outlined,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const StartupGalleryScreen(),
                      ));
                    },
                  ),
                  _buildDrawerNavItem(
                    'Clubs',
                    icon: Icons.groups_outlined,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ClubsScreen(),
                      ));
                    },
                  ),
                  _buildDrawerNavItem(
                    'Exhibition',
                    icon: Icons.palette_outlined,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ExhibitionScreen(),
                      ));
                    },
                  ),
                  _buildDrawerNavItem(
                    'Space',
                    icon: Icons.explore_outlined,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SpaceScreen(),
                      ));
                    },
                  ),
                  _buildDrawerNavItem(
                    'Community',
                    icon: Icons.forum_outlined,
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
                    'Settings',
                    icon: Icons.settings_outlined,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SettingsActivityScreen(),
                      ));
                    },
                  ),
                  _buildDrawerNavItem(
                    'Feedback Form',
                    icon: Icons.rate_review_outlined,
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feedback form opened')),
                      );
                    },
                  ),
                  _buildDrawerNavItem(
                    'Accessibility',
                    icon: Icons.accessibility_new_outlined,
                    onTap: () {
                      Navigator.of(context).pop();
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
    final navTextColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final iconColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 11.0),
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
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  color: navTextColor,
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

  Widget _buildFollowButton(String accountId) {
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
  // MOCK POST CARD BUILDER
  // ------------------------------------------------------------------
  Widget _buildMockPostCard(Map<String, dynamic> post) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
                final String postId = post['id'] ?? 'mock_${post.hashCode}';
    final String authorName = post['authorName'] ?? 'Unknown';
    final String authorSubtitle = post['authorSubtitle'] ?? '';
    final String authorInitials = post['authorInitials'] ?? '?';
    final int authorBgColor = post['authorBgColor'] ?? 0xFF424242;
    final bool isVerified = post['isVerified'] ?? false;
    final String badgeType = post['badgeType'] ?? 'bronze';
    final String timeAgo = post['timeAgo'] ?? '';
    final String content = post['content'] ?? '';
    final int likes = post['likes'] ?? 0;
    final int comments = post['comments'] ?? 0;
    final bool isCollab = post['isCollab'] ?? false;
    final String postType = post['type'] ?? 'student';

    // Collab author data
    final String collabName = post['collabAuthorName'] ?? '';
    final String collabInitials = post['collabAuthorInitials'] ?? '';
    final int collabBgColor = post['collabAuthorBgColor'] ?? 0xFF424242;

    // Determine if this is a notification-type post
    final bool isNotification = postType == 'notification';

    // Use MITS logo for MITS official posts
    final bool isMITSOfficial = authorName.startsWith('MITS');

    final String mainAvatarAsset = isMITSOfficial ? 'assets/images/mits_logo.png' : '';

    return Container(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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

          // Collab banner for collab posts
          if (isCollab)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: _isDark ? const Color(0xFF0F172A) : const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.handshake, size: 16, color: _isDark ? const Color(0xFF38BDF8) : const Color(0xFF1565C0)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Collaboration Post',
                      style: TextStyle(
                        color: _isDark ? const Color(0xFF38BDF8) : const Color(0xFF1565C0),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
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
                    width: 52,
                    height: 44,
                    child: Stack(
                      children: [
                        // Main author avatar
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
                            child: _buildMockAvatar(
                              initials: authorInitials,
                              bgColor: Color(authorBgColor),
                              size: 36,
                              isMITS: isMITSOfficial,
                            ),
                          ),
                        ),
                        // Collab author avatar (overlapping)
                        Positioned(
                          left: 20,
                          top: 8,
                          child: GestureDetector(
                            onTap: () => _navigateToUserProfile(
                              name: collabName,
                              headline: 'Partner Organization @ Acadyk',
                              initials: collabInitials,
                              bgColor: collabBgColor,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: _buildMockAvatar(
                                initials: collabInitials,
                                bgColor: Color(collabBgColor),
                                size: 32,
                                isMITS: false,
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
                        child: _buildMockAvatar(
                          initials: authorInitials,
                          bgColor: Color(authorBgColor),
                          size: 36,
                          isMITS: isMITSOfficial,
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
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                isCollab ? '$authorName × $collabName' : authorName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: textMain,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isVerified) ...[
                              const SizedBox(width: 4),
                              PremiumBadge(type: badgeType),
                            ],
                          ],
                        ),
                        Text(
                          authorSubtitle,
                          style: TextStyle(color: textSub, fontSize: 11.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!isNotification)
                          Text(
                            timeAgo,
                            style: TextStyle(color: textSub, fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                ),
                _buildFollowButton(postId),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _showPostOptionsBottomSheet(
                    context: context,
                    postId: postId,
                    authorName: authorName,
                    authorHeadline: authorSubtitle,
                    authorAvatar: mainAvatarAsset,
                    postText: content,
                    postImage: null,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: _buildExpandableContent(postId, content),
          ),
          const SizedBox(height: 10),

          // Engagement row
          _buildPostActionRow(
            postId: postId,
            defaultLikes: likes,
            defaultComments: comments,
          ),
          if (_commentsExpanded[postId] == true) ...[
            _buildCommentsSection(postId),
          ],
        ],
      ),
    );
  }

  // Helper: Build avatar for mock posts
  Widget _buildMockAvatar({
    required String initials,
    required Color bgColor,
    required double size,
    required bool isMITS,
  }) {
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

  Widget _buildDatabasePostCard(Map<String, dynamic> post) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
                final author = post['profiles'] as Map<String, dynamic>? ?? {};
    final String authorName = author['full_name'] ?? 'Acadyk User';
    final String authorHeadline = author['bio'] ?? 'Member @ Acadyk';
    final String? authorAvatar = author['profile_photo_url'];
    final bool isVerified = author['is_verified'] ?? false;
    final bool isPremium = author['is_premium'] ?? false;
    final String content = post['content'] ?? '';
    final String? image = post['image_url'];
    final String postId = post['id'].toString();

    final int likesCount = post['likes_count'] ?? 0;
    final int commentsCount = post['comments_count'] ?? 0;
    final bool isLiked = _bookmarkedPosts[postId] ?? false;

    return Container(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(isOwnProfile: false, userData: author),
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF3F2EF),
                      image: authorAvatar != null
                          ? DecorationImage(image: NetworkImage(authorAvatar), fit: BoxFit.cover)
                          : null,
                    ),
                    child: authorAvatar == null
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProfileScreen(isOwnProfile: false, userData: author),
                                ),
                              );
                            },
                            child: Text(
                              authorName,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: textMain),
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 4),
                            const PremiumBadge(type: 'gold'),
                          ] else if (isPremium) ...[
                            const SizedBox(width: 4),
                            const PremiumBadge(type: 'silver'),
                          ],
                        ],
                      ),
                      Text(
                        authorHeadline,
                        style: TextStyle(color: textSub, fontSize: 11.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: textSub),
                  onPressed: () {
                    _showPostOptionsBottomSheet(
                      context: context,
                      postId: postId,
                      authorName: authorName,
                      authorHeadline: authorHeadline,
                      authorAvatar: authorAvatar ?? '',
                      postText: content,
                      postImage: image,
                      accountData: author,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              content,
              style: TextStyle(color: textMain, fontSize: 14.5, height: 1.3),
            ),
          ),
          if (image != null && image.isNotEmpty) ...[
            const SizedBox(height: 12),
            Image.network(image, fit: BoxFit.cover, height: 240, width: double.infinity),
          ],
          // Reaction action row (Instagram/curated style)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final previousState = _likedPosts[postId] ?? false;
                    setState(() {
                      _likedPosts[postId] = !previousState;
                    });
                    try {
                      final newState = await PostService.toggleLike(postId, previousState);
                      if (mounted && _likedPosts[postId] != newState) {
                        setState(() {
                          _likedPosts[postId] = newState;
                        });
                      }
                    } catch (_) {
                      if (mounted) {
                        setState(() {
                          _likedPosts[postId] = previousState; // Rollback
                        });
                      }
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                        color: isLiked ? Color(0xFFF91880) : iconColor,
                        size: 24,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${isLiked ? likesCount + 1 : likesCount}',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textMain),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailScreen(
                          authorName: authorName,
                          authorHeadline: authorHeadline,
                          authorAvatar: authorAvatar != null && authorAvatar.isNotEmpty
                              ? authorAvatar
                              : 'assets/images/somraj_avatar.jpg',
                          timeAgo: 'Just now',
                          postText: content,
                          post: post,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.chat_bubble,
                        color: iconColor,
                        size: 24,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$commentsCount',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textMain),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    final wasSaved = _savedPosts[postId] ?? false;
                    setState(() {
                      _savedPosts[postId] = !wasSaved;
                    });
                    await PostService.toggleBookmark(postId, wasSaved);
                  },
                  child: Icon(
                    (_savedPosts[postId] ?? false)
                        ? CupertinoIcons.bookmark_fill
                        : CupertinoIcons.bookmark,
                    color: (_savedPosts[postId] ?? false)
                        ? const Color(0xFF1D9BF0)
                        : iconColor,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicRepostCard(Map<String, dynamic> repost) {
    final postId = '${repost['postId']}_repost';
    final hasImage = repost['postImage'] != null;

    return Container(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Outer Header (Reposter)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(isOwnProfile: true),
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/somraj_avatar.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(isOwnProfile: true),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Somraj lodhi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: textMain,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '• You',
                              style: TextStyle(
                                color: textSub,
                                fontSize: 13.0,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Founder & Builder @ Acadyk',
                          style: TextStyle(
                            color: textSub,
                            fontSize: 12.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: textSub),
                  onPressed: () {
                    _showPostOptionsBottomSheet(
                      context: context,
                      postId: postId,
                      authorName: 'Somraj lodhi',
                      authorHeadline: 'Founder & Builder @ Acadyk',
                      authorAvatar: 'assets/images/somraj_avatar.jpg',
                      postText: repost['comment'] ?? '',
                      postImage: repost['postImage'],
                      accountData: const {
                        'name': 'Somraj lodhi',
                        'role': 'Founder & Builder @ Acadyk',
                        'avatar': 'assets/images/somraj_avatar.jpg',
                        'location': 'India',
                        'connections': '500+',
                        'followers': '10,000',
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Reposter Text / Comment
          if (repost['comment'] != null && (repost['comment'] as String).isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                repost['comment'],
                style: TextStyle(color: textMain, fontSize: 15.0, height: 1.3),
              ),
            ),
          const SizedBox(height: 12),

          // Inner Card (Original Post)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Inner Header
                  GestureDetector(
                    onTap: () {
                      if (repost['authorName'] == 'Y Combinator') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CompanyProfileScreen(companyName: 'Y Combinator'),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(isOwnProfile: false),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: repost['authorAvatar'].startsWith('assets') ? Colors.transparent : const Color(0xFF0A66C2),
                              shape: BoxShape.circle,
                              image: repost['authorAvatar'].startsWith('assets')
                                  ? DecorationImage(
                                      image: AssetImage(repost['authorAvatar']),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: repost['authorAvatar'].startsWith('assets')
                                ? null
                                : Text(
                                    repost['authorAvatar'],
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  repost['authorName'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.0,
                                    color: textMain,
                                  ),
                                ),
                                Text(
                                  repost['authorHeadline'],
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
                  ),

                  // Inner Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      repost['postText'],
                      style: TextStyle(color: textMain, fontSize: 13.0, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Inner Image (if preview was not removed)
                  if (hasImage && repost['showImage'] != false)
                    InstagrammableImage(
                      onDoubleTap: () {
                        final isLiked = _likedPosts[postId] ?? false;
                        final likesCount = _likesCountOverride[postId] ?? 0;
                        setState(() {
                          if (!isLiked) {
                            _likedPosts[postId] = true;
                            _likesCountOverride[postId] = likesCount + 1;
                          }
                        });
                      },
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                        ),
                        child: Image.asset(
                          repost['postImage'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Action/Engagement row
          _buildPostActionRow(
            postId: postId,
            defaultLikes: 0,
            defaultComments: 0,
          ),
          if (_commentsExpanded[postId] == true) ...[
            _buildCommentsSection(postId),
          ],
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

class AcadykSearchDelegate extends SearchDelegate<String> {
  final List<String> suggestions = [
    'Somraj',
    'Y Combinator',
    'Horror Circus tarot deck',
    'Gandalf the White',
    'Parks Europe',
    'Alina Sprongole',
    'Startup Gallery',
    'Clubs',
  ];

  final List<Map<String, dynamic>> mockUsers = [
    {
      'name': 'Somraj Lodhi',
      'headline': 'Founder | Thinker | Quant Engineer',
      'location': 'Indore, Madhya Pradesh, India',
      'avatar': 'assets/images/somraj_avatar.jpg',
      'hiring': false,
      'mutual': <String>[],
    },
    {
      'name': 'Somraj Dev',
      'headline': 'Entrepreneur | Founder @ Nexure Agents & Black Torque Media | AI A...',
      'location': 'India',
      'avatar': 'assets/images/user_avatar.jpg',
      'hiring': false,
      'mutual': <String>['assets/images/somraj_avatar.jpg', 'assets/images/dharmik_avatar.jpg'],
    },
    {
      'name': 'Somraj Ghosh',
      'headline': 'Founder & CEO @ Layrda',
      'location': 'India',
      'avatar': 'assets/images/somraj_avatar.jpg',
      'hiring': true,
      'mutual': <String>['assets/images/dharmik_avatar.jpg'],
    },
    {
      'name': 'Somraj Chalukya',
      'headline': 'Operational Specialist, Direct Apply Operations at Cialfo',
      'location': 'Delhi, India',
      'avatar': 'assets/images/user_avatar.jpg',
      'hiring': false,
      'mutual': <String>['assets/images/dharmik_avatar.jpg'],
    },
    {
      'name': 'Somraj Singh Goyal',
      'headline': 'TOSCA Automation Tester | Certified Tosca Product Consultant| Expertis...',
      'location': 'Indore, Madhya Pradesh, India',
      'avatar': 'assets/images/somraj_avatar.jpg',
      'hiring': false,
      'mutual': <String>[],
    },
    {
      'name': 'Alina Sprongole',
      'headline': 'Software Engineer @ Google | Tech Lead',
      'location': 'Riga, Latvia',
      'avatar': 'assets/images/alina_avatar.jpg',
      'hiring': false,
      'mutual': <String>['assets/images/somraj_avatar.jpg'],
    },
    {
      'name': 'Dharmik Patel',
      'headline': 'Full Stack Developer | Open Source Contributor',
      'location': 'Gujarat, India',
      'avatar': 'assets/images/dharmik_avatar.jpg',
      'hiring': false,
      'mutual': <String>['assets/images/somraj_avatar.jpg', 'assets/images/user_avatar.jpg'],
    },
  ];

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.black, fontSize: 18),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.black54),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black54),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = mockUsers
        .where((user) =>
            user['name'].toLowerCase().contains(query.toLowerCase()) ||
            user['headline'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (query.toLowerCase() == 'y combinator') {
      return Container(
        color: Colors.white,
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFFF6600),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              'Y',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          title: const Text('Y Combinator', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Startup Accelerator - Mountain View, CA'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CompanyProfileScreen(companyName: 'Y Combinator'),
              ),
            );
          },
        ),
      );
    }

    if (results.isEmpty) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Text(
            'No results found for "$query"',
            style: const TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: results.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final user = results[index];
          final bool hiring = user['hiring'] == true;
          final List<String> mutual = List<String>.from(user['mutual']);

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(isOwnProfile: false, userData: user),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Avatar with stacked hiring banner if active
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: hiring ? const Color(0xFF7C3AED) : Colors.transparent,
                            width: hiring ? 2.5 : 0,
                          ),
                        ),
                        padding: EdgeInsets.all(hiring ? 2 : 0),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: AssetImage(user['avatar']),
                        ),
                      ),
                      if (hiring)
                        Positioned(
                          bottom: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '#HIRING',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 7.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Right: Profile info details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'],
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user['headline'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 13.5,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user['location'],
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 13.5,
                          ),
                        ),
                        if (mutual.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Stack of overlapping connection circular avatars
                              SizedBox(
                                width: 20.0 + (mutual.length - 1) * 12.0,
                                height: 20,
                                child: Stack(
                                  children: List.generate(mutual.length, (i) {
                                    return Positioned(
                                      left: i * 12.0,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 1.5),
                                          image: DecorationImage(
                                            image: AssetImage(mutual[i]),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${mutual.length} mutual connection${mutual.length > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? suggestions
        : suggestions.where((element) => element.toLowerCase().contains(query.toLowerCase())).toList();

    return Container(
      color: Colors.white,
      child: ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) => ListTile(
          leading: const Icon(Icons.search, color: Colors.black45),
          title: Text(
            suggestionList[index],
            style: const TextStyle(color: Colors.black87),
          ),
          onTap: () {
            query = suggestionList[index];
            showResults(context);
          },
        ),
      ),
    );
  }
}

class _MainCommentThreadPainter extends CustomPainter {
  final bool hasReplies;
  _MainCommentThreadPainter({required this.hasReplies});

  @override
  void paint(Canvas canvas, Size size) {
    if (!hasReplies) return;
    
    final paint = Paint()
      ..color = const Color(0xFFC7C7C7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerX = 18.0; 
    final startY = 36.0;

    final path = Path();
    path.moveTo(centerX, startY);
    path.lineTo(centerX, size.height);
    
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReplyThreadPainter extends CustomPainter {
  final bool isLast;
  _ReplyThreadPainter({required this.isLast});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC7C7C7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerX = 18.0;
    final centerY = 23.0; 

    final elbowPath = Path();
    elbowPath.moveTo(centerX, 0);
    elbowPath.lineTo(centerX, centerY - 12);
    elbowPath.arcToPoint(
      Offset(centerX + 12, centerY),
      radius: const Radius.circular(12),
      clockwise: false,
    );
    elbowPath.lineTo(size.width, centerY);

    canvas.drawPath(elbowPath, paint);

    if (!isLast) {
      final linePath = Path();
      linePath.moveTo(centerX, centerY - 12);
      linePath.lineTo(centerX, size.height);
      canvas.drawPath(linePath, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 414),
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

class PremiumBadge extends StatelessWidget {
  final String type; // 'gold', 'silver', 'bronze'
  final double size;

  const PremiumBadge({
    super.key,
    required this.type,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    Color outerColor;
    Color innerColor;
    Color crownColor;
    List<Color> gradientColors;

    if (type == 'gold') {
      outerColor = const Color(0xFFFFB300);
      innerColor = const Color(0xFFFFD54F);
      crownColor = const Color(0xFFE65100);
      gradientColors = [
        const Color(0xFFFFD700),
        const Color(0xFFFFA000),
      ];
    } else if (type == 'silver') {
      outerColor = const Color(0xFF78909C);
      innerColor = const Color(0xFFB0BEC5);
      crownColor = const Color(0xFF37474F);
      gradientColors = [
        const Color(0xFFECEFF1),
        const Color(0xFF90A4AE),
      ];
    } else { // bronze
      outerColor = const Color(0xFF8D6E63);
      innerColor = const Color(0xFFBCAAA4);
      crownColor = const Color(0xFF4E342E);
      gradientColors = [
        const Color(0xFFD7CCC8),
        const Color(0xFF8D6E63),
      ];
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: outerColor.withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 0.5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _HexagonBadgePainter(
          outerColor: outerColor,
          innerColor: innerColor,
          crownColor: crownColor,
          gradientColors: gradientColors,
        ),
      ),
    );
  }
}

class _HexagonBadgePainter extends CustomPainter {
  final Color outerColor;
  final Color innerColor;
  final Color crownColor;
  final List<Color> gradientColors;

  const _HexagonBadgePainter({
    required this.outerColor,
    required this.innerColor,
    required this.crownColor,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final w = size.width;
    final h = size.height;
    final radius = size.width / 2;

    // Draw base shadow
    final shadowPath = _getHexagonPath(center, radius);
    canvas.drawShadow(shadowPath, Colors.black.withValues(alpha: 0.15), 2.0, true);

    // 1. Outer Hexagon (Bevel Edge)
    final outerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          outerColor.withValues(alpha: 0.5),
          crownColor.withValues(alpha: 0.3),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(shadowPath, outerPaint);

    // 2. Middle Hexagon (Main body)
    final midHexagonPath = _getHexagonPath(center, radius * 0.9);
    final midPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: gradientColors,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(midHexagonPath, midPaint);

    // 3. Inner Hexagon (Well defined border inset)
    final innerHexagonPath = _getHexagonPath(center, radius * 0.76);
    final innerBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(innerHexagonPath, innerBorderPaint);

    // Inner background
    final innerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gradientColors[0].withValues(alpha: 0.8),
          gradientColors[1].withValues(alpha: 0.95),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(innerHexagonPath, innerPaint);

    // 4. Glossy Highlight Overlay (Glass Reflection Effect)
    final glossPath = Path();
    glossPath.moveTo(w * 0.1, h * 0.5);
    glossPath.lineTo(w * 0.5, h * 0.1);
    glossPath.lineTo(w * 0.9, h * 0.5);
    glossPath.arcToPoint(Offset(w * 0.1, h * 0.5), radius: Radius.circular(radius * 0.8), clockwise: false);
    glossPath.close();

    final glossPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.45),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(glossPath, glossPaint);

    // 5. Stylized Detailed Crown and V inside
    final crownPath = Path();
    crownPath.moveTo(w * 0.30, h * 0.62);
    crownPath.lineTo(w * 0.24, h * 0.44); // left tip
    crownPath.lineTo(w * 0.38, h * 0.50);
    crownPath.lineTo(w * 0.50, h * 0.38); // center tip
    crownPath.lineTo(w * 0.62, h * 0.50);
    crownPath.lineTo(w * 0.76, h * 0.44); // right tip
    crownPath.lineTo(w * 0.70, h * 0.62);
    crownPath.close();

    final crownPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.95),
          Colors.white.withValues(alpha: 0.7),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(crownPath, crownPaint);

    // Crown Base Band
    final bandPath = Path();
    bandPath.moveTo(w * 0.32, h * 0.65);
    bandPath.lineTo(w * 0.68, h * 0.65);
    bandPath.lineTo(w * 0.66, h * 0.68);
    bandPath.lineTo(w * 0.34, h * 0.68);
    bandPath.close();
    canvas.drawPath(bandPath, crownPaint);

    // Draw 'V' text inside
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'V',
        style: TextStyle(
          color: crownColor,
          fontSize: size.width * 0.22,
          fontWeight: FontWeight.w900,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height * 0.38),
    );

    // Tips
    final tipPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.24, h * 0.44), w * 0.045, tipPaint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.38), w * 0.045, tipPaint);
    canvas.drawCircle(Offset(w * 0.76, h * 0.44), w * 0.045, tipPaint);
  }

  Path _getHexagonPath(Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * (3.1415926535 / 180);
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 414),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 414),
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

