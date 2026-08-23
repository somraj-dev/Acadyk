import 'dart:math';
import 'package:flutter/material.dart';
import 'package:acadyk/common/services/search_service.dart';
import 'package:acadyk/features/profile/presentation/screens/profile_screen.dart';
import 'package:acadyk/features/feed/presentation/screens/company_profile_screen.dart';
import 'package:acadyk/features/profile/presentation/screens/club_details_screen.dart';
import 'package:acadyk/features/feed/presentation/screens/startup_gallery_screen.dart';

class AcadykSearchDelegate extends SearchDelegate<String> {
  final List<String> suggestions = const [
    'MITS Gwalior',
    'Robotics Club',
    'AI & Machine Learning',
    'Computer Science',
    'Information Technology',
    'Hackathon 2026',
    'GDSC MITS',
  ];

  @override
  ThemeData appBarTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF121824) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : const Color(0xFF0F172A)),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF0F172A),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          fontSize: 15.5,
        ),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded, size: 20),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded, size: 22),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121824) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBorderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);

    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      return Container(
        color: bgColor,
        child: Center(
          child: Text(
            'Type a name, department, or skill to search',
            style: TextStyle(color: subColor, fontSize: 14),
          ),
        ),
      );
    }

    return Container(
      color: bgColor,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: SearchService.searchProfiles(cleanQuery),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final results = snapshot.data ?? [];

          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.search_off_rounded, size: 32, color: subColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No results found for "$query"',
                    style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try searching with a different name, branch, or enrollment number.',
                    style: TextStyle(color: subColor, fontSize: 13.5, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: results.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: cardBorderColor),
            itemBuilder: (context, index) {
              final user = results[index];
              final name = user['fullName'] ?? user['full_name'] ?? user['username'] ?? 'User';
              final headline = user['headline'] ?? user['bio'] ?? user['major'] ?? 'Student @ MITS Gwalior';
              final avatar = user['profilePhotoUrl'] ?? user['profile_photo_url'] ?? '';
              final location = user['location'] ?? user['collegeName'] ?? 'Gwalior, India';

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(isOwnProfile: false, userData: user),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF0F4C81),
                        backgroundImage: avatar.isNotEmpty
                            ? (avatar.startsWith('http')
                                ? NetworkImage(avatar) as ImageProvider
                                : AssetImage(avatar))
                            : null,
                        child: avatar.isEmpty
                            ? Text(
                                name.toString().isNotEmpty ? name.toString().substring(0, min<int>(2, name.toString().length)).toUpperCase() : 'U',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              headline,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: subColor,
                                fontSize: 13,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              location,
                              style: TextStyle(
                                color: subColor.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: subColor.withOpacity(0.5), size: 20),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121824) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final tileBorderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);

    final cleanQuery = query.trim();

    if (cleanQuery.isNotEmpty) {
      return buildResults(context);
    }

    return Container(
      color: bgColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SUGGESTED SEARCHES',
                  style: TextStyle(
                    color: subColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                Icon(Icons.trending_up, size: 16, color: subColor),
              ],
            ),
          ),
          ...suggestions.map((item) {
            return InkWell(
              onTap: () {
                query = item;
                showResults(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: tileBorderColor, width: 0.8),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.search_rounded,
                        color: subColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.north_west_rounded,
                      color: subColor.withOpacity(0.6),
                      size: 16,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
