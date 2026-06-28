import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../profile/presentation/screens/appearance_screen.dart';
import '../../../profile/presentation/screens/about_account_screen.dart';
import 'post_detail_screen.dart';
import 'startup_gallery_screen.dart';
import 'exhibition_screen.dart';
import 'create_post_screen.dart';
import '../../../notifications/presentation/screens/notification_screen.dart';
import '../../../community/presentation/screens/discover_communities_screen.dart';
import '../../../chat/presentation/screens/message_center_screen.dart';
class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  int _activeTab = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                                    color: Color(0xFF1E1F22), // Dark grey circle
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(CupertinoIcons.search, color: Colors.white, size: 16),
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
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ));
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
              children: [
                // YC Profile square logo
                Container(
                  width: 40,
                  height: 40,
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
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
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
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(color: Color(0xFF191919), fontSize: 13.5, height: 1.45),
                  children: [
                    TextSpan(
                      text: 'Warp',
                      style: TextStyle(
                        color: Color(0xFF0A66C2),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(
                      text: ' has raised \$60 million in Series B funding to automate payroll, HR, tax compliance, and employee onboarding. ...more',
                    ),
                  ],
                ),
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
            likes: '537',
            comments: '51',
          ),
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
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ));
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
              children: [
                // TIME red square logo
                Container(
                  width: 40,
                  height: 40,
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
                      fontSize: 9.5,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
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
                        'Promoted',
                        style: TextStyle(
                          color: Color(0xFF5E5E5E),
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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

          // Engagement Row (TIME post reaction bar)
          _buildPostActionRow(
            likes: '1,204',
            comments: '89',
          ),
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
                builder: (_) => const ProfileScreen(),
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
            likes: '23',
            comments: '15',
          ),
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
                builder: (_) => const ProfileScreen(),
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
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage('assets/images/somraj_avatar.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
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
            likes: '1,492',
            comments: '235',
          ),
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
            likes: '892',
            comments: '124',
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // REUSABLE FEEDBACK ACTION ROW
  // -------------------------------------------------------------

  Widget _buildPostActionRow({
    required String likes,
    required String comments,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.heart, size: 24, color: Colors.black87),
              const SizedBox(width: 6),
              Text(
                likes,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(CupertinoIcons.chat_bubble, size: 24, color: Colors.black87),
              const SizedBox(width: 6),
              Text(
                comments,
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Collage creation coming soon!'),
                            duration: Duration(seconds: 2),
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
          GestureDetector(
            onTap: () => setState(() => _activeTab = 4),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _activeTab == 4 ? Colors.black : Colors.transparent,
                  width: 1.5,
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/images/somraj_avatar.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
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
                _buildDrawerNavItem('Space'),
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
    'Y Combinator',
    'Horror Circus tarot deck',
    'Gandalf the White',
    'Parks Europe',
    'Alina Sprongole',
    'Startup Gallery',
    'Clubs',
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
    return Container(
      color: const Color(0xFFF3F2EF),
      child: Center(
        child: Text(
          'No results found for "$query"',
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
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

