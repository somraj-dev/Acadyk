import 'supabase_service.dart';

class SearchService {
  /// Search user profiles
  static Future<List<Map<String, dynamic>>> searchProfiles(String query) async {
    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select()
          .ilike('full_name', '%$query%')
          .limit(10);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error searching profiles: $e');
      return [];
    }
  }

  /// Get search history
  static Future<List<String>> getSearchHistory() async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await SupabaseService.client
          .from('search_history')
          .select('query')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(10);
      return List<String>.from(response.map((r) => r['query'] as String));
    } catch (e) {
      print('Error getting search history: $e');
      return [];
    }
  }

  /// Save query to search history
  static Future<void> saveSearchQuery(String query) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null || query.trim().isEmpty) return;

      await SupabaseService.client.from('search_history').insert({
        'user_id': userId,
        'query': query.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving search query: $e');
    }
  }
}
