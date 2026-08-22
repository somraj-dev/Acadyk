import 'dart:math';
import 'package:flutter/material.dart';
import 'package:acadyk/features/profile/presentation/screens/profile_screen.dart';
import 'package:acadyk/features/feed/presentation/screens/company_profile_screen.dart';
import 'package:acadyk/features/profile/presentation/screens/club_details_screen.dart';
import 'package:acadyk/features/feed/presentation/screens/startup_gallery_screen.dart';

class AcadykSearchDelegate extends SearchDelegate<String> {
  final List<String> suggestions = [
    'Somraj Lodhi',
    'Y Combinator',
    'Robotics Club',
    'Alina Sprongole',
    'Dharmik Patel',
    'Startup Gallery',
    'IEEE Student Branch',
    'AI & Quant Engineering',
    'TOSCA Automation',
  ];

  final List<Map<String, dynamic>> mockUsers = [
    {
      'type': 'person',
      'name': 'Somraj Lodhi',
      'headline': 'Founder | Thinker | Quant Engineer',
      'location': 'Indore, Madhya Pradesh, India',
      'avatar': 'assets/images/somraj_avatar.jpg',
      'hiring': false,
      'mutual': <String>[],
    },
    {
      'type': 'person',
      'name': 'Somraj Dev',
      'headline': 'Entrepreneur | Founder @ Nexure Agents & Black Torque Media | AI Architecture',
      'location': 'India',
      'avatar': 'assets/images/user_avatar.jpg',
      'hiring': false,
      'mutual': <String>['assets/images/somraj_avatar.jpg', 'assets/images/dharmik_avatar.jpg'],
    },
    {
      'type': 'person',
      'name': 'Somraj Ghosh',
      'headline': 'Founder & CEO @ Layrda',
      'location': 'India',
      'avatar': 'assets/images/somraj_avatar.jpg',
      'hiring': true,
      'mutual': <String>['assets/images/dharmik_avatar.jpg'],
    },
    {
      'type': 'person',
      'name': 'Somraj Chalukya',
      'headline': 'Operational Specialist, Direct Apply Operations at Cialfo',
      'location': 'Delhi, India',
      'avatar': 'assets/images/user_avatar.jpg',
      'hiring': false,
      'mutual': <String>['assets/images/dharmik_avatar.jpg'],
    },
    {
      'type': 'person',
      'name': 'Somraj Singh Goyal',
      'headline': 'TOSCA Automation Tester | Certified Tosca Product Consultant',
      'location': 'Indore, Madhya Pradesh, India',
      'avatar': 'assets/images/somraj_avatar.jpg',
      'hiring': false,
      'mutual': <String>[],
    },
    {
      'type': 'person',
      'name': 'Alina Sprongole',
      'headline': 'Software Engineer @ Google | Tech Lead',
      'location': 'Riga, Latvia',
      'avatar': 'assets/images/alina_avatar.jpg',
      'hiring': false,
      'mutual': <String>['assets/images/somraj_avatar.jpg'],
    },
    {
      'type': 'person',
      'name': 'Dharmik Patel',
      'headline': 'Full Stack Developer | Open Source Contributor',
      'location': 'Gujarat, India',
      'avatar': 'assets/images/dharmik_avatar.jpg',
      'hiring': false,
      'mutual': <String>['assets/images/somraj_avatar.jpg', 'assets/images/user_avatar.jpg'],
    },
    {
      'type': 'person',
      'name': 'Christian Pickett',
      'headline': 'Co-founder @ Orthogonal (YC W26)',
      'location': 'San Francisco, CA, United States',
      'avatar': 'assets/images/dharmik_avatar.jpg',
      'hiring': true,
      'mutual': <String>['assets/images/somraj_avatar.jpg'],
    },
  ];

  final List<Map<String, dynamic>> mockEntities = [
    {
      'type': 'company',
      'name': 'Y Combinator',
      'subtitle': 'Startup Accelerator • Mountain View, CA',
      'avatarText': 'Y',
      'avatarBg': 0xFFFF6600,
      'category': 'Accelerator',
    },
    {
      'type': 'company',
      'name': 'Acadyk Labs',
      'subtitle': 'AI, EdTech & Developer Tools • India',
      'avatarText': 'A',
      'avatarBg': 0xFF1565C0,
      'category': 'Company',
    },
    {
      'type': 'club',
      'name': 'Robotics & Automation Club',
      'subtitle': 'MITS Gwalior • 420 Members',
      'avatarText': '🤖',
      'avatarBg': 0xFF0D9488,
      'category': 'Club',
      'clubData': {
        'title': 'Robotics & Automation Club',
        'subtitle': 'Autonomous Systems & Embedded AI',
        'members': '420',
        'followers': '1.2K',
        'category': 'Engineering',
        'isVerified': true,
      },
    },
    {
      'type': 'club',
      'name': 'IEEE Student Branch',
      'subtitle': 'International Technical Society • 680 Members',
      'avatarText': '⚡',
      'avatarBg': 0xFF2563EB,
      'category': 'Club',
      'clubData': {
        'title': 'IEEE Student Branch',
        'subtitle': 'Advancing Technology for Humanity',
        'members': '680',
        'followers': '2.5K',
        'category': 'Technical Society',
        'isVerified': true,
      },
    },
    {
      'type': 'gallery',
      'name': 'Startup Gallery',
      'subtitle': 'Discover student-led ventures & pitch decks',
      'avatarText': '🚀',
      'avatarBg': 0xFF7C3AED,
      'category': 'Showcase',
    },
  ];

  @override
  ThemeData appBarTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121824) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final hintColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF94A3B8);

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bgColor,
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: hintColor, fontSize: 16),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: textColor, fontSize: 16.5, fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.black54),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black87),
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

    final cleanQuery = query.trim().toLowerCase();

    // Match people
    final matchedUsers = mockUsers.where((user) {
      final name = (user['name'] ?? '').toString().toLowerCase();
      final headline = (user['headline'] ?? '').toString().toLowerCase();
      final location = (user['location'] ?? '').toString().toLowerCase();
      return name.contains(cleanQuery) || headline.contains(cleanQuery) || location.contains(cleanQuery);
    }).toList();

    // Match companies / clubs
    final matchedEntities = mockEntities.where((entity) {
      final name = (entity['name'] ?? '').toString().toLowerCase();
      final subtitle = (entity['subtitle'] ?? '').toString().toLowerCase();
      final category = (entity['category'] ?? '').toString().toLowerCase();
      return name.contains(cleanQuery) || subtitle.contains(cleanQuery) || category.contains(cleanQuery);
    }).toList();

    final hasResults = matchedUsers.isNotEmpty || matchedEntities.isNotEmpty;

    if (!hasResults) {
      return Container(
        color: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Center(
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
                'Try searching with a different keyword, name, club, or company.',
                style: TextStyle(color: subColor, fontSize: 13.5, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: bgColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Matched Entities (Companies / Clubs / Galleries)
          if (matchedEntities.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                'COMMUNITIES & ORGANIZATIONS',
                style: TextStyle(
                  color: subColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            ...matchedEntities.map((entity) {
              final type = entity['type'];
              final String name = entity['name'];
              final String subtitle = entity['subtitle'];
              final int avatarBg = entity['avatarBg'] ?? 0xFF1565C0;
              final String avatarText = entity['avatarText'] ?? name.substring(0, 1);

              return InkWell(
                onTap: () {
                  if (type == 'company') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CompanyProfileScreen(companyName: name),
                      ),
                    );
                  } else if (type == 'club') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClubDetailsScreen(
                          clubData: entity['clubData'] ?? {
                            'title': name,
                            'subtitle': subtitle,
                            'members': '500+',
                            'followers': '1.2K',
                            'category': 'Club',
                          },
                        ),
                      ),
                    );
                  } else if (type == 'gallery') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StartupGalleryScreen(),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Color(avatarBg),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          avatarText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (Color(avatarBg)).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    entity['category'] ?? 'Org',
                                    style: TextStyle(
                                      color: Color(avatarBg),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: TextStyle(color: subColor, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: subColor.withValues(alpha: 0.6), size: 20),
                    ],
                  ),
                ),
              );
            }),
            Divider(height: 24, thickness: 1, color: cardBorderColor),
          ],

          // Matched People
          if (matchedUsers.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                'PEOPLE',
                style: TextStyle(
                  color: subColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            ...matchedUsers.map((user) {
              final bool hiring = user['hiring'] == true;
              final List<String> mutual = List<String>.from(user['mutual'] ?? []);

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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: hiring ? const Color(0xFF7C3AED) : Colors.transparent,
                                width: hiring ? 2.2 : 0,
                              ),
                            ),
                            padding: EdgeInsets.all(hiring ? 2 : 0),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundImage: AssetImage(user['avatar']),
                              onBackgroundImageError: (_, __) {},
                              backgroundColor: const Color(0xFF1565C0),
                              child: Text(
                                user['name'].toString().isNotEmpty
                                    ? user['name'].toString().substring(0, min(2, user['name'].toString().length)).toUpperCase()
                                    : 'U',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ),
                          if (hiring)
                            Positioned(
                              bottom: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C3AED),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '#HIRING',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 7,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'],
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user['headline'],
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
                              user['location'],
                              style: TextStyle(
                                color: subColor.withValues(alpha: 0.8),
                                fontSize: 12.5,
                              ),
                            ),
                            if (mutual.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 18.0 + (mutual.length - 1) * 10.0,
                                    height: 18,
                                    child: Stack(
                                      children: List.generate(mutual.length, (i) {
                                        return Positioned(
                                          left: i * 10.0,
                                          child: Container(
                                            width: 18,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: bgColor, width: 1.2),
                                              image: DecorationImage(
                                                image: AssetImage(mutual[i]),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${mutual.length} mutual connection${mutual.length > 1 ? 's' : ''}',
                                    style: TextStyle(
                                      color: subColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
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

    final suggestionList = query.isEmpty
        ? suggestions
        : suggestions.where((element) => element.toLowerCase().contains(query.toLowerCase())).toList();

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
                  query.isEmpty ? 'POPULAR & RECENT SEARCHES' : 'SUGGESTIONS',
                  style: TextStyle(
                    color: subColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                if (query.isEmpty)
                  Icon(Icons.history_rounded, size: 16, color: subColor),
              ],
            ),
          ),
          ...suggestionList.map((item) {
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
                      color: subColor.withValues(alpha: 0.6),
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
