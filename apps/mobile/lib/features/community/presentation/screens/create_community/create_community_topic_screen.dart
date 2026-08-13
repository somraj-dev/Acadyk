import 'package:flutter/material.dart';
import 'create_community_type_screen.dart';

class CreateCommunityTopicScreen extends StatefulWidget {
  const CreateCommunityTopicScreen({super.key});

  @override
  State<CreateCommunityTopicScreen> createState() => _CreateCommunityTopicScreenState();
}

class _CreateCommunityTopicScreenState extends State<CreateCommunityTopicScreen> {
  String? _selectedTopic;

  final List<Map<String, String>> _topics = [
    {'emoji': '🍣', 'label': 'Anime & Cosplay'},
    {'emoji': '👨‍🎨', 'label': 'Art'},
    {'emoji': '💵', 'label': 'Business & Finance'},
    {'emoji': '🧩', 'label': 'Collectibles & Other Hobbies'},
    {'emoji': '👩‍🏫', 'label': 'Education & Career'},
    {'emoji': '🪞', 'label': 'Fashion & Beauty'},
    {'emoji': '🍔', 'label': 'Food & Drinks'},
    {'emoji': '🕹️', 'label': 'Games'},
    {'emoji': '❤️', 'label': 'Health'},
    {'emoji': '🏡', 'label': 'Home & Garden'},
    {'emoji': '📜', 'label': 'Humanities & Law'},
    {'emoji': '🌈', 'label': 'Identity & Relationships'},
    {'emoji': '🐒', 'label': 'Internet Culture'},
    {'emoji': '🎞️', 'label': 'Movies & TV'},
    {'emoji': '🎶', 'label': 'Music'},
    {'emoji': '🌿', 'label': 'Nature & Outdoors'},
    {'emoji': '📰', 'label': 'News & Politics'},
    {'emoji': '🌐', 'label': 'Places & Travel'},
    {'emoji': '✨', 'label': 'Pop Culture'},
    {'emoji': '✏️', 'label': 'Q&As & Stories'},
  ];

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0B141A);
    const textColor = Colors.white;
    const secondaryTextColor = Color(0xFF8696A0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        iconTheme: const IconThemeData(color: textColor),
        elevation: 0,
        titleSpacing: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2931), // Slightly darker
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            '1 of 3',
            style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: ElevatedButton(
              onPressed: _selectedTopic != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateCommunityTypeScreen(selectedTopic: _selectedTopic!),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedTopic != null ? const Color(0xFF1E2931) : const Color(0xFF1E2931),
                disabledBackgroundColor: const Color(0xFF1E2931),
                foregroundColor: _selectedTopic != null ? textColor : const Color(0xFF3B4A54),
                disabledForegroundColor: const Color(0xFF3B4A54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 0,
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What is your community about?',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose a topic to help redditors discover your community',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: _topics.map((topic) {
                  final isSelected = _selectedTopic == topic['label'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTopic = topic['label'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2A3942) : Colors.transparent,
                        border: Border.all(
                          color: const Color(0xFF2A3942),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(topic['emoji']!, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(
                            topic['label']!,
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
