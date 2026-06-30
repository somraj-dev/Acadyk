import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'discover_opportunities_screen.dart';
import 'select_opportunity_screen.dart';
import 'company_profile_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../profile/presentation/screens/edit_status_screen.dart';
import '../../../profile/presentation/screens/story_view_screen.dart';


import '../../../profile/presentation/screens/appearance_screen.dart';
import '../../../profile/presentation/screens/about_account_screen.dart';
import 'post_detail_screen.dart';
import 'startup_gallery_screen.dart';
import 'exhibition_screen.dart';
import 'create_post_screen.dart';
import '../../../notifications/presentation/screens/notification_screen.dart';
import '../../../community/presentation/screens/discover_communities_screen.dart';
import '../../../profile/presentation/screens/space_screen.dart';
import '../../../chat/presentation/screens/message_center_screen.dart';
class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  int _activeTab = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Dynamic feedback and comment state
  final Map<String, bool> _likedPosts = {};
  final Map<String, int> _likesCountOverride = {};
  final Map<String, bool> _commentsExpanded = {};
  final Map<String, List<Map<String, dynamic>>> _customComments = {};
  final TextEditingController _commentInputCtrl = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  String? _replyingToPostId;
  int? _replyingToCommentIndex;
  String? _replyingToName;

  @override
  void dispose() {
    _commentInputCtrl.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F2EF), // Neutral Grey page canvas background
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480), // Restrict to mobile width
            color: Colors.white,
            child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.white,
              drawer: _buildProfileDrawer(),
              body: Column(
                children: [
                  if (_activeTab == 0) ...[
                    // 1. Top App Bar (Instagram style, Light Theme)
                    Container(
                      color: Colors.white, // Light background
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
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
                                    width: 32,
                                    height: 32,
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
                              const Text(
                                'Acadyk',
                                style: TextStyle(
                                  color: Colors.black, // Dark text for bright mode
                                  fontSize: 32, // Slightly larger for Billabong
                                  fontFamily: 'Billabong', // Exact Instagram style font
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(width: 4), // Small gap between 'k' and arrow
                              const Icon(Icons.keyboard_arrow_down, color: Colors.black87, size: 24),
                            ],
                          ),
                          
                          // Right: Heart
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
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF3F4F6), // Light grey circle
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(CupertinoIcons.search, color: Colors.black87, size: 16),
                                  ),
                                ),
                                const SizedBox(width: 12),
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
                                      const Icon(CupertinoIcons.heart, color: Colors.black87, size: 28),
                                      Positioned(
                                        top: -1,
                                        right: -2,
                                        child: Container(
                                          width: 10,
                                          height: 10,
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
                    const Divider(height: 1, color: Color(0xFFE0E0E0)),

                    // 2. Scrollable List of Posts (re-ordered and curated)
                    Expanded(
                      child: Container(
                        color: const Color(0xFFF3F2EF),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            // Post 1: Y Combinator
                            _buildYCPostCard(),

                            // Post 2: TIME
                            _buildTIMEPostCard(),

                            // Post 3: Alina Sprongole
                            _buildAlinaPostCard(),

                            // Post 4: P Dharmik
                            _buildDharmikPostCard(),

                            // Post 5: Repost Card
                            _buildRepostCard(),

                            const SizedBox(height: 16.0),
                          ],
                        ),
                      ),
                    ),
                  ] else if (_activeTab == 1) ...[
                    const Expanded(
                      child: DiscoverOpportunitiesScreen(),
                    ),
                  ] else if (_activeTab == 4) ...[
                    const Expanded(
                      child: ProfileScreen(isOwnProfile: true),
                    ),
                  ] else ...[
                    const Spacer(),
                  ],

                  // 3. Bottom Tab Bar
                  const Divider(height: 1, color: Color(0xFFE0E0E0)),
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
    return Container(
      color: Colors.white,
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
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Y Combinator',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: Color(0xFF191919),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.verified, size: 14, color: Color(0xFF5E5E5E)),
                          ],
                        ),
                        Text(
                          '21h • Edited',
                          style: TextStyle(color: Color(0xFF5E5E5E), fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showPostOptionsBottomSheet(context, {
                    'name': 'Y Combinator',
                    'avatarText': 'Y',
                    'avatarColor': const Color(0xFFFF6600),
                    'dateJoined': 'March 2005',
                    'location': 'United States',
                    'sharedFollowers': 24,
                  }),
                  child: const Icon(Icons.more_vert, color: Color(0xFF5E5E5E)),
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
                style: const TextStyle(color: Color(0xFF191919), fontSize: 13.5, height: 1.45),
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
                    style: const TextStyle(
                      color: Color(0xFF191919),
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
          Image.asset(
            'assets/images/warp_team.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
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
      color: Colors.white,
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
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'TIME',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: Color(0xFF191919),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.verified, size: 14, color: Color(0xFF5E5E5E)),
                          ],
                        ),
                        Text(
                          '2,484,746 followers',
                          style: TextStyle(color: Color(0xFF5E5E5E), fontSize: 11.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Hyped',
                          style: TextStyle(
                            color: Color(0xFF5E5E5E),
                            fontSize: 11.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showPostOptionsBottomSheet(context, {
                    'name': 'TIME',
                    'avatarText': 'TIME',
                    'avatarColor': const Color(0xFFE50914),
                    'dateJoined': 'October 2010',
                    'location': 'United States',
                    'sharedFollowers': 12,
                  }),
                  child: const Icon(Icons.more_vert, color: Color(0xFF5E5E5E)),
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
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'TIME CEO Jessica Sibley sits down with Alisha Moopen, Managing Director & Group CEO of... more',
                style: TextStyle(color: Color(0xFF191919), fontSize: 13.5, height: 1.45),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Image (TIME video frame with play overlays)
          Stack(
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
      color: Colors.white,
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
                          const Text(
                            'Alina Sprongole',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                              color: Color(0xFF191919),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Gold LinkedIn premium square icon
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC5A059),
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                            child: const Text(
                              'in',
                              style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('• 1st', style: TextStyle(color: Color(0xFF5E5E5E), fontSize: 12)),
                        ],
                      ),
                      const Text(
                        'Co-founder & CEO of Vibe Skills | Plu...',
                        style: TextStyle(color: Color(0xFF5E5E5E), fontSize: 11.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Visit my website',
                        style: TextStyle(
                          color: Color(0xFF0A66C2),
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                        ),
                      ),
                      const Text(
                        '1h • ',
                        style: TextStyle(color: Color(0xFF5E5E5E), fontSize: 11.0),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showPostOptionsBottomSheet(context, {
                    'name': 'Alina Sprongole',
                    'avatarUrl': 'assets/images/alina_avatar.jpg',
                    'dateJoined': 'November 2020',
                    'location': 'India',
                    'sharedFollowers': 2,
                  }),
                  child: const Icon(Icons.more_vert, color: Color(0xFF5E5E5E)),
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
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'A \$24M seed valuation is a death sentence. Carta just released their Q1 2026 data. The... more',
                style: TextStyle(color: Color(0xFF191919), fontSize: 13.5, height: 1.45),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Image (crossed-out valuation poster)
          Image.asset(
            'assets/images/valuation_sentence.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
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
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Color(0xFFEEF3F8),
                child: Icon(Icons.person, size: 14, color: Color(0xFF5E5E5E)),
              ),
              SizedBox(width: 8),
              Text(
                'Ankit Sharma likes this',
                style: TextStyle(
                  color: Color(0xFF191919),
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
      color: Colors.white,
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
                const Expanded(
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
                                color: Color(0xFF191919),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'and',
                            style: TextStyle(fontSize: 13.5, color: Color(0xFF191919)),
                          ),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'somraj lodhi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: Color(0xFF191919),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Solid business? Your LinkedIn should...',
                        style: TextStyle(color: Color(0xFF5E5E5E), fontSize: 11.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '14h • ',
                        style: TextStyle(color: Color(0xFF5E5E5E), fontSize: 11.0),
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
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'A 19-year-old left Patna with borrowed money. 50 years later, his company posted \$18.2B in revenue. This is Anil Agarwal - and the story is not... more',
                style: TextStyle(color: Color(0xFF191919), fontSize: 13.5, height: 1.45),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Image (portrait with double badges overlays)
          Stack(
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
      color: Colors.white,
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
                Container(
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
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Gokul Rajaram',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                              color: Color(0xFF191919),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '• Following',
                            style: TextStyle(
                              color: Color(0xFF5E5E5E),
                              fontSize: 13.0,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Investor and Company Helper',
                        style: TextStyle(
                          color: Color(0xFF5E5E5E),
                          fontSize: 12.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showPostOptionsBottomSheet(context, {
                    'name': 'Gokul Rajaram',
                    'avatarUrl': 'assets/images/dharmik_avatar.jpg',
                    'dateJoined': 'Jan 2010',
                    'location': 'United States',
                    'sharedFollowers': 50,
                  }),
                  child: const Icon(Icons.more_vert, color: Color(0xFF5E5E5E)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Reposter Text
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              'This is awesome!!!!',
              style: TextStyle(color: Color(0xFF191919), fontSize: 16.0, height: 1.3),
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
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rahul Thathoo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: Color(0xFF191919),
                                ),
                              ),
                              Text(
                                'Engineering @ OpenAI',
                                style: TextStyle(
                                  color: Color(0xFF5E5E5E),
                                  fontSize: 12.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // + Follow Button
                        Row(
                          children: [
                            const Icon(Icons.add, color: Color(0xFF0A66C2), size: 20),
                            const SizedBox(width: 2),
                            const Text(
                              'Follow',
                              style: TextStyle(
                                color: Color(0xFF0A66C2),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Inner Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: Color(0xFF191919), fontSize: 13.5, height: 1.45),
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
                            style: TextStyle(color: Color(0xFF5E5E5E)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Inner Image
                  ClipRRect(
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
                style: const TextStyle(
                  color: Colors.black87,
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
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Icon(CupertinoIcons.bookmark, size: 24, color: Colors.black87),
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
                                      child: const Text(
                                        'Reply',
                                        style: TextStyle(color: Color(0xFF5E5E5E), fontSize: 12, fontWeight: FontWeight.w600),
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
                                                child: const Text(
                                                  'Reply',
                                                  style: TextStyle(color: Color(0xFF5E5E5E), fontSize: 11, fontWeight: FontWeight.w600),
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
                    style: const TextStyle(fontSize: 11, color: Color(0xFF5E5E5E), fontWeight: FontWeight.w500),
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
                    child: const Icon(Icons.close, size: 14, color: Color(0xFF5E5E5E)),
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
                            reps.add({
                              'name': 'Somraj lodhi',
                              'headline': 'Founder & Builder @ Acadyk',
                              'avatar': 'assets/images/somraj_avatar.jpg',
                              'timeText': 'Just now',
                              'body': text,
                              'likes': 0,
                              'hasLiked': false,
                            });
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
                        reps.add({
                          'name': 'Somraj lodhi',
                          'headline': 'Founder & Builder @ Acadyk',
                          'avatar': 'assets/images/somraj_avatar.jpg',
                          'timeText': 'Just now',
                          'body': text,
                          'likes': 0,
                          'hasLiked': false,
                        });
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

  void _showPostOptionsBottomSheet(BuildContext context, Map<String, dynamic> accountData) {
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
                    _buildTopActionIcon(CupertinoIcons.bookmark, 'Save'),
                    _buildTopActionIcon(CupertinoIcons.repeat, 'Repost'),
                    _buildTopActionIcon(CupertinoIcons.qrcode_viewfinder, 'QR code'),
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

  Widget _buildTopActionIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2), // Light grey for blocks
            borderRadius: BorderRadius.circular(18), // Slightly less rounded
          ),
          child: Icon(icon, color: Colors.black, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w400),
        ),
      ],
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
      constraints: const BoxConstraints(maxWidth: 480),
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
                      label: 'Pin',
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
                      label: 'Collage',
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

  // Bottom Navigation Bar matching the exact requested UI (Instagram/Threads style) - Light Theme
  Widget _buildBottomNavBar() {
    return Container(
      color: Colors.white, // Exact light background color
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home
          GestureDetector(
            onTap: () => setState(() => _activeTab = 0),
            child: Icon(
              CupertinoIcons.house,
              color: _activeTab == 0 ? Colors.black : const Color(0xFF737373),
              size: 28,
            ),
          ),
          // Search
          GestureDetector(
            onTap: () => setState(() => _activeTab = 1),
            child: Icon(
              CupertinoIcons.search,
              color: _activeTab == 1 ? Colors.black : const Color(0xFF737373),
              size: 28,
            ),
          ),
          // Add/Plus
          GestureDetector(
            onTap: () {
              _showCreatePostBottomSheet(context);
            },
            child: Icon(
              CupertinoIcons.add,
              color: _activeTab == 2 ? Colors.black : const Color(0xFF737373),
              size: 32,
            ),
          ),
          // Message/Chat
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MessageCenterScreen()),
              );
            },
            child: Icon(
              CupertinoIcons.ellipses_bubble,
              color: _activeTab == 3 ? Colors.black : const Color(0xFF737373),
              size: 28,
            ),
          ),
          // Profile Avatar
          Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _activeTab == 4 ? Colors.black : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: StatusAvatar(
              avatarAsset: 'assets/images/somraj_avatar.jpg',
              radius: 13.5,
              enableTapToViewStory: false,
              onDefaultTap: () => setState(() => _activeTab = 4),
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
    return Drawer(
      width: 310,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          // Scrollable top content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(); // close drawer
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Somraj Avatar
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Colors.blueGrey, // Subtle tint change
                                BlendMode.modulate,
                              ),
                              child: Container(
                                width: 68,
                                height: 68,
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
                      const SizedBox(height: 12),

                      // Name & Verified Shield Badge
                      Row(
                        children: const [
                          Text(
                            'Alina Sprongole',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF191919),
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.verified_user, size: 18, color: Color(0xFF191919)),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Headline
                      const Text(
                        'Founder | Thinker | Quant Engineer',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF191919),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Location
                      const Text(
                        'Indore, Madhya Pradesh, India',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Color(0xFF5E5E5E),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Company block
                      Row(
                        children: [
                          // Quantaforze Logo
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            padding: const EdgeInsets.all(3.0),
                            child: CustomPaint(
                              painter: const QuantaforzeLogoPainter(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Quantaforze Corporation',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF191919),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 8),

                _buildDrawerNavItem('Profile', onTap: () {
                  Navigator.of(context).pop(); // close drawer
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                }),
                _buildDrawerNavItem('My saves'),
                _buildDrawerNavItem('Startup Galary', onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const StartupGalleryScreen(),
                  ));
                }),
                _buildDrawerNavItem('Clubs'),
                _buildDrawerNavItem('Exhibition', onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ExhibitionScreen(),
                  ));
                }),
                _buildDrawerNavItem('Space', onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SpaceScreen(),
                  ));
                }),
                _buildDrawerNavItem('Community', onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const DiscoverCommunitiesScreen(),
                  ));
                }),
                
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 8),

                _buildDrawerNavItem('Settings'),
                _buildDrawerNavItem('Copilot settings'),
                _buildDrawerNavItem('Feature preview'),
                _buildDrawerNavItem('Appearance', onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AppearanceScreen(),
                  ));
                }),
                _buildDrawerNavItem('Accessibility'),
                _buildDrawerNavItem('Upgrade'),

                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 8),

                _buildDrawerNavItem('Sign out'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerNavItem(String title, {String? trailingBadge, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                color: Color(0xFF191919),
              ),
            ),
            if (trailingBadge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF191919),
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

