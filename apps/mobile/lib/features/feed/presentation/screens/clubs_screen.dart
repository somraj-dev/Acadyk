import 'package:flutter/material.dart';

class ClubModel {
  final String id;
  final String title;
  final String pinCount;
  final String timeAgo;
  final String members;
  final String category;
  final List<String> images;

  const ClubModel({
    required this.id,
    required this.title,
    required this.pinCount,
    required this.timeAgo,
    required this.members,
    required this.category,
    required this.images,
  });
}

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Technical',
    'Design',
    'Cultural',
    'Entrepreneurship',
    'Literary',
  ];

  final List<ClubModel> _clubs = const [
    ClubModel(
      id: '1',
      title: 'CSE Club',
      pinCount: '29 mem',
      timeAgo: '1mo',
      members: '3.4k Members',
      category: 'Technical',
      images: [
        'assets/images/alina_avatar.jpg',
        'assets/images/somraj_avatar.jpg',
        'assets/images/young_entrepreneur.jpg',
      ],
    ),
    ClubModel(
      id: '2',
      title: 'arunya',
      pinCount: '14 mem',
      timeAgo: '1mo',
      members: '1.8k Members',
      category: 'Cultural',
      images: [
        'assets/images/young_entrepreneur.jpg',
        'assets/images/mits_logo.png',
        'assets/images/alina_avatar.jpg',
      ],
    ),
    ClubModel(
      id: '3',
      title: 'Aerospace',
      pinCount: '11 mem',
      timeAgo: '1mo',
      members: '2.1k Members',
      category: 'Technical',
      images: [
        'assets/images/somraj_avatar.jpg',
        'assets/images/alina_avatar.jpg',
        'assets/images/young_entrepreneur.jpg',
      ],
    ),
    ClubModel(
      id: '4',
      title: 'acadyk',
      pinCount: '5 mem',
      timeAgo: '1mo',
      members: '5.2k Members',
      category: 'Technical',
      images: [
        'assets/images/mits_logo.png',
        'assets/images/somraj_avatar.jpg',
        'assets/images/alina_avatar.jpg',
      ],
    ),
    ClubModel(
      id: '5',
      title: 'darkelk',
      pinCount: '6 mem',
      timeAgo: '1mo',
      members: '940 Members',
      category: 'Design',
      images: [
        'assets/images/young_entrepreneur.jpg',
        'assets/images/alina_avatar.jpg',
        'assets/images/mits_logo.png',
      ],
    ),
    ClubModel(
      id: '6',
      title: 'acadykl',
      pinCount: '4 mem',
      timeAgo: '1mo',
      members: '1.2k Members',
      category: 'Technical',
      images: [
        'assets/images/alina_avatar.jpg',
        'assets/images/mits_logo.png',
        'assets/images/somraj_avatar.jpg',
      ],
    ),
    ClubModel(
      id: '7',
      title: 'GDSC MITS Gwalior',
      pinCount: '38 mem',
      timeAgo: '2w',
      members: '4.1k Members',
      category: 'Technical',
      images: [
        'assets/images/mits_logo.png',
        'assets/images/alina_avatar.jpg',
        'assets/images/young_entrepreneur.jpg',
      ],
    ),
    ClubModel(
      id: '8',
      title: 'E-Cell MITS',
      pinCount: '22 mem',
      timeAgo: '3w',
      members: '2.9k Members',
      category: 'Entrepreneurship',
      images: [
        'assets/images/young_entrepreneur.jpg',
        'assets/images/somraj_avatar.jpg',
        'assets/images/mits_logo.png',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredClubs = _selectedCategory == 'All'
        ? _clubs
        : _clubs.where((c) => c.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Clubs',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 24),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 26),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Create Club option opened'),
                  behavior: SnackBarBehavior.floating,
                  width: 280,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Filter Pills Bar
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Colors.white,
                    backgroundColor: const Color(0xFF1E1E1E),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // 2-Column Pinterest Style Club Boards Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.82,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredClubs.length,
                itemBuilder: (context, index) {
                  final club = filteredClubs[index];
                  return _buildClubCard(context, club);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubCard(BuildContext context, ClubModel club) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${club.title} opened!'),
            behavior: SnackBarBehavior.floating,
            width: 280,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collage Container (1 Main Large Image on Left, 2 Stacked Images on Right)
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  // Main Large Image (Left 65%)
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: const Color(0xFF262626),
                      child: Image.asset(
                        club.images[0],
                        fit: BoxFit.cover,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF333333),
                          child: const Icon(Icons.group, color: Colors.white38, size: 36),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),

                  // Stacked Small Thumbnails (Right 35%)
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        // Top Thumbnail
                        Expanded(
                          child: Container(
                            color: const Color(0xFF333333),
                            child: Image.asset(
                              club.images.length > 1 ? club.images[1] : club.images[0],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF444444)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Bottom Thumbnail
                        Expanded(
                          child: Container(
                            color: const Color(0xFF333333),
                            child: Image.asset(
                              club.images.length > 2 ? club.images[2] : club.images[0],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF444444)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            club.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 17,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),

          // Pins & Timestamp Subtitle
          Text(
            '${club.pinCount}  ${club.timeAgo}',
            style: const TextStyle(
              color: Color(0xFFA3A3A3),
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
