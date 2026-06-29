import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'edit_status_screen.dart';
import 'profile_screen.dart';

class StoryViewScreen extends StatefulWidget {
  const StoryViewScreen({super.key});

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _progressController.addListener(() {
      setState(() {});
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pop(context);
      }
    });

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeEmoji = UserStatusState.emoji ?? '🤕';
    final activeText = UserStatusState.text ?? 'Out sick';
    final activeExpiration = UserStatusState.expiration;
    final activeVisibleTo = UserStatusState.visibleTo;

    // Formatting date
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final dateStr = '${months[now.month - 1]} ${now.day}th, ${now.year}';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: Colors.black,
            child: Stack(
              children: [
                // 1. STORY CARD BODY
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.only(top: 40, bottom: 80),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFEDF2F7), // Light blue-grey
                          Color(0xFFF3E8FF), // Soft lavender
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        // Organized by Acadyk
                        Row(
                          children: [
                            const Text(
                              'Organized by ',
                              style: TextStyle(
                                color: Color(0xFF374151),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0F4C81),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'a',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  height: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'ACADYK',
                              style: TextStyle(
                                color: Color(0xFF0F4C81),
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          '$activeText Highlight',
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          'A thought highlight shared by Somraj Lodhi.\nVisible to: $activeVisibleTo. Expires: $activeExpiration.',
                          style: const TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 15,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Date
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Mid Graphic Area (Grid & Rocket mock from screenshot)
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Decorative Grid on right
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                child: SizedBox(
                                  width: 140,
                                  child: GridView.count(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 2,
                                    crossAxisSpacing: 2,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: [
                                      Container(
                                        color: Colors.white.withOpacity(0.4),
                                        child: const Icon(CupertinoIcons.globe, color: Color(0xFF0F4C81), size: 24),
                                      ),
                                      Container(
                                        color: const Color(0xFF5865F2).withOpacity(0.15),
                                        child: const Icon(CupertinoIcons.ellipses_bubble_fill, color: Color(0xFF5865F2), size: 24),
                                      ),
                                      Container(
                                        color: Colors.white.withOpacity(0.6),
                                        child: const Icon(CupertinoIcons.square_arrow_down, color: Colors.black87, size: 24),
                                      ),
                                      Container(
                                        color: Colors.white.withOpacity(0.3),
                                        child: const Icon(CupertinoIcons.hammer_fill, color: Colors.black87, size: 24),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Rocket and Emoji Graphic on left
                              Positioned(
                                left: 0,
                                bottom: 10,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Big emoji bubble
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        activeEmoji,
                                        style: const TextStyle(fontSize: 44),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Flying rocket icon
                                    Transform.rotate(
                                      angle: 0.6,
                                      child: const Icon(
                                        CupertinoIcons.rocket_fill,
                                        color: Color(0xFF0F4C81),
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Link Button
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context); // Close story
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(isOwnProfile: true),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.link, color: Color(0xFF0A66C2), size: 20),
                                  SizedBox(width: 6),
                                  Text(
                                    'Tap to view profile',
                                    style: TextStyle(
                                      color: Color(0xFF111827),
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text('👉', style: TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. TOP STATUS INDICATOR AND USER BAR
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 60,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      children: [
                        // Progress bar segment
                        Container(
                          width: double.infinity,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: _progressController.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(1.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Profile row
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              backgroundImage: AssetImage('assets/images/somraj_avatar.jpg'),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'somraj_lodhi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.more_horiz, color: Colors.white, size: 22),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {},
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 22),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. BOTTOM SEND MESSAGE BAR
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 70,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: Colors.white54, width: 1.2),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'Send message',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isLiked = !_isLiked;
                            });
                          },
                          child: Icon(
                            _isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                            color: _isLiked ? Colors.red : Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Ad',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
