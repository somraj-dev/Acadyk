import 'supabase_service.dart';

class PostService {
  static Future<List<Map<String, dynamic>>> getFeedPosts({int limit = 20, int offset = 0}) async {
    try {
      if (!SupabaseService.hasValidCredentials) return [];
      final response = await SupabaseService.client
          .from('posts')
          .select('*, profiles(*)')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting feed posts: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createPost(String content, {String? postType, String? imageUrl}) async {
    try {
      if (!SupabaseService.hasValidCredentials) return null;
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return null;

      final postResponse = await SupabaseService.client.from('posts').insert({
        'user_id': userId,
        'content': content,
        'post_type': postType ?? 'text',
      }).select('*, profiles(*)').single();

      if (imageUrl != null && imageUrl.isNotEmpty) {
        await SupabaseService.client.from('post_images').insert({
          'post_id': postResponse['id'],
          'image_url': imageUrl,
        });
        postResponse['image_url'] = imageUrl;
      }

      return postResponse;
    } catch (e) {
      print('Error creating post: $e');
      return null;
    }
  }

  static Future<void> deletePost(String postId) async {
    try {
      if (!SupabaseService.hasValidCredentials) return;
      await SupabaseService.client.from('posts').delete().eq('id', postId);
    } catch (e) {
      print('Error deleting post: $e');
      rethrow;
    }
  }

  static Future<bool> toggleLike(String postId, bool currentLikeState) async {
    try {
      if (!SupabaseService.hasValidCredentials) return currentLikeState;
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return currentLikeState;

      if (currentLikeState) {
        await SupabaseService.client
            .from('likes')
            .delete()
            .match({'user_id': userId, 'post_id': postId});
        return false;
      } else {
        await SupabaseService.client
            .from('likes')
            .insert({'user_id': userId, 'post_id': postId});
        return true;
      }
    } catch (e) {
      print('Error toggling like: $e');
      return currentLikeState;
    }
  }

  static Future<List<Map<String, dynamic>>> getComments(String postId) async {
    try {
      if (!SupabaseService.hasValidCredentials) return [];
      final response = await SupabaseService.client
          .from('comments')
          .select('*, profiles(*)')
          .eq('post_id', postId)
          .order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting comments: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> addComment(String postId, String content) async {
    try {
      if (!SupabaseService.hasValidCredentials) return null;
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return null;

      return await SupabaseService.client.from('comments').insert({
        'post_id': postId,
        'user_id': userId,
        'content': content,
      }).select('*, profiles(*)').single();
    } catch (e) {
      print('Error adding comment: $e');
      return null;
    }
  }

  static Future<bool> toggleBookmark(String postId, bool currentBookmarkState) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return currentBookmarkState;
      if (currentBookmarkState) {
        await SupabaseService.client
            .from('bookmarks')
            .delete()
            .match({'user_id': userId, 'post_id': postId});
        return false;
      } else {
        await SupabaseService.client
            .from('bookmarks')
            .insert({'user_id': userId, 'post_id': postId});
        return true;
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
      return currentBookmarkState;
    }
  }

  static Future<bool> isBookmarked(String postId) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return false;
      final res = await SupabaseService.client
          .from('bookmarks')
          .select()
          .eq('user_id', userId)
          .eq('post_id', postId)
          .maybeSingle();
      return res != null;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isLiked(String postId) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return false;
      final res = await SupabaseService.client
          .from('likes')
          .select()
          .eq('user_id', userId)
          .eq('post_id', postId)
          .maybeSingle();
      return res != null;
    } catch (e) {
      return false;
    }
  }
}
