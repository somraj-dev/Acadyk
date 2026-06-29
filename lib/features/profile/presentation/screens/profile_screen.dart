import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'settings_activity_screen.dart';
import 'about_account_screen.dart';
import '../../../feed/presentation/screens/create_startup_screen.dart';

import 'edit_status_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isOwnProfile;
  const ProfileScreen({super.key, this.isOwnProfile = true});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _activityKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F2EF),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: const Color(0xFFF3F2EF),
            child: Column(
              children: [
                // Top bar with back arrow
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                  child: Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      const Icon(Icons.search, color: Color(0xFF5E5E5E), size: 24),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SettingsActivityScreen(),
                            ),
                          );
                        },
                        child: const Icon(Icons.menu, color: Color(0xFF5E5E5E), size: 24),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      // =============================================
                      // SECTION 1: Profile Header Card
                      // =============================================
                      _buildProfileHeaderCard(),

                      const SizedBox(height: 8),

                      // =============================================
                      // SECTION 2: About
                      // =============================================
                      _buildAboutSection(),

                      const SizedBox(height: 8),

                      // =============================================
                      // SECTION 3: Featured
                      // =============================================
                      _buildFeaturedSection(),

                      const SizedBox(height: 8),

                      // =============================================
                      // SECTION 4: Activity
                      // =============================================
                      _buildActivitySection(),

                      const SizedBox(height: 8),

                      // =============================================
                      // SECTION 5: Experience
                      // =============================================
                      _buildExperienceSection(),

                      const SizedBox(height: 8),

                      // =============================================
                      // SECTION 6: Education
                      // =============================================
                      _buildEducationSection(),




                      // =============================================
                      // SECTION 8: Projects
                      // =============================================
                      _buildProjectsSection(),

                      const SizedBox(height: 8),

                      // =============================================
                      // SECTION 9: Skills
                      // =============================================
                      _buildSkillsSection(),

                      const SizedBox(height: 24),
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

  // =============================================================
  // PROFILE HEADER CARD
  // =============================================================
  Widget _buildProfileHeaderCard() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner + Profile Photo
          SizedBox(
            height: 160,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Dark banner
                Container(
                  height: 120,
                  width: double.infinity,
                  color: const Color(0xFF1A1A1A),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'CONQUER.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.5,
                          fontFamily: 'serif',
                        ),
                      ),
                      const SizedBox(width: 40),
                      // Edit banner icon
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Profile avatar overlapping the banner
                Positioned(
                  left: 16,
                  top: 64,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3.5),
                        ),
                        child: const StatusAvatar(
                          avatarAsset: 'assets/images/somraj_avatar.jpg',
                          radius: 44.5,
                          isProfilePageAccountHolder: true, // Own profile = no status ring
                        ),
                      ),
                      if (widget.isOwnProfile)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: ValueListenableBuilder<bool>(
                            valueListenable: UserStatusState.statusNotifier,
                            builder: (context, statusValue, child) {
                              final displayEmoji = UserStatusState.emoji ?? '🤕';
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const EditStatusScreen()),
                                  );
                                },
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF161B22), // GitHub dark gray badge
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    displayEmoji,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Space for the overlapping avatar
          const SizedBox(height: 8),


          // Edit profile icon row (right-aligned)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () => _showProfileOptionsBottomSheet(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF5E5E5E), width: 1),
                  ),
                  child: const Icon(Icons.more_horiz, size: 18, color: Color(0xFF5E5E5E)),
                ),
              ),
            ),
          ),

          // Name, badge, pronouns
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text(
                  'Somraj Lodhi',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191919),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.verified_user, size: 20, color: Color(0xFF5E5E5E)),
                const SizedBox(width: 6),
                Text(
                  'He/Him',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Headline
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Founder | Thinker | Quant Engineer',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF191919),
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Company + Education
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Quantaforze Corporation · Madhav Institute of Technology and Science, Gwalior',
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF191919),
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Location
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Indore, Madhya Pradesh, India',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF5E5E5E),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Connections
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '167 connections',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A66C2),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // =============================================================
  // ABOUT SECTION
  // =============================================================
  Widget _buildAboutSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'About',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
              ),
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.transparent),
                ),
                child: const Icon(Icons.edit, size: 20, color: Color(0xFF5E5E5E)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 14, color: Color(0xFF191919), height: 1.5),
              children: [
                TextSpan(
                  text: 'I am a Machine Learning student at Madhav Institute of Technology and Science (MITS), Gwalior, with a strong interest in building scalable technology solutions at the intersection of healthcare and intelligent systems.\nCurrently, I am working on AxioVital, a...',
                ),
                TextSpan(
                  text: ' more',
                  style: TextStyle(color: Color(0xFF5E5E5E), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // FEATURED SECTION
  // =============================================================
  Widget _buildFeaturedSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text(
                  'Featured',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                ),
                const Spacer(),
                const Icon(Icons.add, size: 24, color: Color(0xFF5E5E5E)),
                const SizedBox(width: 16),
                const Icon(Icons.edit, size: 20, color: Color(0xFF5E5E5E)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                const SizedBox(width: 16),
                _buildFeaturedCard(
                  category: 'Post',
                  text: 'Healthcare isn\'t broken because of lack of technology — it\'s broken because of fragmentat...',
                  imageAsset: 'assets/images/arogya_dashboard.jpg',
                  reactions: '13',
                ),
                const SizedBox(width: 12),
                _buildFeaturedCard(
                  category: 'Article',
                  text: 'The Future of Decentralized Teamwork and Remote Engineering Collaborations...',
                  imageAsset: 'assets/images/warp_team.jpg',
                  reactions: '42',
                ),
                const SizedBox(width: 12),
                _buildFeaturedCard(
                  category: 'Post',
                  text: 'Deeply honored to be recognized among the top young innovators and entrepreneurs of this year...',
                  imageAsset: 'assets/images/young_entrepreneur.jpg',
                  reactions: '58',
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard({
    required String category,
    required String text,
    required String imageAsset,
    required String reactions,
  }) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Text(
              category,
              style: const TextStyle(fontSize: 12, color: Color(0xFF5E5E5E)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              height: 40,
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Color(0xFF191919), fontWeight: FontWeight.w500, height: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(7),
              bottomRight: Radius.circular(7),
            ),
            child: Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 180,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0A66C2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.thumb_up, size: 10, color: Colors.white),
                ),
                const SizedBox(width: 4),
                Text(reactions, style: const TextStyle(fontSize: 13, color: Color(0xFF5E5E5E))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // ACTIVITY SECTION
  // =============================================================
  Widget _buildActivitySection() {
    return Container(
      key: _activityKey,
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Activity',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
              ),
              Text(
                '168 followers',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A66C2)),
              ),
            ],
          ),
          const SizedBox(height: 14),



          // Activity post
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Somraj Lodhi',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_user, size: 14, color: Color(0xFF5E5E5E)),
                        const SizedBox(width: 4),
                        Text('• You', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                    Text(
                      'Founder | Thinker | Quant Engineer',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Row(
                      children: [
                        Text('3w • Edited • ', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        Icon(Icons.public, size: 12, color: Colors.grey[600]),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, size: 20, color: Color(0xFF5E5E5E)),
            ],
          ),
          const SizedBox(height: 10),

          // Post text
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 14, color: Color(0xFF191919), height: 1.45),
              children: [
                TextSpan(text: 'Akedex is built on a universal identity fabric for education. Every learner receives a lifelong Universal Academic ID from the first day of...'),
                TextSpan(
                  text: ' more',
                  style: TextStyle(color: Color(0xFF5E5E5E), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Dark post image
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: double.infinity,
              height: 260,
              color: const Color(0xFF2A2A2A),
              child: Stack(
                children: [
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.bottomCenter,
                        radius: 1.2,
                        colors: [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Text content
                  const Positioned(
                    left: 24,
                    top: 80,
                    child: Text(
                      'SOMETHING NEW\nIS COMING.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  // Sparkle star
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Icon(Icons.auto_awesome, size: 18, color: Colors.white.withValues(alpha: 0.9)),
                    ),
                  ),
                  // Bottom text
                  Positioned(
                    bottom: 30,
                    left: 24,
                    right: 24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'More thoughtful.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                        ),
                        Text(
                          'More intelligent.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Engagement bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.heart, size: 24, color: Colors.black87),
                  const SizedBox(width: 6),
                  const Text(
                    '5',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(CupertinoIcons.chat_bubble, size: 24, color: Colors.black87),
                  const SizedBox(width: 6),
                  const Text(
                    '0',
                    style: TextStyle(
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
        ],
      ),
    );
  }

  // =============================================================
  // EXPERIENCE SECTION
  // =============================================================
  Widget _buildExperienceSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Experience', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
              const Spacer(),
              const Icon(Icons.add, size: 24, color: Color(0xFF5E5E5E)),
              const SizedBox(width: 16),
              const Icon(Icons.edit, size: 20, color: Color(0xFF5E5E5E)),
            ],
          ),
          const SizedBox(height: 16),

          // Quantaforze entry
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company logo
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.crop_square, size: 24, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Founder', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
                    Text('Quantaforze Corporation · Full-time', style: TextStyle(fontSize: 13, color: Color(0xFF191919))),
                    Text('Oct 2025 - Present · 9 mos', style: TextStyle(fontSize: 13, color: Color(0xFF5E5E5E))),
                    Text('Gwalior, Madhya Pradesh, India · On-site', style: TextStyle(fontSize: 13, color: Color(0xFF5E5E5E))),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.diamond, size: 14, color: Color(0xFF5E5E5E)),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Start-up Leadership and Business Ownership',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================================
  // EDUCATION SECTION
  // =============================================================
  Widget _buildEducationSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Education', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
              const Spacer(),
              const Icon(Icons.add, size: 24, color: Color(0xFF5E5E5E)),
              const SizedBox(width: 16),
              const Icon(Icons.edit, size: 20, color: Color(0xFF5E5E5E)),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // College logo placeholder
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.school, size: 22, color: Color(0xFF5E5E5E)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Madhav Institute of Technology and Science, Gwalior',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                    ),
                    Text(
                      'Bachelor of Technology - BTech, Artificial intelligence and machine learning',
                      style: TextStyle(fontSize: 13, color: Color(0xFF191919)),
                    ),
                    Text(
                      'Aug 2025 – Aug 2029',
                      style: TextStyle(fontSize: 13, color: Color(0xFF5E5E5E)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================================
  // CONNECTED APPS SECTION
  // =============================================================
  Widget _buildConnectedAppsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFBDBDBD), style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Connected apps',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                ),
                const Icon(Icons.close, size: 22, color: Color(0xFF5E5E5E)),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Add the products you use to stand out and get more profile views.',
              style: TextStyle(fontSize: 13, color: Color(0xFF5E5E5E), height: 1.4),
            ),
            const SizedBox(height: 14),

            // App grid
            Row(
              children: [
                Expanded(child: _buildAppChip('Gamma', Icons.g_mobiledata, const Color(0xFF7C3AED))),
                const SizedBox(width: 10),
                Expanded(child: _buildAppChip('IntelliJ\nIDEA', Icons.code, const Color(0xFFE91E63))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildAppChip('HubSpot', Icons.hub, const Color(0xFFFF7043))),
                const SizedBox(width: 10),
                Expanded(child: _buildAppChip('Replit', Icons.terminal, const Color(0xFFFF5722))),
              ],
            ),
            const SizedBox(height: 14),

            // Add connected apps button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0A66C2),
                  side: const BorderSide(color: Color(0xFF0A66C2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text(
                  'Add connected apps',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // PROJECTS SECTION
  // =============================================================
  Widget _buildProjectsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Projects (3)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
              const Spacer(),
              const Icon(Icons.add, size: 24, color: Color(0xFF5E5E5E)),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateStartupScreen(),
                    ),
                  );
                },
                child: const Icon(Icons.edit, size: 20, color: Color(0xFF5E5E5E)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Project 1: Acadex
          const Text('Acadex', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
          const Text('Feb 2026 – Present', style: TextStyle(fontSize: 13, color: Color(0xFF5E5E5E))),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(3)),
                child: const Icon(Icons.crop_square, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 6),
              const Text('Associated with Quantaforze Corporation', style: TextStyle(fontSize: 13, color: Color(0xFF191919))),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 14, color: Color(0xFF191919), height: 1.4),
              children: [
                TextSpan(text: '"Acadex is a school-to-school or institute to institute student records and workflow network that...'),
                TextSpan(text: ' more', style: TextStyle(color: Color(0xFF5E5E5E), fontWeight: FontWeight.w500)),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 16),

          // Project 2: Axiovital
          const Text('Axiovital', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(3)),
                child: const Icon(Icons.crop_square, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 6),
              const Text('Associated with Quantaforze Corporation', style: TextStyle(fontSize: 13, color: Color(0xFF191919))),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 14, color: Color(0xFF191919), height: 1.4),
              children: [
                TextSpan(text: 'AxioVital is building the digital infrastructure layer for modern healthcare — connecting patients,...'),
                TextSpan(text: ' more', style: TextStyle(color: Color(0xFF5E5E5E), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Other contributors
          const Text('Other contributors', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: AssetImage('assets/images/somraj_avatar.jpg'), fit: BoxFit.cover),
                ),
              ),
              Transform.translate(
                offset: const Offset(-8, 0),
                child: Container(
                  width: 36, height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: AssetImage('assets/images/dharmik_avatar.jpg'), fit: BoxFit.cover),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(-16, 0),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF0F0F0),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  alignment: Alignment.center,
                  child: const Text('+3', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5E5E5E))),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Show all link
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Show all',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 18, color: Color(0xFF191919)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // SKILLS SECTION
  // =============================================================
  Widget _buildSkillsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Skills', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
              const Spacer(),
              const Icon(Icons.add, size: 24, color: Color(0xFF5E5E5E)),
              const SizedBox(width: 16),
              const Icon(Icons.edit, size: 20, color: Color(0xFF5E5E5E)),
            ],
          ),
          const SizedBox(height: 16),

          // Skill 1
          const Text('Start-up Leadership', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(3)),
                child: const Icon(Icons.crop_square, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text('Founder at Quantaforze Corporation', style: TextStyle(fontSize: 13, color: Color(0xFF191919))),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 16),

          // Skill 2
          const Text('Business Ownership', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(3)),
                child: const Icon(Icons.crop_square, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text('Founder at Quantaforze Corporation', style: TextStyle(fontSize: 13, color: Color(0xFF191919))),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================================
  // HELPERS
  // =============================================================



  Widget _buildAppChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF191919)),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // BOTTOM SHEETS & POPUPS
  // =============================================================
  void _showProfileOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              _buildBottomSheetOption(
                icon: Icons.near_me_outlined,
                title: 'Send profile in a message',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: const [
                          Icon(Icons.check_circle_outline, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Profile sent in a message successfully!'),
                        ],
                      ),
                      backgroundColor: const Color(0xFF262626),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.share_outlined,
                title: 'Share via...',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: const [
                          Icon(Icons.share_outlined, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Share options loaded!'),
                        ],
                      ),
                      backgroundColor: const Color(0xFF262626),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.import_contacts_outlined,
                title: 'Contact info',
                onTap: () {
                  Navigator.pop(context);
                  _showContactInfoBottomSheet(context);
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.assignment_outlined,
                title: 'Activity',
                onTap: () {
                  Navigator.pop(context);
                  if (_activityKey.currentContext != null) {
                    Scrollable.ensureVisible(
                      _activityKey.currentContext!,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.bookmark_border,
                title: 'Saved items',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: const [
                          Icon(Icons.bookmark_outline, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Saved items loaded!'),
                        ],
                      ),
                      backgroundColor: const Color(0xFF262626),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.info_outline,
                title: 'About this member',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AboutAccountScreen(
                        accountData: {
                          'name': 'Somraj Lodhi',
                          'avatarUrl': 'assets/images/somraj_avatar.jpg',
                          'dateJoined': 'June 2024',
                          'location': 'Indore, India',
                          'sharedFollowers': 18,
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showContactInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 16),
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Contact info',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF262626),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildContactInfoTile(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: 'somraj.lodhi@acadyk.com',
                ),
                const SizedBox(height: 16),
                _buildContactInfoTile(
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  value: '+91 98765 43210',
                ),
                const SizedBox(height: 16),
                _buildContactInfoTile(
                  icon: Icons.link,
                  title: 'Website',
                  value: 'https://acadyk.com/somraj',
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, size: 26, color: const Color(0xFF262626)),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF262626),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F2EF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 22, color: const Color(0xFF5E5E5E)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF5E5E5E),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF191919),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

