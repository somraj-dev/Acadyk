import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                      const Icon(Icons.settings, color: Color(0xFF5E5E5E), size: 24),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: ListView(
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
          Stack(
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
                bottom: -40,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3.5),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/somraj_avatar.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Space for the overlapping avatar
          const SizedBox(height: 48),

          // Edit profile icon row (right-aligned)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF5E5E5E), width: 1),
                ),
                child: const Icon(Icons.edit, size: 16, color: Color(0xFF5E5E5E)),
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          const SizedBox(height: 16),

          // Featured post card
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Text(
                    'Post',
                    style: TextStyle(fontSize: 12, color: Color(0xFF5E5E5E)),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Healthcare isn\'t broken because of lack of technology — it\'s broken because of fragmentat...',
                    style: TextStyle(fontSize: 14, color: Color(0xFF191919), fontWeight: FontWeight.w500, height: 1.4),
                  ),
                ),
                const SizedBox(height: 8),
                // Featured post image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                  child: Image.asset(
                    'assets/images/arogya_dashboard.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
                // Reaction count
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 18, height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0A66C2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.thumb_up, size: 10, color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      const Text('13', style: TextStyle(fontSize: 13, color: Color(0xFF5E5E5E))),
                    ],
                  ),
                ),
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
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              const Expanded(
                child: Column(
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
              ),
              OutlinedButton(
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF5E5E5E)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                ),
                child: const Text(
                  'Create a post',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.edit, size: 20, color: Color(0xFF5E5E5E)),
            ],
          ),
          const SizedBox(height: 14),

          // Tab pills
          Row(
            children: [
              _buildPill('Posts', filled: true),
              const SizedBox(width: 8),
              _buildPill('Comments'),
              const SizedBox(width: 8),
              _buildPill('Videos'),
              const SizedBox(width: 8),
              _buildPill('Images'),
            ],
          ),
          const SizedBox(height: 16),

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
              const Icon(Icons.edit, size: 20, color: Color(0xFF5E5E5E)),
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

  Widget _buildPill(String text, {bool filled = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? const Color(0xFF1B7A2D) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: filled ? const Color(0xFF1B7A2D) : const Color(0xFF5E5E5E)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: filled ? Colors.white : const Color(0xFF191919),
        ),
      ),
    );
  }

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
}
