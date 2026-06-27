import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'post_detail_screen.dart';
import 'startup_gallery_screen.dart';

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
                              Stack(
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
          Padding(
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
                const Icon(Icons.more_horiz, color: Color(0xFF5E5E5E)),
                const SizedBox(width: 10),
                const Icon(Icons.close, color: Color(0xFF5E5E5E)),
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
          _buildLinkedInActionRow(
            likes: '537',
            comments: '51',
            reposts: '24',
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
          Padding(
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
                const Icon(Icons.more_horiz, color: Color(0xFF5E5E5E)),
                const SizedBox(width: 10),
                const Icon(Icons.close, color: Color(0xFF5E5E5E)),
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

          // Engagement Row (TIME post reaction bar)
          _buildLinkedInActionRow(
            likes: '1,204',
            comments: '89',
            reposts: '',
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
          Padding(
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
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 14, color: Color(0xFF0A66C2)),
                  label: const Text(
                    'Follow',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A66C2)),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
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
          _buildLinkedInActionRow(
            likes: '23',
            comments: '15',
            reposts: '',
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
          Row(
            children: [
              Icon(Icons.more_horiz, size: 18, color: Color(0xFF5E5E5E)),
              SizedBox(width: 10),
              Icon(Icons.close, size: 18, color: Color(0xFF5E5E5E)),
            ],
          ),
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
          Padding(
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
          _buildLinkedInActionRow(
            likes: '1,492',
            comments: '235',
            reposts: '48',
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // REUSABLE FEEDBACK ACTION ROW
  // -------------------------------------------------------------

  Widget _buildLinkedInActionRow({
    required String likes,
    required String comments,
    required String reposts,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: User avatar, down arrow, and engagement counters
          Row(
            children: [
              // User Avatar circular photo
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/user_avatar.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.arrow_drop_down, size: 14, color: Color(0xFF5E5E5E)),
              const SizedBox(width: 10),

              // Like Trigger + count
              const Icon(Icons.thumb_up_alt_outlined, size: 16, color: Color(0xFF5E5E5E)),
              const SizedBox(width: 4),
              Text(likes, style: const TextStyle(color: Color(0xFF5E5E5E), fontSize: 12.0, fontWeight: FontWeight.bold)),
              const SizedBox(width: 14),

              // Comment Trigger + count
              const Icon(Icons.comment_outlined, size: 16, color: Color(0xFF5E5E5E)),
              const SizedBox(width: 4),
              Text(comments, style: const TextStyle(color: Color(0xFF5E5E5E), fontSize: 12.0, fontWeight: FontWeight.bold)),
              const SizedBox(width: 14),

              // Repost Trigger + count (if present)
              if (reposts.isNotEmpty && reposts != '0') ...[
                const Icon(Icons.repeat, size: 16, color: Color(0xFF5E5E5E)),
                const SizedBox(width: 4),
                Text(reposts, style: const TextStyle(color: Color(0xFF5E5E5E), fontSize: 12.0, fontWeight: FontWeight.bold)),
                const SizedBox(width: 14),
              ],

              // Send/Share Trigger
              const Icon(Icons.send_outlined, size: 16, color: Color(0xFF5E5E5E)),
            ],
          ),

          // Right: Overlapping reaction circle badges
          Row(
            children: [
              _buildReactionBadge(const Color(0xFF0A66C2), Icons.thumb_up, 10.0), // Blue Like
              Transform.translate(
                offset: const Offset(-4, 0),
                child: _buildReactionBadge(const Color(0xFF10B981), Icons.psychology, 10.0), // Green Insight
              ),
              Transform.translate(
                offset: const Offset(-8, 0),
                child: _buildReactionBadge(const Color(0xFFEF4444), Icons.favorite, 10.0), // Red Heart
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Small circular reaction icon badge helper
  Widget _buildReactionBadge(Color color, IconData icon, double size) {
    return Container(
      width: size * 1.6,
      height: size * 1.6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.0),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.9, color: Colors.white),
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
            onTap: () => setState(() => _activeTab = 2),
            child: Icon(
              CupertinoIcons.add,
              color: _activeTab == 2 ? Colors.black : const Color(0xFF737373),
              size: 32,
            ),
          ),
          // Message/Chat
          GestureDetector(
            onTap: () => setState(() => _activeTab = 3),
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
                _buildDrawerNavItem('Repositories'),
                _buildDrawerNavItem('Startup Galary', onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const StartupGalleryScreen(),
                  ));
                }),
                _buildDrawerNavItem('Gists'),
                _buildDrawerNavItem('Organizations'),
                _buildDrawerNavItem('Enterprises'),
                _buildDrawerNavItem('Sponsors'),
                
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 8),

                _buildDrawerNavItem('Settings'),
                _buildDrawerNavItem('Copilot settings'),
                _buildDrawerNavItem('Feature preview'),
                _buildDrawerNavItem('Appearance'),
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

