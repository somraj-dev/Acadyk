import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

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

class _ClubMembersScreenState extends State<ClubMembersScreen> with SingleTickerProviderStateMixin {
  static const Color textPrimary = Color(0xFF0F1419);
  static const Color textSecondary = Color(0xFF536471);
  static const Color buttonDark = Color(0xFF272C30);
  static const Color dividerColor = Color(0xFFEFF3F4);

  late TabController _tabController;
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
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredMembers {
    if (_searchQuery.trim().isEmpty) return _membersList;
    final q = _searchQuery.toLowerCase().trim();
    return _membersList.where((m) {
      final name = (m['name'] as String).toLowerCase();
      final handle = (m['handle'] as String).toLowerCase();
      final bio = (m['bio'] as String).toLowerCase();
      return name.contains(q) || handle.contains(q) || bio.contains(q);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: textPrimary, size: 20),
            onPressed: _showShareInviteDialog,
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1DA1F2),
          unselectedLabelColor: textSecondary,
          indicatorColor: const Color(0xFF1DA1F2),
          indicatorWeight: 3.0,
          labelStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Members'),
            Tab(text: 'Invite & Join'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: MEMBERS LIST (1:1 Exact Replica of reference design)
          _buildMembersListTab(),

          // TAB 2: INVITE & JOIN
          _buildInviteTab(),
        ],
      ),
    );
  }

  Widget _buildMembersListTab() {
    final list = _filteredMembers;

    return Column(
      children: [
        // Search Input Bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
                          'Try searching with a different name or handle',
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

  Widget _buildInviteTab() {
    const inviteUrl = 'https://acadyk.app/chapters/mits-coding-club/join?ref=somraj';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chapter Invite Banner Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDBA74)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF97316),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.group_add_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invite Peers & Classmates',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Grow your campus student chapter',
                            style: TextStyle(fontSize: 12.5, color: Color(0xFF9A3412)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Anyone with this link will be able to join the chapter channel, access curated workshop notes, and receive hackathon updates.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF431407), height: 1.45),
                ),
                const SizedBox(height: 16),

                // Copy Link Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link_rounded, size: 18, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          inviteUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF334155), fontFamily: 'monospace'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(const ClipboardData(text: inviteUrl));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invite link copied to clipboard!'),
                              backgroundColor: Color(0xFF10B981),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF97316),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Copy',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Share Options
          const Text(
            'Quick Share',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildShareActionItem(
                icon: Icons.chat_rounded,
                label: 'WhatsApp',
                color: const Color(0xFF22C55E),
                onTap: () => _sharePlatform('WhatsApp'),
              ),
              const SizedBox(width: 12),
              _buildShareActionItem(
                icon: Icons.telegram_rounded,
                label: 'Telegram',
                color: const Color(0xFF0284C7),
                onTap: () => _sharePlatform('Telegram'),
              ),
              const SizedBox(width: 12),
              _buildShareActionItem(
                icon: Icons.email_rounded,
                label: 'Campus Email',
                color: const Color(0xFFEA580C),
                onTap: () => _sharePlatform('Campus Email'),
              ),
              const SizedBox(width: 12),
              _buildShareActionItem(
                icon: Icons.qr_code_2_rounded,
                label: 'QR Poster',
                color: const Color(0xFF6366F1),
                onTap: _showQRCodeDialog,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Membership Perks
          const Text(
            'Membership Perks & Roles',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPrimary),
          ),
          const SizedBox(height: 12),
          _buildPerkItem(Icons.verified_user_rounded, 'Verified Student Chapter Badge on profile'),
          _buildPerkItem(Icons.event_available_rounded, 'Early registration to internal college hackathons'),
          _buildPerkItem(Icons.terminal_rounded, 'Access to technical repos, resources and mentor sessions'),
          _buildPerkItem(Icons.card_membership_rounded, 'Official participation and leadership certificates'),
        ],
      ),
    );
  }

  Widget _buildShareActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerkItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF10B981)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF334155), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  void _sharePlatform(String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $platform to share ${widget.clubTitle} invite link...'),
        backgroundColor: const Color(0xFF0F172A),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showQRCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '${widget.clubTitle} QR Code',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDBA74)),
              ),
              child: const Icon(Icons.qr_code_2_rounded, size: 140, color: Color(0xFFF97316)),
            ),
            const SizedBox(height: 14),
            const Text(
              'Scan at campus orientations or club booths to join instantly.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showShareInviteDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share Chapter Invite',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Invite peers and contributors to join ${widget.clubTitle}',
              style: const TextStyle(fontSize: 13.5, color: textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copy Chapter Invite Link'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Clipboard.setData(const ClipboardData(text: 'https://acadyk.app/chapters/join'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chapter link copied to clipboard!'),
                    backgroundColor: Color(0xFF10B981),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
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
    const Color textSecondary = Color(0xFF536471);
    final bool isFollowing = item['isFollowing'] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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

          // Center: User Details (Name, Username, Bio)
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
                const SizedBox(height: 1),
                Text(
                  item['handle'] as String,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 13.5,
                  ),
                ),
                if ((item['bio'] as String?)?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 4),
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
}
