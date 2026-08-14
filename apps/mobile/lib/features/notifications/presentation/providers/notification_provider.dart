import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/state/async_state.dart';

class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final String createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.type = 'general',
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      body: json['body']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString() ?? 'Just now',
    );
  }
}

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}

class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final response = await ApiClient.get('/notifications');
    if (response.data is List) {
      return (response.data as List).map((e) => NotificationEntity.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<void> markAsRead(String id) async {
    await ApiClient.put('/notifications/$id/read');
  }

  @override
  Future<void> markAllAsRead() async {
    await ApiClient.put('/notifications/read-all');
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) => NotificationRepositoryImpl());

final notificationsStateProvider = StateNotifierProvider<NotificationsNotifier, AsyncState<List<NotificationEntity>>>((ref) {
  return NotificationsNotifier(repository: ref.watch(notificationRepositoryProvider));
});

class NotificationsNotifier extends StateNotifier<AsyncState<List<NotificationEntity>>> {
  final NotificationRepository repository;

  NotificationsNotifier({required this.repository}) : super(const AsyncState()) {
    fetchNotifications();
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) state = state.copyWith(isRefreshing: true);
    else state = state.copyWith(status: Status.loading);

    try {
      final list = await repository.getNotifications();
      state = AsyncState(
        status: list.isEmpty ? Status.empty : Status.success,
        data: list,
        isRefreshing: false,
      );
    } catch (e) {
      state = AsyncState(status: Status.error, errorMessage: e.toString(), data: []);
    }
  }

  Future<void> markAllAsRead() async {
    await repository.markAllAsRead();
    final current = state.data;
    if (current != null) {
      final updated = current.map((n) => NotificationEntity(
        id: n.id,
        title: n.title,
        body: n.body,
        type: n.type,
        isRead: true,
        createdAt: n.createdAt,
      )).toList();
      state = state.copyWith(data: updated);
    }
  }
}
