import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'club_members_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final String title = widget.clubData['title']?.toString() ??
        widget.clubData['name']?.toString() ??
        'Acoustic Serenade Showcase';

    final String category = widget.clubData['category']?.toString() ??
        widget.clubData['tag']?.toString() ??
        'Student Chapter';

    final String location = widget.clubData['location']?.toString() ??
        widget.clubData['organization']?.toString() ??
        'MITS Campus, Gwalior';

    final String time = widget.clubData['time']?.toString() ??
        widget.clubData['duration']?.toString() ??
        'Active Chapter';

    final String memberCount = widget.clubData['memberCount']?.toString() ?? '450+ Members';

    final String aboutText = widget.clubData['description']?.toString() ??
        widget.clubData['about']?.toString() ??
        'Official student chapter fostering collaborative learning, technical workshops, open source innovation, competitive programming, and campus hackathons.';

    final String organizerName = widget.clubData['organizerName']?.toString() ??
        widget.clubData['role']?.toString() ??
        'President & Founding Core Member';

    final String organizerRole = widget.clubData['organizerRole']?.toString() ??
        widget.clubData['subtitle']?.toString() ??
        'Leadership & Core Team';

    final String address = widget.clubData['address']?.toString() ??
        'Madhav Institute of Technology & Science, Racecourse Road, Gwalior';

    final String price = widget.clubData['price']?.toString() ?? 'Free';
    final String priceUnit = widget.clubData['priceUnit']?.toString() ?? '/open access';

    final String heroImage = widget.clubData['heroImage']?.toString() ??
        'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=1200&auto=format&fit=crop&q=80';

    const Color primaryBlue = Color(0xFF0284C7); // Light Blue / Sky Blue
    const Color lightBlueBg = Color(0xFFF0F9FF);
    const Color textDark = Color(0xFF0F172A);
    const Color textMuted = Color(0xFF64748B);

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
                            border: Border.all(color: const Color(0xFFBAE6FD)),
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
                        Row(
                          children: [
                            ClipOval(
                              child: Container(
                                width: 48,
                                height: 48,
                                color: lightBlueBg,
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=120',
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => const Icon(
                                    Icons.groups_rounded,
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
                child: Row(
                  children: [
                    // Price / Status Column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Total Price',
                          style: TextStyle(
                            fontSize: 12,
                            color: textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              price,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: primaryBlue,
                              ),
                            ),
                            Text(
                              ' $priceUnit',
                              style: const TextStyle(
                                fontSize: 13,
                                color: textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),

                    // Prominent Rounded Light Blue CTA Button
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isJoined = !_isJoined;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_isJoined ? 'Successfully registered for $title!' : 'Registration cancelled'),
                                backgroundColor: _isJoined ? const Color(0xFF10B981) : const Color(0xFF0F172A),
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
                            _isJoined ? 'Registered' : 'Book Now',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
              color: Color(0xFF0284C7),
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
          color: Color(0xFFF0F9FF),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: const Color(0xFF0284C7), size: 18),
      ),
    );
  }
}
