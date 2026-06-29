import 'package:flutter/material.dart';
import '../../../feed/presentation/services/startup_manager.dart';

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
                  child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: StartupManager.notifications,
                    builder: (context, notificationsList, child) {
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        itemCount: notificationsList.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = notificationsList[index];
                          final isInvite = item['type'] == 'invite';

                          Widget? contentWidget;
                          if (isInvite) {
                            final status = item['status'] ?? 'pending';
                            if (status == 'pending') {
                              contentWidget = Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  children: [
                                    OutlinedButton(
                                      onPressed: () {
                                        StartupManager.updateNotificationStatus(item['id']!, 'declined');
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Co-founder invitation declined.'),
                                            backgroundColor: Colors.black,
                                          ),
                                        );
                                      },
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
                                      onPressed: () {
                                        StartupManager.updateNotificationStatus(item['id']!, 'accepted');
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Joined startup as co-founder with ${item['senderName'] ?? 'Somraj lodhi'}!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
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
                              );
                            } else if (status == 'accepted') {
                              contentWidget = const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      'Accepted invitation to join',
                                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              contentWidget = const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.cancel, color: Colors.red, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      'Declined invitation',
                                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } else if (item['content'] != null) {
                            contentWidget = Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item['content']!,
                                style: const TextStyle(
                                  color: Color(0xFF374151),
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            );
                          }

                          return _buildNotificationItem(
                            avatarUrl: item['avatarUrl']!,
                            username: item['username']!,
                            actionText: item['actionText']!,
                            timeText: item['timeText']!,
                            timeAgo: item['timeAgo']!,
                            isUnread: item['isUnread'] ?? false,
                            contentWidget: contentWidget,
                            badgeIcon: item['type'] == 'like' ? Icons.favorite : null,
                            badgeColor: item['type'] == 'like' ? const Color(0xFF4F46E5) : null,
                          );
                        },
                      );
                    },
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
