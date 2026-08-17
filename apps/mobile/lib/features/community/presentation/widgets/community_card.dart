import 'package:flutter/material.dart';
import 'package:acadyk/features/profile/presentation/screens/profile_screen.dart';
import '../screens/public_community_screen.dart';

class CommunityCardData {
  final String id;
  final String name;
  final String subtitle;
  final String? logoUrl;
  final double rating;
  final int reviewsCount;
  final String categoryTag;
  final String description;
  final int membersCount;
  final int onlineCount;
  final String establishedDate;
  final bool isVerified;
  final String topContributorName;
  final String topContributorAvatar;
  final int topContributorContributions;
  final List<String> activeMemberAvatars;
  final int remainingActiveMembersCount;

  const CommunityCardData({
    required this.id,
    required this.name,
    required this.subtitle,
    this.logoUrl,
    this.rating = 4.8,
    this.reviewsCount = 256,
    this.categoryTag = 'Student Community',
    required this.description,
    this.membersCount = 412,
    this.onlineCount = 78,
    this.establishedDate = 'Aug 2025',
    this.isVerified = true,
    this.topContributorName = 'Somraj Lodhi',
    this.topContributorAvatar = 'assets/images/somraj_avatar.jpg',
    this.topContributorContributions = 128,
    this.activeMemberAvatars = const [
      'assets/images/young_entrepreneur.jpg',
      'assets/images/alina_avatar.jpg',
      'assets/images/dharmik_avatar.jpg',
      'assets/images/user_avatar.jpg',
      'assets/images/somraj_avatar.jpg',
    ],
    this.remainingActiveMembersCount = 73,
  });
}

class CommunityCard extends StatefulWidget {
  final CommunityCardData data;
  final VoidCallback? onJoinTap;
  final VoidCallback? onCardTap;

  const CommunityCard({
    super.key,
    required this.data,
    this.onJoinTap,
    this.onCardTap,
  });

  @override
  State<CommunityCard> createState() => _CommunityCardState();
}

class _CommunityCardState extends State<CommunityCard> {
  bool _isJoined = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF1EBE5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEA580C).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onCardTap ??
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PublicCommunityScreen(
                        communityName: d.name,
                        description: d.description,
                        visitors: '${d.membersCount} members',
                        logoUrl: d.logoUrl,
                      ),
                    ),
                  );
                },
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header: Logo Badge + Title + Subtitle + Reviews + Tag
                  _buildHeader(d),
                  const SizedBox(height: 14),

                  // 2. Community Description
                  Text(
                    d.description,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF475569),
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. 4-Column Key Metrics Stats Row (Fully Adaptive & Responsive)
                  _buildKeyMetrics(d),
                  const SizedBox(height: 16),

                  // 4. Active Members Section
                  _buildActiveMembersSection(d),
                  const SizedBox(height: 14),

                  // 5. Top Contributor Section
                  _buildTopContributorSection(d),
                  const SizedBox(height: 14),

                  // 6. Quick Action Feature Chips (Resources, Discussions, Study Groups, Events)
                  _buildFeatureChips(),
                  const SizedBox(height: 16),

                  // 7. Full-Width Main Action CTA Button
                  _buildJoinButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. HEADER SECTION
  // ===========================================================================
  Widget _buildHeader(CommunityCardData d) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Community Emblem Logo Badge
        _buildEmblemBadge(d),
        const SizedBox(width: 14),

        // Title, Subtitle, Rating, Reviews, Category Tag
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row with Verified Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      d.name,
                      style: const TextStyle(
                        fontSize: 19.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (d.isVerified) ...[
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
                        size: 13,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),

              // Subtitle
              Text(
                d.subtitle,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),

              // Rating, Reviews, and Tag Chip Row
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  // Star Rating
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
                      const SizedBox(width: 3),
                      Text(
                        d.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const Text('|', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13)),

                  // Reviews
                  Text(
                    '${d.reviewsCount} Reviews',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                  const Text('|', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13)),

                  // Student Community Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF97316), width: 1),
                    ),
                    child: Text(
                      d.categoryTag,
                      style: const TextStyle(
                        fontSize: 11.5,
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

  // Emblem Badge with MITS Heritage Dome Icon & GWALIOR
  Widget _buildEmblemBadge(CommunityCardData d) {
    if (d.logoUrl != null && d.logoUrl!.startsWith('http')) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: const Color(0xFF0F172A),
        backgroundImage: NetworkImage(d.logoUrl!),
      );
    }

    return Container(
      width: 58,
      height: 58,
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
          // Dome Spire + Arch
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Positioned(
                top: 0,
                child: Container(
                  width: 3.5,
                  height: 3.5,
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
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              height: 1.0,
            ),
          ),
          const Text(
            'GWALIOR',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 5.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. 4-COLUMN KEY METRICS ROW (Fully Adaptive & Responsive)
  // ===========================================================================
  Widget _buildKeyMetrics(CommunityCardData d) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
      child: Row(
        children: [
          // 1. Members
          Expanded(
            child: _buildMetricItem(
              icon: Icons.people_outline_rounded,
              primaryText: '${d.membersCount}',
              secondaryText: 'Members',
              isPrimaryTop: true,
            ),
          ),
          _buildVerticalDivider(),

          // 2. Online
          Expanded(
            child: _buildMetricItem(
              icon: Icons.bolt_rounded,
              primaryText: '${d.onlineCount}',
              secondaryText: 'Online',
              isPrimaryTop: true,
            ),
          ),
          _buildVerticalDivider(),

          // 3. Since Aug 2025
          Expanded(
            child: _buildMetricItem(
              icon: Icons.calendar_today_outlined,
              primaryText: d.establishedDate,
              secondaryText: 'Since',
              isPrimaryTop: false,
            ),
          ),
          _buildVerticalDivider(),

          // 4. Verified Community
          Expanded(
            child: _buildMetricItem(
              icon: Icons.verified_user_outlined,
              primaryText: 'Verified',
              secondaryText: 'Community',
              isPrimaryTop: true,
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
              child: Icon(icon, color: const Color(0xFFEA580C), size: 15),
            ),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPrimaryTop) ...[
                  Text(
                    primaryText,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      height: 1.1,
                    ),
                  ),
                  Text(
                    secondaryText,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                      height: 1.1,
                    ),
                  ),
                ] else ...[
                  Text(
                    secondaryText,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                      height: 1.1,
                    ),
                  ),
                  Text(
                    primaryText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
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

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 26,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: const Color(0xFFE2E8F0),
    );
  }

  // ===========================================================================
  // 3. ACTIVE MEMBERS SECTION
  // ===========================================================================
  Widget _buildActiveMembersSection(CommunityCardData d) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Members',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                '+${d.remainingActiveMembersCount} more',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0284C7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Avatars Row with adaptive scaling
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                // Avatar 1 with online indicator
                _buildMemberAvatar(d.activeMemberAvatars[0], isOnline: true),
                const SizedBox(width: 8),
                // Avatars 2 - 5
                for (int i = 1; i < d.activeMemberAvatars.length && i < 5; i++) ...[
                  _buildMemberAvatar(d.activeMemberAvatars[i]),
                  const SizedBox(width: 8),
                ],

                // +73 Bubble
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFEDD5), width: 1.2),
                  ),
                  child: Center(
                    child: Text(
                      '+${d.remainingActiveMembersCount}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberAvatar(String assetPath, {bool isOnline = false}) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFCBD5E1),
                  child: const Icon(Icons.person, size: 20, color: Colors.white),
                ),
              ),
            ),
          ),
          if (isOnline)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. TOP CONTRIBUTOR SECTION
  // ===========================================================================
  Widget _buildTopContributorSection(CommunityCardData d) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFED7AA), width: 1.2),
      ),
      child: Row(
        children: [
          // Avatar with Star Badge
          SizedBox(
            width: 42,
            height: 42,
            child: Stack(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      d.topContributorAvatar,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFCBD5E1),
                        child: const Icon(Icons.person, size: 22, color: Colors.white),
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
                      size: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Top Contributor',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEA580C),
                  ),
                ),
                Text(
                  d.topContributorName,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
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
                    Flexible(
                      child: Text(
                        'Active • ${d.topContributorContributions} contributions',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

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
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              minimumSize: const Size(76, 30),
            ),
            child: const Text(
              'View Profile',
              style: TextStyle(
                color: Color(0xFFEA580C),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. FEATURE QUICK ACTION PILLS ROW
  // ===========================================================================
  Widget _buildFeatureChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPillChip(icon: Icons.menu_book_rounded, label: 'Resources'),
          const SizedBox(width: 8),
          _buildPillChip(icon: Icons.chat_bubble_outline_rounded, label: 'Discussions'),
          const SizedBox(width: 8),
          _buildPillChip(icon: Icons.groups_outlined, label: 'Study Groups'),
          const SizedBox(width: 8),
          _buildPillChip(icon: Icons.calendar_today_outlined, label: 'Events'),
        ],
      ),
    );
  }

  Widget _buildPillChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF1E293B)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. MAIN ACTION JOIN BUTTON
  // ===========================================================================
  Widget _buildJoinButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _isJoined = !_isJoined;
          });
          if (widget.onJoinTap != null) {
            widget.onJoinTap!();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isJoined
                      ? 'Joined ${widget.data.name}! Welcome to the community 🎉'
                      : 'Left ${widget.data.name}',
                ),
                backgroundColor: const Color(0xFF0F172A),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _isJoined ? const Color(0xFF047857) : const Color(0xFF09122C),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              _isJoined ? 'Joined Community ✓' : 'Join Community',
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            const Spacer(),
            Icon(
              _isJoined ? Icons.check_circle : Icons.chevron_right_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
