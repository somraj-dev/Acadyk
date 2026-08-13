import 'supabase_service.dart';

class NotificationService {
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      if (!SupabaseService.hasValidCredentials) return [];
      final currentUserId = SupabaseService.client.auth.currentUser?.id;
      if (currentUserId == null) return [];

      final response = await SupabaseService.client
          .from('notifications')
          .select('*, sender:profiles!notifications_sender_id_fkey(*)')
          .eq('recipient_id', currentUserId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    try {
      if (!SupabaseService.hasValidCredentials) return;
      await SupabaseService.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  static Future<void> markAllAsRead() async {
    try {
      if (!SupabaseService.hasValidCredentials) return;
      final currentUserId = SupabaseService.client.auth.currentUser?.id;
      if (currentUserId == null) return;

      await SupabaseService.client
          .from('notifications')
          .update({'is_read': true})
          .eq('recipient_id', currentUserId);
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }
}
