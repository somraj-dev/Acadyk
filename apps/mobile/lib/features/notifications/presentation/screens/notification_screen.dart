import 'package:flutter/material.dart';
import 'package:acadyk/common/services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  final List<Map<String, dynamic>> _mockNotifications = const [
    {
      'id': 'notif_1',
      'title': 'Campus Announcement',
      'body': 'MITS Gwalior released the official timetable for 2026 End-Sem Practicals.',
      'is_read': false,
      'created_at': '15m ago',
      'category': 'Mentions',
      'sender': {
        'full_name': 'MITS Gwalior',
        'username': 'mitsgwalior',
        'profile_photo_url': 'assets/images/mits_logo.png',
      }
    },
    {
      'id': 'notif_2',
      'title': 'New Connection',
      'body': 'Arjun Patel (GDSC Lead) started following your profile.',
      'is_read': false,
      'created_at': '1h ago',
      'category': 'Followers',
      'sender': {
        'full_name': 'Arjun Patel',
        'username': 'arjunpatel',
        'profile_photo_url': 'assets/images/somraj_avatar.jpg',
      }
    },
    {
      'id': 'notif_3',
      'title': 'Event Invitation',
      'body': 'You are invited to join MITS HackInit 2026 as a Lead Developer.',
      'is_read': true,
      'created_at': '3h ago',
      'category': 'Invites',
      'sender': {
        'full_name': 'GDG Gwalior',
        'username': 'gdggwalior',
        'profile_photo_url': 'assets/images/young_entrepreneur.jpg',
      }
    },
    {
      'id': 'notif_4',
      'title': 'New Mention',
      'body': 'Sneha Verma mentioned you in a post: "Big shoutout to @somraj.lodhi for the Quant framework!"',
      'is_read': true,
      'created_at': '5h ago',
      'category': 'Mentions',
      'sender': {
        'full_name': 'Sneha Verma',
        'username': 'snehaverma',
        'profile_photo_url': 'assets/images/alina_avatar.jpg',
      }
    },
    {
      'id': 'notif_5',
      'title': 'Placement Update',
      'body': 'Your resume was shortlisted by Quantaforze Corp for Senior Software Engineer.',
      'is_read': true,
      'created_at': '1d ago',
      'category': 'Invites',
      'sender': {
        'full_name': 'Placement Cell MITS',
        'username': 'placementcell',
        'profile_photo_url': 'assets/images/mits_logo.png',
      }
    },
  ];

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await NotificationService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = data.isNotEmpty ? data : _mockNotifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _notifications = _mockNotifications;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      _notifications = _notifications.map((n) {
        final Map<String, dynamic> updated = Map.from(n);
        updated['is_read'] = true;
        return updated;
      }).toList();
    });
    try {
      await NotificationService.markAllAsRead();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final textColor = theme.colorScheme.onSurface;

    final mentionsCount = _notifications.where((n) => n['category'] == 'Mentions').length;
    final followersCount = _notifications.where((n) => n['category'] == 'Followers').length;
    final invitesCount = _notifications.where((n) => n['category'] == 'Invites').length;

    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: isTablet ? 720 : double.infinity),
            color: scaffoldBg,
            child: Column(
              children: [
                // Top header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Icon(Icons.arrow_back, color: Colors.black87, size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Flexible(
                              child: Text(
                                'Your notifications',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _markAllAsRead,
                        child: Row(
                          children: const [
                            Icon(Icons.done_all, color: Color(0xFF0284C7), size: 18),
                            SizedBox(width: 4),
                            Text(
                              'Mark all as read',
                              style: TextStyle(
                                color: Color(0xFF0284C7),
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
                        _buildTab('View all', '${_notifications.length}', isActive: true),
                        const SizedBox(width: 8),
                        _buildTab('Mentions', '$mentionsCount'),
                        const SizedBox(width: 8),
                        _buildTab('Followers', '$followersCount'),
                        const SizedBox(width: 8),
                        _buildTab('Invites', '$invitesCount'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Notifications List
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _notifications.isEmpty
                          ? const Center(
                              child: Text(
                                'No notifications yet.',
                                style: TextStyle(color: Color(0xFF6B7280)),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                              itemCount: _notifications.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = _notifications[index];
                                final sender = item['sender'] as Map<String, dynamic>? ?? {};
                                final senderName = sender['full_name'] ?? 'Acadyk User';
                                final senderAvatar = sender['profile_photo_url'] ?? 'assets/images/somraj_avatar.jpg';
                                final senderUsername = sender['username'] ?? 'user';
                                final isUnread = !(item['is_read'] ?? false);
                                final title = item['title'] ?? 'Notification';
                                final body = item['body'] ?? '';

                                Widget? contentWidget;
                                if (body.isNotEmpty) {
                                  contentWidget = Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      body,
                                      style: const TextStyle(
                                        color: Color(0xFF374151),
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  );
                                }

                                return _buildNotificationItem(
                                  avatarUrl: senderAvatar,
                                  username: senderUsername,
                                  actionText: title,
                                  timeText: 'Just now',
                                  timeAgo: 'Just now',
                                  isUnread: isUnread,
                                  contentWidget: contentWidget,
                                  badgeIcon: item['type'] == 'like' ? Icons.favorite : null,
                                  badgeColor: item['type'] == 'like' ? const Color(0xFF0284C7) : null,
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
              color: isActive ? const Color(0xFF0284C7) : const Color(0xFF6B7280),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFE0F2FE) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              count,
              style: TextStyle(
                color: isActive ? const Color(0xFF0284C7) : const Color(0xFF6B7280),
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
                    image: avatarUrl.startsWith('http')
                        ? NetworkImage(avatarUrl) as ImageProvider
                        : AssetImage(avatarUrl),
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
                          color: Color(0xFF0284C7),
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
