import 'package:flutter/material.dart';

class CommunityProfileScreen extends StatelessWidget {
  final String communityName;
  final String description;
  final String? logoUrl;

  const CommunityProfileScreen({
    super.key,
    required this.communityName,
    required this.description,
    this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B141A) : Colors.white;
    final dividerColor = isDark ? const Color(0xFF1E2931) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildCommunityHeader(context, isDark),
          ),
          SliverToBoxAdapter(
            child: _buildInsightsAndSetupCards(isDark),
          ),
          SliverToBoxAdapter(
            child: Divider(color: dividerColor, thickness: 6, height: 24),
          ),
          SliverToBoxAdapter(
            child: _buildPostsHeader(isDark),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildPromptCard(
                'Help shape the vibe while we\'re small 🙌',
                Icons.lightbulb,
                Colors.pinkAccent,
                isDark,
              ),
              _buildPromptCard(
                'Introducing $communityName! Here\'s what we\'re all about 👉',
                Icons.lightbulb,
                Colors.tealAccent,
                isDark,
              ),
              _buildPromptCard(
                'This community is ours to build. What are your ideas?',
                Icons.lightbulb,
                Colors.orangeAccent,
                isDark,
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityHeader(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? const Color(0xFF8696A0) : const Color(0xFF64748B);
    final linkColor = isDark ? const Color(0xFF61DAFB) : const Color(0xFF0284C7);
    final iconBorderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF0F172A),
                  child: logoUrl != null && logoUrl!.startsWith('http')
                      ? CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(logoUrl!),
                        )
                      : const CircleAvatar(
                          radius: 28,
                          backgroundColor: Color(0xFF0F172A),
                          child: Icon(Icons.account_balance_rounded, color: Colors.white, size: 26),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          communityName,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.add_circle_outline, color: textColor, size: 20),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF09122C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    elevation: 0,
                  ),
                  child: const Text('Mod Tools', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: iconBorderColor),
                  ),
                  child: Icon(Icons.notifications_none, color: textColor, size: 20),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: iconBorderColor),
                  ),
                  child: Icon(Icons.menu_book, color: textColor, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              description.isEmpty ? 'A collaborative campus student community at MITS Gwalior.' : description,
              style: TextStyle(color: secondaryTextColor, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(
              'See more',
              style: TextStyle(color: linkColor, fontSize: 13.5, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsAndSetupCards(bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E2931) : const Color(0xFFF8FAFC);
    final cardBorder = isDark ? const Color(0xFF2A3942) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? const Color(0xFF8696A0) : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Insights Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cardBorder, width: 1),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Insights', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 6),
                        Text('Past week', style: TextStyle(color: secondaryTextColor, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('142 visitors • 48 contributions', style: TextStyle(color: secondaryTextColor, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Build your community Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.transparent : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cardBorder, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Build your community', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                    Icon(Icons.keyboard_arrow_up, color: textColor),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    SizedBox(
                      width: 64,
                      child: Stack(
                        children: [
                          CircleAvatar(backgroundColor: Colors.grey.shade400, radius: 18),
                          Positioned(left: 14, child: CircleAvatar(backgroundColor: Colors.grey.shade500, radius: 18)),
                          Positioned(left: 28, child: CircleAvatar(backgroundColor: const Color(0xFFEA580C), radius: 18, child: const Icon(Icons.star_rounded, color: Colors.white, size: 18))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Finish setting up', style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(height: 4, decoration: BoxDecoration(color: const Color(0xFFEA580C), borderRadius: BorderRadius.circular(2))),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                flex: 2,
                                child: Container(height: 4, decoration: BoxDecoration(color: cardBorder, borderRadius: BorderRadius.circular(2))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('1/3 achievement unlocked', style: TextStyle(color: secondaryTextColor, fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF2A2A2C) : const Color(0xFF09122C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        elevation: 0,
                      ),
                      child: const Text('Finish', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsHeader(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.rocket_launch, color: isDark ? Colors.white : const Color(0xFFEA580C), size: 18),
              const SizedBox(width: 8),
              Text('BEST POSTS', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
              Icon(Icons.keyboard_arrow_down, color: textColor, size: 18),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: textColor, width: 1.5),
                ),
                child: Icon(Icons.crop_16_9, color: textColor, size: 16),
              ),
              const SizedBox(width: 12),
              Icon(Icons.view_agenda_outlined, color: textColor, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromptCard(String title, IconData icon, Color iconColor, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? const Color(0xFF8696A0) : const Color(0xFF64748B);
    final dividerColor = isDark ? const Color(0xFF1E2931) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: dividerColor, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.contains('Help shape')) ...[
            Text('Kick things off with a few posts', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Looking for inspiration? Explore these ideas.', style: TextStyle(color: secondaryTextColor, fontSize: 14)),
                Icon(Icons.keyboard_arrow_up, color: textColor),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(icon, color: iconColor, size: 14),
                        ),
                        const SizedBox(width: 8),
                        Text('Prompt', style: TextStyle(color: secondaryTextColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: TextStyle(color: textColor, fontSize: 15.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: textColor),
                ),
                child: Icon(Icons.add, color: textColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
