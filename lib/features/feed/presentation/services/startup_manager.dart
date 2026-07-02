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
    },
    {
      'id': '5',
      'avatarUrl': 'assets/images/dharmik_avatar.jpg',
      'username': '@dharmik_patel',
      'actionText': 'invited you to collaborate on a new post',
      'timeText': 'Thursday 1:30pm',
      'timeAgo': '5 hours ago',
      'isUnread': true,
      'type': 'collab',
      'status': 'pending',
    },
    {
      'id': '6',
      'avatarUrl': 'assets/images/somraj_avatar.jpg',
      'username': '@anurag_gurjar',
      'actionText': 'reposted your post',
      'timeText': 'Thursday 12:15pm',
      'timeAgo': '6 hours ago',
      'isUnread': true,
      'type': 'repost',
    },
    {
      'id': '7',
      'avatarUrl': 'assets/images/alina_avatar.jpg',
      'username': '@eleanor_mac',
      'actionText': 'liked your comment: "This is super helpful!"',
      'timeText': 'Wednesday 5:40pm',
      'timeAgo': '1 day ago',
      'isUnread': false,
      'type': 'like',
    },
    {
      'id': '8',
      'avatarUrl': 'assets/images/somraj_avatar.jpg',
      'username': '@tannya_spades',
      'actionText': 'followed you',
      'timeText': 'Wednesday 3:10pm',
      'timeAgo': '1 day ago',
      'isUnread': false,
      'type': 'follow',
    },
    {
      'id': '9',
      'avatarUrl': 'assets/images/arogya_dashboard.jpg',
      'username': 'Acadyk Team',
      'actionText': 'Congratulations! Your team rank jumped to #3 this week',
      'timeText': 'Wednesday 10:00am',
      'timeAgo': '1 day ago',
      'isUnread': true,
      'type': 'rank',
    },
    {
      'id': '10',
      'avatarUrl': 'assets/images/time_handshake.jpg',
      'username': 'Google Careers',
      'actionText': 'posted a new opportunity matching your domain: UI/UX Designer',
      'timeText': 'Tuesday 4:50pm',
      'timeAgo': '2 days ago',
      'isUnread': false,
      'type': 'opportunity',
    },
    {
      'id': '11',
      'avatarUrl': 'assets/images/somraj_avatar.jpg',
      'username': '@abhay_gupta',
      'actionText': 'commented on your repost',
      'timeText': 'Tuesday 2:10pm',
      'timeAgo': '2 days ago',
      'isUnread': false,
      'type': 'comment',
      'content': 'Great insights on how YC startups scale!',
    },
    {
      'id': '12',
      'avatarUrl': 'assets/images/somraj_avatar.jpg',
      'username': '@vishal_dev',
      'actionText': 'liked your repost',
      'timeText': 'Monday 6:30pm',
      'timeAgo': '3 days ago',
      'isUnread': false,
      'type': 'like',
    },
    {
      'id': '13',
      'avatarUrl': 'assets/images/somraj_avatar.jpg',
      'username': '@gaurav_rajawat',
      'actionText': 'followed you',
      'timeText': 'Monday 11:20am',
      'timeAgo': '3 days ago',
      'isUnread': false,
      'type': 'follow',
    },
    {
      'id': '14',
      'avatarUrl': 'assets/images/somraj_avatar.jpg',
      'username': '@tanishk_pal',
      'actionText': 'accepted your collaboration invitation',
      'timeText': 'Sunday 3:40pm',
      'timeAgo': '4 days ago',
      'isUnread': false,
      'type': 'collab',
    },
    {
      'id': '15',
      'avatarUrl': 'assets/images/young_entrepreneur.jpg',
      'username': 'Acadyk Ventures',
      'actionText': 'posted a funding opportunity: NextGen Startup Grant',
      'timeText': 'Saturday 9:15am',
      'timeAgo': '5 days ago',
      'isUnread': false,
      'type': 'opportunity',
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
