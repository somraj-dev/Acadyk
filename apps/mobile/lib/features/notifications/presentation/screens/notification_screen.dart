import 'package:flutter/material.dart';
import 'package:acadyk/common/services/notification_service.dart';
import 'package:acadyk/shared/widgets/skeleton/skeleton.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'club_join_request_review_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> _notifications = NotificationService.getInitialCachedNotifications();
  bool _isLoading = false;
  String _selectedTab = 'View all';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    NotificationService.notificationsNotifier.addListener(_onNotificationsUpdated);
  }

  @override
  void dispose() {
    NotificationService.notificationsNotifier.removeListener(_onNotificationsUpdated);
    super.dispose();
  }

  void _onNotificationsUpdated() {
    if (mounted) {
      setState(() {
        _notifications = List.from(NotificationService.notificationsNotifier.value);
      });
    }
  }

  Future<void> _loadNotifications() async {
    if (_notifications.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      final data = await NotificationService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
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

  Future<void> _approveJoinRequest(String id, String name, String clubTitle) async {
    await NotificationService.approveClubJoinRequest(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Approved $name\'s request to join $clubTitle!'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _declineJoinRequest(String id, String name, String clubTitle) async {
    await NotificationService.declineClubJoinRequest(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Declined $name\'s join request'),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredNotifications() {
    if (_selectedTab == 'Mentions') {
      return _notifications.where((n) => n['category'] == 'Mentions').toList();
    } else if (_selectedTab == 'Followers') {
      return _notifications.where((n) => n['category'] == 'Followers').toList();
    } else if (_selectedTab == 'Invites') {
      return _notifications.where((n) =>
          n['category'] == 'Invites' ||
          n['type'] == 'club_join_request' ||
          n['type'] == 'student_chapter_join_request' ||
          n['type'] == 'chapter_join_request').toList();
    }
    return _notifications;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaffoldBg = theme.scaffoldBackgroundColor;

    final mentionsCount = _notifications.where((n) => n['category'] == 'Mentions').length;
    final followersCount = _notifications.where((n) => n['category'] == 'Followers').length;
    final invitesCount = _notifications.where((n) =>
        n['category'] == 'Invites' ||
        n['type'] == 'club_join_request' ||
        n['type'] == 'student_chapter_join_request' ||
        n['type'] == 'chapter_join_request').length;

    final filteredList = _getFilteredNotifications();
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
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
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

                // Interactive Filter Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildTab('View all', '${_notifications.length}'),
                        const SizedBox(width: 8),
                        _buildTab('Invites', '$invitesCount'),
                        const SizedBox(width: 8),
                        _buildTab('Mentions', '$mentionsCount'),
                        const SizedBox(width: 8),
                        _buildTab('Followers', '$followersCount'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Notifications List
                Expanded(
                  child: _isLoading
                      ? const NotificationSkeleton()
                      : filteredList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.notifications_none_outlined, size: 52, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    _selectedTab == 'Invites'
                                        ? 'No pending club joining requests.'
                                        : 'No notifications in $_selectedTab.',
                                    style: const TextStyle(color: Color(0xFF6B7280), fontSize: 15),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
                              itemCount: filteredList.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final item = filteredList[index];
                                final isClubReq = item['type'] == 'club_join_request' ||
                                    item['type'] == 'student_chapter_join_request' ||
                                    item['type'] == 'chapter_join_request' ||
                                    item['clubTitle'] != null;

                                if (isClubReq) {
                                  return _buildClubJoinRequestCard(item);
                                }

                                final sender = item['sender'] as Map<String, dynamic>? ?? {};
                                final senderName = sender['full_name'] ?? 'Acadyk User';
                                final senderAvatar = sender['profile_photo_url'] ?? '';
                                final senderUsername = sender['username'] ?? 'user';
                                final isUnread = !(item['is_read'] ?? false);
                                final title = item['title'] ?? 'Notification';
                                final body = item['body'] ?? '';
                                final timeAgo = item['timeAgo'] ?? item['timeText'] ?? 'Just now';

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
                                  username: senderName.isNotEmpty ? senderName : senderUsername,
                                  actionText: title,
                                  timeText: timeAgo,
                                  timeAgo: timeAgo,
                                  isUnread: isUnread,
                                  contentWidget: contentWidget,
                                  badgeIcon: item['type'] == 'like' ? Icons.favorite : (item['type'] == 'mention' ? Icons.alternate_email : null),
                                  badgeColor: item['type'] == 'like' ? const Color(0xFF0284C7) : const Color(0xFF8B5CF6),
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

  Widget _buildTab(String label, String count) {
    final isActive = _selectedTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF0284C7) : Colors.grey.shade300,
            width: isActive ? 1.5 : 1.0,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withOpacity(0.08),
                    blurRadius: 6,
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
                color: isActive ? const Color(0xFF0284C7) : const Color(0xFF4B5563),
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFE0F2FE) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count,
                style: TextStyle(
                  color: isActive ? const Color(0xFF0284C7) : const Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openReviewScreen(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClubJoinRequestReviewScreen(
          requestData: item,
          onStatusChanged: () {
            setState(() {});
          },
        ),
      ),
    );
  }

  /// High-polish card for Club and Student Chapter Joining Requests
  Widget _buildClubJoinRequestCard(Map<String, dynamic> item) {
    final id = item['id']?.toString() ?? '';
    final sender = item['sender'] as Map<String, dynamic>? ?? {};
    final senderName = sender['full_name'] ?? sender['name'] ?? 'Student Applicant';
    final senderHandle = sender['username'] ?? 'applicant';
    final senderAvatar = sender['profile_photo_url'] ?? sender['avatar'] ?? '';
    final senderHeadline = sender['headline'] ?? sender['bio'] ?? 'Student Member';
    final clubTitle = item['clubTitle'] ?? 'Student Chapter';
    final role = item['role'] ?? 'Club Member';
    final requestStatus = item['requestStatus'] ?? 'pending';
    final timeAgo = item['timeAgo'] ?? item['timeText'] ?? 'Just now';
    final isUnread = !(item['is_read'] ?? false);

    return InkWell(
      onTap: () => _openReviewScreen(item),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread ? const Color(0xFFBAE6FD) : const Color(0xFFE5E7EB),
            width: isUnread ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Club / Chapter Pill Badge + Timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.groups_rounded, size: 14, color: Color(0xFF0284C7)),
                      const SizedBox(width: 5),
                      Text(
                        clubTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Text(
                    timeAgo,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                  if (isUnread) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0284C7),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Applicant Row (Avatar + Name + Headline)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    isOwnProfile: false,
                    userData: {
                      'id': sender['id'] ?? 'applicant',
                      'name': senderName,
                      'username': senderHandle,
                      'avatar': senderAvatar,
                      'headline': senderHeadline,
                    },
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE2E8F0),
                  ),
                  child: ClipOval(
                    child: senderAvatar.isNotEmpty
                        ? (senderAvatar.startsWith('http')
                            ? Image.network(
                                senderAvatar,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildInitialsAvatar(senderName),
                              )
                            : Image.asset(
                                senderAvatar,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildInitialsAvatar(senderName),
                              ))
                        : _buildInitialsAvatar(senderName),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              senderName,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '@$senderHandle',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        senderHeadline,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF475569),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Request Note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Text(
              'Requested to join as: $role',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF334155),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Pending status / Review prompt (Action happens on the review page)
          if (requestStatus == 'pending') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.pending_actions_rounded, size: 14, color: Color(0xFF2563EB)),
                      SizedBox(width: 4),
                      Text(
                        'Pending Review',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Review Request',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF0284C7)),
                  ],
                ),
              ],
            ),
          ] else if (requestStatus == 'approved') ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF059669)),
                  SizedBox(width: 6),
                  Text(
                    'Approved · Member Added',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (requestStatus == 'declined') ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.cancel_rounded, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 6),
                  Text(
                    'Request Declined',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE2E8F0),
                ),
                child: ClipOval(
                  child: avatarUrl.isNotEmpty
                      ? (avatarUrl.startsWith('http')
                          ? Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildInitialsAvatar(username),
                            )
                          : Image.asset(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildInitialsAvatar(username),
                            ))
                      : _buildInitialsAvatar(username),
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

  Widget _buildInitialsAvatar(String name) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'U';
    return Container(
      color: const Color(0xFF0284C7),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
