import 'package:flutter/material.dart';

class PublicCommunityScreen extends StatelessWidget {
  final String communityName;
  final String description;
  final String visitors;
  final String? logoUrl;

  const PublicCommunityScreen({
    super.key,
    required this.communityName,
    required this.description,
    required this.visitors,
    this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B141A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? const Color(0xFF8696A0) : const Color(0xFF64748B);
    final linkColor = isDark ? const Color(0xFF61DAFB) : const Color(0xFF0284C7);
    final dividerColor = isDark ? const Color(0xFF1E2931) : const Color(0xFFE2E8F0);

    // Extracting just numbers for the "contributions" part
    const contributions = '9.1k';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF0F172A),
                    child: logoUrl != null && logoUrl!.startsWith('http')
                        ? CircleAvatar(
                            radius: 26,
                            backgroundImage: NetworkImage(logoUrl!),
                          )
                        : const CircleAvatar(
                            radius: 26,
                            backgroundColor: Color(0xFF0F172A),
                            child: Icon(Icons.account_balance_rounded, color: Colors.white, size: 24),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                communityName,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios, color: textColor, size: 14),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$visitors and $contributions contributions\nper week',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF09122C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      elevation: 0,
                    ),
                    child: const Text('Join', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Description and Tags
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description.isNotEmpty
                        ? description
                        : '$communityName is a collaborative campus student community at MITS Gwalior.',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14.5,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13.5),
                      children: [
                        TextSpan(text: '#12 in Campus Tech', style: TextStyle(color: linkColor, fontWeight: FontWeight.bold)),
                        TextSpan(text: '  |  ', style: TextStyle(color: secondaryTextColor)),
                        TextSpan(text: 'Top Members', style: TextStyle(color: linkColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Community Highlights
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.push_pin_rounded, color: isDark ? Colors.white : const Color(0xFFEA580C), size: 16),
                          const SizedBox(width: 8),
                          Text('Community highlights', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Icon(Icons.keyboard_arrow_down, color: textColor, size: 20),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildHighlightCard('MITS AI/ML Research & Project Advice Thread', isDark),
                        const SizedBox(width: 12),
                        _buildHighlightCard('[OFFICIAL] Placement & Internship Resource Drive', isDark),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Divider(color: dividerColor, thickness: 1),

            // Post Feed
            _buildStaticPost(isDark, textColor, secondaryTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightCard(String title, bool isDark) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162026) : const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF2A3942) : const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 14,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFFEA580C),
            child: const Icon(Icons.star_rounded, color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticPost(bool isDark, Color textColor, Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundImage: const AssetImage('assets/images/somraj_avatar.jpg'),
                  ),
                  const SizedBox(width: 8),
                  Text('somrajlodhi', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 6),
                  Text('4h • 1.2k views', style: TextStyle(color: secondaryTextColor, fontSize: 12.5)),
                ],
              ),
              Icon(Icons.more_vert, color: secondaryTextColor, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'What are the best open-source AI frameworks for edge computing in 2026?',
            style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.bold, height: 1.3),
          ),
          const SizedBox(height: 8),
          Text(
            'Hey everyone! We are benchmarking TensorFlow Lite, ONNX Runtime, and PyTorch Mobile on resource-constrained robotics hardware at MITS Gwalior. Looking for benchmarks...',
            style: TextStyle(color: isDark ? const Color(0xFFB0BEC5) : const Color(0xFF475569), fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildActionPill(Icons.arrow_upward, '142', isDark, suffixIcon: Icons.arrow_downward),
              const SizedBox(width: 10),
              _buildActionPill(Icons.chat_bubble_outline, '38', isDark),
              const SizedBox(width: 10),
              _buildActionPill(Icons.share_outlined, '12', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionPill(IconData icon, String label, bool isDark, {IconData? suffixIcon}) {
    final pillBg = isDark ? const Color(0xFF1E2931) : const Color(0xFFF1F5F9);
    final pillBorder = isDark ? const Color(0xFF2A3942) : const Color(0xFFE2E8F0);
    final iconColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: pillBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 17),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 12.5),
          ),
          if (suffixIcon != null) ...[
            const SizedBox(width: 8),
            Container(width: 1, height: 14, color: isDark ? const Color(0xFF3B4A54) : const Color(0xFFCBD5E1)),
            const SizedBox(width: 8),
            Icon(suffixIcon, color: iconColor, size: 17),
          ],
        ],
      ),
    );
  }
}
