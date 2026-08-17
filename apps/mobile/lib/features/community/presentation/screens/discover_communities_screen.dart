import 'package:flutter/material.dart';
import 'create_community/create_community_topic_screen.dart';
import '../widgets/community_card.dart';

class DiscoverCommunitiesScreen extends StatefulWidget {
  const DiscoverCommunitiesScreen({super.key});

  @override
  State<DiscoverCommunitiesScreen> createState() => _DiscoverCommunitiesScreenState();
}

class _DiscoverCommunitiesScreenState extends State<DiscoverCommunitiesScreen> {
  String _selectedTopic = 'All';

  final List<String> _topics = [
    'All',
    'AI / ML',
    'Internet Culture',
    'Technology',
    'Web & Cloud',
    'Robotics & IoT',
    'Education',
    'Games',
    'Q&As & Stories',
    'Business & Finance',
    'Sports',
    'News',
  ];

  final List<CommunityCardData> _communities = [
    // 1. Exact MITS AI/ML Batch '30 from Image 1
    const CommunityCardData(
      id: 'mits_aiml_30',
      name: 'MITS AI/ML Batch \'30',
      subtitle: 'Unofficial Community',
      rating: 4.8,
      reviewsCount: 256,
      categoryTag: 'Student Community',
      description:
          'A place for AI/ML students of MITS Gwalior (Batch 30) to learn, collaborate, share resources & grow together.',
      membersCount: 412,
      onlineCount: 78,
      establishedDate: 'Aug 2025',
      isVerified: true,
      topContributorName: 'Somraj Lodhi',
      topContributorAvatar: 'assets/images/somraj_avatar.jpg',
      topContributorContributions: 128,
      activeMemberAvatars: [
        'assets/images/young_entrepreneur.jpg',
        'assets/images/alina_avatar.jpg',
        'assets/images/dharmik_avatar.jpg',
        'assets/images/user_avatar.jpg',
        'assets/images/somraj_avatar.jpg',
      ],
      remainingActiveMembersCount: 73,
    ),

    // 2. MITS Web & Cloud Guild
    const CommunityCardData(
      id: 'mits_web_cloud',
      name: 'MITS Web & Cloud Guild',
      subtitle: 'Campus Tech Community',
      rating: 4.9,
      reviewsCount: 184,
      categoryTag: 'Engineering & Tech',
      description:
          'Connect with full-stack engineers, cloud architects, and Flutter developers building production systems across campus.',
      membersCount: 520,
      onlineCount: 94,
      establishedDate: 'Jan 2025',
      isVerified: true,
      topContributorName: 'Alina Sharma',
      topContributorAvatar: 'assets/images/alina_avatar.jpg',
      topContributorContributions: 142,
      activeMemberAvatars: [
        'assets/images/alina_avatar.jpg',
        'assets/images/somraj_avatar.jpg',
        'assets/images/user_avatar.jpg',
        'assets/images/young_entrepreneur.jpg',
        'assets/images/dharmik_avatar.jpg',
      ],
      remainingActiveMembersCount: 86,
    ),

    // 3. MITS Robotics & IoT Innovation Lab
    const CommunityCardData(
      id: 'mits_robotics_iot',
      name: 'MITS Robotics & IoT Lab',
      subtitle: 'Hardware & Embedded Lab',
      rating: 4.7,
      reviewsCount: 142,
      categoryTag: 'Innovation Lab',
      description:
          'Hands-on robotics, ROS, microcontrollers, embedded circuits, and autonomous systems research group at MITS Gwalior.',
      membersCount: 310,
      onlineCount: 45,
      establishedDate: 'Oct 2024',
      isVerified: true,
      topContributorName: 'Dharmik Lodhi',
      topContributorAvatar: 'assets/images/dharmik_avatar.jpg',
      topContributorContributions: 96,
      activeMemberAvatars: [
        'assets/images/dharmik_avatar.jpg',
        'assets/images/somraj_avatar.jpg',
        'assets/images/alina_avatar.jpg',
        'assets/images/young_entrepreneur.jpg',
        'assets/images/user_avatar.jpg',
      ],
      remainingActiveMembersCount: 48,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFFAF8F5);
    const textColor = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: textColor),
        titleSpacing: 0,
        title: const Text(
          'Discover Communities',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.4,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF1EBE5), height: 1),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFED7AA), width: 1),
              ),
              child: const Icon(Icons.add, color: Color(0xFFEA580C), size: 18),
            ),
            tooltip: 'Create Community',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateCommunityTopicScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Ambient Decorative Background Doodles (Paper plane & Burst Accents)
          Positioned(
            top: 8,
            right: 12,
            child: Icon(
              Icons.send_rounded,
              color: const Color(0xFFEA580C).withValues(alpha: 0.12),
              size: 32,
            ),
          ),
          Positioned(
            top: 20,
            left: 10,
            child: Icon(
              Icons.auto_awesome,
              color: const Color(0xFFEA580C).withValues(alpha: 0.14),
              size: 26,
            ),
          ),

          // Main Scrollable Content
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(top: 14.0, bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Category Topics Filter Carousel
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Explore by Topic',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          'Filter',
                          style: TextStyle(
                            color: Color(0xFFEA580C),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Horizontal Topic Chips Bar
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _topics.length,
                      itemBuilder: (context, index) {
                        final topic = _topics[index];
                        final isSelected = _selectedTopic == topic;
                        return Container(
                          margin: const EdgeInsets.only(right: 8.0),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedTopic = topic;
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF09122C) : Colors.white,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF09122C) : const Color(0xFFE2E8F0),
                                    width: 1.2,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    if (isSelected)
                                      BoxShadow(
                                        color: const Color(0xFF09122C).withValues(alpha: 0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                  ],
                                ),
                                child: Text(
                                  topic,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : const Color(0xFF334155),
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. Section Header: Recommended Communities
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Featured Communities',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Campus Verified',
                          style: TextStyle(
                            color: Color(0xFF0284C7),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 3. New UI Communities Cards List (Matching Image 1)
                  for (final community in _communities)
                    CommunityCard(
                      data: community,
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
