import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/websocket_service.dart';
import '../../../../core/state/async_state.dart';

class ConversationEntity {
  final String id;
  final String? title;
  final String? lastMessageText;
  final String? lastMessageAt;
  final bool isGroup;

  const ConversationEntity({
    required this.id,
    this.title,
    this.lastMessageText,
    this.lastMessageAt,
    this.isGroup = false,
  });

  factory ConversationEntity.fromJson(Map<String, dynamic> json) {
    return ConversationEntity(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Direct Chat',
      lastMessageText: json['lastMessageText'] ?? json['last_message_text'],
      lastMessageAt: json['lastMessageAt'] ?? json['last_message_at'],
      isGroup: json['isGroup'] ?? json['is_group'] ?? false,
    );
  }
}

class ChatMessageEntity {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String content;
  final String messageType;
  final String createdAt;
  final bool isRead;

  const ChatMessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.messageType = 'text',
    required this.createdAt,
    this.isRead = false,
  });

  factory ChatMessageEntity.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] is Map<String, dynamic> ? json['sender'] : null;
    return ChatMessageEntity(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? json['conversation_id']?.toString() ?? '',
      senderId: sender?['id'] ?? json['senderId'] ?? json['sender_id'] ?? '',
      senderName: sender?['fullName'] ?? sender?['full_name'] ?? json['sender_name'] ?? 'User',
      content: json['content']?.toString() ?? '',
      messageType: json['messageType'] ?? json['message_type'] ?? 'text',
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString() ?? 'Just now',
      isRead: json['isRead'] ?? json['is_read'] ?? false,
    );
  }
}

abstract class ChatRepository {
  Future<List<ConversationEntity>> getConversations();
  Future<List<ChatMessageEntity>> getMessages(String conversationId);
  Future<ChatMessageEntity> sendMessage(String conversationId, String content, {String? messageType});
}

class ChatRepositoryImpl implements ChatRepository {
  @override
  Future<List<ConversationEntity>> getConversations() async {
    final response = await ApiClient.get('/chat/conversations');
    if (response.data is List) {
      return (response.data as List).map((e) => ConversationEntity.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<List<ChatMessageEntity>> getMessages(String conversationId) async {
    final response = await ApiClient.get('/chat/conversations/$conversationId/messages');
    if (response.data is List) {
      return (response.data as List).map((e) => ChatMessageEntity.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<ChatMessageEntity> sendMessage(String conversationId, String content, {String? messageType}) async {
    final response = await ApiClient.post('/chat/conversations/$conversationId/messages', data: {
      'content': content,
      'messageType': messageType ?? 'text',
    });
    return ChatMessageEntity.fromJson(response.data as Map<String, dynamic>);
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) => ChatRepositoryImpl());

final conversationsStateProvider = FutureProvider<List<ConversationEntity>>((ref) {
  return ref.watch(chatRepositoryProvider).getConversations();
});

final messagesStateProvider = StateNotifierProvider.family<MessagesNotifier, AsyncState<List<ChatMessageEntity>>, String>((ref, conversationId) {
  return MessagesNotifier(
    conversationId: conversationId,
    chatRepository: ref.watch(chatRepositoryProvider),
  );
});

class MessagesNotifier extends StateNotifier<AsyncState<List<ChatMessageEntity>>> {
  final String conversationId;
  final ChatRepository chatRepository;

  MessagesNotifier({required this.conversationId, required this.chatRepository}) : super(const AsyncState()) {
    fetchMessages();
    subscribeToRealtime();
  }

  void subscribeToRealtime() {
    WebSocketService.subscribe('/topic/conversations/$conversationId');
    WebSocketService.messagesStream.listen((event) {
      if (event is Map<String, dynamic> && event['conversationId'] == conversationId) {
        final newMsg = ChatMessageEntity.fromJson(event);
        final current = state.data ?? [];
        if (!current.any((m) => m.id == newMsg.id)) {
          state = state.copyWith(data: [...current, newMsg]);
        }
      }
    });
  }

  Future<void> fetchMessages() async {
    state = state.copyWith(status: Status.loading);
    try {
      final messages = await chatRepository.getMessages(conversationId);
      state = AsyncState(
        status: messages.isEmpty ? Status.empty : Status.success,
        data: messages,
      );
    } catch (e) {
      state = AsyncState(status: Status.error, errorMessage: e.toString(), data: []);
    }
  }

  Future<bool> sendMessage(String content, {String? messageType}) async {
    try {
      final msg = await chatRepository.sendMessage(conversationId, content, messageType: messageType);
      final current = state.data ?? [];
      state = state.copyWith(data: [...current, msg]);
      return true;
    } catch (_) {
      return false;
    }
  }
}
