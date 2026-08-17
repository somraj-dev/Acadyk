import 'package:flutter/material.dart';
import 'package:acadyk/features/profile/presentation/screens/profile_screen.dart';
import '../community_profile_screen.dart';

class CreateCommunitySuccessScreen extends StatelessWidget {
  final String communityName;
  final String description;
  final String categoryTag;

  const CreateCommunitySuccessScreen({
    super.key,
    required this.communityName,
    required this.description,
    this.categoryTag = 'Student Community',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B141A) : const Color(0xFFFAF8F5);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? const Color(0xFF8696A0) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background Festive Gradient
          Container(
            height: MediaQuery.of(context).size.height * 0.40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF3B2F0F),
                        const Color(0xFF1E1B10),
                        const Color(0xFF0B141A),
                      ]
                    : [
                        const Color(0xFFFFF7ED),
                        const Color(0xFFFEF3C7).withValues(alpha: 0.5),
                        const Color(0xFFFAF8F5),
                      ],
              ),
            ),
          ),

          // Confetti dots
          Positioned(bottom: 120, right: 30, child: _buildConfettiSquare(Colors.redAccent, 12, 0.2)),
          Positioned(bottom: 240, left: 30, child: _buildConfettiSquare(Colors.orange, 9, -0.4)),
          Positioned(bottom: 50, left: 60, child: _buildConfettiSquare(Colors.greenAccent, 10, 0.5)),
          Positioned(bottom: 20, right: 20, child: _buildConfettiSquare(Colors.blueAccent, 12, -0.2)),
          Positioned(top: 80, right: 25, child: _buildConfettiSquare(const Color(0xFFEA580C), 10, 0.3)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    'You launched a new\ncommunity! 🎉',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // =========================================================
                  // COMMUNITY PREVIEW CARD (Image 1 Design Adapted for New Community)
                  // =========================================================
                  _buildNewCommunityCard(context, isDark),
                  const SizedBox(height: 20),

                  // =========================================================
                  // INFO / GUIDANCE SECTION
                  // =========================================================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF162026) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2A3942) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Here's what you should know",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "We've applied recommended student settings. You can edit permissions and guidelines anytime in your mod tools.",
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 13.5,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: _buildCheckButton('Rules', isDark)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildCheckButton('Community Guide', isDark)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // =========================================================
                  // MAIN ACTION BUTTONS
                  // =========================================================
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommunityProfileScreen(
                              communityName: communityName,
                              description: description,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF09122C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Go To Community Page',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invite link copied to clipboard! 📋'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Color(0xFF0F172A),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? const Color(0xFF3B4A54) : const Color(0xFFCBD5E1),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Share Invite Link',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // NEW COMMUNITY CARD (Matches the Image 1 Aesthetic for New Communities)
  // ===========================================================================
  Widget _buildNewCommunityCard(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF162026) : Colors.white;
    final cardBorderColor = isDark ? const Color(0xFF2A3942) : const Color(0xFFF1EBE5);
    final cardTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardSubtextColor = isDark ? const Color(0xFF8696A0) : const Color(0xFF475569);

    final displayDescription = description.isNotEmpty
        ? description
        : 'A place for students to learn, collaborate, share resources & grow together.';

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEA580C).withValues(alpha: isDark ? 0.1 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Emblem + Name + Subtitle + Rating + Tag)
            _buildCardHeader(isDark, cardTextColor),
            const SizedBox(height: 12),

            // 2. Description
            Text(
              displayDescription,
              style: TextStyle(
                fontSize: 13.5,
                color: cardSubtextColor,
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 14),

            // 3. 4-Column Key Metrics Stats Row (Adapted for 1st Member / Launch)
            _buildKeyMetrics(isDark),
            const SizedBox(height: 14),

            // 4. Active Members Section (New State: 1 Founder + Invite Button)
            _buildActiveMembersSection(isDark),
            const SizedBox(height: 12),

            // 5. Founder / Top Contributor Section
            _buildFounderSection(context, isDark),
            const SizedBox(height: 12),

            // 6. Feature Chips
            _buildFeatureChips(isDark),
          ],
        ),
      ),
    );
  }

  // Header Section
  Widget _buildCardHeader(bool isDark, Color cardTextColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // MITS Heritage Dome Emblem Badge
        _buildEmblemBadge(),
        const SizedBox(width: 12),

        // Title, Subtitle, Rating, Tag
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      communityName,
                      style: TextStyle(
                        fontSize: 18.5,
                        fontWeight: FontWeight.w800,
                        color: cardTextColor,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEA580C),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),

              Text(
                'Student Community',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF8696A0) : const Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),

              // Rating + Reviews + Category Tag
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
                      SizedBox(width: 3),
                      Text(
                        '5.0',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const Text('|', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),

                  const Text(
                    '1 Review',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                  const Text('|', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF97316), width: 1),
                    ),
                    child: Text(
                      categoryTag,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEA580C),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Emblem Badge
  Widget _buildEmblemBadge() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              Positioned(
                top: 0,
                child: Container(
                  width: 3,
                  height: 3,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF97316),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          const Text(
            'MITS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 7.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              height: 1.0,
            ),
          ),
          const Text(
            'GWALIOR',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 5.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // Key Metrics Bar
  Widget _buildKeyMetrics(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2931) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3942) : const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 1. Members (1)
          Expanded(
            child: _buildMetricItem(
              icon: Icons.people_outline_rounded,
              primaryText: '1',
              secondaryText: 'Member',
              isPrimaryTop: true,
              isDark: isDark,
            ),
          ),
          _buildVerticalDivider(isDark),

          // 2. Online (1)
          Expanded(
            child: _buildMetricItem(
              icon: Icons.bolt_rounded,
              primaryText: '1',
              secondaryText: 'Online',
              isPrimaryTop: true,
              isDark: isDark,
            ),
          ),
          _buildVerticalDivider(isDark),

          // 3. Since Aug 2026
          Expanded(
            child: _buildMetricItem(
              icon: Icons.calendar_today_outlined,
              primaryText: 'Aug 2026',
              secondaryText: 'Since',
              isPrimaryTop: false,
              isDark: isDark,
            ),
          ),
          _buildVerticalDivider(isDark),

          // 4. Verified Community
          Expanded(
            child: _buildMetricItem(
              icon: Icons.verified_user_outlined,
              primaryText: 'Verified',
              secondaryText: 'Community',
              isPrimaryTop: true,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String primaryText,
    required String secondaryText,
    required bool isPrimaryTop,
    required bool isDark,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFFEA580C), size: 14),
            ),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPrimaryTop) ...[
                  Text(
                    primaryText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      height: 1.1,
                    ),
                  ),
                  Text(
                    secondaryText,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF8696A0) : const Color(0xFF64748B),
                      height: 1.1,
                    ),
                  ),
                ] else ...[
                  Text(
                    secondaryText,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF8696A0) : const Color(0xFF64748B),
                      height: 1.1,
                    ),
                  ),
                  Text(
                    primaryText,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      height: 1.1,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: isDark ? const Color(0xFF2A3942) : const Color(0xFFE2E8F0),
    );
  }

  // Active Members Section (New State)
  Widget _buildActiveMembersSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2931) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3942) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Members',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const Text(
                '1 online',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Avatars Row: Founder + Invite Bubble
          Row(
            children: [
              // Founder Avatar with online dot
              SizedBox(
                width: 38,
                height: 38,
                child: Stack(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/somraj_avatar.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFCBD5E1),
                            child: const Icon(Icons.person, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // + Invite Bubble Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFEDD5), width: 1.2),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add_alt_1_rounded, size: 14, color: Color(0xFFEA580C)),
                    SizedBox(width: 5),
                    Text(
                      'Invite Classmates',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEA580C),
                      ),
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

  // Founder Section
  Widget _buildFounderSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2931) : const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3942) : const Color(0xFFFED7AA),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Founder Avatar with Star Badge
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/somraj_avatar.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFCBD5E1),
                        child: const Icon(Icons.person, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEA580C),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 9,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Community Founder',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEA580C),
                  ),
                ),
                Text(
                  'Somraj Lodhi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Active • Founder',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? const Color(0xFF8696A0) : const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // View Profile Outlined Button
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(isOwnProfile: true),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFEA580C), width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              minimumSize: const Size(72, 28),
            ),
            child: const Text(
              'View Profile',
              style: TextStyle(
                color: Color(0xFFEA580C),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Feature Quick Action Pills
  Widget _buildFeatureChips(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPillChip(icon: Icons.menu_book_rounded, label: 'Resources', isDark: isDark),
          const SizedBox(width: 6),
          _buildPillChip(icon: Icons.chat_bubble_outline_rounded, label: 'Discussions', isDark: isDark),
          const SizedBox(width: 6),
          _buildPillChip(icon: Icons.groups_outlined, label: 'Study Groups', isDark: isDark),
          const SizedBox(width: 6),
          _buildPillChip(icon: Icons.calendar_today_outlined, label: 'Events', isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildPillChip({required IconData icon, required String label, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2931) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3942) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: isDark ? Colors.white : const Color(0xFF1E293B)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckButton(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2931) : Colors.white,
        border: Border.all(
          color: isDark ? const Color(0xFF2A3942) : const Color(0xFFE2E8F0),
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 17),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfettiSquare(Color color, double size, double rotation) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size,
        color: color,
      ),
    );
  }
}
