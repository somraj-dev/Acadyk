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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B141A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? const Color(0xFF8696A0) : const Color(0xFF64748B);
    final badgeBg = isDark ? const Color(0xFF1E2931) : const Color(0xFFF1F5F9);
    final badgeText = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '1 of 3',
            style: TextStyle(color: badgeText, fontSize: 13, fontWeight: FontWeight.bold),
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
                backgroundColor: _selectedTopic != null
                    ? const Color(0xFF09122C)
                    : (isDark ? const Color(0xFF1E2931) : const Color(0xFFF1F5F9)),
                disabledBackgroundColor: isDark ? const Color(0xFF1E2931) : const Color(0xFFF1F5F9),
                foregroundColor: _selectedTopic != null ? Colors.white : (isDark ? const Color(0xFF3B4A54) : const Color(0xFF94A3B8)),
                disabledForegroundColor: isDark ? const Color(0xFF3B4A54) : const Color(0xFF94A3B8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 18),
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
              Text(
                'What is your community about?',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Choose a topic to help students and members discover your community',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: _topics.map((topic) {
                  final isSelected = _selectedTopic == topic['label'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTopic = topic['label'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF2A3942) : const Color(0xFF09122C))
                            : (isDark ? Colors.transparent : Colors.white),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? const Color(0xFF2A3942) : const Color(0xFF09122C))
                              : (isDark ? const Color(0xFF2A3942) : const Color(0xFFE2E8F0)),
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          if (!isDark && !isSelected)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          if (isSelected)
                            BoxShadow(
                              color: const Color(0xFF09122C).withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(topic['emoji']!, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(
                            topic['label']!,
                            style: TextStyle(
                              color: isSelected ? Colors.white : textColor,
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
