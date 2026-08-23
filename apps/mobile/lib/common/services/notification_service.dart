import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';

class NotificationService {
  static final ValueNotifier<List<Map<String, dynamic>>> notificationsNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  static List<Map<String, dynamic>> _cachedNotifications = [
    {
      'id': 'req_gdsc_1',
      'type': 'club_join_request',
      'category': 'Invites',
      'title': 'Club Joining Request',
      'clubId': 'club_gdsc_1',
      'clubTitle': 'GDSC MITS Chapter',
      'requestStatus': 'pending', // 'pending' | 'approved' | 'declined'
      'role': 'Technical Team Member',
      'is_read': false,
      'created_at': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
      'timeAgo': '15m ago',
      'timeText': '15 mins ago',
      'body': 'Requested to join GDSC MITS Chapter as a Technical Team Member.',
      'sender': {
        'id': 'user_kavya_1',
        'full_name': 'Kavya Singhania',
        'username': 'kavya_s',
        'profile_photo_url': 'assets/images/alina_avatar.jpg',
        'headline': '2nd Year B.Tech CSE · AIML Enthusiast',
      },
    },
    {
      'id': 'req_cse_2',
      'type': 'student_chapter_join_request',
      'category': 'Invites',
      'title': 'Student Chapter Join Request',
      'clubId': 'club_cse_2',
      'clubTitle': 'CSE Student Chapter',
      'requestStatus': 'pending',
      'role': 'Web & Cloud Lead',
      'is_read': false,
      'created_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      'timeAgo': '1h ago',
      'timeText': '1 hour ago',
      'body': 'Requested to join CSE Student Chapter as a Web & Cloud Lead.',
      'sender': {
        'id': 'user_aman_2',
        'full_name': 'Aman Verma',
        'username': 'aman_v',
        'profile_photo_url': 'assets/images/young_entrepreneur.jpg',
        'headline': '3rd Year IT · Competitive Programmer & Mentor',
      },
    },
    {
      'id': 'req_ecell_3',
      'type': 'club_join_request',
      'category': 'Invites',
      'title': 'Club Joining Request',
      'clubId': 'club_ecell_3',
      'clubTitle': 'E-Cell MITS',
      'requestStatus': 'approved',
      'role': 'Startup Associate',
      'is_read': true,
      'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'timeAgo': '1d ago',
      'timeText': 'Yesterday',
      'body': 'Requested to join E-Cell MITS as a Startup & Sponsorship Associate.',
      'sender': {
        'id': 'user_rohan_3',
        'full_name': 'Rohan Sharma',
        'username': 'rohan_s',
        'profile_photo_url': 'assets/images/somraj_avatar.jpg',
        'headline': 'Final Year CSE · E-Cell Member',
      },
    },
    {
      'id': 'notif_mention_1',
      'type': 'mention',
      'category': 'Mentions',
      'title': 'mentioned you in a post',
      'is_read': false,
      'created_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      'timeAgo': '3h ago',
      'timeText': '3 hours ago',
      'body': 'Great presentation on Flutter cross-platform architecture at the tech symposium!',
      'sender': {
        'id': 'user_alina_4',
        'full_name': 'Alina Sprongole',
        'username': 'alina_s',
        'profile_photo_url': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=120',
        'headline': 'Software Engineer @ Google',
      },
    },
    {
      'id': 'notif_follow_1',
      'type': 'follow',
      'category': 'Followers',
      'title': 'started following you',
      'is_read': true,
      'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'timeAgo': '2d ago',
      'timeText': '2 days ago',
      'body': '',
      'sender': {
        'id': 'user_rahul_5',
        'full_name': 'Rahul Verma',
        'username': 'rahul_devops',
        'profile_photo_url': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=120',
        'headline': 'DevOps & Cloud Architect',
      },
    },
  ];

  static List<Map<String, dynamic>> getInitialCachedNotifications() {
    return List<Map<String, dynamic>>.from(_cachedNotifications);
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await ApiClient.get('/notifications');
      if (response.statusCode == 200) {
        final resData = response.data;
        List<Map<String, dynamic>> serverList = [];
        if (resData is Map && resData.containsKey('data')) {
          final payload = resData['data'];
          if (payload is Map && payload.containsKey('content') && payload['content'] is List) {
            serverList = List<Map<String, dynamic>>.from(payload['content']);
          } else if (payload is List) {
            serverList = List<Map<String, dynamic>>.from(payload);
          }
        } else if (resData is List) {
          serverList = List<Map<String, dynamic>>.from(resData);
        }

        if (serverList.isNotEmpty) {
          // Merge server notifications with existing cached club join requests
          final existingIds = serverList.map((e) => e['id']?.toString()).toSet();
          for (final c in _cachedNotifications) {
            if (!existingIds.contains(c['id']?.toString())) {
              serverList.add(c);
            }
          }
          _cachedNotifications = serverList;
          notificationsNotifier.value = List.from(_cachedNotifications);
          return List.from(_cachedNotifications);
        }
      }
    } catch (e) {
      debugPrint('[NotificationService] Error getting notifications from backend: $e');
    }

    notificationsNotifier.value = List.from(_cachedNotifications);
    return List.from(_cachedNotifications);
  }

  /// Create a new Club or Student Chapter Join Request notification for the President
  static Future<void> addClubJoinRequest({
    required String clubId,
    required String clubTitle,
    required String userName,
    required String userHandle,
    required String userAvatar,
    String? userHeadline,
    String? role,
  }) async {
    final newId = 'req_${DateTime.now().millisecondsSinceEpoch}';
    final requestItem = {
      'id': newId,
      'type': 'club_join_request',
      'category': 'Invites',
      'title': 'Club Joining Request',
      'clubId': clubId,
      'clubTitle': clubTitle,
      'requestStatus': 'pending',
      'role': role ?? 'Club Member',
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
      'timeAgo': 'Just now',
      'timeText': 'Just now',
      'body': 'Requested to join $clubTitle as a ${role ?? 'Member'}.',
      'sender': {
        'id': 'user_$newId',
        'full_name': userName,
        'username': userHandle,
        'profile_photo_url': userAvatar,
        'headline': userHeadline ?? 'Acadyk Student',
      },
    };

    _cachedNotifications.insert(0, requestItem);
    notificationsNotifier.value = List.from(_cachedNotifications);

    try {
      await ApiClient.post('/clubs/$clubId/join-requests', data: {
        'clubId': clubId,
        'clubTitle': clubTitle,
        'applicantName': userName,
        'applicantHandle': userHandle,
        'applicantAvatar': userAvatar,
        'applicantHeadline': userHeadline,
      });
    } catch (_) {}
  }

  /// President approves a club or student chapter join request
  static Future<bool> approveClubJoinRequest(String notificationId) async {
    final idx = _cachedNotifications.indexWhere((n) => n['id'] == notificationId);
    if (idx != -1) {
      final updated = Map<String, dynamic>.from(_cachedNotifications[idx]);
      updated['requestStatus'] = 'approved';
      updated['is_read'] = true;
      _cachedNotifications[idx] = updated;
      notificationsNotifier.value = List.from(_cachedNotifications);
    }

    try {
      await ApiClient.post('/notifications/$notificationId/approve');
    } catch (_) {}

    return true;
  }

  /// President declines a club or student chapter join request
  static Future<bool> declineClubJoinRequest(String notificationId) async {
    final idx = _cachedNotifications.indexWhere((n) => n['id'] == notificationId);
    if (idx != -1) {
      final updated = Map<String, dynamic>.from(_cachedNotifications[idx]);
      updated['requestStatus'] = 'declined';
      updated['is_read'] = true;
      _cachedNotifications[idx] = updated;
      notificationsNotifier.value = List.from(_cachedNotifications);
    }

    try {
      await ApiClient.post('/notifications/$notificationId/decline');
    } catch (_) {}

    return true;
  }

  static Future<void> markAsRead(String notificationId) async {
    final idx = _cachedNotifications.indexWhere((n) => n['id'] == notificationId);
    if (idx != -1) {
      final updated = Map<String, dynamic>.from(_cachedNotifications[idx]);
      updated['is_read'] = true;
      _cachedNotifications[idx] = updated;
      notificationsNotifier.value = List.from(_cachedNotifications);
    }
    try {
      await ApiClient.post('/notifications/$notificationId/read');
    } catch (e) {
      debugPrint('[NotificationService] Error marking notification as read: $e');
    }
  }

  static Future<void> markAllAsRead() async {
    _cachedNotifications = _cachedNotifications.map((n) {
      final updated = Map<String, dynamic>.from(n);
      updated['is_read'] = true;
      return updated;
    }).toList();
    notificationsNotifier.value = List.from(_cachedNotifications);

    try {
      await ApiClient.post('/notifications/read-all');
    } catch (e) {
      debugPrint('[NotificationService] Error marking all notifications as read: $e');
    }
  }

  static Future<int> getUnreadCount() async {
    final unreadLocal = _cachedNotifications.where((n) => n['is_read'] != true).length;
    try {
      final response = await ApiClient.get('/notifications/unread-count');
      if (response.statusCode == 200 && response.data is Map) {
        final resData = response.data;
        if (resData.containsKey('data') && resData['data'] is Map) {
          final serverCount = (resData['data']['unreadCount'] as num?)?.toInt();
          if (serverCount != null && serverCount > 0) return serverCount;
        }
      }
    } catch (_) {}
    return unreadLocal;
  }

  static Future<void> registerFcmToken(String fcmToken) async {
    try {
      await ApiClient.post('/notifications/fcm-token', data: {'fcmToken': fcmToken});
    } catch (e) {
      debugPrint('[NotificationService] Error registering FCM token: $e');
    }
  }

  static Future<Map<String, dynamic>?> getPreferences() async {
    try {
      final response = await ApiClient.get('/notifications/preferences');
      if (response.statusCode == 200 && response.data is Map) {
        final resData = response.data;
        if (resData.containsKey('data')) {
          return resData['data'] as Map<String, dynamic>?;
        }
        return resData as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint('[NotificationService] Error getting preferences: $e');
    }
    return null;
  }

  static Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    try {
      await ApiClient.put('/notifications/preferences', data: preferences);
    } catch (e) {
      debugPrint('[NotificationService] Error updating preferences: $e');
    }
  }
}
