import 'package:flutter/material.dart';

class CommunityProfileScreen extends StatelessWidget {
  final String communityName;
  final String description;
  final String? logoUrl;

  const CommunityProfileScreen({
    super.key,
    required this.communityName,
    required this.description,
    this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0B141A);
    const textColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildCommunityHeader(),
          ),
          SliverToBoxAdapter(
            child: _buildInsightsAndSetupCards(),
          ),
          const SliverToBoxAdapter(
            child: Divider(color: Color(0xFF1E2931), thickness: 8, height: 24),
          ),
          SliverToBoxAdapter(
            child: _buildPostsHeader(),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildPromptCard(
                'Help shape the vibe while we\'re small 🙌',
                Icons.lightbulb,
                Colors.pinkAccent,
              ),
              _buildPromptCard(
                'Introducing $communityName! Here\'s what we\'re all about 👉',
                Icons.lightbulb,
                Colors.tealAccent,
              ),
              _buildPromptCard(
                'This community is ours to build. What are your ideas?',
                Icons.lightbulb,
                Colors.orangeAccent,
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                child: logoUrl != null 
                  ? CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(logoUrl!),
                    )
                  : CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.pinkAccent.shade100,
                      child: const Icon(Icons.extension, color: Colors.pink, size: 36),
                    ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        communityName, // No "r/" prefix
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.add_circle_outline, color: Colors.white, size: 20), // "Custom Feed" icon placeholder
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1955CC),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  elevation: 0,
                ),
                child: const Text('Mod Tools', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: const Icon(Icons.notifications_none, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: const Icon(Icons.menu_book, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description.isEmpty ? 'Community description goes here...' : description,
            style: const TextStyle(color: Color(0xFFD3D3D3), fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'See more',
            style: TextStyle(color: Color(0xFF61DAFB), fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsAndSetupCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Insights Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2931),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Insights', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(width: 6),
                        Text('Past week', style: TextStyle(color: Color(0xFF8696A0), fontSize: 14)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text('0 visitors • 0 contributions', style: TextStyle(color: Color(0xFF8696A0), fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Build your community Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1E2931))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Build your community', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Icon(Icons.keyboard_arrow_up, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Simulated overlapping circles
                    SizedBox(
                      width: 64,
                      child: Stack(
                        children: [
                          CircleAvatar(backgroundColor: Colors.grey.shade800, radius: 18),
                          Positioned(left: 14, child: CircleAvatar(backgroundColor: Colors.grey.shade700, radius: 18)),
                          Positioned(left: 28, child: CircleAvatar(backgroundColor: Colors.orange, radius: 18, child: Icon(Icons.backpack, color: Colors.red, size: 20))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Finish setting up', style: TextStyle(color: Colors.white, fontSize: 16)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(height: 4, color: Colors.redAccent),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(height: 4, color: const Color(0xFF333333)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text('1/3 achievement unlocked', style: TextStyle(color: Color(0xFF8696A0), fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2A2C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        elevation: 0,
                      ),
                      child: const Text('Finish', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.rocket_launch, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('BEST POSTS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
              Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(Icons.crop_16_9, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.view_agenda_outlined, color: Colors.white, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromptCard(String title, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF1E2931), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.contains('Help shape')) ...[
            const Text('Kick things off with a few posts', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Looking for inspiration? Explore these ideas.', style: TextStyle(color: Color(0xFF8696A0), fontSize: 14)),
                Icon(Icons.keyboard_arrow_up, color: Colors.white),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(icon, color: iconColor, size: 14),
                        ),
                        const SizedBox(width: 8),
                        const Text('Prompt', style: TextStyle(color: Color(0xFF8696A0), fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
