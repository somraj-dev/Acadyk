import 'package:flutter/material.dart';

class StartupManager {
  static final ValueNotifier<List<Map<String, dynamic>>> startups = ValueNotifier([
    {'title': 'Graphic Design', 'image': 'assets/images/arogya_dashboard.jpg'},
    {'title': 'Fine Arts', 'image': 'assets/images/backblaze_agreement.jpg'},
    {'title': 'Photography', 'image': 'assets/images/young_entrepreneur.jpg'},
    {'title': 'Interior Design', 'image': 'assets/images/time_handshake.jpg'},
    {'title': 'Icon Design', 'image': 'assets/images/valuation_sentence.jpg'},
    {'title': 'Street Art', 'image': 'assets/images/warp_team.jpg'},
    {'title': 'UI/UX', 'image': 'assets/images/alina_avatar.jpg'},
    {'title': 'Typography', 'image': 'assets/images/dharmik_avatar.jpg'},
  ]);

  static final ValueNotifier<List<Map<String, dynamic>>> notifications = ValueNotifier([
    {
      'id': '1',
      'avatarUrl': 'assets/images/somraj_avatar.jpg',
      'username': '@frankiesullivan',
      'actionText': 'followed you',
      'timeText': 'Thursday 4:20pm',
      'timeAgo': '2 hours ago',
      'isUnread': true,
      'type': 'follow',
    },
    {
      'id': '2',
      'avatarUrl': 'assets/images/alina_avatar.jpg',
      'username': '@eleanor_mac',
      'actionText': 'commented on your post',
      'timeText': 'Thursday 3:12pm',
      'timeAgo': '3 hours ago',
      'isUnread': true,
      'type': 'comment',
      'content': 'Love the background on this! Would love to learn how you created the mesh gradient effect.',
    },
    {
      'id': '3',
      'avatarUrl': 'assets/images/alina_avatar.jpg',
      'username': '@eleanor_mac',
      'actionText': 'liked your post',
      'timeText': 'Thursday 3:11pm',
      'timeAgo': '3 hours ago',
      'isUnread': true,
      'type': 'like',
    },
    {
      'id': '4',
      'avatarUrl': 'assets/images/dharmik_avatar.jpg',
      'username': '@ollie_diggs',
      'actionText': 'invited you to Sisyphus Dashboard',
      'timeText': 'Thursday 2:44pm',
      'timeAgo': '4 hours ago',
      'isUnread': false,
      'type': 'invite',
      'status': 'pending', // pending, accepted, declined
    }
  ]);

  static void addStartup(Map<String, dynamic> startup) {
    startups.value = List.from(startups.value)..add(startup);
  }

  static void addNotification(Map<String, dynamic> notification) {
    notifications.value = List.from(notifications.value)..insert(0, notification);
  }

  static void updateNotificationStatus(String id, String status) {
    notifications.value = notifications.value.map((n) {
      if (n['id'] == id) {
        return Map<String, dynamic>.from(n)..['status'] = status;
      }
      return n;
    }).toList();
  }
}
