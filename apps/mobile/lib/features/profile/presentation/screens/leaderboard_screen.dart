import 'package:flutter/material.dart';
import 'filter_leaderboard_bottom_sheet.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _selectedFilterTab = 2; // National active by default
  final List<String> _filterTabs = ['Global', 'International', 'National', 'State', 'District', 'College'];
  
  LeaderboardFilterSettings _filterSettings = LeaderboardFilterSettings();

  // Unified Leaderboard mock dataset
  final List<Map<String, dynamic>> _allTeams = [
    // Ranks 1, 2, 3 (Podium)
    {'rank': 1, 'name': 'Stella Fernandez', 'level': 'Level 7', 'xp': 6790, 'change': '↑ 24', 'changeColor': Color(0xFF10B981), 'badgeColor': Color(0xFFF59E0B), 'isUser': true, 'category': 'Tech Teams', 'eventType': 'Hackathon', 'levelNum': 7, 'verified': true, 'active': true},
    {'rank': 2, 'name': 'Nexus Innovators', 'level': 'Level 6', 'xp': 4850, 'change': '↑ 12', 'changeColor': Color(0xFF10B981), 'badgeColor': Color(0xFF94A3B8), 'category': 'Tech Teams', 'eventType': 'Code Challenge', 'levelNum': 6, 'verified': true, 'active': true},
    {'rank': 3, 'name': 'CodeCrafters', 'level': 'Level 6', 'xp': 4120, 'change': '↓ 5', 'changeColor': Color(0xFFEF4444), 'badgeColor': Color(0xFFD97706), 'category': 'Tech Teams', 'eventType': 'Hackathon', 'levelNum': 6, 'verified': false, 'active': true},
    
    // Top Performers
    {'rank': 4, 'name': 'Tech Titans', 'level': 'Level 6', 'xp': 3960, 'change': '↑ 4', 'changeColor': Color(0xFF10B981), 'category': 'Tech Teams', 'eventType': 'Ideathon', 'levelNum': 6, 'verified': true, 'active': true},
    {'rank': 5, 'name': 'Binary Brains', 'level': 'Level 5', 'xp': 3450, 'change': '↓ 2', 'changeColor': Color(0xFFEF4444), 'category': 'Tech Teams', 'eventType': 'Code Challenge', 'levelNum': 5, 'verified': true, 'active': true},
    {'rank': 6, 'name': 'Alpha Team', 'level': 'Level 5', 'xp': 3120, 'change': '↑ 1', 'changeColor': Color(0xFF10B981), 'category': 'Non-Tech Teams', 'eventType': 'Designathon', 'levelNum': 5, 'verified': false, 'active': true},
    
    // Table Rows
    {'rank': 7, 'name': 'Hack Mavericks', 'level': 'Level 5', 'xp': 2980, 'change': '↑ 8', 'changeColor': Color(0xFF10B981), 'category': 'Tech Teams', 'eventType': 'Hackathon', 'levelNum': 5, 'verified': true, 'active': true},
    {'rank': 8, 'name': 'Innovation Hub', 'level': 'Level 5', 'xp': 2750, 'change': '↓ 3', 'changeColor': Color(0xFFEF4444), 'category': 'Non-Tech Teams', 'eventType': 'Ideathon', 'levelNum': 5, 'verified': true, 'active': true},
    {'rank': 9, 'name': 'Dev Dynamos', 'level': 'Level 4', 'xp': 2450, 'change': '↑ 6', 'changeColor': Color(0xFF10B981), 'category': 'Tech Teams', 'eventType': 'Code Challenge', 'levelNum': 4, 'verified': true, 'active': true},
    {'rank': 10, 'name': 'Problem Solvers', 'level': 'Level 4', 'xp': 2210, 'change': '↓ 1', 'changeColor': Color(0xFFEF4444), 'category': 'Non-Tech Teams', 'eventType': 'Other', 'levelNum': 4, 'verified': false, 'active': true},
    {'rank': 11, 'name': 'Future Coders', 'level': 'Level 4', 'xp': 1980, 'change': '↑ 2', 'changeColor': Color(0xFF10B981), 'category': 'Tech Teams', 'eventType': 'Hackathon', 'levelNum': 4, 'verified': true, 'active': false},
    {'rank': 12, 'name': 'Byte Builders', 'level': 'Level 4', 'xp': 1760, 'change': '—', 'changeColor': Color(0xFF94A3B8), 'category': 'Tech Teams', 'eventType': 'Designathon', 'levelNum': 4, 'verified': true, 'active': true},
    {'rank': 13, 'name': 'Algorithm Army', 'level': 'Level 3', 'xp': 1540, 'change': '↓ 2', 'changeColor': Color(0xFFEF4444), 'category': 'Tech Teams', 'eventType': 'Hackathon', 'levelNum': 3, 'verified': false, 'active': true},
    {'rank': 14, 'name': 'Stack Breakers', 'level': 'Level 3', 'xp': 1320, 'change': '—', 'changeColor': Color(0xFF94A3B8), 'category': 'Tech Teams', 'eventType': 'Other', 'levelNum': 3, 'verified': true, 'active': false},
    {'rank': 15, 'name': 'Zero Bugs', 'level': 'Level 3', 'xp': 1120, 'change': '↑ 1', 'changeColor': Color(0xFF10B981), 'category': 'Tech Teams', 'eventType': 'Code Challenge', 'levelNum': 3, 'verified': true, 'active': true},
  ];

  // Resolve filtered and sorted lists in real time
  List<Map<String, dynamic>> get _filteredTeams {
    final list = _allTeams.where((team) {
      // 1. Level/Scope simulated filters (We show different subsets to feel fully operational)
      if (_filterSettings.levelScope != 'National') {
        if (_filterSettings.levelScope == 'College' && team['rank'] % 2 == 0) return false;
        if (_filterSettings.levelScope == 'Global' && team['rank'] > 8) return false;
        if (_filterSettings.levelScope == 'State' && team['rank'] > 12) return false;
      }

      // 2. Team Background filter
      if (team['category'] != _filterSettings.teamBackground) {
        return false;
      }

      // 3. Event Type filter
      if (_filterSettings.eventType != 'All Events') {
        if (team['eventType'] != _filterSettings.eventType) {
          return false;
        }
      }

      // 4. Team Level filter
      if (_filterSettings.teamLevel != 'All Levels') {
        final targetLvl = _filterSettings.teamLevel;
        if (targetLvl == 'Level 5+') {
          if (team['levelNum'] < 5) return false;
        } else {
          final intLvl = int.tryParse(targetLvl.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          if (team['levelNum'] != intLvl) return false;
        }
      }

      // 5. Verification status filter
      if (_filterSettings.onlyShowVerified && !team['verified']) {
        return false;
      }

      // 6. Active status filter
      if (_filterSettings.hideInactive && !team['active']) {
        return false;
      }

      return true;
    }).toList();

    // Sorting logic
    if (_filterSettings.sortBy == 'XP (High to Low)') {
      list.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));
    } else if (_filterSettings.sortBy == 'XP (Low to High)') {
      list.sort((a, b) => (a['xp'] as int).compareTo(b['xp'] as int));
    } else if (_filterSettings.sortBy == 'Level (High to Low)') {
      list.sort((a, b) {
        final cmp = (b['levelNum'] as int).compareTo(a['levelNum'] as int);
        if (cmp != 0) return cmp;
        return (b['xp'] as int).compareTo(a['xp'] as int);
      });
    } else if (_filterSettings.sortBy == 'Team Name (A-Z)') {
      list.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final currentFiltered = _filteredTeams;

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
                _buildFilterTabs(),
                Expanded(
                  child: currentFiltered.isEmpty
                      ? _buildEmptyState()
                      : ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            const SizedBox(height: 12),
                            _buildRankingsUpdateHeader(),
                            const SizedBox(height: 16),
                            _buildPodiumSection(currentFiltered),
                            const SizedBox(height: 24),
                            if (currentFiltered.length > 3) ...[
                              _buildTopPerformersHeader(),
                              const SizedBox(height: 12),
                              _buildTopPerformersList(currentFiltered),
                              const SizedBox(height: 20),
                            ],
                            if (currentFiltered.length > 6) ...[
                              _buildRankingsTable(currentFiltered),
                              const SizedBox(height: 20),
                            ],
                            _buildBottomStatisticsBar(),
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, color: Colors.grey.shade300, size: 72),
          const SizedBox(height: 16),
          const Text(
            'No Teams Match Your Filters',
            style: TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try resetting or adjusting the leaderboard filters to view active teams.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _resetAllFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
            ),
            child: const Text('Reset Leaderboard Filters', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _resetAllFilters() {
    setState(() {
      _filterSettings = LeaderboardFilterSettings();
      _selectedFilterTab = 2; // National
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // APP BAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chevron_left, size: 22, color: Color(0xFF4F46E5)),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leaderboard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'See how teams are performing across levels',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final result = await showModalBottomSheet<LeaderboardFilterSettings>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => FilterLeaderboardBottomSheet(initialSettings: _filterSettings),
              );
              if (result != null) {
                setState(() {
                  _filterSettings = result;
                  final idx = _filterTabs.indexOf(result.levelScope);
                  if (idx != -1) {
                    _selectedFilterTab = idx;
                  }
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.filter_list_rounded, size: 22, color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FILTER TABS BAR (Horizontal scroll)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filterTabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterTab == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilterTab = index;
                _filterSettings = _filterSettings.copyWith(levelScope: _filterTabs[index]);
              });
            },
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Text(
                _filterTabs[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // UPDATE NOTICE + DROPDOWN
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRankingsUpdateHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.emoji_events_outlined, size: 16, color: Color(0xFF64748B)),
              SizedBox(width: 6),
              Text(
                'Rankings update every 24 hours',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Text(
                  _filterSettings.rankingHistory,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF475569)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PODIUM SECTION (Ranks 2, 1, 3 side-by-side)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPodiumSection(List<Map<String, dynamic>> currentFiltered) {
    if (currentFiltered.isEmpty) return const SizedBox.shrink();

    final hasRank1 = currentFiltered.isNotEmpty;
    final hasRank2 = currentFiltered.length > 1;
    final hasRank3 = currentFiltered.length > 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Rank 2 - Left
          Expanded(
            child: hasRank2
                ? _buildPodiumCard(
                    rank: 2,
                    teamName: currentFiltered[1]['name'],
                    level: currentFiltered[1]['level'],
                    xp: '${currentFiltered[1]['xp']} XP',
                    change: currentFiltered[1]['change'],
                    changeColor: currentFiltered[1]['changeColor'] ?? const Color(0xFF10B981),
                    badgeColor: const Color(0xFF94A3B8),
                    customLogo: _buildTeamLogo(currentFiltered[1]['name'], size: 48),
                    glow: false,
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 10),
          // Rank 1 - Center
          Expanded(
            child: hasRank1
                ? _buildPodiumCard(
                    rank: 1,
                    teamName: currentFiltered[0]['name'],
                    level: currentFiltered[0]['level'],
                    xp: '${currentFiltered[0]['xp']} XP',
                    change: currentFiltered[0]['change'],
                    changeColor: currentFiltered[0]['changeColor'] ?? const Color(0xFF10B981),
                    badgeColor: const Color(0xFFF59E0B),
                    avatarAsset: currentFiltered[0]['isUser'] == true ? 'assets/images/user_avatar.jpg' : null,
                    customLogo: currentFiltered[0]['isUser'] != true ? _buildTeamLogo(currentFiltered[0]['name'], size: 56) : null,
                    glow: true,
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 10),
          // Rank 3 - Right
          Expanded(
            child: hasRank3
                ? _buildPodiumCard(
                    rank: 3,
                    teamName: currentFiltered[2]['name'],
                    level: currentFiltered[2]['level'],
                    xp: '${currentFiltered[2]['xp']} XP',
                    change: currentFiltered[2]['change'],
                    changeColor: currentFiltered[2]['changeColor'] ?? const Color(0xFFEF4444),
                    badgeColor: const Color(0xFFD97706),
                    customLogo: _buildTeamLogo(currentFiltered[2]['name'], size: 48),
                    glow: false,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumCard({
    required int rank,
    required String teamName,
    required String level,
    required String xp,
    required String change,
    required Color changeColor,
    required Color badgeColor,
    String? avatarAsset,
    Widget? customLogo,
    required bool glow,
  }) {
    final height = glow ? 210.0 : 185.0;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: glow ? const Color(0xFFFCD34D) : const Color(0xFFE2E8F0),
          width: glow ? 2.0 : 1.0,
        ),
        boxShadow: [
          if (glow)
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24, left: 8, right: 8, bottom: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    customLogo ?? Container(
                      width: glow ? 56 : 48,
                      height: glow ? 56 : 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: glow ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
                          width: 2,
                        ),
                        image: DecorationImage(
                          image: AssetImage(avatarAsset!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      teamName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: glow ? 13.5 : 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.grid_view_rounded,
                            size: 10,
                            color: glow ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            level,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: glow ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      xp,
                      style: TextStyle(
                        fontSize: glow ? 14 : 12.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: changeColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: -12,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                rank.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TOP PERFORMERS SECTION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTopPerformersHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'Top Performers',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          Text(
            'View All',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4F46E5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformersList(List<Map<String, dynamic>> currentFiltered) {
    if (currentFiltered.length <= 3) return const SizedBox.shrink();
    final performers = currentFiltered.sublist(3, currentFiltered.length < 6 ? currentFiltered.length : 6);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: performers.map((p) {
          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                _buildTeamLogo(p['name'] as String, size: 32),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      p['name'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${p['level']}  \u00b7  ${p['xp']} XP',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // RANKINGS DETAILED TABLE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRankingsTable(List<Map<String, dynamic>> currentFiltered) {
    if (currentFiltered.length <= 6) return const SizedBox.shrink();
    final listData = currentFiltered.sublist(6);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: const [
                SizedBox(width: 30, child: Text('Rank', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
                SizedBox(width: 8),
                Expanded(child: Text('Team', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
                SizedBox(width: 60, child: Text('Level', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
                SizedBox(width: 70, child: Text('XP', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
                SizedBox(width: 50, child: Text('Change', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ...listData.map((row) {
            final teamIndex = currentFiltered.indexOf(row) + 1;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      '$teamIndex',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        _buildTeamLogo(row['name'] as String, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            row['name'] as String,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        row['level'] as String,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text(
                      '${row['xp']} XP',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(
                      row['change'] as String,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: row['changeColor'] as Color,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'View More Teams',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF4F46E5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BOTTOM STATISTICS BAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBottomStatisticsBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(Icons.groups_outlined, '2,842', 'Total Teams'),
          _statItem(Icons.star_outline_rounded, '15,680', 'Active This Month'),
          _statItem(Icons.trending_up_rounded, '8.7%', 'Growth This Month', trend: true),
          _statItem(Icons.emoji_events_outlined, '125,340', 'Total XP Earned'),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String val, String desc, {bool trend = false}) {
    return Column(
      children: [
        Icon(icon, size: 20, color: trend ? const Color(0xFF10B981) : const Color(0xFF64748B)),
        const SizedBox(height: 6),
        Text(
          val,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: trend ? const Color(0xFF10B981) : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          desc,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CUSTOM TEAM LOGO BUILDER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTeamLogo(String teamName, {double size = 32}) {
    Color bg;
    Widget child;

    switch (teamName) {
      case 'Nexus Innovators':
        bg = const Color(0xFF0F172A);
        child = Text(
          'N',
          style: TextStyle(
            color: const Color(0xFF38BDF8),
            fontWeight: FontWeight.w900,
            fontSize: size * 0.5,
            fontFamily: 'Courier',
          ),
        );
        break;
      case 'CodeCrafters':
        bg = const Color(0xFF1E293B);
        child = Text(
          '</>',
          style: TextStyle(
            color: const Color(0xFF4ADE80),
            fontWeight: FontWeight.w800,
            fontSize: size * 0.38,
          ),
        );
        break;
      case 'Tech Titans':
        bg = const Color(0xFF1E3A8A);
        child = Icon(Icons.shield_outlined, size: size * 0.5, color: const Color(0xFF60A5FA));
        break;
      case 'Binary Brains':
        bg = const Color(0xFF3B0764);
        child = Icon(Icons.psychology_outlined, size: size * 0.5, color: const Color(0xFFC084FC));
        break;
      case 'Alpha Team':
        bg = const Color(0xFF334155);
        child = Text(
          'A',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: size * 0.5,
          ),
        );
        break;
      case 'Hack Mavericks':
        bg = const Color(0xFF064E3B);
        child = Icon(Icons.adjust_rounded, size: size * 0.55, color: const Color(0xFF34D399));
        break;
      case 'Innovation Hub':
        bg = const Color(0xFF1E40AF);
        child = Icon(Icons.view_in_ar_rounded, size: size * 0.55, color: const Color(0xFF93C5FD));
        break;
      case 'Dev Dynamos':
        bg = const Color(0xFF1F2937);
        child = Icon(Icons.bolt, size: size * 0.6, color: const Color(0xFFFBBF24));
        break;
      case 'Problem Solvers':
        bg = const Color(0xFF312E81);
        child = Icon(Icons.extension_rounded, size: size * 0.55, color: const Color(0xFF818CF8));
        break;
      case 'Future Coders':
        bg = const Color(0xFF042F2E);
        child = Text(
          '>_',
          style: TextStyle(
            color: const Color(0xFF2DD4BF),
            fontWeight: FontWeight.w900,
            fontSize: size * 0.38,
          ),
        );
        break;
      case 'Byte Builders':
        bg = const Color(0xFF1D4ED8);
        child = Icon(Icons.grid_view_rounded, size: size * 0.55, color: const Color(0xFF93C5FD));
        break;
      case 'Algorithm Army':
        bg = const Color(0xFF7F1D1D);
        child = Text(
          '∑',
          style: TextStyle(
            color: const Color(0xFFFCA5A5),
            fontWeight: FontWeight.w800,
            fontSize: size * 0.55,
          ),
        );
        break;
      case 'Stack Breakers':
        bg = const Color(0xFF4C1D95);
        child = Icon(Icons.layers_outlined, size: size * 0.55, color: const Color(0xFFC084FC));
        break;
      case 'Zero Bugs':
        bg = const Color(0xFF14532D);
        child = Icon(Icons.check_circle_outline_rounded, size: size * 0.55, color: const Color(0xFF4ADE80));
        break;
      default:
        bg = const Color(0xFF64748B);
        child = Text(
          teamName.isNotEmpty ? teamName[0] : '',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.5,
          ),
        );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: bg.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
