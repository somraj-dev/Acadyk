import 'package:flutter/material.dart';
import 'package:acadyk/features/profile/presentation/screens/profile_screen.dart';
import 'add_team_member_screen.dart';
import 'edit_team_member_screen.dart';
import '../widgets/invite_friends_dialog.dart';
import '../services/opportunities_manager.dart';
import 'home_feed_screen.dart';

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
  late TextEditingController _teamSloganController;
  late TextEditingController _instituteNameController;
  late TextEditingController _instituteLocationController;
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
    _teamSloganController = TextEditingController(text: 'Building the future, together.');
    _instituteNameController = TextEditingController(text: 'Madhav Institute of Technology & Science');
    _instituteLocationController = TextEditingController(text: 'Gwalior, Madhya Pradesh');
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _teamSloganController.dispose();
    _instituteNameController.dispose();
    _instituteLocationController.dispose();
    super.dispose();
  }

  void _addNewMember() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddTeamMemberScreen(
          memberNumber: _members.length + 1,
          leaderLocation: _instituteLocationController.text,
          leaderCollege: _instituteNameController.text,
        ),
      ),
    );

    if (!mounted) return;
    if (result != null) {
      setState(() {
        _members.add({
          ...result,
          'role': result['role'] ?? 'Member',
        });
      });
    }
  }

  void _openEditMemberScreen(int index) async {
    final member = _members[index];
    final isLeader = member['isLeader'] == true;

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditTeamMemberScreen(
          memberIndex: index,
          memberData: Map<String, dynamic>.from(member),
          isLeader: isLeader,
          totalMembers: _members.length,
        ),
      ),
    );

    if (!mounted) return;
    if (result != null) {
      if (result['action'] == 'delete') {
        setState(() {
          _members.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Member removed from team roster'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      } else if (result['action'] == 'update') {
        setState(() {
          final updated = result['member'] as Map<String, dynamic>;
          if (updated['isLeader'] == true) {
            for (var m in _members) {
              m['isLeader'] = false;
            }
          }
          _members[index] = updated;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Member details updated!'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    }
  }

  void _openEditTeamDetailsSheet() {
    final tempNameCtrl = TextEditingController(text: _teamNameController.text);
    final tempSloganCtrl = TextEditingController(text: _teamSloganController.text);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Team Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(sheetCtx),
                  ),
                ],
              ),
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 12),
              const Text('Team Name', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: tempNameCtrl,
                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter team name'),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Tagline / Slogan', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: tempSloganCtrl,
                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter team tagline'),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () {
                    setState(() {
                      _teamNameController.text = tempNameCtrl.text.trim().isNotEmpty ? tempNameCtrl.text.trim() : 'Axio Innovators';
                      _teamSloganController.text = tempSloganCtrl.text.trim().isNotEmpty ? tempSloganCtrl.text.trim() : 'Building the future, together.';
                    });
                    Navigator.pop(sheetCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Team information updated!'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  child: const Text('Save Team Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        );
      },
    );
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
            'bio': '${member['role']} at ${_instituteNameController.text}',
            'location': _instituteLocationController.text,
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

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF0284C7);
    const Color darkNavy = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                    // 1. Team Title, Slogan & Edit Pencil
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                              Text(
                                _teamSloganController.text,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0284C7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Pencil edit button for team info
                        GestureDetector(
                          onTap: _openEditTeamDetailsSheet,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFBAE6FD)),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF0284C7),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
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

                    // 2. Institute Info Card (Host Institute - Fixed)
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
                              children: [
                                const Text(
                                  'HOST INSTITUTE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF64748B),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _instituteNameController.text,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: darkNavy,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _instituteLocationController.text,
                                  style: const TextStyle(
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
                            onTap: isLeader
                                ? () => _openMemberProfile(index)
                                : () => _openEditMemberScreen(index),
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
                                  // Top Row: Number Badge & Pencil Edit Icon (for teammates)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
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
                                      if (!isLeader)
                                        GestureDetector(
                                          onTap: () => _openEditMemberScreen(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: const Color(0xFFE2E8F0)),
                                            ),
                                            child: const Icon(
                                              Icons.edit_outlined,
                                              size: 13,
                                              color: Color(0xFF475569),
                                            ),
                                          ),
                                        )
                                      else
                                        const SizedBox.shrink(),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Avatar (Tap to view profile)
                                  GestureDetector(
                                    onTap: () => _openMemberProfile(index),
                                    child: Container(
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
                                  const SizedBox(height: 4),
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

                    // 5. Metadata Row (Leader & Institute details - Fixed info)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Builder(
                        builder: (context) {
                          final leader = _members.firstWhere(
                            (m) => m['isLeader'] == true,
                            orElse: () => _members.first,
                          );

                          return Column(
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
                                        children: [
                                          const Text(
                                            'TEAM LEADER',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0284C7),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            leader['name']?.toString() ?? '',
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                              color: darkNavy,
                                            ),
                                          ),
                                          Text(
                                            leader['role']?.toString() ?? '',
                                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                          ),
                                          Text(
                                            leader['email']?.toString() ?? '',
                                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
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
                                      children: [
                                        const Text(
                                          'INSTITUTE',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0284C7),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _instituteNameController.text,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: darkNavy,
                                          ),
                                        ),
                                        Text(
                                          _instituteLocationController.text,
                                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
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
                      final teamName = _teamNameController.text.trim().isNotEmpty
                          ? _teamNameController.text.trim()
                          : 'Axio Innovators';

                      final leader = _members.firstWhere(
                        (m) => m['isLeader'] == true,
                        orElse: () => _members.first,
                      );
                      final leaderName = leader['name']?.toString() ?? 'Team Lead';

                      final newOpportunity = {
                        'title': '$teamName · Hackathon Team',
                        'logoUrl': 'assets/images/mits_logo.png',
                        'bannerUrl': 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800&auto=format&fit=crop',
                        'organizer': leaderName,
                        'timeAgo': 'Just now',
                        'tagline': '${_teamSloganController.text} ${_members.length} members joined.',
                        'dates': 'Recruiting Now\nOpen Applications',
                        'location': '${_instituteLocationController.text}\nCampus & Online',
                        'teamSizeText': '${_members.length} Members\nLooking for Teammates',
                        'tags': ['Create Team', 'Hackathon', 'Team Recruitment', 'Open to All'],
                        'lookingForTeammates': _lookingForTeammates,
                        'prizePool': 'Team Collaboration',
                        'likes': 0,
                        'comments': 0,
                        'event': {
                          'title': '$teamName · Hackathon Team',
                          'organizer': leaderName,
                          'bannerUrl': 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800&auto=format&fit=crop',
                          'logoUrl': 'assets/images/mits_logo.png',
                          'teamSize': '${_members.length} Members',
                          'registered': _members.length,
                          'prizes': 'Hackathon Team Spot & Project Collaboration',
                          'eligibility': 'Open to developers, designers, and students looking for hackathon teammates at ${_instituteNameController.text}.',
                          'description': 'Join $teamName (${_teamSloganController.text}) for hackathons, innovation challenges, and student projects.\n\nCurrent Members:\n${_members.map((m) => "• ${m['name']} (${m['role']})").join('\n')}',
                          'members': _members,
                          'timeline': [
                            {
                              'day': 'NOW',
                              'month': 'OPEN',
                              'title': 'Team Recruitment Active',
                              'startDate': 'Open Now',
                              'endDate': 'Rolling basis',
                              'isLive': true,
                              'desc': 'Connect with the team lead and join the roster.'
                            }
                          ]
                        }
                      };

                      OpportunitiesManager.addOpportunity(newOpportunity);
                      HomeFeedScreen.switchTab(1);

                      Navigator.pop(context); // Close CreateTeamScreen
                      Navigator.pop(context); // Close SelectOpportunityScreen

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Team "$teamName" published directly to Opportunities! 🎉'),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    },
                    child: const Text(
                      'Publish to Opportunities',
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
