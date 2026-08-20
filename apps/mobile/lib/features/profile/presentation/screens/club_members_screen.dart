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
  static const Color primaryOrange = Color(0xFFF97316);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color cardBorder = Color(0xFFE2E8F0);

  late TabController _tabController;
  String _searchQuery = '';
  String _selectedRoleFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _allMembers = [
    {
      'id': '1',
      'name': 'Somraj Lodhi',
      'handle': '@somraj_dev',
      'role': 'President & Founding Core Member',
      'roleType': 'Core Team',
      'department': 'Computer Science & Engineering',
      'year': '3rd Year',
      'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120',
      'isLead': true,
      'isMentor': false,
      'isConnected': true,
      'joinedDate': 'Aug 2023',
    },
    {
      'id': '2',
      'name': 'Dr. R. K. Shrivastava',
      'handle': '@rk_shrivastava',
      'role': 'Faculty Advisor & Mentor',
      'roleType': 'Faculty Mentors',
      'department': 'Information Technology Dept',
      'year': 'Professor & Head',
      'avatarUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120',
      'isLead': false,
      'isMentor': true,
      'isConnected': true,
      'joinedDate': 'Jul 2021',
    },
    {
      'id': '3',
      'name': 'Ananya Sharma',
      'handle': '@ananya_tech',
      'role': 'Vice President & Community Lead',
      'roleType': 'Core Team',
      'department': 'Information Technology',
      'year': '3rd Year',
      'avatarUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=120',
      'isLead': true,
      'isMentor': false,
      'isConnected': false,
      'joinedDate': 'Sep 2023',
    },
    {
      'id': '4',
      'name': 'Rahul Verma',
      'handle': '@rahul_devops',
      'role': 'Open Source & Dev Lead',
      'roleType': 'Tech & Dev',
      'department': 'Computer Science & Engineering',
      'year': '4th Year',
      'avatarUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120',
      'isLead': true,
      'isMentor': false,
      'isConnected': false,
      'joinedDate': 'Aug 2023',
    },
    {
      'id': '5',
      'name': 'Prof. Sunita Agrawal',
      'handle': '@sunita_agrawal',
      'role': 'Faculty Co-Coordinator',
      'roleType': 'Faculty Mentors',
      'department': 'Computer Applications',
      'year': 'Associate Professor',
      'avatarUrl': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=120',
      'isLead': false,
      'isMentor': true,
      'isConnected': false,
      'joinedDate': 'Jan 2022',
    },
    {
      'id': '6',
      'name': 'Aarav Patel',
      'handle': '@aarav_cp',
      'role': 'Competitive Programming Lead',
      'roleType': 'Tech & Dev',
      'department': 'Electronics & Telecommunication',
      'year': '3rd Year',
      'avatarUrl': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=120',
      'isLead': true,
      'isMentor': false,
      'isConnected': false,
      'joinedDate': 'Oct 2023',
    },
    {
      'id': '7',
      'name': 'Priya Singh',
      'handle': '@priya_design',
      'role': 'Design & Creative Lead',
      'roleType': 'Core Team',
      'department': 'Architecture & Design',
      'year': '2nd Year',
      'avatarUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=120',
      'isLead': true,
      'isMentor': false,
      'isConnected': false,
      'joinedDate': 'Nov 2023',
    },
    {
      'id': '8',
      'name': 'Vikram Mehra',
      'handle': '@vikram_m',
      'role': 'Full Stack Contributor',
      'roleType': 'Tech & Dev',
      'department': 'Information Technology',
      'year': '2nd Year',
      'avatarUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=120',
      'isLead': false,
      'isMentor': false,
      'isConnected': false,
      'joinedDate': 'Dec 2023',
    },
    {
      'id': '9',
      'name': 'Sneha Tiwari',
      'handle': '@sneha_cloud',
      'role': 'Cloud & DevOps Contributor',
      'roleType': 'Tech & Dev',
      'department': 'Computer Science & Engineering',
      'year': '2nd Year',
      'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120',
      'isLead': false,
      'isMentor': false,
      'isConnected': false,
      'joinedDate': 'Jan 2024',
    },
    {
      'id': '10',
      'name': 'Rohan Gupta',
      'handle': '@rohan_g',
      'role': 'Active Student Member',
      'roleType': 'General Members',
      'department': 'Mechanical Engineering',
      'year': '1st Year',
      'avatarUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120',
      'isLead': false,
      'isMentor': false,
      'isConnected': false,
      'joinedDate': 'Feb 2024',
    },
    {
      'id': '11',
      'name': 'Kavya Jain',
      'handle': '@kavya_j',
      'role': 'Active Student Member',
      'roleType': 'General Members',
      'department': 'Electrical Engineering',
      'year': '1st Year',
      'avatarUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=120',
      'isLead': false,
      'isMentor': false,
      'isConnected': false,
      'joinedDate': 'Feb 2024',
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
    return _allMembers.where((member) {
      final name = (member['name'] as String).toLowerCase();
      final handle = (member['handle'] as String).toLowerCase();
      final role = (member['role'] as String).toLowerCase();
      final dept = (member['department'] as String).toLowerCase();
      final q = _searchQuery.toLowerCase().trim();

      final matchesQuery = q.isEmpty ||
          name.contains(q) ||
          handle.contains(q) ||
          role.contains(q) ||
          dept.contains(q);

      final matchesRole = _selectedRoleFilter == 'All' ||
          member['roleType'] == _selectedRoleFilter;

      return matchesQuery && matchesRole;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.clubTitle} Members',
              style: const TextStyle(
                color: textDark,
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
                color: textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: textDark, size: 20),
            onPressed: _showShareInviteDialog,
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryOrange,
          unselectedLabelColor: textMuted,
          indicatorColor: primaryOrange,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Directory'),
            Tab(text: 'Invite & Join'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: MEMBERS DIRECTORY
          _buildDirectoryTab(),

          // TAB 2: INVITE & JOIN
          _buildInviteTab(),
        ],
      ),
    );
  }

  Widget _buildDirectoryTab() {
    final filtered = _filteredMembers;
    final roleFilters = ['All', 'Core Team', 'Faculty Mentors', 'Tech & Dev', 'General Members'];

    return Column(
      children: [
        // Search Input
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cardBorder),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: const TextStyle(fontSize: 14, color: textDark),
              decoration: InputDecoration(
                hintText: 'Search members by name, role or branch...',
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: Color(0xFF64748B)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),

        // Role Filter Pills
        Container(
          color: Colors.white,
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            scrollDirection: Axis.horizontal,
            itemCount: roleFilters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final role = roleFilters[index];
              final isSelected = _selectedRoleFilter == role;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRoleFilter = role;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFF7ED) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? primaryOrange : cardBorder,
                      width: 1.2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    role,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? primaryOrange : const Color(0xFF475569),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // Members List View
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_search_rounded, size: 48, color: Color(0xFF94A3B8)),
                      SizedBox(height: 12),
                      Text(
                        'No members found',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Try adjusting your search or role filters',
                        style: TextStyle(fontSize: 13, color: textMuted),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final member = filtered[index];
                    return _buildMemberCard(member);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    final bool isLead = member['isLead'] == true;
    final bool isMentor = member['isMentor'] == true;
    final bool isConnected = member['isConnected'] == true;

    Color badgeBg = const Color(0xFFF1F5F9);
    Color badgeText = const Color(0xFF475569);

    if (isMentor) {
      badgeBg = const Color(0xFFEFF6FF);
      badgeText = const Color(0xFF2563EB);
    } else if (isLead) {
      badgeBg = const Color(0xFFFFF7ED);
      badgeText = primaryOrange;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isLead ? primaryOrange : (isMentor ? const Color(0xFF2563EB) : cardBorder),
                width: 1.5,
              ),
              color: const Color(0xFFFED7AA),
            ),
            child: ClipOval(
              child: Image.network(
                member['avatarUrl'] as String,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    (member['name'] as String).substring(0, 1),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isLead ? primaryOrange : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name & Verified Badge
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member['name'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isLead || isMentor) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified,
                        size: 15,
                        color: isMentor ? const Color(0xFF2563EB) : primaryOrange,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),

                // Role Badge Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    member['role'] as String,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: badgeText,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Department & Year
                Text(
                  '${member['department']} • ${member['year']}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Connect / Message Button
          GestureDetector(
            onTap: () {
              setState(() {
                member['isConnected'] = !isConnected;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    !isConnected
                        ? 'Connection request sent to ${member['name']}'
                        : 'Disconnected from ${member['name']}',
                  ),
                  backgroundColor: !isConnected ? const Color(0xFF10B981) : const Color(0xFF0F172A),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isConnected ? const Color(0xFFF1F5F9) : primaryOrange,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isConnected ? cardBorder : primaryOrange,
                ),
              ),
              child: Text(
                isConnected ? 'Connected' : 'Connect',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isConnected ? const Color(0xFF334155) : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteTab() {
    const inviteUrl = 'https://acadyk.app/chapters/mits-coding-club/join?ref=somraj';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Chapter Invite Banner Card
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
                              color: textDark,
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
                    border: Border.all(color: cardBorder),
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
                            color: primaryOrange,
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

          // 2. Share Options Row
          const Text(
            'Quick Share',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textDark),
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

          // 3. Chapter Guidelines
          const Text(
            'Membership Perks & Roles',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textDark),
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
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            Text(
              'Invite peers and contributors to join ${widget.clubTitle}',
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
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
