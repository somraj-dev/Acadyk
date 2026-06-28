import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: const Color(0xFFF9FAFB),
            child: Column(
              children: [
                // Top header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Icons.arrow_back, color: Colors.black87, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Your notifications',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Row(
                          children: const [
                            Icon(Icons.done_all, color: Color(0xFF4F46E5), size: 18),
                            SizedBox(width: 4),
                            Text(
                              'Mark all as read',
                              style: TextStyle(
                                color: Color(0xFF4F46E5),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTab('View all', '12', isActive: true),
                        const SizedBox(width: 8),
                        _buildTab('Mentions', '6'),
                        const SizedBox(width: 8),
                        _buildTab('Followers', '4'),
                        const SizedBox(width: 8),
                        _buildTab('Invites', '2'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Notifications List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      _buildNotificationItem(
                        avatarUrl: 'assets/images/somraj_avatar.jpg', 
                        username: '@frankiesullivan',
                        actionText: 'followed you',
                        timeText: 'Thursday 4:20pm',
                        timeAgo: '2 hours ago',
                        isUnread: true,
                      ),
                      const SizedBox(height: 12),
                      _buildNotificationItem(
                        avatarUrl: 'assets/images/alina_avatar.jpg', 
                        username: '@eleanor_mac',
                        actionText: 'commented on your post',
                        timeText: 'Thursday 3:12pm',
                        timeAgo: '3 hours ago',
                        isUnread: true,
                        contentWidget: Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Love the background on this! Would love to learn how you created the mesh gradient effect.',
                            style: TextStyle(
                              color: Color(0xFF374151),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildNotificationItem(
                        avatarUrl: 'assets/images/alina_avatar.jpg',
                        username: '@eleanor_mac',
                        actionText: 'liked your post',
                        timeText: 'Thursday 3:11pm',
                        timeAgo: '3 hours ago',
                        isUnread: true,
                        badgeIcon: Icons.favorite,
                        badgeColor: const Color(0xFF4F46E5), 
                        isActiveBackground: true, 
                      ),
                      const SizedBox(height: 12),
                      _buildNotificationItem(
                        avatarUrl: 'assets/images/dharmik_avatar.jpg', 
                        username: '@ollie_diggs',
                        actionText: 'invited you to Sisyphus Dashboard',
                        timeText: 'Thursday 2:44pm',
                        timeAgo: '4 hours ago',
                        isUnread: false,
                        contentWidget: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            children: [
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  foregroundColor: const Color(0xFF374151),
                                  minimumSize: const Size(0, 36),
                                ),
                                child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  minimumSize: const Size(0, 36),
                                ),
                                child: const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, String count, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF6B7280),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFEEF2FF) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              count,
              style: TextStyle(
                color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required String avatarUrl,
    required String username,
    required String actionText,
    required String timeText,
    required String timeAgo,
    required bool isUnread,
    Widget? contentWidget,
    IconData? badgeIcon,
    Color? badgeColor,
    bool isActiveBackground = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActiveBackground ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isActiveBackground
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(avatarUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (badgeIcon != null && badgeColor != null)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(badgeIcon, size: 10, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
                          children: [
                            TextSpan(
                              text: username,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                            ),
                            const TextSpan(text: ' '),
                            TextSpan(text: actionText),
                          ],
                        ),
                      ),
                    ),
                    if (isUnread) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4F46E5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeText,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    Text(
                      timeAgo,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
                if (contentWidget != null) contentWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
