import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

class SpaceScreen extends StatefulWidget {
  const SpaceScreen({super.key});

  @override
  State<SpaceScreen> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends State<SpaceScreen> {
  int _selectedTab = 0;
  final String _selectedTimeRange = 'Last 6 Weeks';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: const Color(0xFFF7F8FC),
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildTeamHeaderCard(),
                      _buildTabBar(),
                      const SizedBox(height: 16),
                      _buildStatsCardsRow(),
                      const SizedBox(height: 16),
                      _buildPerformanceChart(),
                      const SizedBox(height: 16),
                      _buildTeamLevelRankingScoreSection(),
                      const SizedBox(height: 20),
                      _buildAchievementsAndCompetitions(),
                      const SizedBox(height: 16),
                      _buildPastCompetitions(),
                      const SizedBox(height: 32),
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

  // ═══════════════════════════════════════════════════════════════
  // APP BAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.chevron_left, size: 28, color: Color(0xFF191919)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Team Analytics',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF191919),
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Track your team\'s performance and growth',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.ios_share_outlined, size: 22, color: Color(0xFF191919)),
          const SizedBox(width: 16),
          const Icon(Icons.more_horiz, size: 22, color: Color(0xFF191919)),
        ],
      ),
    );
  }

  Widget _buildTeamHeaderCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      height: 290,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/team_celebration_banner.png',
                fit: BoxFit.cover,
              ),
            ),
            // Glassmorphic Overlay at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.65),
                      border: Border(
                        top: BorderSide(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Row 1: Rank/Rating tag + Avatars
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7).withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFFDE68A), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.stars_rounded, size: 13, color: Color(0xFFD97706)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Rank #24',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFD97706),
                                    ),
                                  ),
                                  Text(
                                    '  \u00b7  ★ 4.8 Ratings',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildAvatarStack(),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Row 2: Stella Fernandez name
                        const Text(
                          'Stella Fernandez',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Row 3: Schedule + Join Now
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                '10:00 AM \u2013 11:00 AM  \u00b7  Video Call',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF374151),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Join Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack() {
    final avatars = [
      'assets/images/somraj_avatar.jpg',
      'assets/images/dharmik_avatar.jpg',
      'assets/images/alina_avatar.jpg',
      'assets/images/user_avatar.jpg',
    ];
    return SizedBox(
      width: 22.0 * 3 + 36,
      height: 36,
      child: Stack(
        children: List.generate(avatars.length, (i) {
          return Positioned(
            left: i * 22.0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                image: DecorationImage(image: AssetImage(avatars[i]), fit: BoxFit.cover),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB BAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTabBar() {
    final tabData = [
      {'icon': Icons.grid_view_rounded, 'label': 'Overview'},
      {'icon': Icons.check_circle_outline, 'label': 'Performance'},
      {'icon': Icons.house_outlined, 'label': 'Activity'},
      {'icon': Icons.people_outline, 'label': 'Members (4)'},
    ];
    return Container(
      color: Colors.white,
      child: Row(
        children: List.generate(tabData.length, (i) {
          final selected = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.only(top: 14, bottom: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
                      width: selected ? 2.5 : 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(tabData[i]['icon'] as IconData,
                        size: 15, color: selected ? const Color(0xFF3B82F6) : const Color(0xFF9CA3AF)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        tabData[i]['label'] as String,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                          color: selected ? const Color(0xFF3B82F6) : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STATS CARDS ROW
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStatsCardsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _statCard(Icons.emoji_events_outlined, const Color(0xFFEEF2FF), const Color(0xFF6366F1), '12',
              'Events Joined', '\u2191 20% vs last month', const Color(0xFF10B981)),
          const SizedBox(width: 10),
          _statCard(Icons.flag_outlined, const Color(0xFFF3E8FF), const Color(0xFF9333EA), '3', 'Won',
              '\u2191 100% vs last month', const Color(0xFF10B981)),
          const SizedBox(width: 10),
          _statCard(Icons.groups_outlined, const Color(0xFFE0F2FE), const Color(0xFF0EA5E9), '2', 'Runner-up',
              '\u2191 50% vs last month', const Color(0xFF10B981)),
          const SizedBox(width: 10),
          _statCard(Icons.pending_actions_outlined, const Color(0xFFFFF7ED), const Color(0xFFF97316), '7',
              'In Progress', '\u2014 No change', const Color(0xFF9CA3AF)),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, Color bg, Color fg, String val, String label, String change, Color changeColor) {
    return Container(
      width: 125,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: fg),
          ),
          const SizedBox(height: 12),
          Text(val,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827), height: 1)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFF9CA3AF), height: 1.2)),
          const SizedBox(height: 6),
          Text(change, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w500, color: changeColor)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PERFORMANCE OVER TIME — line chart
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPerformanceChart() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Performance Over Time',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_selectedTimeRange,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF6B7280)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 170,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, 170),
                  painter: _LineChartPainter(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TEAM LEVEL  |  RANKING  |  SCORE BREAKDOWN
  // Split into: [Team Level + Ranking] top row, [Score Breakdown] below
  // to match reference proportions on mobile viewport
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTeamLevelRankingScoreSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 170,
              child: _buildTeamLevelCard(),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 170,
              child: _buildRankingCard(),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 270,
              child: _buildScoreBreakdownCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamLevelCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Team Level',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
          const SizedBox(height: 16),
          // Shield badge
          SizedBox(
            width: 60,
            height: 68,
            child: CustomPaint(painter: _ShieldBadgePainter()),
          ),
          const SizedBox(height: 12),
          const Text('Level 4',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          const SizedBox(height: 2),
          const Text('Innovator',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: const LinearProgressIndicator(
              value: 0.72,
              minHeight: 5,
              backgroundColor: Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
          ),
          const SizedBox(height: 6),
          const Text('720 / 1000 XP',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 2),
          const Text('Next Level: Trailblazer',
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w400, color: Color(0xFFD1D5DB))),
        ],
      ),
    );
  }

  Widget _buildRankingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('Ranking',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
              SizedBox(width: 4),
              Icon(Icons.info_outline, size: 14, color: Color(0xFFD1D5DB)),
            ],
          ),
          const SizedBox(height: 18),
          const Text('#24',
              style: TextStyle(
                  fontSize: 40, fontWeight: FontWeight.w900, color: Color(0xFF111827), height: 1, letterSpacing: -1)),
          const SizedBox(height: 6),
          const Text('In National Ranking',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(14)),
            child: const Text('\u2191 8 spots',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF10B981))),
          ),
          const SizedBox(height: 16),
          const Text('Top 5% of all teams',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w400, color: Color(0xFFD1D5DB))),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdownCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Score Breakdown',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
          const SizedBox(height: 18),
          Row(
            children: [
              // Donut chart
              SizedBox(
                width: 90,
                height: 90,
                child: CustomPaint(
                  painter: _DonutChartPainter(),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('87',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827), height: 1)),
                        SizedBox(height: 2),
                        Text('Total Score',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w400, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Legend — plenty of room now
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendRow(const Color(0xFF6366F1), 'Innovation', '35%'),
                    const SizedBox(height: 10),
                    _legendRow(const Color(0xFF9333EA), 'Execution', '25%'),
                    const SizedBox(height: 10),
                    _legendRow(const Color(0xFF0EA5E9), 'Impact', '20%'),
                    const SizedBox(height: 10),
                    _legendRow(const Color(0xFFF59E0B), 'Presentation', '20%'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendRow(Color color, String label, String pct) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w400)),
        ),
        Text(pct, style: const TextStyle(fontSize: 13, color: Color(0xFF111827), fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildAchievementsAndCompetitions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 320,
              child: _buildAchievementsCard(),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 320,
              child: _buildActiveCompetitionsCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Achievements',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              Text('View All',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF3B82F6))),
            ],
          ),
          const SizedBox(height: 16),
          _achItem(Icons.emoji_events, const Color(0xFFFBBF24), const Color(0xFFFEF3C7), 'First Place',
              'CodeFuture Hack 2024', 'Feb 2024'),
          const SizedBox(height: 14),
          _achItem(Icons.military_tech, const Color(0xFF9CA3AF), const Color(0xFFF3F4F6), 'Runner-up',
              'InnovateX Challenge', 'Jan 2024'),
          const SizedBox(height: 14),
          _achItem(Icons.star_rounded, const Color(0xFF3B82F6), const Color(0xFFEFF6FF), 'Top 10 Finalist',
              'TechSprint 5.0', 'Dec 2023'),
        ],
      ),
    );
  }

  Widget _achItem(IconData icon, Color ic, Color bg, String title, String sub, String date) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18, color: ic),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              Text(sub, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
        Text(date, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w400, color: Color(0xFFD1D5DB))),
      ],
    );
  }

  Widget _buildActiveCompetitionsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Flexible(
                child: Text('Active Competitions',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              ),
              SizedBox(width: 4),
              Text('View All',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF3B82F6))),
            ],
          ),
          const SizedBox(height: 16),
          _compItem('assets/images/arogya_dashboard.jpg', 'AI for Good Hackathon',
              'Online \u00b7 Ends in 3 days', 'Live', const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
          const SizedBox(height: 14),
          _compItem('assets/images/warp_team.jpg', 'Smart India Hack 2024',
              'Grand Finale \u00b7 In Progress', 'In Progress', const Color(0xFF3B82F6), const Color(0xFFEFF6FF)),
        ],
      ),
    );
  }

  Widget _compItem(String img, String title, String sub, String badge, Color bc, Color bg) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(img, width: 38, height: 38, fit: BoxFit.cover),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
              const SizedBox(height: 2),
              Text(sub,
                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w400, color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Text(badge, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: bc)),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PAST COMPETITIONS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPastCompetitions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Past Competitions',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              Text('View All',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF3B82F6))),
            ],
          ),
          const SizedBox(height: 16),
          _pastItem('Won', const Color(0xFF10B981), const Color(0xFFECFDF5), 'CodeFuture Hack 2024', 'Feb 2024',
              '1st Place'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF3F4F6)),
          ),
          _pastItem('Runner-up', const Color(0xFFF59E0B), const Color(0xFFFEF3C7), 'InnovateX Challenge',
              'Jan 2024', '2nd Place'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF3F4F6)),
          ),
          _pastItem(
              'Lost', const Color(0xFFEF4444), const Color(0xFFFEE2E2), 'Hack the North 2023', 'Nov 2023', 'Top 20'),
        ],
      ),
    );
  }

  Widget _pastItem(String status, Color sc, Color bg, String name, String date, String place) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
          child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sc)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
              Text(date,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
        Text(place, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF6B7280))),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, size: 18, color: Color(0xFFD1D5DB)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CUSTOM PAINTER — Line Chart
// ═══════════════════════════════════════════════════════════════════
class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final data = [15.0, 35.0, 58.0, 52.0, 68.0, 92.0];
    const yLabels = ['0', '25', '50', '75', '100'];
    const xLabels = ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4', 'Wk 5', 'Wk 6'];

    const l = 28.0, r = 8.0, t = 8.0, b = 22.0;
    final cw = size.width - l - r;
    final ch = size.height - t - b;

    final gridP = Paint()
      ..color = const Color(0xFFF3F4F6)
      ..strokeWidth = 1;

    for (int i = 0; i < yLabels.length; i++) {
      final y = t + ch - (ch * i / (yLabels.length - 1));
      canvas.drawLine(Offset(l, y), Offset(size.width - r, y), gridP);
      final tp = TextPainter(
        text: TextSpan(
            text: yLabels[i],
            style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w400)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(l - tp.width - 6, y - tp.height / 2));
    }

    for (int i = 0; i < xLabels.length; i++) {
      final x = l + (cw * i / (xLabels.length - 1));
      final tp = TextPainter(
        text: TextSpan(
            text: xLabels[i],
            style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w400)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - b + 6));
    }

    final pts = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      pts.add(Offset(l + (cw * i / (data.length - 1)), t + ch - (ch * data[i] / 100)));
    }

    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final c = pts[i], n = pts[i + 1];
      path.cubicTo(c.dx + (n.dx - c.dx) * 0.35, c.dy, c.dx + (n.dx - c.dx) * 0.65, n.dy, n.dx, n.dy);
    }

    final fill = Path.from(path)
      ..lineTo(pts.last.dx, t + ch)
      ..lineTo(pts.first.dx, t + ch)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF3B82F6).withValues(alpha: 0.18),
            const Color(0xFF3B82F6).withValues(alpha: 0.01),
          ],
        ).createShader(Rect.fromLTWH(l, t, cw, ch)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF3B82F6)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (final p in pts) {
      canvas.drawCircle(p, 5, Paint()..color = Colors.white);
      canvas.drawCircle(p, 3.5, Paint()..color = const Color(0xFF3B82F6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════
// CUSTOM PAINTER — Donut Chart
// ═══════════════════════════════════════════════════════════════════
class _DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 3;
    const sw = 10.0;
    const gap = 0.05;

    final segs = [
      (0.35, const Color(0xFF6366F1)),
      (0.25, const Color(0xFF9333EA)),
      (0.20, const Color(0xFF0EA5E9)),
      (0.20, const Color(0xFFF59E0B)),
    ];

    var a = -pi / 2;
    for (final (v, c) in segs) {
      final sweep = 2 * pi * v - gap;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - sw / 2),
        a,
        sweep,
        false,
        Paint()
          ..color = c
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round,
      );
      a += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════
// CUSTOM PAINTER — Shield Badge
// ═══════════════════════════════════════════════════════════════════
class _ShieldBadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height, cx = w / 2;

    final shield = Path()
      ..moveTo(cx, 0)
      ..quadraticBezierTo(w * 0.92, 2, w * 0.94, h * 0.16)
      ..lineTo(w * 0.94, h * 0.48)
      ..quadraticBezierTo(w * 0.9, h * 0.8, cx, h)
      ..quadraticBezierTo(w * 0.1, h * 0.8, w * 0.06, h * 0.48)
      ..lineTo(w * 0.06, h * 0.16)
      ..quadraticBezierTo(w * 0.08, 2, cx, 0)
      ..close();

    canvas.drawPath(
      shield,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF7C3AED), const Color(0xFF4F46E5)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    canvas.drawPath(
      shield,
      Paint()
        ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final sc = Offset(cx, h * 0.42);
    _star(canvas, sc, 12, 5.5, 5, const Color(0xFFFFD700));

    canvas.drawCircle(
      sc,
      16,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _star(Canvas canvas, Offset c, double outer, double inner, int n, Color color) {
    final path = Path();
    final step = pi / n;
    for (int i = 0; i < 2 * n; i++) {
      final r = i.isEven ? outer : inner;
      final a = i * step - pi / 2;
      final p = Offset(c.dx + r * cos(a), c.dy + r * sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
