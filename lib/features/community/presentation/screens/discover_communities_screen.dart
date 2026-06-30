import 'package:flutter/material.dart';
import 'create_community/create_community_topic_screen.dart';
import 'public_community_screen.dart';

class DiscoverCommunitiesScreen extends StatelessWidget {
  const DiscoverCommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Colors.white;
    const textColor = Color(0xFF111827);
    const secondaryTextColor = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        iconTheme: const IconThemeData(color: textColor),
        titleSpacing: 0,
        title: const Text(
          'Discover communities',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateCommunityTopicScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Explore communities by topic
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Explore communities by topic',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140, // Height for 3 rows of chips
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildTopicChip('Internet Culture'),
                          _buildTopicChip('Games'),
                          _buildTopicChip('Q&As & Stories'),
                          _buildTopicChip('Education'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildTopicChip('Movies & TV'),
                          _buildTopicChip('Technology'),
                          _buildTopicChip('Places & Travel'),
                          _buildTopicChip('Fashion'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildTopicChip('Sports'),
                          _buildTopicChip('Pop Culture'),
                          _buildTopicChip('Business & Finance'),
                          _buildTopicChip('News'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recommended for you
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Recommended for you',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 165,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    _buildCommunityCard(
                      context: context,
                      title: 'Python',
                      visitors: '136k weekly visitors',
                      description: 'Python community for discussing libraries, frameworks, and more.',
                      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Python-logo-notext.svg/180px-Python-logo-notext.svg.png',
                    ),
                    _buildCommunityCard(
                      context: context,
                      title: 'ProgrammerHumor',
                      visitors: '1.1m weekly visitors',
                      description: 'From syntax errors to infinite loops, find humor in the coding chaos.',
                      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Reddit_logo.svg/180px-Reddit_logo.svg.png',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // More like webdev
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'More like webdev',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: textColor, size: 24),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 165,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    _buildCommunityCard(
                      context: context,
                      title: 'web_design',
                      visitors: '60.5k weekly visitors',
                      description: 'The perfect place for web designers to connect and collaborate.',
                      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/61/HTML5_logo_and_wordmark.svg/180px-HTML5_logo_and_wordmark.svg.png',
                    ),
                    _buildCommunityCard(
                      context: context,
                      title: 'reactjs',
                      visitors: '96.5k weekly visitors',
                      description: 'Develop web applications with ease and connect with other developers.',
                      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/React-icon.svg/180px-React-icon.svg.png',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF1F2937), fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityCard({
    required BuildContext context,
    required String title,
    required String visitors,
    required String description,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PublicCommunityScreen(
              communityName: title,
              description: description,
              visitors: visitors,
              logoUrl: imageUrl,
            ),
          ),
        );
      },
      child: Container(
        width: 310,
        margin: const EdgeInsets.only(right: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(imageUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        visitors,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C81),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    minimumSize: const Size(60, 36),
                  ),
                  child: const Text('Join', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 13.5,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
