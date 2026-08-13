import 'package:flutter/material.dart';

class PublicCommunityScreen extends StatelessWidget {
  final String communityName;
  final String description;
  final String visitors;
  final String? logoUrl;

  const PublicCommunityScreen({
    super.key,
    required this.communityName,
    required this.description,
    required this.visitors,
    this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0B141A);
    const textColor = Colors.white;
    const secondaryTextColor = Color(0xFF8696A0);
    const accentColor = Color(0xFF1955CC); // Blue
    const linkColor = Color(0xFF61DAFB); // Light blue for tags

    // Extracting just numbers for the "contributions" part since it's hardcoded for visual match
    String contributions = '9.1k';
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: textColor),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: logoUrl != null
                        ? CircleAvatar(
                            radius: 26,
                            backgroundImage: NetworkImage(logoUrl!),
                          )
                        : const CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.greenAccent,
                            child: Text(
                              '>?',
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'r/$communityName',
                                style: const TextStyle(
                                  color: textColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios, color: textColor, size: 14),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$visitors visitors and $contributions contributions\nper week',
                          style: const TextStyle(
                            color: secondaryTextColor,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      elevation: 0,
                    ),
                    child: const Text('Join', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description and Tags
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description.isNotEmpty 
                        ? description 
                        : '$communityName is a community for those who are in the process of entering or are already part of the computer ...',
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 14),
                      children: [
                        TextSpan(text: '#12 in Career', style: TextStyle(color: linkColor, fontWeight: FontWeight.bold)),
                        TextSpan(text: '  |  ', style: TextStyle(color: secondaryTextColor)),
                        TextSpan(text: 'Top Members', style: TextStyle(color: linkColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            
            // Community Highlights
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.push_pin, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text('Community highlights', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildHighlightCard('Resume Advice Thread - June 27, 2026'),
                        const SizedBox(width: 12),
                        _buildHighlightCard('[OFFICIAL] Salary Sharing thread for NEW GRADS :: June, ...'),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(color: Color(0xFF1E2931), thickness: 1),
            
            // Post Feed
            _buildStaticPost(),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightCard(String title) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF162026),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3942), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, height: 1.3),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.tealAccent.shade400,
            child: const Icon(Icons.android, color: Colors.black, size: 16), // Dummy icon replacing reddit logo
          ),
        ],
      ),
    );
  }

  Widget _buildStaticPost() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.brown.shade700,
                    child: const Icon(Icons.person, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text('jholliday55', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 6),
                  const Text('16h • 125k views', style: TextStyle(color: Color(0xFF8696A0), fontSize: 13)),
                ],
              ),
              const Icon(Icons.more_vert, color: Colors.white, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'If AI is so good, how come every app and website I use has gotten worse?',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.3),
          ),
          const SizedBox(height: 8),
          const Text(
            'Genuine question. Every app I used has gotten worse in the last year plus. Reddit: First time I use the search or first post I click into takes 20 seconds to l...',
            style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildActionPill(Icons.arrow_upward, '681', suffixIcon: Icons.arrow_downward),
              const SizedBox(width: 12),
              _buildActionPill(Icons.chat_bubble_outline, '172'),
              const SizedBox(width: 12),
              _buildActionPill(Icons.reply, '62'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionPill(IconData icon, String label, {IconData? suffixIcon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2931),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A3942), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          if (suffixIcon != null) ...[
            const SizedBox(width: 8),
            Container(width: 1, height: 14, color: const Color(0xFF3B4A54)),
            const SizedBox(width: 8),
            Icon(suffixIcon, color: Colors.white, size: 18),
          ],
        ],
      ),
    );
  }
}
