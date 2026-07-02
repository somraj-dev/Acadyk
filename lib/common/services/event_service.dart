import 'supabase_service.dart';

class EventService {
  /// Fetch all events
  static Future<List<Map<String, dynamic>>> getEvents() async {
    try {
      final response = await SupabaseService.client
          .from('events')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  /// Register for an event
  static Future<bool> registerForEvent(String eventId, Map<String, dynamic> registrationDetails) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return false;

      await SupabaseService.client.from('event_registrations').insert({
        'event_id': eventId,
        'user_id': userId,
        'registration_details': registrationDetails,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error registering for event: $e');
      return false;
    }
  }

  /// Check if user is registered for an event
  static Future<bool> hasRegistered(String eventId) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return false;

      final res = await SupabaseService.client
          .from('event_registrations')
          .select()
          .eq('user_id', userId)
          .eq('event_id', eventId)
          .maybeSingle();
      return res != null;
    } catch (e) {
      return false;
    }
  }
}
