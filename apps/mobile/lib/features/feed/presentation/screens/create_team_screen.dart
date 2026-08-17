import 'package:flutter/material.dart';
import 'package:acadyk/features/profile/presentation/screens/profile_screen.dart';
import 'add_team_member_screen.dart';
import '../widgets/invite_friends_dialog.dart';

class CreateTeamScreen extends StatefulWidget {
  final String? initialTeamName;
  final String? competitionTitle;

  const CreateTeamScreen({
    super.key,
    this.initialTeamName,
    this.competitionTitle,
  });

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  late TextEditingController _teamNameController;
  final bool _lookingForTeammates = true;

  final List<Map<String, dynamic>> _members = [
    {
      'name': 'Somraj Lodhi',
      'role': 'B.Tech AIML, 3rd Year',
      'email': '25AM10SO80@mitsgwl.ac.in',
      'contact': '+919243657795',
      'status': 'verified',
      'initial': 'S',
      'isLeader': true,
      'avatar': 'assets/images/somraj_avatar.jpg',
      'badgeIcon': Icons.workspace_premium_rounded,
    },
    {
      'name': 'Ananya Singh',
      'role': 'ML Engineer',
      'email': '25AM10SO81@mitsgwl.ac.in',
      'contact': '+919876543210',
      'status': 'verified',
      'initial': 'A',
      'isLeader': false,
      'avatar': 'assets/images/alina_avatar.jpg',
      'badgeIcon': Icons.psychology_outlined,
    },
    {
      'name': 'Rohit Sharma',
      'role': 'Backend Developer',
      'email': '25AM10SO82@mitsgwl.ac.in',
      'contact': '+919876543211',
      'status': 'verified',
      'initial': 'R',
      'isLeader': false,
      'avatar': 'assets/images/dharmik_avatar.jpg',
      'badgeIcon': Icons.code_rounded,
    },
    {
      'name': 'Priya Verma',
      'role': 'UI/UX Designer',
      'email': '25AM10SO83@mitsgwl.ac.in',
      'contact': '+919876543212',
      'status': 'verified',
      'initial': 'P',
      'isLeader': false,
      'avatar': 'assets/images/user_avatar.jpg',
      'badgeIcon': Icons.brush_outlined,
    },
  ];

  String _getOrdinal(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }

  @override
  void initState() {
    super.initState();
    final initialName = widget.initialTeamName ?? 'Axio Innovators';
    _teamNameController = TextEditingController(text: initialName);
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  void _addNewMember() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddTeamMemberScreen(
          memberNumber: _members.length + 1,
          leaderLocation: 'Gwalior, Madhya Pradesh',
          leaderCollege: 'Madhav Institute of Technology & Science',
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _members.add({
          ...result,
          'role': result['role'] ?? 'Member',
          'badgeIcon': Icons.person_outline,
        });
      });
    }
  }

  void _openMemberProfile(int index) {
    final member = _members[index];
    final isLeader = member['isLeader'] == true;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          isOwnProfile: isLeader,
          userData: {
            'name': member['name'],
            'full_name': member['name'],
            'headline': member['role'],
            'bio': '${member['role']} at Madhav Institute of Technology & Science',
            'location': 'Gwalior, Madhya Pradesh',
            'avatar': member['avatar'],
            'email': member['email'],
          },
        ),
      ),
    );
  }

  void _inviteFriends() {
    InviteFriendsDialog.show(
      context,
      teamName: _teamNameController.text,
    );
  }

  void _removeMember(int index) {
    if (index == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team leader cannot be removed')),
      );
      return;
    }
    setState(() {
      _members.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF0284C7);
    const Color darkNavy = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Team Showcase',
          style: TextStyle(color: darkNavy, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Team Title & Slogan
                    Text(
                      _teamNameController.text,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: darkNavy,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Building the future, together.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 44,
                      height: 3.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. Institute Info Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.account_balance_outlined,
                              color: Color(0xFF0284C7),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'HOST INSTITUTE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF64748B),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Madhav Institute of Technology & Science',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: darkNavy,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Gwalior, Madhya Pradesh',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. Team Member Cards Row (Horizontal Scroll / Grid)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _members.asMap().entries.map((entry) {
                          final index = entry.key;
                          final member = entry.value;
                          final isLeader = member['isLeader'] == true;
                          final numberStr = (index + 1).toString().padLeft(2, '0');

                          return GestureDetector(
                            onTap: () => _openMemberProfile(index),
                            onLongPress: () => _removeMember(index),
                            child: Container(
                              width: 160,
                              margin: const EdgeInsets.only(right: 14),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isLeader ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                                  width: isLeader ? 1.8 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isLeader
                                        ? const Color(0xFF0284C7).withValues(alpha: 0.08)
                                        : Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Top Number Badge
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0284C7),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        numberStr,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Avatar
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFE0F2FE), width: 2),
                                    ),
                                    child: ClipOval(
                                      child: member['avatar'] != null
                                          ? Image.asset(
                                              member['avatar'] as String,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => _buildFallbackInitial(member['initial']),
                                            )
                                          : _buildFallbackInitial(member['initial']),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Team Leader Badge
                                  if (isLeader) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0F2FE),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'TEAM LEADER',
                                        style: TextStyle(
                                          color: Color(0xFF0284C7),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                  ] else
                                    const SizedBox(height: 18),

                                  // Name
                                  Text(
                                    member['name'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: darkNavy,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 3),

                                  // Role Subtitle
                                  Text(
                                    member['role'] ?? member['contact'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),

                                  // Bottom Icon Circle
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      member['badgeIcon'] as IconData? ?? Icons.star_outline,
                                      size: 16,
                                      color: const Color(0xFF0284C7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4. Metrics / Stats Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMetricItem(
                            icon: Icons.people_alt_outlined,
                            label: 'MEMBERS',
                            value: '${_members.length}',
                          ),
                          _buildDivider(),
                          _buildMetricItem(
                            icon: Icons.folder_open_outlined,
                            label: 'PROJECTS',
                            value: '3',
                          ),
                          _buildDivider(),
                          _buildMetricItem(
                            icon: Icons.emoji_events_outlined,
                            label: 'HACKATHONS',
                            value: '6',
                          ),
                          _buildDivider(),
                          _buildMetricItem(
                            icon: Icons.calendar_today_outlined,
                            label: 'SINCE',
                            value: '2025',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 5. Metadata Row (Leader & Institute details)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _openMemberProfile(0),
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.person_outline, color: Color(0xFF0284C7), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'TEAM LEADER',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0284C7),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Somraj Lodhi',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: darkNavy,
                                        ),
                                      ),
                                      Text(
                                        'B.Tech AIML, 3rd Year',
                                        style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                      ),
                                      Text(
                                        '25AM10SO80@mitsgwl.ac.in',
                                        style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 24, color: Color(0xFFF1F5F9)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.account_balance_outlined, color: Color(0xFF0284C7), size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'INSTITUTE',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0284C7),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Madhav Institute of Technology & Science',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: darkNavy,
                                      ),
                                    ),
                                    Text(
                                      'Gwalior, Madhya Pradesh',
                                      style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 6. Action Buttons Row (Add Member & Invite Friends)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFF0284C7), width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _addNewMember,
                            icon: const Icon(Icons.add, color: Color(0xFF0284C7), size: 20),
                            label: Text(
                              '+ ${_getOrdinal(_members.length + 1)} Member',
                              style: const TextStyle(
                                color: Color(0xFF0284C7),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0284C7),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _inviteFriends,
                            icon: const Icon(Icons.share_outlined, size: 18),
                            label: const Text(
                              'Invite Friends',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Bottom Actions Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Team "${_teamNameController.text}" updated successfully!'),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                      Navigator.pop(context, {
                        'teamName': _teamNameController.text,
                        'membersCount': _members.length,
                        'lookingForTeammates': _lookingForTeammates,
                      });
                    },
                    child: const Text(
                      'Update Details',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackInitial(String? initial) {
    return Container(
      color: const Color(0xFF0284C7),
      alignment: Alignment.center,
      child: Text(
        initial ?? 'U',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF0284C7), size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFF1F5F9),
    );
  }
}
