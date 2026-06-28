import 'package:flutter/material.dart';
import 'direct_message_screen.dart';

class MessageCenterScreen extends StatelessWidget {
  const MessageCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F1015);

    final List<Map<String, dynamic>> chats = [
      {
        'name': 'Tannya♠️📌',
        'subtitle': 'Seen 8h ago',
        'hasBlueDot': false,
        'isMuted': false,
        'avatarColor': Colors.grey.shade900,
        'icon': Icons.person_outline,
      },
      {
        'name': 'Vandna📌',
        'subtitle': 'Reacted 👍 to your message · 13h',
        'hasBlueDot': false,
        'isMuted': false,
        'avatarColor': Colors.brown.shade800,
        'icon': Icons.person,
      },
      {
        'name': 'Dev Sahu',
        'subtitle': 'Sent a reel by trollingvyoom · 2h',
        'hasBlueDot': true,
        'isMuted': false,
        'avatarColor': Colors.blueGrey.shade700,
        'icon': Icons.person,
      },
      {
        'name': 'ujjwal',
        'nameStyle': const TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        'subtitle': 'Sent 2h ago',
        'hasBlueDot': false,
        'isMuted': false,
        'avatarColor': Colors.teal.shade900,
        'icon': Icons.person,
      },
      {
        'name': 'Gaurav Rajawat',
        'subtitle': 'Reacted 😈 to your messag... 3h',
        'hasBlueDot': true,
        'isMuted': false,
        'avatarColor': Colors.indigo.shade900,
        'icon': Icons.person,
      },
      {
        'name': 'ਆਯੂਸ਼',
        'subtitle': 'Same same · 4h',
        'hasBlueDot': true,
        'isMuted': false,
        'avatarColor': const Color(0xFF9E9E9E), // Grey background
        'icon': Icons.person,
        'iconColor': Colors.white,
      },
      {
        'name': 'BHAANG BHOS*A',
        'subtitle': '4 new messages · 4h',
        'hasBlueDot': false,
        'isMuted': true,
        'avatarColor': const Color(0xFF42A5F5), // Blue background
        'icon': Icons.emoji_emotions,
        'iconColor': Colors.yellow,
      },
      {
        'name': 'ANURAG GURJAR💓',
        'subtitle': '4 new messages · 4h',
        'hasBlueDot': false,
        'isMuted': false,
        'avatarColor': Colors.deepOrange.shade900,
        'icon': Icons.person,
      },
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Right Icon (Edit/Compose)
            Padding(
              padding: const EdgeInsets.only(top: 16.0, right: 16.0, bottom: 12.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: const Icon(Icons.edit_square, color: Colors.white, size: 28), // Note: use outlined variant if available in context, else this works as placeholder
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF22242B), // Dark grey pill
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    // AI Search Icon Simulation
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Stack(
                        children: [
                          const Positioned(
                            bottom: 0,
                            left: 0,
                            child: Icon(Icons.search, color: Colors.white, size: 22),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Icon(Icons.star, color: Colors.white, size: 10),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Search',
                      style: TextStyle(
                        color: Color(0xFF8696A0),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Chats List
            Expanded(
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return _buildChatItem(
                    context: context,
                    name: chat['name'] as String,
                    subtitle: chat['subtitle'] as String,
            hasBlueDot: chat['hasBlueDot'] as bool,
            isMuted: chat['isMuted'] as bool,
            avatarColor: chat['avatarColor'] as Color,
            icon: chat['icon'] as IconData,
            iconColor: chat['iconColor'] as Color? ?? Colors.white54,
            nameStyle: chat['nameStyle'] as TextStyle?,
          );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem({
    required BuildContext context,
    required String name,
    required String subtitle,
    required bool hasBlueDot,
    required bool isMuted,
    required Color avatarColor,
    required IconData icon,
    required Color iconColor,
    TextStyle? nameStyle,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DirectMessageScreen(
              name: name,
              handle: 'ayu3_ushhx', // Simulated handle for dummy integration
              avatarColor: avatarColor,
              avatarIcon: icon,
              iconColor: iconColor,
            ),
          ),
        );
      },
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Avatar with border
          Container(
            padding: const EdgeInsets.all(2.0), // space for border
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF22242B), width: 2), // Outer dark border
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: avatarColor,
              child: Icon(icon, color: iconColor, size: 30),
            ),
          ),
          const SizedBox(width: 16),
          // Name and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: nameStyle ?? const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: hasBlueDot ? Colors.white : const Color(0xFFA0A0A0),
                          fontSize: 14,
                          fontWeight: hasBlueDot ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMuted) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.notifications_off_outlined, color: Color(0xFFA0A0A0), size: 14),
                    ]
                  ],
                ),
              ],
            ),
          ),
          // Blue Dot indicator
          if (hasBlueDot) ...[
            const SizedBox(width: 8),
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6), // Bright blue dot
                shape: BoxShape.circle,
              ),
            ),
          ]
        ],
      ),
    ),
    );
  }
}
