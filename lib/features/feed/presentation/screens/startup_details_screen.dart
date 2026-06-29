import 'package:flutter/material.dart';

class StartupDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? customData;
  const StartupDetailsScreen({super.key, this.customData});

  @override
  State<StartupDetailsScreen> createState() => _StartupDetailsScreenState();
}

class _StartupDetailsScreenState extends State<StartupDetailsScreen> {
  int _activeTab = 0; // 0: Company, 1: Jobs, 2: News

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFFBFBFA); // Warm off-white YC style
    const textColor = Color(0xFF1E1E1E);
    const secondaryTextColor = Color(0xFF333333);
    const linkColor = Color(0xFF0066CC);

    final custom = widget.customData;
    final isCustom = custom != null;

    final companyName = custom?['companyName'] ?? 'Airbnb';
    final descriptionText = custom?['description'] ?? 'Founded in August of 2008 and based in San Francisco, California, Airbnb is a trusted community marketplace for people to list, discover, and book unique accommodations around the world — online or from a mobile phone. Whether an apartment for a night, a castle for a week, or a villa for a month, Airbnb connects people to unique travel experiences, at any price point, in more than 33,000 cities and 192 countries. And with world-class customer service and a growing community of users, Airbnb is the easiest way for people to monetize their extra space and showcase it to an audience of millions.';
    final locationText = custom?['location'] ?? 'San Francisco';
    final urlText = custom?['url'] ?? 'http://airbnb.com';
    final progressText = custom?['progress'] ?? 'No global movement springs from individuals. It takes an entire team united behind something big. Together, we work hard, we laugh a lot, we brainstorm nonstop, we use hundreds of Post-Its a week, and we give the best high-fives in town. Headquartered in San Francisco, we have satellite offices across the globe.';
    final techStackText = custom?['techStack'] ?? 'Ruby on Rails, React, Flutter, Dart';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: bgColor,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              children: [
                // Header (Logo + Title)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Airbnb Logo
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5A5F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: _buildAirbnbLogo(size: 30, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    // Title and Badges
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            companyName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Badges wrapped in a wrap layout
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildYCBadge(isCustom ? 'FALL 2026' : 'WINTER 2009'),
                              _buildStatusBadge(isCustom ? 'ACTIVE' : 'PUBLIC'),
                              if (isCustom) ...[
                                _buildTextBadge(locationText.toUpperCase()),
                              ] else ...[
                                _buildTextBadge('MARKETPLACE'),
                                _buildTextBadge('TRAVEL'),
                                _buildTextBadge('SAN FRANCISCO'),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Navigation Tabs
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5E5E0), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildTabItem('Company', 0),
                      _buildTabItem('Jobs', 1, count: 0),
                      _buildTabItem('News', 2),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Link Row
                Row(
                  children: [
                    const Icon(Icons.link, size: 18, color: Color(0xFF7A7A76)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        urlText,
                        style: const TextStyle(
                          color: linkColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Headline
                Text(
                  isCustom ? descriptionText : 'Book accommodations around the world.',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Description Paragraphs
                Text(
                  isCustom
                      ? 'Progress: $progressText'
                      : 'Founded in August of 2008 and based in San Francisco, California, Airbnb is a trusted community marketplace for people to list, discover, and book unique accommodations around the world — online or from a mobile phone. Whether an apartment for a night, a castle for a week, or a villa for a month, Airbnb connects people to unique travel experiences, at any price point, in more than 33,000 cities and 192 countries. And with world-class customer service and a growing community of users, Airbnb is the easiest way for people to monetize their extra space and showcase it to an audience of millions.',
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isCustom
                      ? 'Tech Stack: $techStackText'
                      : 'No global movement springs from individuals. It takes an entire team united behind something big. Together, we work hard, we laugh a lot, we brainstorm nonstop, we use hundreds of Post-Its a week, and we give the best high-fives in town. Headquartered in San Francisco, we have satellite offices across the globe.',
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Active Founders Section
                const Text(
                  'Active Founders',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 16),

                if (isCustom) ...[
                  _buildFounderCard(
                    name: custom['founders'] ?? 'Somraj lodhi',
                    title: 'Founder/CEO',
                    avatarAsset: 'assets/images/somraj_avatar.jpg',
                    bio: 'Technical lead and active developer building the foundation of this venture.',
                  ),
                ] else ...[
                  // Founder Card 1: Brian Chesky
                  _buildFounderCard(
                    name: 'Brian Chesky',
                    title: 'Founder/CEO',
                    avatarAsset: 'assets/images/somraj_avatar.jpg',
                    bio: 'Brian Chesky is the co-founder, Head of Community, and CEO of Airbnb, which he started with Joe Gebbia and Nathan Blecharczyk in 2008. Brian sets the company\'s strategy to connect people to unique travel experiences, and drives Airbnb\'s mission to create a world where anyone can belong anywhere. Originally from New York, Brian graduated from the Rhode Island School of Design where he received a Bachelor of Fine Arts in Industrial Design.',
                  ),
                  const SizedBox(height: 16),

                  // Founder Card 2: Nathan Blecharczyk
                  _buildFounderCard(
                    name: 'Nathan Blecharczyk',
                    title: 'Founder/CTO',
                    avatarAsset: 'assets/images/dharmik_avatar.jpg',
                    bio: 'Nathan Blecharczyk is the co-founder, Chief Strategy Officer, and Chairman of Airbnb China. Nathan plays a leading role in driving key strategic initiatives across the global business. Previously he oversaw the creation of Airbnb\'s engineering, data science, and performance marketing teams. Nathan became an entrepreneur in his youth, running a business that provided advertising services online.',
                  ),
                ],
                const SizedBox(height: 32),

                // Latest News Section
                const Text(
                  'Latest News',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 16),
                _buildNewsTile(
                  title: 'Airbnb CEO Brian Chesky on taking it back to basics: \'I can\'t make products just for 41-year-old tech founders\' - The Verge',
                  date: 'May 09, 2023',
                ),
                _buildNewsTile(
                  title: 'Airbnb launches Airbnb Rooms listing category for budget travel',
                  date: 'May 03, 2023',
                ),
                _buildNewsTile(
                  title: 'Brian Chesky Isn\'t Running Airbnb--He\'s \'Designing\' It',
                  date: 'Mar 16, 2023',
                ),
                _buildNewsTile(
                  title: 'Airbnb\'s cofounder just donated \$25M to get plastic out of the ocean',
                  date: 'Feb 02, 2023',
                ),
                _buildNewsTile(
                  title: 'Hocus Pocus\' fans can now stay in the Sanderson Sisters\' cottage : NPR',
                  date: 'Oct 06, 2022',
                ),
                const SizedBox(height: 32),

                // YC Photos Section
                const Text(
                  'YC Photos',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/young_entrepreneur.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 240,
                  ),
                ),
                const SizedBox(height: 32),

                // Summary Sidebar Card (Bottom)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE5E5E0)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mini Logo + Name
                      Row(
                        children: [
                          _buildAirbnbLogo(size: 24, color: const Color(0xFFFF5A5F)),
                          const SizedBox(width: 8),
                          Text(
                            companyName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _buildSummaryRow('Founded:', isCustom ? '2026' : '2008'),
                      const Divider(color: Color(0xFFECECE8), height: 24),

                      _buildSummaryRow('Batch:', isCustom ? 'Fall 2026' : 'Winter 2009'),
                      const Divider(color: Color(0xFFECECE8), height: 24),

                      _buildSummaryRow('Team Size:', isCustom ? '1-5' : '6132'),
                      const Divider(color: Color(0xFFECECE8), height: 24),

                      _buildSummaryRow('Status:', isCustom ? 'Active' : 'Public', hasStatusDot: true),
                      const Divider(color: Color(0xFFECECE8), height: 24),

                      _buildSummaryRow('Location:', locationText),
                      const Divider(color: Color(0xFFECECE8), height: 24),

                      _buildSummaryRow('Primary Partner:', 'Garry Tan', isLink: true),
                      const SizedBox(height: 24),

                      // Social Icons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildSocialCardButton(
                            const Icon(Icons.link, size: 18, color: Color(0xFF7A7A76)),
                          ),
                          const SizedBox(width: 10),
                          _buildSocialCardButton(
                            _buildLinkedInLogo(size: 18),
                          ),
                          const SizedBox(width: 10),
                          _buildSocialCardButton(
                            _buildXLogo(size: 14, color: Colors.black),
                          ),
                          const SizedBox(width: 10),
                          _buildSocialCardButton(
                            const Icon(Icons.facebook, size: 20, color: Color(0xFF1877F2)),
                          ),
                          const SizedBox(width: 10),
                          _buildSocialCardButton(
                            _buildCrunchbaseLogo(size: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYCBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0E5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFF04E23),
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Text(
              'Y',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFD35A00),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEE),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF00B074),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF4A4A46),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEE),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF4A4A46),
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildTabItem(String label, int tabIndex, {int? count}) {
    final isActive = _activeTab == tabIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = tabIndex;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: isActive
              ? const Border(
                  bottom: BorderSide(color: Color(0xFFF04E23), width: 2),
                )
              : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF1E1E1E) : const Color(0xFF7A7A76),
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 15,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4A46),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildFounderCard({
    required String name,
    required String title,
    required String avatarAsset,
    required String bio,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E5E0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  avatarAsset,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildXLogo(size: 14, color: const Color(0xFF1E1E1E)),
                        const SizedBox(width: 8),
                        _buildLinkedInLogo(size: 15),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7A7A76),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            bio,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsTile({required String title, required String date}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {},
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0066CC),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            date,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7A7A76),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isLink = false, bool hasStatusDot = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7A7A76),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasStatusDot) ...[
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF00B074),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isLink ? const Color(0xFF0066CC) : const Color(0xFF1E1E1E),
                decoration: isLink ? TextDecoration.underline : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialCardButton(Widget child) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFECECE8)),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _buildLinkedInLogo({double size = 16}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0077B5),
        borderRadius: BorderRadius.circular(size * 0.15),
      ),
      alignment: Alignment.center,
      child: Text(
        'in',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.7,
          fontWeight: FontWeight.w900,
          fontFamily: 'sans-serif',
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildXLogo({double size = 16, Color color = Colors.black}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _XLogoPainter(color: color),
      ),
    );
  }

  Widget _buildCrunchbaseLogo({double size = 16}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0288D1),
        borderRadius: BorderRadius.circular(size * 0.15),
      ),
      alignment: Alignment.center,
      child: Text(
        'cb',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.65,
          fontWeight: FontWeight.w800,
          fontFamily: 'sans-serif',
          height: 1.0,
        ),
      ),
    );
  }
}

class _XLogoPainter extends CustomPainter {
  final Color color;
  _XLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    double w = size.width;

    final scale = w / 24.0;
    final path = Path()
      ..moveTo(18.244 * scale, 2.25 * scale)
      ..lineTo(21.552 * scale, 2.25 * scale)
      ..lineTo(14.325 * scale, 10.51 * scale)
      ..lineTo(22.827 * scale, 21.75 * scale)
      ..lineTo(16.17 * scale, 21.75 * scale)
      ..lineTo(10.956 * scale, 14.933 * scale)
      ..lineTo(4.99 * scale, 21.75 * scale)
      ..lineTo(1.68 * scale, 21.75 * scale)
      ..lineTo(9.41 * scale, 12.915 * scale)
      ..lineTo(1.254 * scale, 2.25 * scale)
      ..lineTo(8.08 * scale, 2.25 * scale)
      ..lineTo(12.793 * scale, 8.481 * scale)
      ..close();

    final hollowPath = Path()
      ..moveTo(17.083 * scale, 19.77 * scale)
      ..lineTo(18.916 * scale, 19.77 * scale)
      ..lineTo(7.084 * scale, 4.126 * scale)
      ..lineTo(5.117 * scale, 4.126 * scale)
      ..close();

    final combinedPath = Path.combine(PathOperation.difference, path, hollowPath);
    canvas.drawPath(combinedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AirbnbLogoPainter extends CustomPainter {
  final Color color;
  _AirbnbLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    double w = size.width;
    final scale = w / 24.0;

    // Loop 1: Inner loop (teardrop)
    final innerPath = Path()
      ..moveTo(12.001 * scale, 16.709 * scale)
      ..relativeCubicTo(-1.013 * scale, -1.271 * scale, -1.609 * scale, -2.386 * scale, -1.808 * scale, -3.34 * scale)
      ..relativeCubicTo(-0.197 * scale, -0.954 * scale, 0.08 * scale, -1.782 * scale, 0.835 * scale, -2.484 * scale)
      ..relativeCubicTo(0.755 * scale, -0.702 * scale, 1.636 * scale, -0.937 * scale, 2.645 * scale, -0.937 * scale)
      ..relativeCubicTo(1.01 * scale, 0.0 * scale, 1.89 * scale, 0.235 * scale, 2.645 * scale, 0.937 * scale)
      ..relativeCubicTo(0.755 * scale, 0.702 * scale, 1.033 * scale, 1.53 * scale, 0.836 * scale, 2.484 * scale)
      ..relativeCubicTo(-0.199 * scale, 0.954 * scale, -1.196 * scale, 2.069 * scale, -2.209 * scale, 3.34 * scale)
      ..relativeCubicTo(-0.143 * scale, 0.181 * scale, -0.242 * scale, 0.308 * scale, -0.242 * scale, 0.308 * scale)
      ..relativeCubicTo(0.0 * scale, 0.0 * scale, -0.099 * scale, -0.127 * scale, -0.242 * scale, -0.308 * scale)
      ..close();

    // Loop 2: Outer loop
    final outerPath = Path()
      ..moveTo(16.896 * scale, 20.353 * scale)
      ..relativeCubicTo(-1.242 * scale, 0.668 * scale, -2.613 * scale, 0.385 * scale, -3.896 * scale, -0.734 * scale)
      ..relativeCubicTo(-1.282 * scale, 1.119 * scale, -2.653 * scale, 1.402 * scale, -3.896 * scale, 0.734 * scale)
      ..relativeCubicTo(-1.725 * scale, -0.929 * scale, -2.585 * scale, -3.007 * scale, -1.666 * scale, -5.835 * scale)
      ..relativeCubicTo(0.421 * scale, -1.28 * scale, 1.144 * scale, -2.58 * scale, 2.166 * scale, -3.892 * scale)
      ..relativeCubicTo(1.022 * scale, -1.312 * scale, 2.138 * scale, -2.355 * scale, 3.344 * scale, -3.13 * scale)
      ..relativeCubicTo(1.206 * scale, 0.775 * scale, 2.322 * scale, 1.818 * scale, 3.344 * scale, 3.13 * scale)
      ..relativeCubicTo(1.022 * scale, 1.312 * scale, 1.745 * scale, 2.612 * scale, 2.166 * scale, 3.892 * scale)
      ..relativeCubicTo(0.919 * scale, 2.828 * scale, 0.059 * scale, 4.906 * scale, -1.666 * scale, 5.835 * scale)
      ..close();

    final combined = Path.combine(PathOperation.difference, outerPath, innerPath);
    canvas.drawPath(combined, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

  Widget _buildAirbnbLogo({double size = 32, Color color = Colors.white}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AirbnbLogoPainter(color: color),
      ),
    );
  }
