import 'supabase_service.dart';

class FollowService {
  static Future<bool> isFollowing(String targetUserId) async {
    try {
      if (!SupabaseService.hasValidCredentials) return false;
      final currentUserId = SupabaseService.client.auth.currentUser?.id;
      if (currentUserId == null) return false;

      final response = await SupabaseService.client
          .from('followers')
          .select()
          .eq('follower_id', currentUserId)
          .eq('following_id', targetUserId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }

  static Future<bool> toggleFollow(String targetUserId, bool currentFollowState) async {
    try {
      if (!SupabaseService.hasValidCredentials) return currentFollowState;
      final currentUserId = SupabaseService.client.auth.currentUser?.id;
      if (currentUserId == null) return currentFollowState;

      if (currentFollowState) {
        await SupabaseService.client
            .from('followers')
            .delete()
            .match({'follower_id': currentUserId, 'following_id': targetUserId});
        return false;
      } else {
        await SupabaseService.client
            .from('followers')
            .insert({'follower_id': currentUserId, 'following_id': targetUserId});
        return true;
      }
    } catch (e) {
      print('Error toggling follow: $e');
      return currentFollowState;
    }
  }

  static Future<List<Map<String, dynamic>>> getFollowers(String userId) async {
    try {
      if (!SupabaseService.hasValidCredentials) return [];
      final response = await SupabaseService.client
          .from('followers')
          .select('profiles!followers_follower_id_fkey(*)')
          .eq('following_id', userId);
      return List<Map<String, dynamic>>.from(
        (response as List).map((row) => row['profiles'] ?? {}),
      );
    } catch (e) {
      print('Error getting followers: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getFollowing(String userId) async {
    try {
      if (!SupabaseService.hasValidCredentials) return [];
      final response = await SupabaseService.client
          .from('followers')
          .select('profiles!followers_following_id_fkey(*)')
          .eq('follower_id', userId);
      return List<Map<String, dynamic>>.from(
        (response as List).map((row) => row['profiles'] ?? {}),
      );
    } catch (e) {
      print('Error getting following: $e');
      return [];
    }
  }
}
