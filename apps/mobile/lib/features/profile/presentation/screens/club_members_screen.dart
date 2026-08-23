import 'package:flutter/material.dart';
import '../../../../common/services/auth_service.dart';
import '../services/profile_manager.dart';
import 'profile_screen.dart';

class ClubMembersScreen extends StatefulWidget {
  final String clubTitle;
  final String category;
  final String memberCount;

  const ClubMembersScreen({
    super.key,
    required this.clubTitle,
    this.category = 'Student Chapter',
    this.memberCount = '450+ Members',
  });

  @override
  State<ClubMembersScreen> createState() => _ClubMembersScreenState();
}

class _ClubMembersScreenState extends State<ClubMembersScreen> {
  static const Color textPrimary = Color(0xFF0F1419);
  static const Color textSecondary = Color(0xFF536471);
  static const Color dividerColor = Color(0xFFEFF3F4);

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _membersList = [
    {
      'id': '1',
      'name': 'Google Developer Groups',
      'handle': '@GDGMITS',
      'avatarUrl': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=120',
      'bio': 'GDG on Campus · MITS Gwalior Chapter | Building for developers',
      'isFollowing': true,
    },
    {
      'id': '2',
      'name': 'Student Development Cell',
      'handle': '@SDCMITS',
      'avatarUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120',
      'bio': 'Official Student Council for Innovation, Hackathons & Tech at MITS-DU',
      'isFollowing': true,
    },
    {
      'id': '3',
      'name': 'ACM Student Chapter',
      'handle': '@ACMMITS',
      'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120',
      'bio': 'Association for Computing Machinery · Student Chapter at MITS Gwalior',
      'isFollowing': true,
    },
    {
      'id': '4',
      'name': 'Alina Sprongole',
      'handle': '@AlinaSprongole',
      'avatarUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=120',
      'bio': 'Software Engineer @ Google | Tech Lead',
      'isFollowing': true,
    },
    {
      'id': '5',
      'name': 'Somraj Lodhi',
      'handle': '@somraj_dev',
      'avatarUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120',
      'bio': 'President & Founding Core Member · Computer Science & Engineering | Flutter & Cloud',
      'isFollowing': true,
    },
    {
      'id': '6',
      'name': 'Dr. R. K. Shrivastava',
      'handle': '@rk_shrivastava',
      'avatarUrl': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=120',
      'bio': 'Faculty Advisor & Mentor · Information Technology Department Head',
      'isFollowing': true,
    },
    {
      'id': '7',
      'name': 'Ananya Sharma',
      'handle': '@ananya_tech',
      'avatarUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=120',
      'bio': 'Vice President & Community Lead · Open Source & Hackathon Organizer',
      'isFollowing': false,
    },
    {
      'id': '8',
      'name': 'Rahul Verma',
      'handle': '@rahul_devops',
      'avatarUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=120',
      'bio': 'DevOps & Cloud Architect | Docker, Kubernetes & CI/CD Pipelines',
      'isFollowing': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredMembers {
    if (_searchQuery.trim().isEmpty) return _membersList;
    final q = _searchQuery.toLowerCase().trim();
    return _membersList.where((m) {
      final name = (m['name'] as String).toLowerCase();
      final bio = (m['bio'] as String).toLowerCase();
      return name.contains(q) || bio.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textPrimary, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.clubTitle} Members',
              style: const TextStyle(
                color: textPrimary,
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            Text(
              '${widget.memberCount} • ${widget.category}',
              style: const TextStyle(
                color: textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: _buildMembersListBody(),
    );
  }

  Widget _buildMembersListBody() {
    final list = _filteredMembers;

    return Column(
      children: [
        // Search Input Bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(21),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: const TextStyle(fontSize: 14, color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Search members...',
                hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16, color: Color(0xFF64748B)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: dividerColor),

        // Members List View
        Expanded(
          child: list.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search_rounded, size: 48, color: Color(0xFF94A3B8)),
                        SizedBox(height: 12),
                        Text(
                          'No members found',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Try searching with a different name or keyword',
                          style: TextStyle(fontSize: 13, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: dividerColor,
                  ),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _MemberRowItem(
                      item: item,
                      onToggleFollow: () {
                        setState(() {
                          item['isFollowing'] = !(item['isFollowing'] == true);
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _MemberRowItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onToggleFollow;

  const _MemberRowItem({
    required this.item,
    required this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF0F1419);
    final bool isFollowing = item['isFollowing'] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tappable Left & Center (Avatar + Details -> ProfileScreen)
          Expanded(
            child: InkWell(
              onTap: () => _openUserProfile(context),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: User avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFED7AA),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        item['avatarUrl'] as String? ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            (item['name'] as String).substring(0, 1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Center: User Details (Name & Bio)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] as String,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if ((item['bio'] as String?)?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 3),
                          Text(
                            item['bio'] as String,
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 13.5,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Right: Follow button (capsule style)
          GestureDetector(
            onTap: onToggleFollow,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isFollowing ? const Color(0xFF272C30) : textColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isFollowing ? 'Following' : 'Follow',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openUserProfile(BuildContext context) {
    final bool isOwn = item['id'] == AuthService.currentUser?.id ||
        (item['name'] != null && item['name'] == ProfileManager.name) ||
        ((item['handle'] as String? ?? '').replaceAll('@', '').toLowerCase() == AuthService.currentUser?.username?.toLowerCase());
    final Map<String, dynamic> userData = {
      'name': item['name'],
      'fullName': item['name'],
      'username': (item['handle'] as String? ?? '').replaceAll('@', ''),
      'handle': item['handle'] ?? '@${(item['name'] as String).replaceAll(' ', '').toLowerCase()}',
      'avatar': item['avatarUrl'],
      'avatarUrl': item['avatarUrl'],
      'bio': item['bio'],
      'headline': item['bio'],
      'role': item['bio'],
      'branch': 'Computer Science & Engineering',
      'department': 'Information Technology',
      'academicSession': '2022 – 2026',
      'isFollowing': item['isFollowing'] == true,
      'followersCount': 842,
      'followingCount': 310,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          isOwnProfile: isOwn,
          userData: userData,
        ),
      ),
    );
  }
}
