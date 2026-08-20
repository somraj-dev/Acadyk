import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/profile_pins_manager.dart';
import 'project_details.dart';
import 'experience_details.dart';

class ProfilePinsScreen extends StatefulWidget {
  const ProfilePinsScreen({super.key});

  @override
  State<ProfilePinsScreen> createState() => _ProfilePinsScreenState();
}

class _ProfilePinsScreenState extends State<ProfilePinsScreen> with SingleTickerProviderStateMixin {
  PinCategory? _selectedCategory; // null = All
  String _searchQuery = '';
  String _selectedStatusFilter = 'All'; // 'All', 'Posted', 'Joined', 'Completed', 'Active'
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ProfilePinsManager.pinsChangeNotifier.addListener(_onPinsUpdated);
  }

  @override
  void dispose() {
    ProfilePinsManager.pinsChangeNotifier.removeListener(_onPinsUpdated);
    _searchController.dispose();
    super.dispose();
  }

  void _onPinsUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  List<ProfilePinItem> _getFilteredItems() {
    List<ProfilePinItem> items = ProfilePinsManager.getAllItems(_selectedCategory);

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      items = items.where((item) {
        final matchTitle = item.title.toLowerCase().contains(q);
        final matchSub = item.subtitle.toLowerCase().contains(q);
        final matchOrg = (item.organization ?? '').toLowerCase().contains(q);
        final matchDesc = (item.description ?? '').toLowerCase().contains(q);
        final matchTags = item.tags.any((t) => t.toLowerCase().contains(q));
        return matchTitle || matchSub || matchOrg || matchDesc || matchTags;
      }).toList();
    }

    if (_selectedStatusFilter != 'All') {
      items = items.where((item) {
        switch (_selectedStatusFilter) {
          case 'Posted':
            return item.originStatus == PinOriginStatus.posted;
          case 'Joined':
            return item.originStatus == PinOriginStatus.joined;
          case 'Completed':
            return item.originStatus == PinOriginStatus.completed;
          case 'Active':
            return item.originStatus == PinOriginStatus.active;
          case 'Pinned':
            return item.isPinned;
          case 'Hidden':
            return !item.isPinned;
          default:
            return true;
        }
      }).toList();
    }

    return items;
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.push_pin_rounded, color: Color(0xFF0284C7)),
            SizedBox(width: 8),
            Text('About Profile Pins', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Profile Pins give you complete control over what appears on your public and college profile.',
              style: TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF334155)),
            ),
            SizedBox(height: 12),
            Text(
              '• Every project you ever posted, joined, or completed is logged here.\n'
              '• Work experiences, education, and campus clubs are organized in one place.\n'
              '• Toggle the pin switch on any item to show or hide it from your Profile screen.',
              style: TextStyle(fontSize: 13.5, height: 1.5, color: Color(0xFF475569)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
          ),
        ],
      ),
    );
  }

  void _showMaxPinsWarningDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: Colors.white,
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Pin Limit Reached',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'You can feature a maximum of 10 items on your profile page at a time.',
              style: TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Please unpin an existing project, experience, education, or club before pinning another item.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Understood',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickActionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              const Text('Quick Pin Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.playlist_add_check_rounded, color: Color(0xFF0284C7)),
                title: Text(_selectedCategory == null ? 'Pin all items to profile' : 'Pin all in this category'),
                subtitle: const Text('Display items on profile (up to 10 maximum)'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  final itemsToPin = ProfilePinsManager.getAllItems(_selectedCategory).where((i) => !i.isPinned).toList();
                  if (ProfilePinsManager.pinnedCount + itemsToPin.length > ProfilePinsManager.maxPinsAllowed) {
                    _showMaxPinsWarningDialog();
                    return;
                  }
                  ProfilePinsManager.pinAll(_selectedCategory);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Items pinned to your profile!'), duration: Duration(seconds: 2)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility_off_outlined, color: Color(0xFF64748B)),
                title: Text(_selectedCategory == null ? 'Hide all items from profile' : 'Hide all in this category'),
                subtitle: const Text('Unpin items to keep them private / unlisted'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  ProfilePinsManager.unpinAll(_selectedCategory);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All items unpinned from profile.'), duration: Duration(seconds: 2)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF8FAFC);
    final filteredItems = _getFilteredItems();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.left_chevron, color: Color(0xFF0F172A), size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: false,
        title: const Text(
          'Profile Pins',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 22),
            onPressed: _showInfoDialog,
            tooltip: 'About Profile Pins',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF64748B), size: 22),
            onPressed: _showQuickActionsMenu,
            tooltip: 'Quick Actions',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            _buildSearchBar(),

            // Category Filter Pills
            _buildCategoryTabs(),

            // Status Filter Row
            _buildStatusFilters(),

            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Content List
            Expanded(
              child: filteredItems.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        return _buildPinItemCard(filteredItems[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: 'Search projects, companies, skills...',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = [
      {'label': 'All', 'cat': null, 'count': ProfilePinsManager.totalCount},
      {'label': 'Projects', 'cat': PinCategory.project, 'count': ProfilePinsManager.countByCategory(PinCategory.project)},
      {'label': 'Experience', 'cat': PinCategory.experience, 'count': ProfilePinsManager.countByCategory(PinCategory.experience)},
      {'label': 'Education', 'cat': PinCategory.education, 'count': ProfilePinsManager.countByCategory(PinCategory.education)},
      {'label': 'Clubs & Chapters', 'cat': PinCategory.club, 'count': ProfilePinsManager.countByCategory(PinCategory.club)},
    ];

    return Container(
      color: Colors.white,
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final item = categories[idx];
          final cat = item['cat'] as PinCategory?;
          final isSelected = _selectedCategory == cat;
          final count = item['count'] as int;

          return InkWell(
            onTap: () => setState(() => _selectedCategory = cat),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusFilters() {
    final filters = ['All', 'Pinned', 'Hidden', 'Posted', 'Joined', 'Completed', 'Active'];

    return Container(
      color: Colors.white,
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, idx) {
          final filter = filters[idx];
          final isSelected = _selectedStatusFilter == filter;

          return InkWell(
            onTap: () => setState(() => _selectedStatusFilter = filter),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openProjectDetails(ProfilePinItem item) {
    final Map<String, dynamic> projData = {
      'title': item.title,
      'companyName': item.title,
      'subtitle': item.subtitle,
      'association': item.organization ?? item.subtitle,
      'organization': item.organization ?? item.subtitle,
      'duration': item.duration ?? '',
      'time': item.duration ?? '',
      'location': item.location ?? 'Gwalior, MP',
      'description': item.description ?? '',
      'progress': item.description ?? '',
      'techStack': item.tags.isNotEmpty ? item.tags.join(', ') : 'Flutter, Dart, Spring Boot',
      'tags': item.tags,
      'logoAsset': item.imageAsset,
      'imageAsset': item.imageAsset,
      'category': item.category.name,
      'originStatus': item.statusLabel,
      'status': item.statusLabel.toUpperCase(),
      'batch': '2024–2026',
      'isPinned': item.isPinned,
      ...item.rawData,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectDetailsScreen(projectData: projData),
      ),
    );
  }

  void _openExperienceDetails(ProfilePinItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExperienceDetailsScreen(pinItem: item),
      ),
    );
  }

  Widget _buildPinItemCard(ProfilePinItem item) {
    final statusColor = _getStatusColor(item.originStatus);
    final categoryLabel = _getCategoryLabel(item.category);
    final bool isProject = item.category == PinCategory.project;
    final bool isExperience = item.category == PinCategory.experience;
    final bool isTappable = isProject || isExperience;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isProject
              ? () => _openProjectDetails(item)
              : isExperience
                  ? () => _openExperienceDetails(item)
                  : null,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Icon, Badges, Title, and Switch Toggle
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon / Logo
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: item.iconBg.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: item.iconBg.withValues(alpha: 0.25)),
                      ),
                      alignment: Alignment.center,
                      child: item.imageAsset != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                item.imageAsset!,
                                width: 32,
                                height: 32,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(item.icon, color: item.iconBg, size: 22),
                              ),
                            )
                          : Icon(item.icon, color: item.iconBg, size: 22),
                    ),
                    const SizedBox(width: 12),
                    // Title and badges
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  categoryLabel.toUpperCase(),
                                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF475569), letterSpacing: 0.5),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.statusLabel,
                                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: statusColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    CupertinoSwitch(
                      value: item.isPinned,
                      activeTrackColor: const Color(0xFF0284C7),
                      onChanged: (val) {
                        if (val && !item.isPinned && ProfilePinsManager.pinnedCount >= ProfilePinsManager.maxPinsAllowed) {
                          _showMaxPinsWarningDialog();
                          return;
                        }
                        final success = ProfilePinsManager.setPin(item.id, val);
                        if (!success && val) {
                          _showMaxPinsWarningDialog();
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Subtitle & Organization
                if (item.subtitle.isNotEmpty)
                  Text(
                    item.subtitle,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                  ),

                // Duration & Location Chips
                if (item.duration != null || item.location != null) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (item.duration != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule_rounded, size: 13, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(item.duration!, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          ],
                        ),
                      if (item.location != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF64748B)),
                            const SizedBox(width: 3),
                            Text(item.location!, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          ],
                        ),
                    ],
                  ),
                ],

                // Description preview
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.35),
                  ),
                ],

                // Tags
                if (item.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: item.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.filter_list_off_rounded, size: 36, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 16),
            const Text(
              'No matching items found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try changing your search query or status filter to see other items.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedStatusFilter = 'All';
                  _selectedCategory = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('Reset Filters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(PinOriginStatus status) {
    switch (status) {
      case PinOriginStatus.posted:
        return const Color(0xFF0284C7);
      case PinOriginStatus.joined:
        return const Color(0xFF7C3AED);
      case PinOriginStatus.completed:
        return const Color(0xFF059669);
      case PinOriginStatus.active:
        return const Color(0xFFD97706);
    }
  }

  String _getCategoryLabel(PinCategory cat) {
    switch (cat) {
      case PinCategory.project:
        return 'Project';
      case PinCategory.experience:
        return 'Experience';
      case PinCategory.education:
        return 'Education';
      case PinCategory.club:
        return 'Club / Org';
    }
  }
}
