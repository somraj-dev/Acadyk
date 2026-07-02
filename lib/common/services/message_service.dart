import 'supabase_service.dart';

class MessageService {
  /// Fetch all conversations for the current user
  static Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final currentUserId = SupabaseService.client.auth.currentUser?.id;
      if (currentUserId == null) return [];

      // Get conversation IDs where the user is a participant
      final participantRecords = await SupabaseService.client
          .from('conversation_participants')
          .select('conversation_id')
          .eq('user_id', currentUserId);

      if (participantRecords.isEmpty) return [];

      final conversationIds = participantRecords
          .map((r) => r['conversation_id'] as String)
          .toList();

      // Fetch conversation details along with other participants
      final response = await SupabaseService.client
          .from('conversations')
          .select('*, conversation_participants(*, profiles(*))')
          .inFilter('id', conversationIds)
          .order('last_message_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching conversations: $e');
      return [];
    }
  }

  /// Fetch messages for a specific conversation
  static Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    try {
      final response = await SupabaseService.client
          .from('messages')
          .select('*, profiles(*)')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  /// Send a message to a conversation
  static Future<Map<String, dynamic>?> sendMessage(String conversationId, String content) async {
    try {
      final senderId = SupabaseService.client.auth.currentUser?.id;
      if (senderId == null) return null;

      final response = await SupabaseService.client.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': senderId,
        'content': content,
        'message_type': 'text',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      // Update the conversation's last message info
      await SupabaseService.client.from('conversations').update({
        'last_message_text': content,
        'last_message_at': DateTime.now().toIso8601String(),
      }).eq('id', conversationId);

      return response;
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  /// Create or fetch an existing 1-to-1 conversation with another user
  static Future<String?> createConversation(String targetUserId) async {
    try {
      final currentUserId = SupabaseService.client.auth.currentUser?.id;
      if (currentUserId == null) return null;

      // 1. Find existing conversations for current user
      final myConversations = await SupabaseService.client
          .from('conversation_participants')
          .select('conversation_id')
          .eq('user_id', currentUserId);

      if (myConversations.isNotEmpty) {
        final conversationIds = myConversations.map((r) => r['conversation_id'] as String).toList();
        
        // 2. Check if target user is in any of these conversations (and conversation is not a group)
        final commonConversations = await SupabaseService.client
            .from('conversation_participants')
            .select('conversation_id, conversations!inner(is_group)')
            .inFilter('conversation_id', conversationIds)
            .eq('user_id', targetUserId)
            .eq('conversations.is_group', false);

        if (commonConversations.isNotEmpty) {
          return commonConversations.first['conversation_id'] as String;
        }
      }

      // 3. Create new conversation if none exists
      final newConversation = await SupabaseService.client
          .from('conversations')
          .insert({
            'is_group': false,
            'last_message_at': DateTime.now().toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final newConvId = newConversation['id'] as String;

      // 4. Add both participants
      await SupabaseService.client.from('conversation_participants').insert([
        {'conversation_id': newConvId, 'user_id': currentUserId},
        {'conversation_id': newConvId, 'user_id': targetUserId},
      ]);

      return newConvId;
    } catch (e) {
      print('Error creating conversation: $e');
      return null;
    }
  }
}
