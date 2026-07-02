import 'supabase_service.dart';

class CommunityService {
  /// Fetch all communities
  static Future<List<Map<String, dynamic>>> getCommunities() async {
    try {
      final response = await SupabaseService.client
          .from('communities')
          .select()
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching communities: $e');
      return [];
    }
  }

  /// Join a community
  static Future<bool> joinCommunity(String communityId) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return false;

      await SupabaseService.client.from('community_members').insert({
        'community_id': communityId,
        'user_id': userId,
        'role': 'member',
        'joined_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error joining community: $e');
      return false;
    }
  }

  /// Leave a community
  static Future<bool> leaveCommunity(String communityId) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return false;

      await SupabaseService.client
          .from('community_members')
          .delete()
          .match({'community_id': communityId, 'user_id': userId});
      return true;
    } catch (e) {
      print('Error leaving community: $e');
      return false;
    }
  }
}
