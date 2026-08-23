import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../common/services/notification_service.dart';
import '../../../../common/services/auth_service.dart';
import '../services/profile_manager.dart';
import 'club_members_screen.dart';
import 'profile_screen.dart';

class ClubDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> clubData;

  const ClubDetailsScreen({
    super.key,
    required this.clubData,
  });

  @override
  State<ClubDetailsScreen> createState() => _ClubDetailsScreenState();
}

class _ClubDetailsScreenState extends State<ClubDetailsScreen> {
  bool _isFavorite = false;
  bool _isReadMore = false;
  bool _isJoined = false;

  static const Color primaryBlue = Color(0xFF0284C7); // Light/Sky Blue
  static const Color lightBlueBg = Color(0xFFF0F9FF);
  static const Color lightBlueBorder = Color(0xFFBAE6FD);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  final List<Map<String, String>> _eventPhotos = [
    {
      'title': 'Hackathon Night & Keynote',
      'url': 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=800',
      'caption': 'Over 300 students collaborating at the annual 36-hour hackathon.',
    },
    {
      'title': 'Flutter & Cloud Workshop',
      'url': 'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=800',
      'caption': 'Hands-on practical session building scalable cross-platform apps.',
    },
    {
      'title': 'Project Demo & Pitch Day',
      'url': 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800',
      'caption': 'Student teams showcasing their working prototypes to industry judges.',
    },
    {
      'title': 'Award Distribution & Ceremony',
      'url': 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800',
      'caption': 'Celebrating winners and contributors at the annual tech gala.',
    },
    {
      'title': 'Campus Tech Orientation',
      'url': 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=800',
      'caption': 'Welcoming incoming freshmen and introducing student club initiatives.',
    },
  ];

  final List<Map<String, dynamic>> _organizedEvents = [
    {
      'title': 'CodeSprint 2024 · 36H Hackathon',
      'category': 'National Hackathon',
      'date': 'NOV 15 - 16',
      'time': '36 Hours Non-stop',
      'venue': 'Main Auditorium & SAC Hall',
      'attendees': '350+ Hackers',
      'status': 'Upcoming',
      'isUpcoming': true,
      'price': 'Free Entry',
      'image': 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=600',
    },
    {
      'title': 'Cloud AI & DevOps Masterclass',
      'category': 'Technical Workshop',
      'date': 'DEC 02',
      'time': '10:00 AM - 4:00 PM',
      'venue': 'CSE Seminar Hall 2',
      'attendees': '180 Attendees',
      'status': 'Upcoming',
      'isUpcoming': true,
      'price': 'Free Entry',
      'image': 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600',
    },
    {
      'title': 'Google Solution Challenge Bootcamp',
      'category': 'Mentorship Series',
      'date': 'OCT 12',
      'time': 'Full Day Sprint',
      'venue': 'Virtual / Google Meet',
      'attendees': '290 Students',
      'status': 'Completed',
      'isUpcoming': false,
      'price': 'Recorded',
      'image': 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=600',
    },
    {
      'title': 'Git & Open Source Contribution Sprint',
      'category': 'Hands-on Lab',
      'date': 'AUG 28',
      'time': '2:00 PM - 6:00 PM',
      'venue': 'Central Computing Facility',
      'attendees': '410 Attendees',
      'status': 'Completed',
      'isUpcoming': false,
      'price': '15 PRs Merged',
      'image': 'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=600',
    },
  ];

  final List<String> _domains = [
    'Flutter & Mobile',
    'AI & Machine Learning',
    'Cloud Architecture',
    'Open Source',
    'Competitive Programming',
    'DevOps & CI/CD',
    'Web3 & Distributed Systems',
    'Hardware & IoT',
  ];

  final List<Map<String, String>> _achievements = [
    {
      'icon': '🏆',
      'title': '1st Prize - Smart India Hackathon',
      'subtitle': 'National Level Winner with ₹1,00,000 grant',
    },
    {
      'icon': '🌟',
      'title': 'Top 50 Global Chapter Milestone',
      'subtitle': 'Recognized for high developer engagement & workshops',
    },
    {
      'icon': '🚀',
      'title': '40+ Core Open Source PRs Merged',
      'subtitle': 'Contributing to leading global developer toolchains',
    },
    {
      'icon': '🎓',
      'title': '100% Core Member Placement Support',
      'subtitle': 'Alumni working at Google, Microsoft, Amazon & Startups',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final String title = widget.clubData['title']?.toString() ??
        widget.clubData['name']?.toString() ??
        'MITS Coding & Open Source Club';

    final String category = widget.clubData['category']?.toString() ??
        widget.clubData['tag']?.toString() ??
        'Student Chapter';

    final String location = widget.clubData['location']?.toString() ??
        widget.clubData['organization']?.toString() ??
        'MITS Campus, Gwalior';

    final String time = widget.clubData['time']?.toString() ??
        widget.clubData['duration']?.toString() ??
        'Joined Aug 2023 • Active';

    final String memberCount = widget.clubData['memberCount']?.toString() ?? '450+ Members';

    final String aboutText = widget.clubData['description']?.toString() ??
        widget.clubData['about']?.toString() ??
        'Official student chapter fostering collaborative learning, technical workshops, open source innovation, competitive programming, and campus hackathons. Connect with industry leaders, build impactful tech projects, and represent the institute on national stages.';

    final String organizerName = widget.clubData['organizerName']?.toString() ??
        widget.clubData['role']?.toString() ??
        'President & Founding Core Member';

    final String organizerRole = widget.clubData['organizerRole']?.toString() ??
        widget.clubData['subtitle']?.toString() ??
        'Leadership & Core Team';

    final String address = widget.clubData['address']?.toString() ??
        'Madhav Institute of Technology & Science, Racecourse Road, Gwalior';

    final String heroImage = widget.clubData['heroImage']?.toString() ??
        'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=1200&auto=format&fit=crop&q=80';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HERO IMAGE HEADER WITH OVERLAY BUTTONS
                Stack(
                  children: [
                    Container(
                      height: 340,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E293B),
                      ),
                      child: Image.network(
                        heroImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFF0F172A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Icon(Icons.groups_rounded, size: 72, color: Colors.white38),
                            ),
                          );
                        },
                      ),
                    ),

                    // Top Floating Navigation Bar
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Button
                            _buildCircularButton(
                              icon: Icons.arrow_back,
                              onTap: () => Navigator.of(context).pop(),
                            ),

                            // Share & Favorite Buttons
                            Row(
                              children: [
                                _buildCircularButton(
                                  icon: Icons.share_outlined,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Sharing "$title" link'),
                                        backgroundColor: const Color(0xFF0F172A),
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                _buildCircularButton(
                                  icon: _isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                  iconColor: _isFavorite ? Colors.red : textDark,
                                  onTap: () {
                                    setState(() {
                                      _isFavorite = !_isFavorite;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(_isFavorite ? 'Saved to favorites!' : 'Removed from favorites'),
                                        backgroundColor: const Color(0xFF0F172A),
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // 2. MAIN SHEET CONTENT
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: lightBlueBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: lightBlueBorder),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              color: primaryBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Title
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                            height: 1.25,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Location & Time Row
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 18, color: primaryBlue),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                location,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13.5, color: textMuted, fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Icon(Icons.access_time_filled, size: 17, color: primaryBlue),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                time,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13.5, color: textMuted, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Attendees / Members Stack Row
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ClubMembersScreen(
                                  clubTitle: title,
                                  category: category,
                                  memberCount: memberCount,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 104,
                                  height: 36,
                                  child: Stack(
                                    children: [
                                      _buildAvatar('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100', 0),
                                      _buildAvatar('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100', 20),
                                      _buildAvatar('https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100', 40),
                                      Positioned(
                                        left: 60,
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: primaryBlue,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            '+',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  memberCount,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: textDark,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'View All',
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Chapter Impact Metrics Banner
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: lightBlueBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: lightBlueBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMetricItem('24+', 'Events Held'),
                              _buildVerticalDivider(),
                              _buildMetricItem('8', 'Hackathons'),
                              _buildVerticalDivider(),
                              _buildMetricItem('1.2k+', 'Attendees'),
                              _buildVerticalDivider(),
                              _buildMetricItem('15+', 'Projects'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // About Event / About Chapter Section
                        const Text(
                          'About Event',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF475569),
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(
                                text: _isReadMore || aboutText.length <= 150
                                    ? aboutText
                                    : '${aboutText.substring(0, 150)}... ',
                              ),
                              if (aboutText.length > 150)
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isReadMore = !_isReadMore;
                                      });
                                    },
                                    child: Text(
                                      _isReadMore ? ' Show less' : 'Read more',
                                      style: const TextStyle(
                                        color: primaryBlue,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Domain & Technology Tags
                        const Text(
                          'Domains & Tech Stack',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _domains.map((d) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Text(
                                d,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // Event Photos & Moments Gallery
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Event Photos & Moments',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: textDark,
                              ),
                            ),
                            Text(
                              '${_eventPhotos.length} Photos',
                              style: const TextStyle(
                                fontSize: 13,
                                color: primaryBlue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 150,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _eventPhotos.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final photo = _eventPhotos[index];
                              return GestureDetector(
                                onTap: () => _showImageDialog(photo['url']!, photo['title']!, photo['caption']!),
                                child: Container(
                                  width: 220,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: const Color(0xFFF1F5F9),
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          photo['url']!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: const Color(0xFFE2E8F0),
                                            child: const Icon(Icons.image, color: textMuted),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.75),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        left: 10,
                                        right: 10,
                                        child: Text(
                                          photo['title']!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Organized Events (Upcoming & Past)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Organized Events',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: textDark,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: lightBlueBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '24 Total',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: _organizedEvents.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final ev = _organizedEvents[index];
                            final bool isUpcoming = ev['isUpcoming'] == true;
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isUpcoming ? lightBlueBorder : const Color(0xFFE2E8F0),
                                  width: isUpcoming ? 1.5 : 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date Block
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      color: isUpcoming ? lightBlueBg : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isUpcoming ? lightBlueBorder : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      ev['date'] as String,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: isUpcoming ? primaryBlue : const Color(0xFF475569),
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Event Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isUpcoming ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                ev['status'] as String,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: isUpcoming ? const Color(0xFF15803D) : const Color(0xFF64748B),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              ev['category'] as String,
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w500,
                                                color: textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          ev['title'] as String,
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.bold,
                                            color: textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.place_outlined, size: 14, color: textMuted),
                                            const SizedBox(width: 3),
                                            Expanded(
                                              child: Text(
                                                ev['venue'] as String,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 12, color: textMuted),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 28),

                        // Chapter Milestones & Achievements
                        const Text(
                          'Achievements & Milestones',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: _achievements.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final ach = _achievements[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  Text(ach['icon']!, style: const TextStyle(fontSize: 22)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ach['title']!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          ach['subtitle']!,
                                          style: const TextStyle(fontSize: 12, color: textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 28),

                        // Organizer / Core Team Lead Section
                        const Text(
                          'Organizer',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(isOwnProfile: true),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                ClipOval(
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    color: lightBlueBg,
                                    child: Image.network(
                                      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120',
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => const Icon(
                                        Icons.person,
                                        color: primaryBlue,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        organizerName,
                                        style: const TextStyle(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w700,
                                          color: textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        organizerRole,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildActionIconButton(
                                  icon: Icons.phone_rounded,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Connecting to $organizerName coordinator...'),
                                        backgroundColor: const Color(0xFF0F172A),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 10),
                                _buildActionIconButton(
                                  icon: CupertinoIcons.chat_bubble_fill,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Opening chat with $organizerName...'),
                                        backgroundColor: const Color(0xFF0F172A),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Address Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Address',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: textDark,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Opening campus / venue map...'),
                                    backgroundColor: Color(0xFF0F172A),
                                  ),
                                );
                              },
                              child: const Text(
                                'View on Map',
                                style: TextStyle(
                                  color: primaryBlue,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          address,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. STICKY BOTTOM BAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    offset: const Offset(0, -4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      final willJoin = !_isJoined;
                      setState(() {
                        _isJoined = willJoin;
                      });

                      if (willJoin) {
                        final currentUserName = ProfileManager.name.isNotEmpty && ProfileManager.name != 'Acadyk Member'
                            ? ProfileManager.name
                            : (AuthService.currentUser?.fullName ?? 'Acadyk Student');
                        final currentUserHandle = ProfileManager.username.isNotEmpty
                            ? ProfileManager.username
                            : (AuthService.currentUser?.username ?? 'student');
                        final currentUserAvatar = ProfileManager.avatarUrl.isNotEmpty
                            ? ProfileManager.avatarUrl
                            : 'assets/images/somraj_avatar.jpg';
                        final currentUserHeadline = ProfileManager.bio.isNotEmpty
                            ? ProfileManager.bio
                            : (AuthService.currentUser?.branch != null
                                ? '${AuthService.currentUser?.degree ?? "B.Tech"} in ${AuthService.currentUser?.branch}'
                                : 'Student @ MITS Gwalior');

                        NotificationService.addClubJoinRequest(
                          clubId: widget.clubData['id']?.toString() ?? 'club_${DateTime.now().millisecondsSinceEpoch}',
                          clubTitle: title,
                          userName: currentUserName,
                          userHandle: currentUserHandle,
                          userAvatar: currentUserAvatar,
                          userHeadline: currentUserHeadline,
                          role: 'Core Member',
                        );
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(willJoin
                              ? 'Join request sent to the President of $title!'
                              : 'Left $title'),
                          backgroundColor: willJoin ? const Color(0xFF10B981) : const Color(0xFF0F172A),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isJoined ? const Color(0xFF0F172A) : primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: Text(
                      _isJoined ? 'Joined' : 'Join',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: primaryBlue,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 24,
      color: lightBlueBorder,
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    Color iconColor = const Color(0xFF0F172A),
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildAvatar(String url, double left) {
    return Positioned(
      left: left,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          color: const Color(0xFFBAE6FD),
        ),
        child: ClipOval(
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => const Icon(
              Icons.person,
              size: 20,
              color: primaryBlue,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: lightBlueBg,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: primaryBlue, size: 18),
      ),
    );
  }

  void _showImageDialog(String url, String title, String caption) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFE2E8F0),
                        child: const Icon(Icons.image, size: 48, color: textMuted),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      caption,
                      style: const TextStyle(fontSize: 13.5, color: textMuted, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
