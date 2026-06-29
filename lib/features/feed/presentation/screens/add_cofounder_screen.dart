import 'package:flutter/material.dart';
import '../services/startup_manager.dart';

class AddCofounderScreen extends StatefulWidget {
  const AddCofounderScreen({super.key});

  @override
  State<AddCofounderScreen> createState() => _AddCofounderScreenState();
}

class _AddCofounderScreenState extends State<AddCofounderScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // Mock list of users from the screenshot
  final List<Map<String, String>> _allUsers = [
    {
      'name': 'Raja Sharma',
      'subtitle': '--',
      'avatarType': 'letter',
      'letter': 'R',
      'color': 'orange',
    },
    {
      'name': 'Abhinav Jain',
      'subtitle': 'Co-Founder at Little Monk',
      'avatarType': 'icon',
    },
    {
      'name': 'Pankaj kumar Jha',
      'subtitle': 'Javascript | node.js | Backend',
      'avatarType': 'image',
      'image': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=120&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Ashish Sengar',
      'subtitle': 'SAP Consultant Package Implementation @ LTM| SAP Certified in S/4 HANA Private and Public Cloud',
      'avatarType': 'image',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120&auto=format&fit=crop&q=80',
    },
    {
      'name': 'UTTAM JATAV',
      'subtitle': 'Founder & CEO @ TechPeth | Entrepreneurship, EdTech Strategy',
      'avatarType': 'image',
      'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Vinay Shukla',
      'subtitle': 'Owner Of Vdsshine ( Digital Marketing Agency )',
      'avatarType': 'icon',
    },
    {
      'name': 'Parag Kudav',
      'subtitle': 'Building the Future of Land & Real Estate | Founder - Acreexpert (LandTech), Selfmade Realty (Sales Ops), Cinematic Psychos (Creative Agency)',
      'avatarType': 'image',
      'image': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=120&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Raj kishan chourasiya',
      'subtitle': 'AI & Data Science Undergraduate',
      'avatarType': 'image',
      'image': 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=120&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Atharva Shrotriya',
      'subtitle': 'Bridging Business Strategy & Tech | IT BDE & ECE Undergrad',
      'avatarType': 'image',
      'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Sochuem Bunnarom',
      'subtitle': 'Biz Owner at SOKKAN GROUP.Co., LTD',
      'avatarType': 'image',
      'image': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=120&auto=format&fit=crop&q=80',
    },
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _sendCoFounderRequest(Map<String, String> user) {
    // Generate cofounder invitation notification
    final invitation = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'avatarUrl': 'assets/images/somraj_avatar.jpg', // Current user somraj
      'username': '@somraj_lodhi',
      'actionText': 'invited you to join as a co-founder for their startup',
      'timeText': 'Just now',
      'timeAgo': '0 mins ago',
      'isUnread': true,
      'type': 'invite',
      'status': 'pending', // pending, accepted, declined
      'senderName': 'Somraj lodhi',
      'targetUser': user['name'],
    };

    StartupManager.addNotification(invitation);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Co-founder request sent to ${user['name']}!'),
        backgroundColor: Colors.black,
      ),
    );

    // Return the selected co-founder name back to the form
    Navigator.of(context).pop(user['name']);
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _allUsers.where((u) {
      final nameMatches = u['name']!.toLowerCase().contains(_searchQuery.toLowerCase());
      final subMatches = u['subtitle']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return nameMatches || subMatches;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Co-founder',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Responsive Search Bar Container
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search developers, designers...',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Users List
          Expanded(
            child: ListView.separated(
              itemCount: filteredUsers.length,
              separatorBuilder: (context, index) => const Divider(
                color: Color(0xFFF3F4F6),
                height: 1,
                indent: 72,
              ),
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  onTap: () => _sendCoFounderRequest(user),
                  leading: _buildAvatar(user),
                  title: Text(
                    user['name']!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      user['subtitle']!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: user['subtitle'] == '--' ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                        height: 1.3,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Map<String, String> user) {
    if (user['avatarType'] == 'letter') {
      return CircleAvatar(
        radius: 22,
        backgroundColor: Colors.orange.shade700,
        child: Text(
          user['letter']!,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      );
    } else if (user['avatarType'] == 'icon') {
      return CircleAvatar(
        radius: 22,
        backgroundColor: const Color(0xFFE5E7EB),
        child: const Icon(Icons.person, color: Color(0xFF9CA3AF), size: 24),
      );
    } else {
      return CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage(user['image']!),
        backgroundColor: Colors.transparent,
      );
    }
  }
}
