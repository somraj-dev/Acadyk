import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'post_detail_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class CompanyProfileScreen extends StatefulWidget {
  final String companyName;
  const CompanyProfileScreen({super.key, required this.companyName});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  // Post states (like feed post)
  bool _isLiked = false;
  int _likesCount = 538;
  bool _commentsExpanded = false;

  final TextEditingController _commentInputCtrl = TextEditingController();
  final List<Map<String, dynamic>> _customComments = [
    {
      'name': 'Christian Pickett',
      'headline': 'Co-founder @ Orthogonal (YC W26)',
      'avatar': 'assets/images/dharmik_avatar.jpg',
      'isAuthor': true,
      'timeText': '1d',
      'body': 'Read more:\nhttps://www.thestreet.com/crypto/newsroom/orthogonal-is-betting-the-agent-economy-needs-better-infrastructure',
      'likes': 10,
      'hasLiked': false,
      'replies': <Map<String, dynamic>>[],
    },
    {
      'name': 'Aryan Gandhi',
      'headline': 'Building the Future with AI 0->1 | Gen ...',
      'avatar': 'assets/images/alina_avatar.jpg',
      'isAuthor': false,
      'timeText': '15h',
      'body': 'Congratulations on the raise! The idea of agents dynamically discovering and orchestrating capabilities feels like a missing layer in today\'s agent stack. Excited to see where Orthogonal goes from here. Christian Pickett 👏',
      'likes': 0,
      'hasLiked': false,
      'replies': <Map<String, dynamic>>[],
    },
    {
      'name': 'Ryan Widgeon',
      'headline': 'Founder | AI/ML | AI Agents |GTM| Forb...',
      'avatar': 'assets/images/somraj_avatar.jpg',
      'isAuthor': false,
      'timeText': '1d',
      'body': 'Congrats! This is a reallyyy interesting layer to build.\n\nMost agents today are only as useful as the tools they were pre-wired with. The moment the task requires a new capability, they either hallucinate a workaround, fail silently, or punt back to a human.\n\nDynamic capability discovery...',
      'likes': 9,
      'hasLiked': false,
      'replies': <Map<String, dynamic>>[
        {
          'name': 'Dr. Xi Zeng',
          'headline': 'Founder and CEO of Chance A...',
          'avatar': 'assets/images/dharmik_avatar.jpg',
          'timeText': '18h',
          'body': 'Ryan Widgeon The safety point is where this gets interesting. Tool discovery is easy to describe as routing, but the agent also needs a reason to stop....',
        }
      ],
    }
  ];

  @override
  void dispose() {
    _commentInputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5F3FFC); // Purple follow button color
    const textColor = Color(0xFF111827);
    const secondaryTextColor = Color(0xFF4B5563);
    const lightBgColor = Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false, // Let banner bleed into status bar
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. BANNER & OVERLAY LOGO AREA
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Banner Image (Corporate layout matching screenshot)
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&auto=format&fit=crop&q=60',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(0.2), // Dark filter
                      padding: const EdgeInsets.only(left: 20, top: 40),
                      alignment: Alignment.topLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          const Text(
                            'Build the future,',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'together.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Floating Back Button
                  Positioned(
                    top: 40,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: textColor, size: 20),
                      ),
                    ),
                  ),

                  // Floating Options Button
                  Positioned(
                    top: 40,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.more_horiz, color: textColor, size: 20),
                    ),
                  ),

                  // Floating Logo Card - rounded box overlapping the banner
                  Positioned(
                    bottom: -40,
                    left: 20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: lightBgColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Center(
                        child: CustomPaint(
                          size: const Size(40, 40),
                          painter: _CompanyLogoPainter(name: widget.companyName),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // 2. HEADER DETAILS SECTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.companyName == 'Warp' ? 'Warp Terminal' : widget.companyName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, color: primaryColor, size: 18),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.companyName == 'Warp'
                          ? 'Reimagining the terminal for modern developer teams.'
                          : 'Building intelligent products that empower people and teams.',
                      style: const TextStyle(fontSize: 14, color: secondaryTextColor, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _buildMetaTag(Icons.business, 'Software Development'),
                        _buildMetaTag(Icons.location_on, 'Bengaluru, India'),
                        _buildMetaTag(Icons.link, widget.companyName == 'Warp' ? 'warp.dev' : 'acadyk.com', isLink: true),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Actions: Follow and Message
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Follow',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFD1D5DB)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.chat_bubble_outline, color: primaryColor, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. STATS GRID
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(Icons.people_outline, '256', 'Members'),
                    _buildStatItem(Icons.calendar_today_outlined, '2019', 'Founded'),
                    _buildStatItem(Icons.dashboard_outlined, '12+', 'Products'),
                    _buildStatItem(Icons.star_outline, '3.2K', 'Followers'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. NAVIGATION TABS
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFECECE8), width: 1)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildTabItem('Overview', isActive: true),
                      _buildTabItem('Feed'),
                      _buildTabItem('Members'),
                      _buildTabItem('Jobs'),
                      _buildTabItem('About'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 5. ABOUT CARD
              _buildCardContainer(
                title: 'About',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.companyName == 'Warp'
                          ? 'Warp is a lightning-fast, Rust-based terminal reimagined from the ground up with AI tools and collaborative spaces, built to help software teams build the future together.'
                          : 'Acadyk Labs is a product and research company focused on AI, education technology and developer tools. We build solutions that create impact at scale.',
                      style: const TextStyle(fontSize: 14, color: secondaryTextColor, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Show more',
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 6. TOP MEMBERS CARD
              _buildCardContainer(
                title: 'Top Members',
                trailing: const Text(
                  'View all',
                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildMemberItem('Arjun Rao', 'Co-Founder & CEO', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120&auto=format&fit=crop'),
                      _buildMemberItem('Meera Iyer', 'CTO', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=120&auto=format&fit=crop'),
                      _buildMemberItem('Rohit Nair', 'Head of Product', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&auto=format&fit=crop'),
                      _buildMemberItem('Sneha Joshi', 'Design Lead', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&auto=format&fit=crop'),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: lightBgColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '+32',
                          style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 7. RECENT ACTIVITY CARD (picture-perfect replica of YC post card UI)
              _buildCardContainer(
                title: 'Recent Activity',
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Row
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const CompanyProfileScreen(companyName: 'Y Combinator'),
                          ));
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF6600), // YC Orange logo
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Y',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Y Combinator',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                          color: Color(0xFF191919),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.verified, size: 14, color: Color(0xFF5E5E5E)),
                                    ],
                                  ),
                                  Text(
                                    '21h • Edited',
                                    style: TextStyle(color: Color(0xFF5E5E5E), fontSize: 11.5),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.more_vert, color: Color(0xFF5E5E5E)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // RichText for post content with links
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Color(0xFF191919), fontSize: 13.5, height: 1.45),
                          children: [
                            TextSpan(
                              text: 'Warp',
                              style: const TextStyle(
                                color: Color(0xFF0A66C2),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  if (widget.companyName != 'Warp') {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const CompanyProfileScreen(companyName: 'Warp'),
                                      ),
                                    );
                                  }
                                },
                            ),
                            const TextSpan(
                              text: ' has raised \$60 million in Series B funding to automate payroll, HR, tax compliance, and employee onboarding. ',
                            ),
                            TextSpan(
                              text: '...more',
                              style: const TextStyle(
                                color: Color(0xFF191919),
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => const PostDetailScreen(
                                      authorName: 'Christian Pickett',
                                      authorHeadline: 'Co-founder @ Orthogonal (YC W26)',
                                      authorAvatar: 'assets/images/dharmik_avatar.jpg',
                                      timeAgo: '1d',
                                      postText: '',
                                      connectionDegree: '3rd+',
                                    ),
                                  ));
                                },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Couch image of Warp team
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/warp_team.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Reusable engagement action bar inside profile
                      _buildActivityActionRow(),

                      // Expandable Comments accordion inside profile
                      if (_commentsExpanded) ...[
                        const SizedBox(height: 8),
                        _buildCommentsSection(),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaTag(IconData icon, String text, {bool isLink = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isLink ? const Color(0xFF5F3FFC) : const Color(0xFF4B5563),
            fontWeight: isLink ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF5F3FFC), size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827)),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildTabItem(String label, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 24),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isActive
            ? const Border(bottom: BorderSide(color: Color(0xFF5F3FFC), width: 2))
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          color: isActive ? const Color(0xFF5F3FFC) : const Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildCardContainer({required String title, Widget? trailing, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECECE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildMemberItem(String name, String role, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 2),
          Text(
            role,
            style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  // Activity card feedback engagement row
  Widget _buildActivityActionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isLiked = !_isLiked;
                  _likesCount = _isLiked ? 539 : 538;
                });
              },
              child: Icon(
                _isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                size: 24,
                color: _isLiked ? Colors.red : Colors.black87,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _likesCount.toString(),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  _commentsExpanded = !_commentsExpanded;
                });
              },
              child: Icon(
                _commentsExpanded ? CupertinoIcons.chat_bubble_fill : CupertinoIcons.chat_bubble,
                size: 24,
                color: _commentsExpanded ? const Color(0xFF0A66C2) : Colors.black87,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              '51',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Icon(CupertinoIcons.bookmark, size: 24, color: Colors.black87),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Most relevant',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF374151)),
              ),
              Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF374151)),
            ],
          ),
          const SizedBox(height: 12),

          ..._customComments.map((comment) {
            final replies = comment['replies'] as List<dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage(comment['avatar']),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  comment['name'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                if (comment['isAuthor'] == true) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F2FE),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Author',
                                      style: TextStyle(color: Color(0xFF0369A1), fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                Text(
                                  comment['timeText'],
                                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                            Text(
                              comment['headline'],
                              style: const TextStyle(color: Colors.grey, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            _buildCommentBodyText(comment['body']),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Text(
                                  'Like',
                                  style: TextStyle(color: Color(0xFF5E5E5E), fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                if (comment['likes'] > 0) ...[
                                  const SizedBox(width: 6),
                                  const Icon(CupertinoIcons.hand_thumbsup_fill, size: 12, color: Color(0xFF0A66C2)),
                                  const SizedBox(width: 2),
                                  Text(
                                    comment['likes'].toString(),
                                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                                  ),
                                ],
                                const SizedBox(width: 12),
                                const Text(
                                  'Reply',
                                  style: TextStyle(color: Color(0xFF5E5E5E), fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (replies.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 36.0, top: 12.0),
                      child: Column(
                        children: replies.map((reply) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundImage: AssetImage(reply['avatar']),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          reply['name'],
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                        const Spacer(),
                                        Text(
                                          reply['timeText'],
                                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      reply['headline'],
                                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    _buildCommentBodyText(reply['body']),
                                    const SizedBox(height: 6),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),

          const Divider(height: 1, color: Color(0xFFECECE8)),
          const SizedBox(height: 12),

          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/images/somraj_avatar.jpg'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: _commentInputCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13.5),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 13.5, color: Colors.black),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        final newComment = {
                          'name': 'Somraj lodhi',
                          'headline': 'Founder & Builder @ Acadyk',
                          'avatar': 'assets/images/somraj_avatar.jpg',
                          'isAuthor': false,
                          'timeText': 'Just now',
                          'body': val.trim(),
                          'likes': 0,
                          'hasLiked': false,
                          'replies': <Map<String, dynamic>>[],
                        };
                        setState(() {
                          _customComments.add(newComment);
                          _commentInputCtrl.clear();
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.alternate_email, color: Color(0xFF6B7280), size: 22),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentBodyText(String body) {
    final words = ['Christian Pickett', 'Ryan Widgeon'];
    String? foundWord;
    for (final w in words) {
      if (body.contains(w)) {
        foundWord = w;
        break;
      }
    }

    if (foundWord == null) {
      return Text(
        body,
        style: const TextStyle(color: Color(0xFF374151), fontSize: 13, height: 1.4),
      );
    }

    final parts = body.split(foundWord);
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Color(0xFF374151), fontSize: 13, height: 1.4),
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: foundWord,
            style: const TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ));
              },
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
    );
  }
}

class _CompanyLogoPainter extends CustomPainter {
  final String name;
  _CompanyLogoPainter({required this.name});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5F3FFC)
      ..style = PaintingStyle.fill;

    if (name.toLowerCase() == 'warp' || name.toLowerCase().contains('combinator')) {
      // Warp stylized terminal icon or YC orange painter
      final borderPaint = Paint()
        ..color = const Color(0xFF111827)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      final path = Path()
        ..moveTo(size.width * 0.2, size.height * 0.2)
        ..lineTo(size.width * 0.6, size.height * 0.5)
        ..lineTo(size.width * 0.2, size.height * 0.8);
      canvas.drawPath(path, borderPaint);

      canvas.drawRect(
        Rect.fromLTWH(size.width * 0.6, size.height * 0.7, size.width * 0.3, size.height * 0.12),
        Paint()..color = const Color(0xFF111827),
      );
    } else {
      // Acadyk abstract modern A logo
      final path = Path()
        ..moveTo(size.width * 0.5, size.height * 0.1)
        ..lineTo(size.width * 0.9, size.height * 0.9)
        ..lineTo(size.width * 0.7, size.height * 0.9)
        ..lineTo(size.width * 0.5, size.height * 0.45)
        ..lineTo(size.width * 0.3, size.height * 0.9)
        ..lineTo(size.width * 0.1, size.height * 0.9)
        ..close();
      canvas.drawPath(path, paint);

      // Add a dot inside
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.68), 3.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
