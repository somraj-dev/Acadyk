import 'package:flutter/material.dart';

class LeaderboardFilterSettings {
  final String levelScope;
  final String teamBackground;
  final String rankingHistory;
  final String eventType;
  final String teamLevel;
  final String locationCountry;
  final String locationState;
  final String sortBy;
  final bool onlyShowVerified;
  final bool hideInactive;

  LeaderboardFilterSettings({
    this.levelScope = 'National',
    this.teamBackground = 'Tech Teams',
    this.rankingHistory = 'This Month',
    this.eventType = 'All Events',
    this.teamLevel = 'All Levels',
    this.locationCountry = 'India',
    this.locationState = 'All States',
    this.sortBy = 'XP (High to Low)',
    this.onlyShowVerified = true,
    this.hideInactive = true,
  });

  LeaderboardFilterSettings copyWith({
    String? levelScope,
    String? teamBackground,
    String? rankingHistory,
    String? eventType,
    String? teamLevel,
    String? locationCountry,
    String? locationState,
    String? sortBy,
    bool? onlyShowVerified,
    bool? hideInactive,
  }) {
    return LeaderboardFilterSettings(
      levelScope: levelScope ?? this.levelScope,
      teamBackground: teamBackground ?? this.teamBackground,
      rankingHistory: rankingHistory ?? this.rankingHistory,
      eventType: eventType ?? this.eventType,
      teamLevel: teamLevel ?? this.teamLevel,
      locationCountry: locationCountry ?? this.locationCountry,
      locationState: locationState ?? this.locationState,
      sortBy: sortBy ?? this.sortBy,
      onlyShowVerified: onlyShowVerified ?? this.onlyShowVerified,
      hideInactive: hideInactive ?? this.hideInactive,
    );
  }
}

class FilterLeaderboardBottomSheet extends StatefulWidget {
  final LeaderboardFilterSettings initialSettings;

  const FilterLeaderboardBottomSheet({
    super.key,
    required this.initialSettings,
  });

  @override
  State<FilterLeaderboardBottomSheet> createState() => _FilterLeaderboardBottomSheetState();
}

class _FilterLeaderboardBottomSheetState extends State<FilterLeaderboardBottomSheet> {
  late String _selectedLevel;
  late String _selectedBackground;
  late String _selectedHistory;
  late String _selectedEventType;
  late String _selectedTeamLevel;
  late String _selectedCountry;
  late String _selectedState;
  late String _selectedSortBy;
  late bool _onlyShowVerified;
  late bool _hideInactive;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialSettings.levelScope;
    _selectedBackground = widget.initialSettings.teamBackground;
    _selectedHistory = widget.initialSettings.rankingHistory;
    _selectedEventType = widget.initialSettings.eventType;
    _selectedTeamLevel = widget.initialSettings.teamLevel;
    _selectedCountry = widget.initialSettings.locationCountry;
    _selectedState = widget.initialSettings.locationState;
    _selectedSortBy = widget.initialSettings.sortBy;
    _onlyShowVerified = widget.initialSettings.onlyShowVerified;
    _hideInactive = widget.initialSettings.hideInactive;
  }

  void _resetAll() {
    setState(() {
      _selectedLevel = 'National';
      _selectedBackground = 'Tech Teams';
      _selectedHistory = 'This Month';
      _selectedEventType = 'All Events';
      _selectedTeamLevel = 'All Levels';
      _selectedCountry = 'India';
      _selectedState = 'All States';
      _selectedSortBy = 'XP (High to Low)';
      _onlyShowVerified = true;
      _hideInactive = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF1E293B);
    const Color textSecondary = Color(0xFF64748B);
    const Color borderCol = Color(0xFFE2E8F0);
    const Color purplePrimary = Color(0xFF4F46E5);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: 8,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter Leaderboard',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Customize the leaderboard view',
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: textColor, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // SCROLLABLE CONTAINER
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Level / Scope
                  _buildSectionHeader('Level / Scope', 'Select the ranking level', Icons.people_outline),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: ['Global', 'International', 'National', 'State', 'District', 'College'].map((level) {
                        final bool active = _selectedLevel == level;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedLevel = level),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: active ? purplePrimary : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active ? purplePrimary : borderCol,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              level,
                              style: TextStyle(
                                color: active ? Colors.white : textSecondary,
                                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Team Background
                  _buildSectionHeader('Team Background', 'Choose the team type', Icons.psychology_outlined),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBackgroundCard(
                          'Tech Teams',
                          'Technology focused teams',
                          Icons.code_rounded,
                          _selectedBackground == 'Tech Teams',
                          () => setState(() => _selectedBackground = 'Tech Teams'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildBackgroundCard(
                          'Non-Tech Teams',
                          'Non-technology teams',
                          Icons.groups_outlined,
                          _selectedBackground == 'Non-Tech Teams',
                          () => setState(() => _selectedBackground = 'Non-Tech Teams'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3. Ranking History
                  _buildSectionHeader('Ranking History', 'Choose the time period', Icons.calendar_today_outlined),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: ['Today', 'This Week', 'This Month', '3 Months', '1 Year', 'All Time'].map((period) {
                        final bool active = _selectedHistory == period;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedHistory = period),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: active ? purplePrimary : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active ? purplePrimary : borderCol,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              period,
                              style: TextStyle(
                                color: active ? Colors.white : textSecondary,
                                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Event Type
                  _buildSectionHeader('Event Type', 'Filter by event category', Icons.emoji_events_outlined),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: ['All Events', 'Hackathon', 'Code Challenge', 'Ideathon', 'Designathon', 'Other'].map((event) {
                        final bool active = _selectedEventType == event;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedEventType = event),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: active ? purplePrimary : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active ? purplePrimary : borderCol,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              event,
                              style: TextStyle(
                                color: active ? Colors.white : textSecondary,
                                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. Team Level
                  _buildSectionHeader('Team Level', 'Filter by team level', Icons.trending_up_rounded),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: ['All Levels', 'Level 1', 'Level 2', 'Level 3', 'Level 4', 'Level 5+'].map((lvl) {
                        final bool active = _selectedTeamLevel == lvl;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTeamLevel = lvl),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: active ? purplePrimary : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active ? purplePrimary : borderCol,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              lvl,
                              style: TextStyle(
                                color: active ? Colors.white : textSecondary,
                                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 6. Location
                  _buildSectionHeader('Location', 'Filter by location', Icons.location_on_outlined),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderCol),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.language_outlined, color: textSecondary, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedCountry,
                                    icon: const Icon(Icons.keyboard_arrow_down, color: textSecondary, size: 18),
                                    style: const TextStyle(color: textColor, fontSize: 13.5, fontWeight: FontWeight.w600),
                                    onChanged: (val) => setState(() => _selectedCountry = val!),
                                    items: ['India', 'USA', 'UK', 'Global'].map((c) {
                                      return DropdownMenuItem(value: c, child: Text(c));
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderCol),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_outlined, color: textSecondary, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedState,
                                    icon: const Icon(Icons.keyboard_arrow_down, color: textSecondary, size: 18),
                                    style: const TextStyle(color: textColor, fontSize: 13.5, fontWeight: FontWeight.w600),
                                    onChanged: (val) => setState(() => _selectedState = val!),
                                    items: ['All States', 'Madhya Pradesh', 'Maharashtra', 'Delhi', 'Karnataka'].map((s) {
                                      return DropdownMenuItem(value: s, child: Text(s));
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 7. Sort By
                  _buildSectionHeader('Sort By', 'Choose sorting preference', Icons.sort_rounded),
                  const SizedBox(height: 10),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderCol),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.swap_vert_rounded, color: textSecondary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSortBy,
                              icon: const Icon(Icons.keyboard_arrow_down, color: textSecondary, size: 18),
                              style: const TextStyle(color: textColor, fontSize: 13.5, fontWeight: FontWeight.w600),
                              onChanged: (val) => setState(() => _selectedSortBy = val!),
                              items: ['XP (High to Low)', 'XP (Low to High)', 'Level (High to Low)', 'Team Name (A-Z)'].map((sortOpt) {
                                return DropdownMenuItem(value: sortOpt, child: Text(sortOpt));
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 8. Show Teams
                  _buildSectionHeader('Show Teams', 'Customize visibility', Icons.visibility_outlined),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Checkbox(
                              value: _onlyShowVerified,
                              activeColor: purplePrimary,
                              onChanged: (val) => setState(() => _onlyShowVerified = val!),
                            ),
                            const Text(
                              'Only show verified teams',
                              style: TextStyle(color: textColor, fontSize: 12.5, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Checkbox(
                              value: _hideInactive,
                              activeColor: purplePrimary,
                              onChanged: (val) => setState(() => _hideInactive = val!),
                            ),
                            const Text(
                              'Hide inactive teams',
                              style: TextStyle(color: textColor, fontSize: 12.5, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // FOOTER: RESET ALL & APPLY FILTERS ROW
          const Divider(height: 1, color: borderCol),
          const SizedBox(height: 12),
          Row(
            children: [
              // Reset Button
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetAll,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: purplePrimary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Reset All',
                    style: TextStyle(color: purplePrimary, fontWeight: FontWeight.bold, fontSize: 14.5),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Apply Filters Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final settings = LeaderboardFilterSettings(
                      levelScope: _selectedLevel,
                      teamBackground: _selectedBackground,
                      rankingHistory: _selectedHistory,
                      eventType: _selectedEventType,
                      teamLevel: _selectedTeamLevel,
                      locationCountry: _selectedCountry,
                      locationState: _selectedState,
                      sortBy: _selectedSortBy,
                      onlyShowVerified: _onlyShowVerified,
                      hideInactive: _hideInactive,
                    );
                    Navigator.pop(context, settings);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purplePrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Section Header Card with Icon and Title
  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    const Color textColor = Color(0xFF1E293B);
    const Color textSecondary = Color(0xFF64748B);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Color(0xFFEEF2F6),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF4F46E5), size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: textSecondary, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  // Card element for Background picker
  Widget _buildBackgroundCard(
    String title,
    String desc,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    const Color purplePrimary = Color(0xFF4F46E5);
    const Color borderCol = Color(0xFFE2E8F0);
    const Color textColor = Color(0xFF1E293B);
    const Color textSecondary = Color(0xFF64748B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5F3FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? purplePrimary : borderCol,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2F6),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? purplePrimary : textSecondary, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? purplePrimary : textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: textSecondary, fontSize: 10.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            // Circle selection indicator on the right edge
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? purplePrimary : textSecondary,
                  width: isSelected ? 5 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
