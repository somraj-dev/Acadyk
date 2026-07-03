import 'supabase_service.dart';

class ProfileService {
  static Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      if (!SupabaseService.hasValidCredentials) return null;
      return await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  static Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      if (!SupabaseService.hasValidCredentials) return;
      await SupabaseService.client
          .from('profiles')
          .update(data)
          .eq('id', userId);
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  static Future<void> createProfile(Map<String, dynamic> data) async {
    try {
      if (!SupabaseService.hasValidCredentials) return;
      await SupabaseService.client.from('profiles').insert(data);
    } catch (e) {
      print('Error creating profile: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> searchProfiles(String query) async {
    try {
      if (!SupabaseService.hasValidCredentials) return [];
      final response = await SupabaseService.client
          .from('profiles')
          .select()
          .ilike('full_name', '%$query%')
          .limit(20);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error searching profiles: $e');
      return [];
    }
  }
}
